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

## Guardrails

- Never modify raw data files — always work on processed copies in a separate directory
- Always report statistical significance tests with effect sizes and confidence intervals
- Document the complete analysis pipeline from raw data to final figure
- Use relative paths only — never hardcode absolute paths (breaks reproducibility)
- Version paper drafts explicitly (v1, v2, v3) — never overwrite previous versions
- Never commit participant-identifiable data (PII, PHI) to git
- Free-text user data (role descriptions, persona gaps) stays local only (gitignored). Only fixed-taxonomy enums from `collective/role-categories.yaml` may flow to shared telemetry. Never put raw descriptions in telemetry, collective signals, or encrypted staging.

## Directory Map

```
.
├── CLAUDE.md
├── README.md
├── docs/
├── scripts/
├── data/raw/          (original, unmodified data — read-only)
├── data/processed/    (cleaned, transformed data)
├── analysis/          (numbered scripts: 01_clean.py, 02_analyze.py, ...)
├── paper/             (manuscript source — LaTeX or Markdown)
├── figures/           (publication-quality figures with provenance)
└── results/           (analysis outputs, tables, statistics)
```

## Running

```bash
make check    # Full validation: validate + lint + test (123 checks)
make audit    # Deep security lint: injection, secrets, traps, sync
make fix      # Auto-fix: sync commands + hooks + permissions
```

## Tools

- **Python formatter**: ruff or black
- **R formatter**: styler
- **Document tools**: LaTeX + BibTeX, pandoc
- **Test runner**: pytest (Python) or testthat (R)

## Slash Commands

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

## Hooks

- **Format on write**: auto-formats files after every edit (detects ruff, prettier, gofmt, etc.)
- **Session start**: shows git status, branch safety, onboarding progress, and session resume
- **Session bookmark**: saves task context on session end for resume next time
- **Feedback capture**: reminds to save corrections as memories before session ends
- **Pre-compact**: saves critical context before conversation compression

## Explain Gate

When you encounter a slash command for a habit you haven't graduated yet, briefly explain what it does and why before executing. Check `.claude/.onboarding-state.json` for graduation status. Once graduated, execute silently.

## Smart Suggestions

Every Alfred command should surface at the right moment. Full trigger list is in `skills/smart-suggestions/SKILL.md`. Key suggestions:

| Trigger | Suggest | Why |
|---------|---------|-----|
| Working on main | `/new-work` | Prevent direct-to-main changes |
| 30+ min without commit | `/commit` | Create a rollback checkpoint |
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

**Rules:** One suggestion per response. Never repeat a dismissed suggestion. Never auto-run destructive commands. If user says "stop suggesting" — respect it for the session.

## Do NOT

- Modify raw data files — always work on processed copies
- Hardcode absolute paths — use relative paths only
- Overwrite previous paper draft versions — version explicitly (v1, v2, v3)
- Commit participant-identifiable data (PII, PHI) to git
- Skip reporting effect sizes and confidence intervals alongside significance tests
