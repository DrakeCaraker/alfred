# Alfred

Alfred is an AI that helps you build things with code — and teaches you how along the way.

You tell it what you do (researcher, analyst, data scientist, developer) and what you're working on. It sets up a new project with safety nets that prevent common mistakes — or audits an existing project and brings it up to code. Either way, it teaches you good practices one at a time, in language that makes sense for your work.

When you've learned something, Alfred stops explaining it and just does it. The more you use it, the more it gets out of your way.

## What it looks like

You open Alfred and describe your project:

> **You:** I'm building a quarterly revenue report that pulls from our Snowflake database
>
> **Alfred:** Got it. I've set up your project with:
> - A `queries/` folder for your SQL
> - A `reports/` folder for output
> - Safety checks that prevent you from accidentally overwriting results
> - Automatic formatting so your code stays clean
>
> I'll explain things as we go. Ready to start on the revenue query?

From here, you just work. Alfred handles version control, formatting, and safety checks in the background. When you encounter something new — like needing to try two different approaches without losing your current work — Alfred explains the concept using an analogy from your field, then sets it up for you.

## Who it's for

**You're new to coding.** Alfred builds things for you. You describe what you want in plain language, and Alfred writes the code, runs it, and explains what it did. Over time, you learn to direct it more precisely — and eventually to build independently.
→ [Start here: First-time setup guide](docs/GETTING_STARTED.md)

**You write SQL or scripts, but you're not a software engineer.** Alfred adds the engineering practices you're missing — version control, testing, reproducible environments — without making you learn them upfront. It translates each concept into your domain: "saving a version of your spreadsheet" instead of "committing to a branch."
→ [Quick start](#get-started)

**You're an experienced developer.** Skip the teaching. Alfred gives you pre-configured hooks (auto-format, CI gate, drift detection), 11 slash commands, and a self-improving rule system. Point it at a new repo or an existing one — it audits what's there, fills in what's missing, and starts in silent mode. Every correction you make gets captured; repeat it enough and Alfred promotes it into a permanent rule or an automated hook that enforces it without you. Over time, your environment reshapes itself around how you actually work.
→ [System design docs](docs/AI_ASSISTED_DEV_GUIDE.md)

---

## Why

Most people fail at building things with AI not because the AI is bad, but because the surrounding habits aren't there — scoping work before starting, committing frequently, isolating experiments on branches, tracing results to source code. These habits are simple but easy to skip, and skipping them is how you end up with half-finished work on main, lost changes, and results nobody can reproduce.

Alfred teaches these habits using language you already understand. An ML scientist hears "think of commits as experiment checkpoints." A business analyst hears "saving a version of the spreadsheet." A researcher hears "signing a lab notebook page." Same concept, different framing — because the framing is what makes it stick.

Then it shuts up. Once you've seen a concept three times without asking "why?", Alfred stops explaining and just does it. Advanced users start in silent mode from day one.

---

## Get started

Alfred runs on [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's AI coding tool.

**If you've never used Claude Code:**
Follow the [setup guide](docs/GETTING_STARTED.md) — it walks through everything from installation to your first project, step by step.

**Starting a new project:**

```bash
git clone https://github.com/DrakeCaraker/alfred.git my-project
cd my-project
git config core.hooksPath .githooks
claude
```

**Adding Alfred to an existing project:**

```bash
cd your-existing-project
git remote add alfred https://github.com/DrakeCaraker/alfred.git
git fetch alfred main && git merge alfred/main --allow-unrelated-histories
git config core.hooksPath .githooks
claude
```

Then type `/bootstrap` and answer 3 questions. Alfred audits what's already there, fills in what's missing, and sets up guardrails around your existing work. That's it. Start working.

After `/bootstrap`, three commands cover 90% of daily use:

| Command | When to use it |
|---------|---------------|
| `/new-work` | Starting a task — creates a branch, scopes the work |
| `/commit` | Saving progress — checks for dangerous files first |
| `/teach` | Curious about a habit — delivers a lesson in your domain's language |

<details>
<summary>All commands</summary>

| Command | What it does |
|---------|-------------|
| `/bootstrap` | Picks your persona, generates CLAUDE.md, initializes tracking |
| `/github-account-setup` | Connect to GitHub or create an account |
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
| `/vet` | Pressure-test a plan before committing to it |
| `/persona` | View or change your active persona |
| `/collective preview` | Preview collective team corrections |
| `/pilot-consent` | View what's collected, opt in or out |
| `/pilot-report` | Submit feedback (PII-scrubbed) |
| `/pilot-delete` | Delete your data locally or from the repo |

</details>

---

## What makes this different

Alfred teaches 8 habits, one at a time, when you need them:

1. **Check before you start** — See what's changed since last time before diving in
2. **Name your work** — Define what you're doing before you start, so you don't lose track
3. **Save as you go** — Create restore points so you can always undo mistakes
4. **Try things safely** — Experiment without risking your working code
5. **Change one thing at a time** — Make small changes and verify each one
6. **Let the machine fix typos** — Formatting and syntax errors get fixed automatically
7. **Track where results come from** — Every output traces back to what produced it
8. **Teach the system your preferences** — Corrections become permanent rules over time

Type `/teach` to learn the next one. Type `/status` to see your progress.

---

## How it adapts

**Explains, then stops.** The first time you run `/commit`, Alfred explains what a save point is using your domain's analogy. The third time, it goes silent. If you ever say "I know" or "skip," it graduates you immediately.

**Learns from corrections.** When you say "no, don't do that," Alfred saves a feedback memory. If the same correction comes up repeatedly, `/self-improve` promotes it to a permanent rule in CLAUDE.md — or even an automated hook that prevents the mistake entirely. You're not configuring a tool; you're training an environment. Your feedback literally becomes the system.

```
You correct Alfred once  →  It remembers (this session)
The same thing comes up  →  It becomes a permanent rule (every session)
You want it enforced     →  It becomes an automated hook (runs by itself)
```

The end state: a working environment that was shaped by your own decisions — where good practices are the default and mistakes require effort.

**Resumes across sessions.** When a session ends, Alfred bookmarks what you were working on. Next session, it picks up where you left off.

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

## Contributing

Add a persona:

1. Create `.claude/personas/<name>.md` with [all 9 sections](docs/AI_ASSISTED_DEV_GUIDE.md#adding-a-new-persona)
2. Add it to the role question in `.claude/commands/bootstrap.md`
3. Test: `/bootstrap` → `/teach` → `/status`
4. PR

Full system docs: [`docs/AI_ASSISTED_DEV_GUIDE.md`](docs/AI_ASSISTED_DEV_GUIDE.md)

## License

MIT
