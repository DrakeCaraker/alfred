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

## Guardrails

- Never modify raw data files — always work on processed copies in a separate directory
- Always report statistical significance tests with effect sizes and confidence intervals
- Document the complete analysis pipeline from raw data to final figure
- Use relative paths only — never hardcode absolute paths (breaks reproducibility)
- Version paper drafts explicitly (v1, v2, v3) — never overwrite previous versions
- Never commit participant-identifiable data (PII, PHI) to git

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

No test/lint commands detected yet. Add them here as your project grows.

## Tools

- **Python formatter**: ruff or black
- **R formatter**: styler
- **Document tools**: LaTeX + BibTeX, pandoc
- **Test runner**: pytest (Python) or testthat (R)

## Slash Commands

| Command | Purpose |
|---------|---------|
| /bootstrap | Persona-aware project setup (you just ran this) |
| /teach | Learn the next development pattern |
| /status | See your progress and graduated patterns |
| /commit | Safe commit with file guards |
| /new-work | Start scoped work on a new branch |
| /ci-fix | Auto-fix CI failures in a loop |
| /self-improve | Promote feedback to rules or hooks |
| /health-check | Assess project maturity |
| /safe-refactor | Test-gated refactoring with rollback |
| /pr | Branch → commit → push → PR workflow |

## Hooks

- **Format on write**: auto-formats files after every edit (detects ruff, prettier, gofmt, etc.)
- **Session start**: shows git status, branch safety, onboarding progress, and session resume
- **Session bookmark**: saves task context on session end for resume next time
- **Feedback capture**: reminds to save corrections as memories before session ends
- **Pre-compact**: saves critical context before conversation compression

## Explain Gate

When you encounter a slash command for a pattern you haven't graduated yet, briefly explain what it does and why before executing. Check `.claude/.onboarding-state.json` for graduation status. Once graduated, execute silently.

## Do NOT

- Modify raw data files — always work on processed copies
- Hardcode absolute paths — use relative paths only
- Overwrite previous paper draft versions — version explicitly (v1, v2, v3)
- Commit participant-identifiable data (PII, PHI) to git
- Skip reporting effect sizes and confidence intervals alongside significance tests
