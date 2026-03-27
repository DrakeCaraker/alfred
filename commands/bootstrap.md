# Alfred Bootstrap

Set up a persona-tailored AI-assisted development environment. This command detects what exists, asks targeted questions, selects a persona, generates your CLAUDE.md, and initializes progressive skill building.

## Step 1: Detect current state

Check which infrastructure already exists:
```bash
ls CLAUDE.md .cursorrules .github/copilot-instructions.md 2>/dev/null
ls .githooks/pre-push .git/hooks/pre-push 2>/dev/null
ls Makefile justfile taskfile.yml package.json 2>/dev/null
ls .claude/settings.json 2>/dev/null
ls .gitignore 2>/dev/null
git rev-parse --is-inside-work-tree 2>/dev/null
```

If CLAUDE.md already exists and contains more than the placeholder text ("Run `/bootstrap`"), this is a re-bootstrap. Ask the user: "CLAUDE.md already exists. Replace it with a fresh persona-tailored version, or keep existing and add missing infrastructure?"

If not a git repo, initialize: `git init`

## Step 2: Ask questions

Start with a brief welcome, then ask these questions **one at a time**. Show only one question per message. Do NOT combine questions or show the next question until the user has answered the current one. Wait for the user to respond before moving on.

**Welcome preamble** (show before Question 1):
```
I'm going to ask you three quick questions so I can set things up for you.
There are no wrong answers — just pick whatever feels closest. You can
always change these later.
```

### Question 1: Role

**Why we're asking**: Alfred uses your answer to choose the right language when explaining things. For example, if you work with data models, it'll use terms you already know instead of generic software jargon.

```
What kind of work do you mainly do?

1. ML / Data Science — training models, running experiments, building pipelines
2. Research — writing papers, statistical analysis, making results reproducible
3. Business Analytics — building dashboards, writing reports, SQL queries
4. Product Analytics — A/B tests, funnels, understanding user behavior
5. BI / Data Platform — data warehouses, dbt, data quality engineering
6. General software dev — building apps, APIs, or tools (not data-specific)
7. Something else — just describe it and I'll figure out the best fit
```

For option 7: infer the closest persona from the user's description. Confirm: "That sounds closest to [persona]. I'll use that — let me know if that doesn't feel right."

Map answers to persona files:
- 1 → `.claude/personas/ml-ds.md`
- 2 → `.claude/personas/research.md`
- 3 → `.claude/personas/business-analytics.md`
- 4 → `.claude/personas/product-analytics.md`
- 5 → `.claude/personas/platform-bi.md`
- 6 → `.claude/personas/general.md`

### Question 2: Coding comfort

**Why we're asking**: This controls how much Alfred explains along the way. Pick "beginner" and you'll get more context with each step. Pick "advanced" and Alfred stays out of your way.

```
How comfortable are you with coding and version control (things like git)?

1. Getting started — I'm learning, and mostly use notebooks or spreadsheets
2. Comfortable — I write code regularly and know the basics of git
3. Very comfortable — I use branches, CI pipelines, and automated testing
```

Map to coding_level: 1→"beginner", 2→"intermediate", 3→"advanced"
Map to code_complexity_level: 1→1, 2→2, 3→3

### Question 3: Project description

**Why we're asking**: This becomes the title of your project's instruction file. Alfred reads it at the start of every session to stay oriented on what you're building.

```
In one sentence, what are you working on?

For example: "A dashboard that tracks weekly engagement metrics"
or "Training a sleep staging model on accelerometer data"
```

## Step 3: Read persona

Read the selected persona file from `.claude/personas/<persona>.md`. Extract:
- **Domain Context Template** → for CLAUDE.md "About" section
- **Guardrails** → for CLAUDE.md "Guardrails" section
- **Common Tasks** → for context (not written to CLAUDE.md directly)
- **Starter Artifacts** → for directory creation
- **Recommended Tools** → for CLAUDE.md "Tools" section
- **Analogy Map** → stored in onboarding state for /teach to use

If the persona file does not exist, fall back to `.claude/personas/general.md`. If that also does not exist, inform the user and halt — persona files are required for bootstrap.

## Step 4: Generate CLAUDE.md

Write a new CLAUDE.md file with this structure. Adapt content from the persona file and the user's answers. The file should be immediately useful as the project's AI instruction set.

```markdown
# [Project Description from Q3]

[Domain context from persona, tailored to the user's project description]

## Non-Negotiable Rules

1. **Never push directly to main.** Always create a feature branch and open a PR.
2. **Keep commits atomic.** One concern per commit, one concern per branch.
3. **Read before planning.** Verify by reading actual code before proposing any changes.
4. **Capture corrections immediately.** When redirected ("no", "don't", "stop", "instead"), save a feedback memory before continuing with the corrected approach.

## Guardrails

[Guardrails from persona file — include all of them verbatim]

## Directory Map

[Auto-detect from `ls` — show the project's current top-level structure]

## Running

[Detect test command from Makefile/package.json/pyproject.toml, or ask the user]
[Detect lint/format commands if available]
[If nothing is detected, write: "No test/lint commands detected yet. Add them here as your project grows."]

## Tools

[Recommended tools from persona file]

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

[Do-not rules from persona guardrails — reformatted as a bullet list]
```

## Step 5: Create onboarding state

Write `.claude/.onboarding-state.json`:

```json
{
  "persona": "<selected-persona-key>",
  "coding_level": "<beginner|intermediate|advanced>",
  "code_complexity_level": <1|2|3>,
  "bootstrapped_at": "<ISO-8601 timestamp>",
  "patterns": {
    "context_before_action": {"seen": 0, "graduated": false, "last_asked_why": false},
    "scope_before_work": {"seen": 0, "graduated": false, "last_asked_why": false},
    "save_points": {"seen": 0, "graduated": false, "last_asked_why": false},
    "safe_experimentation": {"seen": 0, "graduated": false, "last_asked_why": false},
    "one_change_one_test": {"seen": 0, "graduated": false, "last_asked_why": false},
    "automated_recovery": {"seen": 0, "graduated": false, "last_asked_why": false},
    "provenance": {"seen": 0, "graduated": false, "last_asked_why": false},
    "self_improvement": {"seen": 0, "graduated": false, "last_asked_why": false}
  },
  "session_count": 0,
  "incidents": {}
}
```

**For Advanced users (coding_level "advanced")**: Set ALL patterns to `"graduated": true` — they get auto-mode immediately with no teaching. They can always opt back in with `/teach <pattern>`.

For Beginner and Intermediate users: All patterns start with `"graduated": false`.

## Step 6: Generate alfred.yaml

Write `.claude/alfred.yaml` — the project configuration that all hooks and commands read at runtime. Detect values from the project environment; ask the user if detection fails.

```yaml
# Alfred project configuration — generated by /bootstrap
# Hooks and commands read this instead of hardcoding values.
# Edit anytime; changes take effect on next hook/command run.

project:
  name: "<project name from Q3 — slugified>"
  type: "<detected from files: python if .py/pyproject.toml, js if package.json, ts if tsconfig.json, rust if Cargo.toml, go if go.mod, r if .Rproj, mixed if multiple>"

formatting:
  tool: "<detected: ruff if pyproject.toml has ruff, black if has black, prettier if package.json, gofmt if go.mod, rustfmt if Cargo.toml, none if nothing found>"

testing:
  command: "<detected from Makefile/package.json/pyproject.toml, or ask user>"
  fast_command: "<same as command if no fast variant detected>"

ci:
  lint_command: "<detected or empty string>"
  typecheck_command: "<detected or empty string>"
  source_paths: ["<detected source directories>"]
  source_glob: "<*.py, *.ts, etc. based on project type>"

protected_files: []
blocked_extensions: [".pkl", ".pt", ".pth", ".h5", ".joblib", ".ckpt", ".safetensors"]
max_file_size_mb: 10

git:
  main_branch: "<detected from git: default branch name, usually main>"

domain: {}
```

**Detection rules:**
- `project.type`: Check for `pyproject.toml`/`*.py` → python, `package.json` → js, `tsconfig.json` → ts, `Cargo.toml` → rust, `go.mod` → go, `*.Rproj` → r. Multiple → mixed.
- `formatting.tool`: Check pyproject.toml for `[tool.ruff]` → ruff, `[tool.black]` → black. Check package.json for prettier dep → prettier. Default to none if nothing detected.
- `testing.command`: Check Makefile for test target, pyproject.toml for pytest config, package.json for test script.
- `git.main_branch`: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||'` or default to "main".

If a value can't be detected, use the defaults shown above. Do NOT ask the user for every field — only ask if no test command is detected (since that's critical for /ci-fix and /safe-refactor).

## Step 7: Create starter directories (was Step 6)

Read the Starter Artifacts section from the persona file. Create each directory with `mkdir -p`. Do NOT create files inside them — only the directory structure.

List the directories you created so the user can see what was set up.

## Step 8: Set up infrastructure

- If `.gitignore` doesn't exist or is minimal (fewer than 5 lines), create or extend it with persona-appropriate patterns (e.g., `__pycache__/`, `.env`, `*.pyc`, `.DS_Store`, `node_modules/`, etc.)
- If `.githooks/pre-push` doesn't exist, note: "Pre-push hook is available at `.githooks/pre-push`. Activate with: `git config core.hooksPath .githooks`"
- If `.claude/settings.json` exists but doesn't have hooks configured, note that hooks are available and can be configured

Do NOT overwrite existing `.gitignore` entries — only append missing patterns.

## Step 9: Welcome message

Display a welcome message tailored to the coding level:

**Beginner**:
```
You're all set! Here's what I just did:

- Created a CLAUDE.md file — this is like a cheat sheet that tells me
  about your project and how to help you. You can read or edit it anytime.
- Set up [N] folders to organize your work
- Turned on a learning system that will teach you [persona]-friendly
  development habits as you go (0/8 habits learned so far)

What to do next:
  /teach — learn your first development habit (takes ~2 minutes)

Or just start working on your project. I'll explain things as they come up.
```

**Intermediate**:
```
Alfred is set up for [persona] development.
- CLAUDE.md generated with domain-specific guardrails
- Onboarding tracking initialized (0/8 habits)

Start working — habits are explained as you encounter them.
Or run /teach to learn proactively, /status to see progress.
```

**Advanced**:
```
Alfred is set up for [persona] development.
- CLAUDE.md generated with domain-specific guardrails
- All 8 habits in auto-mode (no explanations unless you ask)

Available: /status, /health-check, /self-improve, /teach <pattern>
```

## Rules

- Never overwrite an existing CLAUDE.md without asking the user first.
- Never skip the questions — they determine everything downstream.
- Always create the onboarding state file — /teach and /status depend on it.
- If git is not initialized, initialize it before doing anything else.
- Show what was created before finishing (files, directories, state).
- Ask questions ONE AT A TIME. Show only one question per message. Wait for the user's answer before showing the next question. Never combine or batch questions.
- If a persona file is missing, fall back to general.md.
- Always use the exact JSON schema above for onboarding state — other commands parse it.
