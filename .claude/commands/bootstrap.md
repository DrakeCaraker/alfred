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

## Step 1.5: GitHub Account Setup

Run the GitHub account setup check. This ensures the user has a GitHub account, is authenticated, and optionally has a repository — before we ask project questions.

Execute the full flow from `.claude/commands/github-account-setup.md`:

1. Explain what GitHub is and why they need it (in plain language)
2. Check if `gh` CLI is installed — guide installation if not
3. Check if already authenticated (`gh auth status`) — skip ahead if yes
4. If not authenticated, ask whether they have an account:
   - **Yes/Not sure**: Run `gh auth login --web -p https` and walk them through it
   - **No**: Guide them to https://github.com/signup with detailed instructions, then authenticate
5. Verify authentication succeeded
6. Note: Repository creation is deferred to Step 7.5 (after we know the project name)

**If GitHub setup fails or user declines**, do NOT block bootstrap. Set `github.skipped: true` in onboarding state and continue. The user can run `/github-account-setup` later.

## Step 2: Ask questions

Ask these questions one at a time, waiting for each answer before proceeding.

### Question 1: Role

```
What best describes your work?

1. ML / Data Science — model development, experiments, pipelines
2. Research — academic papers, statistical analysis, reproducibility
3. Business Analytics — dashboards, reports, SQL, ad-hoc analysis
4. Product Analytics — A/B tests, funnels, user behavior
5. BI Platform — data modeling, warehouse, dbt, data quality
6. General — software development, not domain-specific
7. Something else (describe)
```

For option 7: infer the closest persona from the user's description.

Map answers to persona files:
- 1 → `.claude/personas/ml-ds.md`
- 2 → `.claude/personas/research.md`
- 3 → `.claude/personas/business-analytics.md`
- 4 → `.claude/personas/product-analytics.md`
- 5 → `.claude/personas/platform-bi.md`
- 6 → `.claude/personas/general.md`

### Question 2: Coding comfort

```
How comfortable are you with coding?

1. Beginner — I'm learning. Mostly notebooks, spreadsheets, or copy-pasting code I find online.
2. Intermediate — I write code regularly and can save my work with git.
3. Advanced — I use branches, automated testing, and CI/CD pipelines routinely.
```

Map to coding_level: 1→"beginner", 2→"intermediate", 3→"advanced"
Map to code_complexity_level: 1→1, 2→2, 3→3

### Question 3: Project description

```
Describe your project in one sentence (this goes in your CLAUDE.md):
```

## Step 2b: Foundations primer (beginners only)

If `coding_level == "beginner"`, display this primer immediately after collecting answers and before generating any files. This is the user's first encounter with these concepts — define them in plain language before they appear in hooks, commands, or session output.

```
Before we set things up, here are 5 concepts you'll see as you work.
You don't need to memorize these — the system will remind you as they come up.

**Repository (repo)** — A folder that tracks every change you make to your files.
Think of it like a shared notebook where every edit is recorded with who made it and when.

**Commit** — A snapshot of your work at a specific moment, like pressing "Save" in a
video game. You can always go back to any previous save.

**Branch** — A separate copy of your project where you can try things without
affecting the original. Like duplicating a spreadsheet tab to test a formula.

**Main** — The "official" branch. You work on other branches, and only merge into
main when something is finished and tested.

**Hook** — A small script that runs automatically at certain moments (like when you
start a session or try to save). It's a safety net — you don't need to run it yourself.
```

Do NOT show this primer to intermediate or advanced users.

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
| /github-account-setup | Connect to GitHub or create an account |
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

## Step 6: Create starter directories

Read the Starter Artifacts section from the persona file. Create each directory with `mkdir -p`. Do NOT create files inside them — only the directory structure.

List the directories you created so the user can see what was set up.

## Step 7: Set up infrastructure

- If `.gitignore` doesn't exist or is minimal (fewer than 5 lines), create or extend it with persona-appropriate patterns (e.g., `__pycache__/`, `.env`, `*.pyc`, `.DS_Store`, `node_modules/`, etc.)
- If `.githooks/pre-push` doesn't exist, note: "Pre-push hook is available at `.githooks/pre-push`. Activate with: `git config core.hooksPath .githooks`"
- If `.claude/settings.json` exists but doesn't have hooks configured, note that hooks are available and can be configured

Do NOT overwrite existing `.gitignore` entries — only append missing patterns.

## Step 7.5: Create GitHub Repository (if authenticated)

If GitHub was set up in Step 1.5 (user is authenticated), now create a repository using the project name from Q3.

Follow Steps 6-7 from `.claude/commands/github-account-setup.md`:

1. Check if a remote already exists (`git remote -v`) — skip if yes
2. Ask if they want a repository created (explain what it is in plain language)
3. Use the project directory name as the default repo name
4. Default to **private** — ask for confirmation before making public
5. Create with: `gh repo create [name] --private --source=. --push`
6. Update onboarding state with `github.repo_url`

If GitHub was skipped in Step 1.5, remind the user:
```
Note: Your project is saved locally. To back it up online later, run /github-account-setup
```

## Step 8: Welcome message

Display a welcome message tailored to the coding level:

**Beginner**:
```
Alfred is set up! Here's what just happened:

- Created a file called CLAUDE.md — this tells the AI how to help you
  (what rules to follow, what to avoid, how your project is organized)
- Set up [N] folders for your project (like data/, analysis/, results/)
- Started tracking your learning progress (0/8 skills to learn)

Everything will be explained as you go. You have two options:

→ Run /teach — a short lesson on the first skill (takes ~2 minutes)
→ Just start working — tell me what you want to build, and I'll guide you

You can always ask "what does that mean?" if something is unclear.
```

**Intermediate**:
```
Alfred is set up for [persona] development.
- CLAUDE.md generated with domain-specific guardrails
- Onboarding tracking initialized (0/8 patterns)

Start working — patterns are explained as you encounter them.
Or run /teach to learn proactively, /status to see progress.
```

**Advanced**:
```
Alfred is set up for [persona] development.
- CLAUDE.md generated with domain-specific guardrails
- All 8 patterns in auto-mode (no explanations unless you ask)

Available: /status, /health-check, /self-improve, /teach <pattern>
```

## Rules

- Never overwrite an existing CLAUDE.md without asking the user first.
- Never skip the questions — they determine everything downstream.
- Always create the onboarding state file — /teach and /status depend on it.
- If git is not initialized, initialize it before doing anything else.
- Show what was created before finishing (files, directories, state).
- Ask questions one at a time. Wait for each answer before continuing.
- If a persona file is missing, fall back to general.md.
- Always use the exact JSON schema above for onboarding state — other commands parse it.
