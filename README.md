# Alfred

Development habits that stick — taught in your language, enforced automatically.

Alfred wraps Claude Code with progressive teaching, domain-specific guardrails,
and a self-improvement loop that turns your corrections into permanent rules.

## Install + Demo

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview). Setup takes 2 minutes. You answer 3 questions, Alfred does the rest.

```bash
git clone https://github.com/DrakeCaraker/alfred.git my-project
cd my-project && git config core.hooksPath .githooks && claude
```

```
> /bootstrap

What kind of work do you mainly do?  1
How comfortable are you with coding and version control?  2
In one sentence, what are you working on?  quarterly revenue forecasting model

Done. CLAUDE.md generated, guardrails active, 0/8 habits learned.
Start working — I'll explain things as they come up.
```

That's it. Start working.

---

## Get started

After `/bootstrap`, three commands cover 90% of daily use:

| Command | When to use it |
|---------|---------------|
| `/new-work` | Starting a task — creates a branch, scopes the work |
| `/commit` | Saving progress — checks for dangerous files first |
| `/teach` | Curious about a habit — delivers a lesson in your domain's language |

Everything else is available but not required upfront:

<details>
<summary>All commands</summary>

| Command | What it does |
|---------|-------------|
| `/bootstrap` | Picks your persona, generates CLAUDE.md, initializes tracking |
| `/teach` | Next habit lesson — or `/teach all` for progress, `/teach <name>` to revisit |
| `/status` | Graduated habits, level, next steps |
| `/commit` | Safe commit — blocks binaries, warns on large files |
| `/new-work` | Scoped branch with task list |
| `/ci-fix` | Auto-fix loop: lint, format, typecheck, test until green |
| `/self-improve` | Promote recurring corrections to permanent rules |
| `/health-check` | Project maturity assessment (5 levels) |
| `/safe-refactor` | One change at a time, auto-rollback on test failure |
| `/experiment-summary` | Inventory results with provenance |
| `/pr` | Push and open a pull request |
| `/persona` | View or change your active persona |
| `/collective preview` | Preview collective team corrections |
| `/pilot-consent` | View what's collected, opt in or out |
| `/pilot-report` | Submit feedback (PII-scrubbed) |
| `/pilot-delete` | Delete your data locally or from the repo |

</details>

---

## What makes this different

### It speaks your language

You pick a domain — ML/DS, Research, Analytics, BI, or General — and Alfred adapts everything: guardrails, teaching, directory structure, tools. An ML scientist hears "think of commits as experiment checkpoints." A business analyst hears "saving a version of the spreadsheet." A researcher hears "signing a lab notebook page." Same concept, different framing — because the framing is what makes it stick.

### Your corrections become permanent

Other AI tools forget when you close the tab. Alfred saves corrections as feedback memories. Run `/self-improve` and recurring corrections become permanent rules. Rules that still get violated become automated hooks that block the mistake entirely.

```
Feedback memory  →  CLAUDE.md rule  →  Automated hook
(soft, one session)    (durable)         (enforced)
```

You tell Alfred "don't commit .env files" twice. `/self-improve` adds a pre-commit guard. You never say it again.

### It gets out of your way

Alfred teaches 8 development habits, one at a time, as you encounter the situations where they matter. After three exposures, it stops explaining and just does it. Say "I know" and it graduates you immediately. Advanced users start in silent mode from day one.

The habits span the full cycle — from checking context before starting, through safe commits and branch isolation, to automated CI recovery and turning your own corrections into team-wide rules. Run `/teach` to learn the next one. `/status` shows your progress.

---

## Power tools

**`/safe-refactor`** — Writes tests that capture current behavior first, then refactors one change at a time. Tests fail? Automatic rollback. No manual git recovery.

**`/ci-fix`** — Loops through lint → format → typecheck → tests until green. Detects when it's stuck (same error twice) and stops instead of churning.

**`/health-check`** — Assesses your project across 5 maturity levels. Recommends the highest-impact gaps to close next.

---

## Personas

| # | Persona | Example guardrail |
|---|---------|-------------------|
| 1 | **ML / Data Science** | Never commit .pkl files; use fixed random seeds |
| 2 | **Research** | Never modify raw data; report significance tests |
| 3 | **Business Analytics** | Never hard-code dates; validate join row counts |
| 4 | **Product Analytics** | Never peek at results before planned end date |
| 5 | **BI Platform** | Never DROP production tables without backup |
| 6 | **General** | Never commit .env files; run tests before pushing |

---

## For teams

Alfred is per-repo. Each team member runs `/bootstrap` with their own persona and coding level — guardrails are consistent, explanations are personalized. The first member bootstraps and commits CLAUDE.md — that becomes the shared team config. Others run `/bootstrap` and choose "keep existing" to get personal onboarding with shared guardrails.

**The team flywheel:**

1. **Someone makes a correction.** A team member corrects Alfred: "always validate join row counts before aggregating." Alfred saves it as a feedback memory.
2. **It becomes a team rule.** `/self-improve` promotes recurring corrections to CLAUDE.md — which lives in the repo and applies to every team member.
3. **It gets enforced.** If the rule is still violated, the next `/self-improve` run promotes it to a pre-commit hook that blocks the mistake automatically.

One person's discovery becomes everyone's guardrail.

**Adoption friction is self-correcting.** If anyone finds Alfred too verbose, they say "I know" and it goes silent for that habit. No team-wide configuration needed.

**Measuring adoption**: Opt-in pilot telemetry tracks which habits are graduating and which commands are used — without collecting code, file paths, or PII. Run `scripts/aggregate-pilot.sh` for a team summary. See [`.pilot/README.md`](.pilot/README.md) for the full privacy policy.

**Project health**: `/health-check` gives leaders a 5-level maturity snapshot — what's in place, what's missing, what to prioritize.

---

## Setup notes

Activate the pre-push hook after cloning (blocks binaries and direct pushes to main):

```bash
git config core.hooksPath .githooks
```

This activates branch protection, binary blocking, and PII scanning. Format-on-write, session bookmarks, and feedback capture run automatically via `.claude/settings.json`.

---

## Contributing

Add a persona:

1. Create `.claude/personas/<name>.md` with [all 9 sections](docs/AI_ASSISTED_DEV_GUIDE.md#adding-a-new-persona)
2. Add it to the role question in `.claude/commands/bootstrap.md`
3. Test: `/bootstrap` → `/teach` → `/status`
4. PR

Full system docs: [`docs/AI_ASSISTED_DEV_GUIDE.md`](docs/AI_ASSISTED_DEV_GUIDE.md)

## License

MIT
