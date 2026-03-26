# Alfred

Alfred sets up Claude Code for your project. You answer two questions — what you do and how much you code — and it generates a tailored environment with guardrails, automation, and progressive teaching that adapts to you.

## Setup

### 1. Install Claude Code

Alfred runs inside [Claude Code](https://docs.anthropic.com/en/docs/claude-code), an AI assistant you interact with by typing messages. Claude Code requires a paid subscription — either [Claude Max/Team](https://claude.ai) or an [Anthropic API key](https://console.anthropic.com).

Install the CLI (requires [Node.js](https://nodejs.org)):

```bash
npm install -g @anthropic-ai/claude-code
```

Other options (desktop app, web) are available — see the [setup guide](https://docs.anthropic.com/en/docs/claude-code/getting-started).

### 2. Get Alfred

```bash
git clone https://github.com/DrakeCaraker/alfred.git my-project
cd my-project
git config core.hooksPath .githooks
```

This downloads Alfred into a `my-project` folder and activates its safety checks.

> **No git?** Click the green "Code" button on GitHub → "Download ZIP", unzip it, and open a terminal in that folder. Alfred will set up git for you during bootstrap.

### 3. Run /bootstrap

Start Claude Code:

```bash
claude
```

You'll see a status summary — this is normal. Alfred is telling you it hasn't been set up yet. At the Claude Code prompt, type:

```
/bootstrap
```

Alfred asks three questions:

```
What best describes your work?  1
How comfortable are you with coding?  2
Describe your project:  quarterly revenue forecasting model
```

It may also offer to connect your GitHub account — you can skip this and do it later with `/github-account-setup`.

```
Done. CLAUDE.md generated, guardrails active, 0/8 patterns learned.
Start working — I'll explain things as they come up.
```

That's it. Start working.

---

## Why

Most people fail at AI-assisted development not because the AI is bad, but because the surrounding habits aren't there — scoping work before starting, committing frequently, isolating experiments on branches, tracing results to source code. These habits are simple but easy to skip, and skipping them is how you end up with half-finished work on main, lost changes, and results nobody can reproduce.

Alfred teaches these habits using language you already understand. An ML scientist hears "think of commits as experiment checkpoints." A business analyst hears "saving a version of the spreadsheet." A researcher hears "signing a lab notebook page." Same concept, different framing — because the framing is what makes it stick.

Then it shuts up. Once you've seen a concept three times without asking "why?", Alfred stops explaining and just does it. Advanced users start in silent mode from day one.

---

## Get started

After `/bootstrap`, three commands cover most of what you need:

| Command | When to use it |
|---------|---------------|
| `/new-work` | Starting a task — creates a branch, scopes the work |
| `/commit` | Saving progress — checks for dangerous files first |
| `/teach` | Curious about a pattern — delivers a lesson in your domain's language |

Everything else is available but not required upfront:

<details>
<summary>All commands</summary>

| Command | What it does |
|---------|-------------|
| `/bootstrap` | Picks your persona, generates CLAUDE.md, initializes tracking |
| `/teach` | Next pattern lesson — or `/teach all` for progress, `/teach <name>` to revisit |
| `/status` | Graduated patterns, level, next steps |
| `/commit` | Safe commit — blocks binaries, warns on large files |
| `/new-work` | Scoped branch with task list |
| `/ci-fix` | Auto-fix loop: lint, format, typecheck, test until green |
| `/self-improve` | Promote recurring corrections to permanent rules |
| `/health-check` | Project maturity assessment (5 levels) |
| `/safe-refactor` | One change at a time, auto-rollback on test failure |
| `/experiment-summary` | Inventory results with provenance |
| `/pr` | Push and open a pull request |

</details>

---

## What it teaches

Alfred teaches 8 patterns — the habits that make AI-assisted development work. They're taught in order, one at a time, as you encounter the situations where they matter.

**1. Context before action** — Check where you are before you start. The session-start hook does this automatically.

**2. Scope before work** — Name what you're doing and create a branch before writing code. `/new-work`

**3. Save points** — Commit frequently. `/commit` adds safety checks.

**4. Safe experimentation** — Use branches to try things. If it works, merge. If not, delete.

**5. One change, one test** — Change one thing, test, commit or rollback. `/safe-refactor`

**6. Automated recovery** — Let the machine fix lint and format errors. `/ci-fix`

**7. Provenance** — Every result traces to the code that produced it. `/experiment-summary`

**8. Self-improvement** — The system learns from your corrections. `/self-improve`

Run `/teach` to learn the next one. Run `/status` to see which you've graduated.

---

## How it adapts

**Explains, then stops.** The first time you run `/commit`, Alfred explains what a save point is using your domain's analogy. The third time, it goes silent. If you ever say "I know" or "skip," it graduates you immediately.

**Learns from corrections.** When you say "no, don't do that," Alfred saves a feedback memory. If the same correction comes up repeatedly, `/self-improve` promotes it to a permanent rule in CLAUDE.md — or even an automated hook that prevents the mistake entirely.

```
Feedback memory  →  CLAUDE.md rule  →  Automated hook
(soft, one session)  (durable, every session)  (enforced, blocks the action)
```

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

## Setup notes

Activate the pre-push hook after cloning (blocks binaries and direct pushes to main):

```bash
git config core.hooksPath .githooks
```

Alfred also installs these hooks via `.claude/settings.json`:
- **Format on write** — auto-formats Python, JS/TS, Go, Rust, R, SQL after every edit
- **Session start** — git status, branch safety, onboarding progress, session resume
- **Session end** — bookmarks your task context and captures feedback
- **Pre-compact** — preserves critical context before conversation compression

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
