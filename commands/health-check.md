# Project Health Check

Assess the current project's AI-assisted development maturity and recommend improvements.

## Step 1: Detect project characteristics

Scan for:
- **Language:** Python (pyproject.toml, setup.py, *.py), JS/TS (package.json), Go (go.mod), Rust (Cargo.toml), R (DESCRIPTION, *.R)
- **Has notebooks:** `*.ipynb` files exist
- **Has experiments:** results/, experiment configs, runner scripts
- **Has CI:** .github/workflows/, .gitlab-ci.yml, Jenkinsfile
- **Has tests:** tests/, test_*, *_test.*, spec/
- **Team or solo:** check git log for multiple authors
- **Formatter:** ruff, black, prettier, gofmt, rustfmt (from config files)
- **Type checker:** mypy, pyright, tsc (from config files)

## Step 2: Check each level

### Level 1: Safety
- [ ] Project instructions file exists (CLAUDE.md, .cursorrules, .github/copilot-instructions.md, or equivalent)
  - If exists: show line count and last modified date
  - Check: does it have a "Do NOT" or "Rules" section?
  - Check: does it reference files that no longer exist?
- [ ] Pre-push hook exists (.githooks/pre-push or .git/hooks/pre-push)
  - If exists: check if it blocks binary files and main pushes
- [ ] .gitignore exists and covers: binary artifacts for detected language, .env, __pycache__/cache dirs
- [ ] Onboarding command exists (make setup, npm run setup, or equivalent in Makefile/package.json)

### Level 2: Automation
- [ ] Auto-format configured
  - Claude Code: PostToolUse hook for Write|Edit in .claude/settings.json
  - Other: pre-commit hook runs formatter
  - Check: formatter is installed and config exists
- [ ] Session status hook (Claude Code: SessionStart in .claude/settings.json)
- [ ] Command runner exists (Makefile, package.json scripts, justfile, taskfile)
  - Check: has test, lint, format targets
- [ ] Safe commit workflow (.claude/commands/commit.md or equivalent)

### Level 3: Domain-Specific (only check if applicable)
- [ ] **If notebooks exist:** Canonical notebooks documented in instructions file
- [ ] **If notebooks exist:** Notebook size check hook (PreToolUse)
- [ ] **If experiments/config exist:** Configuration centralized in one file (not duplicated)
- [ ] **If results/ exists:** Result files have provenance metadata (_meta blocks or equivalent)
- [ ] Dependency lockfile exists (requirements.lock, package-lock.json, Cargo.lock, renv.lock, go.sum)
- [ ] **If tests take >30s:** Fast/slow test markers and make test-fast target
- [ ] **If long-running experiments:** Code/data branch separation documented

### Level 4: Resilience (only check if CI exists)
- [ ] CI workflow includes: lint, typecheck, test, coverage
- [ ] CI fix command exists (.claude/commands/ci-fix.md)
- [ ] Session-end CI gate (Stop hook in .claude/settings.json)
- [ ] Context preservation (PreCompact hook in .claude/settings.json)

### Level 5: Institutional
- [ ] Memory files exist (check ~/.claude/projects/*/memory/)
- [ ] Feedback memories present (grep for "type: feedback" in memory files)

## Step 3: Report

Format the report as:

```
Project Health Check — [project name from instructions file or directory name]
Language: [detected]  |  Type: [notebook-only / package / monorepo]  |  Contributors: [N]

Level 1 (Safety):       [Complete / Partial / Missing]
  [✓] or [✗] for each check, with one-line detail

Level 2 (Automation):   [Complete / Partial / Missing]
  [✓] or [✗] for each check

Level 3 (Domain):       [Complete / Partial / N/A]
  [✓] or [✗] or [—] (not applicable) for each check

Level 4 (Resilience):   [Complete / Partial / N/A]
  [✓] or [✗] or [—] for each check

Level 5 (Institutional): [Complete / Partial / Missing]
  [✓] or [✗] for each check
```

## Step 4: Recommend

Show the top 3 missing items, ranked by impact for THIS project:

```
Recommendations (highest impact first):

1. [Item] — [one sentence: why this matters for your specific project]
   Fix: [one sentence: what to do, or "run /bootstrap to set this up"]

2. [Item] — [reason]
   Fix: [action]

3. [Item] — [reason]
   Fix: [action]
```

Ranking heuristics:
- Missing Level 1 items always rank highest (safety first)
- Format hook ranks high if the project has CI (eliminates format failures)
- Dependency lockfile ranks high if team has >1 contributor
- Notebook protection ranks high if notebooks >2MB exist
- CI fix command ranks high if recent PRs had multiple fix commits
- PreCompact ranks high if the project has long sessions (check transcript count or memory files)

## Rules
- Skip checks that don't apply (no notebook checks if no notebooks, no CI checks if no CI)
- Never create files — only report and recommend. Use /bootstrap to create.
- Show [—] for non-applicable checks, not [✗]
- If instructions file references files that don't exist, flag as "stale reference"
- Be specific in recommendations — "Add ruff format hook" not "Add formatting"
