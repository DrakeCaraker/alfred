# I'm testing Alfred

Project type: academic research, statistical analysis, paper writing.
Typical stack: Python/R, LaTeX, Jupyter/RMarkdown, statistical packages (scipy, statsmodels, lme4).
Lifecycle: literature review → hypothesis → data collection → analysis → writing → submission → revision.
Key concern: rigor, reproducibility, citation accuracy, IRB compliance.

## Non-Negotiable Rules

1. **Never push directly to main.** Always create a feature branch and open a PR.
2. **Keep commits atomic.** One concern per commit, one concern per branch.
3. **Read before planning.** Verify by reading actual code before proposing any changes.
4. **Capture corrections immediately.** When redirected ("no", "don't", "stop", "instead"), save a feedback memory before continuing with the corrected approach.
5. **Vet before committing to plans.** Before calling ExitPlanMode or claiming a plan is complete, run the /vet checklist: verify assumptions against actual code, identify missing failure modes, and flag remaining uncertainties. Do not present unvetted plans as ready.
6. **Sync command and hook copies.** After editing `.claude/commands/*.md` or `.claude/hooks/*.sh`, always copy to `commands/` and `hooks/` respectively — both directories must match. CI will reject mismatches. Run `make fix` to sync automatically.
7. **Check all output touchpoints after terminology changes.** When renaming user-facing terms, grep `.sh` files, command `.md` templates, and generated file templates. Shell hooks are the highest-frequency touchpoint and easiest to miss.
8. **Ask security requirements before building data transport.** Before building any feature that stores, moves, or exposes data externally, ask: "Who should have access? Does this need encryption?" Skipping this wastes work when requirements surface later.

## Guardrails

- Never modify raw data files — always work on processed copies in a separate directory
- Always report statistical significance tests with effect sizes and confidence intervals
- Document the complete analysis pipeline from raw data to final figure
- Use relative paths only — never hardcode absolute paths (breaks reproducibility)
- Version paper drafts explicitly (v1, v2, v3) — never overwrite previous versions
- Never commit participant-identifiable data (PII, PHI) to git
- Free-text user data (role descriptions, persona gaps) stays local only (gitignored). Only fixed-taxonomy enums from `collective/role-categories.yaml` may flow to shared telemetry. Never put raw descriptions in telemetry, collective signals, or encrypted staging.
- Spike-test hook mechanisms before building on them — create a one-line test hook, trigger the event, verify it fires before writing the real implementation

## Directory Map

```
.
├── CLAUDE.md
├── README.md
├── Makefile               (check, audit, fix, publish targets)
├── .claude/commands/      (slash command definitions)
├── .claude/hooks/         (session-start, format-on-write, telemetry, etc.)
├── .claude-plugin/        (plugin.json manifest)
├── collective/            (aggregator, anonymizer, signal schema, keys)
├── commands/              (mirror of .claude/commands/ — CI enforces sync)
├── docs/                  (user guides, internal strategy docs)
├── hooks/                 (mirror of .claude/hooks/)
├── personas/              (7 persona templates: ml-ds, research, writer, etc.)
├── scripts/               (audit, PII scanner, smoke test, collective-sync)
├── skills/                (smart-suggestions, persona-evolve, etc.)
└── .pilot/                (telemetry data, privacy docs)
```

## Running

```bash
make check    # Full validation: validate + lint + test (128 checks)
make audit    # Deep security lint: injection, secrets, traps, sync
make fix      # Auto-fix: sync commands + hooks + permissions
```

## Tools

- **Python formatter**: ruff or black
- **R formatter**: styler
- **Document tools**: LaTeX + BibTeX, pandoc
- **Test runner**: pytest (Python) or testthat (R)

## Slash Commands

> When Alfred is installed as a Claude Code plugin, commands are namespaced as `/alfred:<command>` (e.g., `/alfred:bootstrap`, `/alfred:teach`).

| Command | Purpose |
|---------|---------|
| /bootstrap | Persona-aware project setup (you just ran this) |
| /github-account-setup | Connect to GitHub or create an account |
| /teach | Learn the next development habit |
| /status | See your progress and graduated habits |
| /commit | Safe commit with file guards |
| /new-work | Start scoped work on a new branch |
| /ci-fix | Auto-fix CI failures in a loop |
| /self-improve | Promote feedback to rules or hooks |
| /health-check | Assess project maturity |
| /safe-refactor | Test-gated refactoring with rollback |
| /pr | Branch → commit → push → PR workflow |
| /vet | Pressure-test a plan before committing to it |
| /audit | Security and quality audit with guided fixes |
| /persona | Check or evolve your persona fit |
| /collective | Preview or contribute anonymized learning signals |
| /experiment-summary | Trace results back to source code |
| /pilot-consent | Manage data collection consent |
| /pilot-report | Submit anonymous feedback |
| /pilot-delete | Delete your telemetry data |

## Hooks

- **Format on write**: auto-formats files after every edit (detects ruff, prettier, gofmt, etc.)
- **Session start**: shows git status, branch safety, onboarding progress, and session resume
- **Session bookmark**: notifies user that session progress is being saved
- **Feedback capture**: notifies user that improvements are being checked
- **Pilot telemetry**: records session data and aggregates collective signals on session end
- **Pre-compact**: notifies user that context is being preserved

## Re-consent Handling

On your FIRST response in any session, check `.claude/.pilot-consent.json`. If it exists and `schema_version` is not `"3.0"`, the user needs to re-consent to expanded data collection. Ask them immediately, before answering their question:

> "Quick note: Alfred's data collection has expanded to include habit graduation patterns, anonymized rules, and automation signals (all encrypted). Your previous consent covered an earlier version. Do you consent to the expanded collection? (yes/no)"

Then process their response:
- **yes/y/ok/sure/fine**: Write `{"consented": true, "consent_date": "<today>", "schema_version": "3.0"}`. Say: "Consent updated." Then answer their original question.
- **no/n/nope/decline**: Write `{"consented": false, "declined_date": "<today>", "schema_version": "3.0"}`. Say: "No problem. No data collected." Then answer their original question.
- **User ignores it**: Remind once. If ignored again, write `{"consented": false, "schema_version": "3.0"}` and proceed.

Never ask more than twice. Never block the session on consent. If no `.pilot-consent.json` exists, don't ask — consent is handled by `/alfred:bootstrap`.

## Session End Behavior

When a session ends (Stop hooks fire), do these silently — the hooks show user-friendly messages, your job is the actual work:

1. **Save bookmark**: Write `.claude/.session-bookmark.json` with: task description, progress summary, branch name, files modified, and next steps. Read the existing bookmark first. Format as JSON with keys: `timestamp`, `task`, `progress`, `branch`, `files_modified`, `next_steps`.

2. **Capture feedback**: Check if any user corrections from this session need to be saved as feedback memories (Rule #4). Only capture genuine approach corrections, not routine requests. Check existing memories first to avoid duplicates.

## Pre-Compact Behavior

When context compression starts (PreCompact hook fires):

1. **Update bookmark**: Write `.claude/.session-bookmark.json` with current task state (same format as session-end). Add `"checkpoint": "pre-compact"` to distinguish from session-end bookmarks.

2. **Safety-net feedback scan**: Check if any user corrections from this session haven't been saved as feedback memories yet (Rule #4 safety net).

3. **Save uncommitted decisions**: If you made design decisions during this session that aren't captured in code, commits, or memories, write them to memory now — the reasoning will not survive compression.

Do this quickly and silently. Do not suggest commands or ask questions.

## Explain Gate

When you encounter a slash command for a habit you haven't graduated yet, briefly explain what it does and why before executing. Check `.claude/.onboarding-state.json` for graduation status. Once graduated, execute silently.

## Smart Suggestions

Every Alfred command should surface at the right moment. Full trigger list is in `skills/smart-suggestions/SKILL.md`. Key suggestions:

| Trigger | Suggest | Why |
|---------|---------|-----|
| Working on main | `/new-work` | Prevent direct-to-main changes |
| Significant work without commit | `/commit` | Create a rollback checkpoint |
| Work seems complete | `/pr` | Validate, push, and open PR in one step |
| CI failing | `/ci-fix` | Automates the fix-and-retest loop |
| About to exit plan mode | `/vet` | Check assumptions before building (Rule #5) |
| Before creating a PR | `/audit` | 5-second security sweep |
| 5+ feedback memories | `/self-improve` | Promote corrections to permanent rules |
| 10+ commits on branch | Split into PRs | Smaller PRs are easier to review |
| Building data transport | Ask security reqs | "Who has access? Need encryption?" |
| Refactoring without tests | `/safe-refactor` | Test-gated changes with rollback |
| All habits graduated | `/health-check` | What to improve next |
| New files in results/ | `/experiment-summary` | Trace results to source code |
| Sessions 1-3, no habits | `/teach` | First development habit lesson |
| Session 3+, persona unchecked | `/persona` | Verify Alfred uses the right language |
| After /self-improve signals | `/collective` | Share anonymized corrections |

**Rules:** One suggestion per response. Never repeat a dismissed suggestion. Never auto-run destructive commands. If user says "stop suggesting" — respect it for the session.

## Do NOT

- Modify raw data files — always work on processed copies
- Hardcode absolute paths — use relative paths only
- Overwrite previous paper draft versions — version explicitly (v1, v2, v3)
- Commit participant-identifiable data (PII, PHI) to git
- Skip reporting effect sizes and confidence intervals alongside significance tests
