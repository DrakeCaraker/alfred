# CI Auto-Fix Pipeline Design

**Date:** 2026-03-27
**Status:** Approved
**Goal:** Fully automated, Claude-powered CI failure and merge conflict resolution for PRs.

## Context

Alfred has four separate workflows handling CI validation, deterministic fixes, Claude-powered fixes, and merge conflict resolution. This design consolidates them into two workflows: one for validation (`ci.yml`, unchanged) and one for all automated fixes (`ci-autofix.yml`). It also closes the local/CI parity gap so developers catch failures before pushing.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Fix engine | Claude Code Action for all fixes | Handles novel failures, not just scripted patterns. Trivial fix cost (~$0.05) is acceptable. |
| Retry limit | 3 attempts within 15-min timeout | Balances thoroughness with cost. Claude retries `make check` internally. |
| Conflict trigger | Push to main (not cron) | Conflicts only appear when main changes. Zero wasted runs. |
| Multi-PR conflicts | Matrix job (one Claude invocation per PR) | Isolates failures. One bad PR can't poison another. |
| Loop protection | Skip if last commit author is `alfred-bot` | Prevents infinite fix cycles. |
| Graceful degradation | PR comment when auto-fix unavailable or fails | Developer always knows what happened and how to fix locally. |

## Architecture

### Workflows

**`ci.yml`** — unchanged. Runs all validation on PRs and pushes to main.

**`ci-autofix.yml`** — replaces `auto-fix.yml`, `claude-fix.yml`, and `resolve-conflicts.yml`.

```
Triggers:
  - workflow_run: [Alfred CI] completed
  - push: branches [main]
  - workflow_dispatch: inputs [pr_number, task, custom_prompt]

Job 1: fix-ci-failures
  Condition: workflow_run + failure + PR event + last commit NOT by alfred-bot
  Steps:
    1. Get PR branch from workflow_run payload
    2. Check last commit author — skip if alfred-bot
    3. Check CLAUDE_ENABLED — if not, comment "unavailable" and exit
    4. Checkout PR branch
    5. Claude Code Action: read failure logs, fix code, run make check, push
       - Prompt includes: 3 retry attempts, sync commands rule, vocabulary rules
       - Timeout: 15 minutes
    6. On success: no comment needed (CI will re-run and pass)
    7. On failure: comment on PR with failure details + "run make fix && make check locally"

Job 2: resolve-conflicts
  Condition: push to main
  Steps:
    2a. Detect — list all open PRs, check mergeable status, output JSON array
    2b. Matrix — for each conflicting PR:
      1. Check CLAUDE_ENABLED — if not, comment "unavailable" and exit
      2. Checkout PR branch
      3. Claude Code Action: merge origin/main, resolve conflicts, run make check, push
         - Timeout: 15 minutes
      4. On success: comment on PR confirming resolution
      5. On failure: comment with manual resolution steps

Job 3: manual-fix
  Condition: workflow_dispatch only
  Steps:
    1. Accept inputs: pr_number, task (fix-ci | resolve-conflicts | custom), custom_prompt
    2. Checkout PR branch
    3. Claude Code Action with task-appropriate prompt
    4. Comment on PR with result
```

### Files Deleted

| File | Reason |
|------|--------|
| `.github/workflows/auto-fix.yml` | Replaced by ci-autofix.yml Job 1 |
| `.github/workflows/claude-fix.yml` | Replaced by ci-autofix.yml Job 3 |
| `.github/workflows/resolve-conflicts.yml` | Replaced by ci-autofix.yml Job 2 |

### Local CI Parity

**Problem:** `make check` only runs shellcheck + smoke test. CI also validates JSON, YAML, conflict markers, and command sync. Developers can't reproduce CI failures locally.

**Solution:** Create `scripts/validate.sh` with all validation logic, used by both Makefile and CI.

**`scripts/validate.sh`** performs:
1. Conflict marker scan (all tracked file types)
2. JSON validation (`settings.json`, `plugin.json`, `package.json`, `hooks.json`)
3. YAML validation (`_schema.yaml`, `_default.yaml`, `alfred.schema.yaml`, `signal_schema.yaml`, `role-categories.yaml`)
4. Command copy sync check (`.claude/commands/*.md` vs `commands/*.md`)
5. Shell syntax check (`bash -n` on all scripts)

**`Makefile` changes:**

```makefile
## validate: Run all CI-equivalent validation checks
validate:
	@bash scripts/validate.sh

## fix: Auto-fix deterministic issues (sync commands, permissions)
fix:
	@for f in .claude/commands/*.md; do \
		base=$$(basename "$$f"); \
		if [ -f "commands/$$base" ]; then \
			cp "$$f" "commands/$$base"; \
		fi; \
	done
	@chmod +x .claude/hooks/*.sh .githooks/pre-push .githooks/pre-commit scripts/*.sh 2>/dev/null || true
	@echo "Fixed: command sync + permissions"

## check: Run all validations (validate + lint + test)
check: validate lint test
	@echo "All checks passed."
```

**CI update:** `ci.yml` replaces its inline validation steps (conflict markers, JSON, YAML, command sync, shell syntax) with `bash scripts/validate.sh`. Shellcheck linting and the smoke test remain as separate CI steps, matching the Makefile structure (`check: validate lint test`).

### Loop Protection Flow

```
CI fails on PR
  → ci-autofix triggers
  → Check: last commit by alfred-bot?
    → YES: skip, comment "auto-fix already attempted, needs manual intervention"
    → NO: Check CLAUDE_ENABLED?
      → YES: Claude fixes + pushes → CI re-runs
      → NO: comment "auto-fix unavailable, run: make fix && make check"
```

### Claude Prompt Rules

Both fix jobs include these rules in the Claude prompt:
- After editing `.claude/commands/*.md`, sync to `commands/`
- Never put free-text user data in telemetry files
- Use "habits" not "patterns" in user-facing text
- Run `make check` to verify fixes before committing
- Max 3 fix-and-retry cycles within the timeout
- Commit with author `alfred-bot <alfred-bot@users.noreply.github.com>`

### Prerequisites

- `ANTHROPIC_API_KEY` secret in GitHub repo settings
- `CLAUDE_ENABLED` repo variable set to `true`
- Repository permissions: `contents: write`, `pull-requests: write`

## Scope Boundary

This design covers CI automation only. It does not cover:
- Auto-merge after CI passes (separate concern)
- PR review or approval automation
- Deployment pipelines
