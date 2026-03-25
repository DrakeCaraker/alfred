# Alfred

**Your AI-assisted development environment, tailored to how you actually work.**

Alfred is a template repository for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Clone it into any project, answer two questions, and get a development environment that knows your domain, enforces best practices, and teaches you as you go — then goes silent once you've learned.

```
cd your-project
claude
> /bootstrap

What best describes your work?
  1. ML / Data Science
  2. Research
  3. Business Analytics
  4. Product Analytics
  5. BI Platform
  6. General
> 1

How comfortable are you with coding?
  1. Beginner
  2. Intermediate
  3. Advanced
> 2

Describe your project in one sentence:
> XGBoost ensemble for stable feature importance

Alfred is set up for ML / Data Science development.
- CLAUDE.md generated with domain-specific guardrails
- Onboarding tracking initialized (0/8 patterns)

Start working — patterns are explained as you encounter them.
Or run /teach to learn proactively, /status to see progress.
```

## What Alfred Does

**1. Knows your domain.** Six personas — ML/DS, Research, Business Analytics, Product Analytics, BI Platform, and General — each with tailored guardrails, analogies, directory structures, and error context. An ML scientist gets "think of commits as experiment checkpoints." A business analyst gets "think of commits as saving a version of the spreadsheet."

**2. Teaches progressively.** Alfred teaches 8 development patterns — not all at once, but as you encounter them. The first time you run `/commit`, Alfred explains what a save point is and why it matters, using language from your domain. By the third time, it goes silent.

**3. Gets out of your way.** Every explanation passes through an *explain gate*. Once you've seen a pattern 3 times without asking "why?", Alfred graduates you and stops explaining. Advanced users skip teaching entirely — all 8 patterns start in auto-mode.

**4. Learns from you.** When you correct Alfred's approach, it saves a feedback memory. Run `/self-improve` to promote recurring corrections into permanent CLAUDE.md rules or automated hooks. The system literally writes its own rules from watching you work.

## Quick Start

```bash
# Clone into an existing project, or start fresh
git clone https://github.com/DrakeCaraker/alfred.git my-project
cd my-project
claude

# Inside Claude Code:
/bootstrap      # answer 2 questions, get your environment
/teach          # learn your first pattern
/status         # check your progress
```

After cloning, activate the pre-push safety hook:
```bash
git config core.hooksPath .githooks
```

## The 8 Patterns

These are the building blocks of effective AI-assisted development. Alfred teaches them in order, adapting the language to your persona.

| # | Pattern | Principle | Command |
|---|---------|-----------|---------|
| 1 | Context before action | Know where you are before you move | session-start hook |
| 2 | Scope before work | Name what you're doing before you do it | `/new-work` |
| 3 | Save points | Checkpoint progress so you can always go back | `/commit` |
| 4 | Safe experimentation | Try things without risk to working code | branching via `/new-work` |
| 5 | One change, one test | Change deliberately, verify each step | `/safe-refactor` |
| 6 | Automated recovery | Let machines fix mechanical errors | `/ci-fix` |
| 7 | Provenance | Every result traces to a source | `/experiment-summary` |
| 8 | Self-improvement | The system learns from corrections | `/self-improve` |

Run `/teach` to learn the next pattern. Run `/teach all` to see your graduation status. Run `/teach save-points` to revisit a specific pattern.

## Personas

Each persona provides domain context, guardrails, analogies for all 8 patterns, starter directories, recommended tools, work product templates at 4 complexity levels, and domain-specific error interpretations.

| Persona | Domain | Example guardrail |
|---------|--------|-------------------|
| **ML / Data Science** | Models, experiments, pipelines | Never commit .pkl files; always use fixed random seeds |
| **Research** | Papers, statistics, reproducibility | Never modify raw data; always report significance tests |
| **Business Analytics** | Dashboards, SQL, reports | Never hard-code dates; always validate join row counts |
| **Product Analytics** | A/B tests, funnels, metrics | Never peek at results before planned end date |
| **BI Platform** | dbt, warehouses, data quality | Never DROP production tables without backup |
| **General** | Software development, any language | Never commit .env files; always run tests before pushing |

## Commands

| Command | What it does |
|---------|-------------|
| `/bootstrap` | Picks persona, generates CLAUDE.md, initializes onboarding |
| `/teach` | Delivers the next pattern lesson with domain-specific analogies |
| `/status` | Shows graduated patterns, level, and next steps |
| `/commit` | Safe commit — blocks binaries, warns on large files |
| `/new-work` | Creates a scoped branch with a task list |
| `/ci-fix` | Auto-fix loop: lint, format, typecheck, test — until green |
| `/self-improve` | Promotes feedback memories to CLAUDE.md rules or hooks |
| `/health-check` | Assesses project maturity across 5 levels |
| `/safe-refactor` | Characterize, refactor one step at a time, auto-rollback on failure |
| `/experiment-summary` | Inventories results with provenance metadata |
| `/pr` | Push and open a PR with lint gates |

## How the Explain Gate Works

```
Action triggered (e.g., /commit)
    |
Has user graduated this pattern? -- yes --> just do it
    | no
Seen explanation < 3 times? -- yes --> full explanation in domain language
    | no
User asked "why?" last time? -- yes --> full explanation
    | no
Brief reminder, then do it
```

Graduation happens when you've seen a pattern 3 times without asking "why?" — or instantly if you say "I know, skip."

## The Self-Improvement Loop

Corrections flow through three levels of permanence:

```
Feedback memory        (soft — this session learned X)
    |  repeated 2+ times
CLAUDE.md rule         (durable — every session enforces X)
    |  still violated
Hook / automated guard (enforced — blocks the action)
```

Run `/self-improve` to trigger promotion. The system proposes changes, you approve or reject.

## Project Structure

```
.claude/
  commands/       11 slash commands
  hooks/          5 automation hooks
  personas/       6 persona modules
  settings.json   Hook configuration
  tool-catalog.md Pattern-to-tool reference
.githooks/
  pre-push        Blocks binaries + main pushes
```

State files (created at runtime by `/bootstrap`):
- `.claude/.onboarding-state.json` — persona, coding level, pattern graduation
- `.claude/.session-bookmark.json` — task context for session resume
- `.claude/.session-count` — session counter for self-improve nudges

## Contributing

To add a new persona:

1. Create `.claude/personas/<name>.md` following the [9-section template](docs/AI_ASSISTED_DEV_GUIDE.md#adding-a-new-persona)
2. Add the persona to the role question in `.claude/commands/bootstrap.md`
3. Test: `/bootstrap` with the new persona, then `/teach`, `/status`
4. Submit a PR

See [`docs/AI_ASSISTED_DEV_GUIDE.md`](docs/AI_ASSISTED_DEV_GUIDE.md) for full system documentation.

## License

MIT
