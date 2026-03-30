# Alfred

A Claude Code plugin that teaches development habits in your domain's language — then fades as you learn. Your corrections become permanent rules; your rules become automated hooks.

```
/plugin marketplace add DrakeCaraker/alfred
/plugin install alfred@alfred-marketplace
/reload-plugins
```

Then type `/alfred:bootstrap` and answer 3 questions. Done. [New to Claude Code?](docs/GETTING_STARTED.md)

---

## What it does

Alfred teaches 8 habits one at a time, when you need them:

1. **Check before you start** — See what's changed since last time
2. **Name your work** — Scope what you're doing before coding
3. **Save as you go** — Create restore points you can always undo to
4. **Try things safely** — Experiment without risking working code
5. **Change one thing at a time** — Small changes, verified individually
6. **Let the machine fix typos** — Auto-format on every edit
7. **Track where results come from** — Every output traces to source
8. **Teach the system your preferences** — Corrections become rules

Each habit is explained using your domain's language. An ML scientist hears "checkpoint your experiment." A researcher hears "sign a lab notebook page." A writer hears "seal a draft." Same concept — framing that sticks.

After three exposures without asking "why?", Alfred stops explaining and just does it. Advanced users start in silent mode.

---

## How corrections compound

```
You correct Alfred once  →  It remembers (this session)
The same thing comes up  →  It becomes a permanent rule (every session)
You want it enforced     →  It becomes an automated hook (runs by itself)
```

This is the core loop. You're not configuring a tool — you're training an environment. Every correction makes the system better. Over time, good practices become the default and mistakes require effort.

---

## 7 Personas

| # | Persona | Example guardrail |
|---|---------|-------------------|
| 1 | **ML / Data Science** | Never commit .pkl files; use fixed random seeds |
| 2 | **Research** | Never modify raw data; report significance tests |
| 3 | **Business Analytics** | Never hard-code dates; validate join row counts |
| 4 | **Product Analytics** | Never peek at results before planned end date |
| 5 | **BI Platform** | Never DROP production tables without backup |
| 6 | **General** | Never commit .env files; run tests before pushing |
| 7 | **Writer / Editor** | Never overwrite approved drafts; version explicitly |

---

## 19 Commands

Three commands cover 90% of daily use:

- **`/alfred:new-work`** — start a scoped task on a branch
- **`/alfred:commit`** — safe commit with pre-flight checks
- **`/alfred:teach`** — learn the next habit

<details>
<summary>All 19 commands</summary>

| Command | What it does |
|---------|-------------|
| `/bootstrap` | Picks your persona, generates CLAUDE.md, initializes tracking |
| `/github-account-setup` | Connect to GitHub or create an account |
| `/teach` | Next habit lesson — `/teach <name>` to revisit |
| `/status` | Graduated habits, level, next steps |
| `/commit` | Safe commit — pre-flight checks, blocks binaries |
| `/new-work` | Scoped branch with task list |
| `/ci-fix` | Auto-fix loop: lint → format → typecheck → test until green |
| `/self-improve` | Promote recurring corrections to permanent rules |
| `/health-check` | Project maturity assessment (5 levels) |
| `/safe-refactor` | One change at a time, auto-rollback on test failure |
| `/experiment-summary` | Inventory results with provenance |
| `/pr` | Push and open a PR (runs checks first) |
| `/vet` | Pressure-test a plan before committing to it |
| `/audit` | Security and quality audit with guided fixes |
| `/persona` | View or change your active persona |
| `/collective` | Preview, contribute, or ingest shared learning signals |
| `/pilot-consent` | View what's collected, opt in or out |
| `/pilot-report` | Submit feedback (PII-scrubbed) |
| `/pilot-delete` | Delete your data locally or from the repo |

When installed as a plugin, prefix with `alfred:` (e.g., `/alfred:teach`).

</details>

---

## Power tools

**`/safe-refactor`** — Writes characterization tests first, then refactors one change at a time. Tests fail? Automatic rollback.

**`/ci-fix`** — Loops lint → format → typecheck → tests until green. Detects when it's stuck and stops.

**`/health-check`** — Assesses your project across 5 maturity levels. Recommends what to fix next.

---

<details>
<summary>For teams</summary>

Alfred is per-repo. Each team member runs `/bootstrap` with their own persona and coding level — guardrails are consistent, explanations are personalized.

**The flywheel:**
1. Someone corrects Alfred → feedback memory saved
2. `/self-improve` promotes recurring corrections → CLAUDE.md rule (shared, every session)
3. Still violated? → automated hook (enforced, blocks the mistake)

One person's discovery becomes everyone's guardrail.

**Collective learning**: Corrections are anonymized, encrypted, and shared. When 3+ users hit the same correction, it becomes a recommended rule. Zero setup for contributors.

</details>

<details>
<summary>Alternative install methods</summary>

**Starting a new project** (clones Alfred as a template):

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

Then type `/bootstrap` and answer 3 questions.

</details>

<details>
<summary>Who it's for</summary>

**Beginners** — Alfred builds things for you. Describe what you want in plain language. Over time, you learn to direct it. → [First-time setup guide](docs/GETTING_STARTED.md)

**Intermediate** — Alfred adds engineering practices you're missing (version control, testing, reproducibility) without making you learn them upfront.

**Advanced** — Skip the teaching. Alfred starts in silent mode, gives you 19 commands, and reshapes itself from your corrections. → [System design docs](docs/AI_ASSISTED_DEV_GUIDE.md)

</details>

---

## Contributing

Add a persona:
1. Create `personas/<name>.md` with [all 10 sections](docs/AI_ASSISTED_DEV_GUIDE.md#adding-a-new-persona)
2. Add it to the role question in `.claude/commands/bootstrap.md`
3. Test: `/bootstrap` → `/teach` → `/status`
4. PR

Docs: [`AI_ASSISTED_DEV_GUIDE.md`](docs/AI_ASSISTED_DEV_GUIDE.md) | [`WORKFLOW_GUIDE.md`](docs/WORKFLOW_GUIDE.md) | [`PROMPTING_GUIDE.md`](docs/PROMPTING_GUIDE.md) | [Comprehensive README](docs/internal/README_COMPREHENSIVE.md)

## License

MIT
