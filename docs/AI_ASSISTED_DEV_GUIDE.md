# AI-Assisted Development Guide

A comprehensive reference for how Alfred works, the habits it teaches, and how to customize it.

See the [README](../README.md) for quick start and positioning.

## Overview

Alfred is an AI coding assistant that teaches development habits in your domain's language and turns corrections into permanent rules. It teaches 8 development habits progressively, adapting to your role and skill level. The system explains itself as you work, then gradually goes silent as you demonstrate understanding.

## The 8 Development Habits

### Habit 1: Context Before Action
**Principle**: Know where you are before you move.

Before starting any work, check the state of your project: uncommitted changes, current branch, how far behind main you are, and what happened in your last session. The session-start hook does this automatically.

**Auto-mode**: Session-start hook prints status silently.
**Learn-mode**: "Here's what these numbers mean and why they matter..."

### Habit 2: Scope Before Work
**Principle**: Name what you're doing before you do it.

Define the scope of your work before writing code. Create a branch with a descriptive name, write a task list, and confirm scope before starting. This prevents half-finished sessions and scope creep.

**Auto-mode**: `/new-work` creates branch + task list without explanation.
**Learn-mode**: "We're creating a separate workspace so your main project stays safe..."

### Habit 3: Save Points
**Principle**: Checkpoint progress so you can always go back.

Commit frequently with meaningful messages. The `/commit` command adds safety checks (large files, binary artifacts) before each commit. Think of commits as save points in a game — you can always return.

**Auto-mode**: `/commit` runs safety checks and commits silently.
**Learn-mode**: "This is like saving a version of your document — you can always return to this exact state..."

### Habit 4: Safe Experimentation
**Principle**: Try things without risk to working code.

Use branches to isolate experiments. If an experiment works, merge it. If not, delete the branch. Your main code is never at risk.

**Auto-mode**: Branch creation and merge/discard without explanation.
**Learn-mode**: "Think of this as running a side experiment. If it works, we keep it. If not, we throw it away..."

### Habit 5: One Change, One Test
**Principle**: Change deliberately, verify each step.

Make one change at a time and test after each. If something breaks, you know exactly what caused it. The `/safe-refactor` command enforces this with automatic rollback on test failure.

**Auto-mode**: `/safe-refactor` applies + tests + rollbacks silently.
**Learn-mode**: "We're going to make one change at a time and check after each one..."

### Habit 6: Automated Recovery
**Principle**: Let machines fix mechanical errors.

Formatting issues, lint errors, and simple type errors can be fixed automatically. The `/ci-fix` command loops through failures, applying fixes until everything passes.

**Auto-mode**: `/ci-fix` loops until green without explanation.
**Learn-mode**: "These are formatting and syntax errors — like spell-check. The system can fix them automatically..."

### Habit 7: Provenance
**Principle**: Every result traces to a source.

Every number, figure, and result should trace back to the code, data, and configuration that produced it. The `/experiment-summary` command inventories results and tags them with provenance metadata.

**Auto-mode**: `/experiment-summary` tags outputs silently.
**Learn-mode**: "Every number in your report needs to trace back to the code and data that produced it..."

### Habit 8: Self-Improvement
**Principle**: The system learns from corrections.

When you correct Claude's approach, that correction is saved as a feedback memory. Over time, recurring corrections are promoted to permanent rules (in CLAUDE.md) or automated guards (hooks). The `/self-improve` command manages this promotion ladder.

**Auto-mode**: `/self-improve` promotes memories to rules silently.
**Learn-mode**: "I noticed you've corrected me on this 3 times. I'm adding it as a permanent rule..."

## The Explain Gate

Every automated action passes through an explain gate that decides whether to explain:

```
Action triggered
    |
Has user graduated this habit? --yes--> AUTO: just do it
    | no
Has user seen explanation <3 times? --yes--> LEARN: full explanation
    | no
Did user ask "why?" last time? --yes--> LEARN: full explanation
    | no
BRIEF: one-line reminder + do it
```

### Graduation Criteria
- Seen the explanation 3+ times
- `last_asked_why` is false (asking "why?" resets progress — need 3 more without asking)
- OR user explicitly says "I know, just do it" (immediate graduation)

## The Promotion Ladder

Corrections flow through three levels of permanence:

```
feedback memory (soft, session-scoped)
    | repeated 2+ times or high-impact
CLAUDE.md rule (durable, every-session)
    | still violated after rule exists
hook/guard (enforced, blocks the action)
```

Use `/self-improve` to trigger promotion analysis.

## Personas

Alfred ships with 6 personas, each providing:
- **Domain context** for CLAUDE.md
- **Guardrails** specific to the domain
- **Analogy map** translating the 8 habits into domain language
- **Starter artifacts** (directory structure)
- **Recommended tools** (formatters, linters, etc.)
- **Work product templates** at 4 complexity levels
- **Error context** for domain-specific troubleshooting

### Available Personas
1. **ML / Data Science** — experiment reproducibility, model versioning, notebook management
2. **Research** — academic rigor, raw data protection, LaTeX workflow
3. **Business Analytics** — metric accuracy, SQL patterns, stakeholder communication
4. **Product Analytics** — experiment rigor, funnel analysis, A/B testing
5. **BI Platform** — data modeling, dbt workflow, pipeline reliability
6. **General** — language-agnostic software development habits

## Customization

### Adding a New Persona
1. Create `.claude/personas/<name>.md` with all 9 sections
2. Add the persona option to bootstrap.md Question 1
3. Test the full flow: `/bootstrap` → `/teach` → `/status`

### Modifying Graduation Criteria
Edit the logic in `.claude/commands/teach.md` Step 3. Default is 3 exposures without asking "why?".

### Resetting Onboarding
Delete `.claude/.onboarding-state.json` and run `/bootstrap` again. This resets all graduation progress.

### Manual Graduation
Edit `.claude/.onboarding-state.json` directly — set `"graduated": true` for any habit you want to skip.

## Hooks Reference

| Hook | Event | Purpose |
|------|-------|---------|
| format-on-write.sh | PostToolUse (Write/Edit) | Auto-format by language (ruff, prettier, gofmt, etc.) |
| session-start.sh | SessionStart | Git status, onboarding progress, session resume |
| session-bookmark.sh | Stop | Save task context for next session |
| feedback-capture.sh | Stop | Remind to save user corrections |
| pre-compact.sh | PreCompact | Save critical context before compression |
| pilot-telemetry.sh | Stop | Record session telemetry + aggregate collective signals |
| pre-push | git push | Block binaries, large files, and main pushes |

## State Files

| File | Purpose |
|------|---------|
| `.claude/.onboarding-state.json` | Persona, coding level, habit graduation tracking |
| `.claude/.session-bookmark.json` | Last session's task, progress, and next steps |
| `.claude/.session-count` | Session counter for self-improve nudges |
| `.claude/.pilot-consent.json` | Consent state for telemetry and collective signals |
| `.claude/.pilot-identity.json` | Anonymous UUID for telemetry |
| `.claude/.collective-pending.json` | Aggregated signals awaiting push |
| `.claude/.pilot-session-start` | Session start timestamp for duration bucketing |

## Collective Learning

Alfred's collective learning system lets corrections compound across users:

1. Individual corrections are saved as feedback memories
2. `/self-improve` promotes recurring corrections to CLAUDE.md rules or hooks
3. `/collective contribute` anonymizes and encrypts corrections, then submits them
4. When 3+ users hit the same correction, it becomes a recommended team rule

**Privacy**: Signals are anonymized locally (no code, paths, or identifiers), encrypted with a public RSA key before leaving the machine, and stored in a private repo. Contributors need zero setup beyond `gh auth login`.

**For maintainers**: Set `ALFRED_COLLECTIVE_KEY` to decrypt and review signals via `/collective ingest`.

## Automation Stack

Alfred automates development workflows through 7 layers:

| Layer | Trigger | What it does |
|-------|---------|-------------|
| PostToolUse | Every Write/Edit | Auto-format + sync command/hook mirrors |
| Pre-commit | `git commit` | Block stale mirrors + PII scan |
| Pre-push | `git push` | Security audit + PII scan |
| CI | Every PR | Validate + lint + test + audit |
| CI Auto-fix | CI failure | Claude fixes code automatically |
| Conflict Resolution | Push to main | Claude resolves merge conflicts |
| Weekly Scan | Monday 9am UTC | Security audit, opens issue on failure |

```bash
make check    # Full CI-equivalent validation
make audit    # Deep security lint
make fix      # Auto-fix sync + permissions
```

## Prompting Guide

Each persona includes domain-specific prompting tips (Section 10 in persona files). Core principles:

1. **State what, not how** — describe outcomes, not implementations
2. **Scope before starting** — state constraints and success criteria upfront
3. **Ask for alternatives** — "give me 2-3 approaches with trade-offs"
4. **Use depth signals** — "think carefully" for analysis, "vet this" for pressure-testing, "audit this" for review
5. **Let corrections compound** — explicit corrections become permanent rules

Full guide: [`PROMPTING_GUIDE.md`](PROMPTING_GUIDE.md)
Full workflow reference: [`WORKFLOW_GUIDE.md`](WORKFLOW_GUIDE.md)

## Troubleshooting

### "Run /bootstrap first"
The onboarding state file is missing. Run `/bootstrap` to create it.

### Hooks not firing
1. Check `.claude/settings.json` — verify hook paths are correct
2. Run `bash -n .claude/hooks/<hook>.sh` to check for syntax errors
3. Ensure hooks are executable: `chmod +x .claude/hooks/*.sh`

### Pre-push hook not active
Run: `git config core.hooksPath .githooks`

### Want to start over
Delete `.claude/.onboarding-state.json` and run `/bootstrap` again.
