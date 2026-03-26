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

---

## What it teaches

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

## Personas

Your answer to "what best describes your work?" selects a persona. Each one provides guardrails, teaching analogies, directory structure, recommended tools, and error interpretations specific to your domain.

| # | Persona | Example guardrail |
|---|---------|-------------------|
| 1 | **ML / Data Science** | Never commit .pkl files; use fixed random seeds |
| 2 | **Research** | Never modify raw data; report significance tests |
| 3 | **Business Analytics** | Never hard-code dates; validate join row counts |
| 4 | **Product Analytics** | Never peek at results before planned end date |
| 5 | **BI Platform** | Never DROP production tables without backup |
| 6 | **General** | Never commit .env files; run tests before pushing |

Each persona translates the same 8 patterns into different language. "Safe experimentation" becomes "hyperparameter sweep in isolation" for ML, "pilot study" for research, and "copy of the report" for business analytics.

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
