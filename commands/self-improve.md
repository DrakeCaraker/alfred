# Self-Improve

Analyze accumulated feedback memories and session patterns, then propose promotions to CLAUDE.md rules or hooks. This is the on-demand promotion engine for the self-improvement loop.

## Promotion Ladder

```
feedback memory (soft, session-scoped)
    ↓ repeated 2+ times or high-impact
CLAUDE.md rule (durable, every-session)
    ↓ still violated after rule exists
hook/guard (enforced, blocks the action)
```

## Algorithm

### Step 1: Gather current state

Read these files to build a capabilities inventory:

1. `CLAUDE.md` — extract all non-negotiable rules, conventions, and workflow instructions
2. `.claude/settings.json` — extract all hook configurations and their purposes
3. List all skills: `ls .claude/commands/*.md`
4. Detect and list feedback memories:
   ```bash
   # Detect memory directory from current working directory
   project_key=$(pwd | sed 's|/|-|g; s|^-||')
   memory_dir="$HOME/.claude/projects/-${project_key}/memory"
   ls "$memory_dir"/feedback_*.md 2>/dev/null
   ```
5. Read each feedback memory file to understand the correction it captures

Summarize: "The project has N rules, M hooks, P skills, Q feedback memories."

### Step 2: Collect friction signals

In addition to feedback memories, check for friction patterns in git history:

```bash
# Fix-after-feat pattern (indicates something was wrong)
git log --oneline -50 | grep -E "^[a-f0-9]+ fix:" | head -10

# Reverts (indicates a bad change)
git log --oneline -50 --all --grep="revert" | head -5
```

Check for recent audit reports in `docs/audit/`, `docs/`, or the project root.

If a recent audit report exists, read its CRITICAL and HIGH findings.

### Step 3: Classify each feedback memory

For each feedback memory, determine its status:

| Classification | Criteria | Action |
|---|---|---|
| **Already a rule** | Keywords match an existing CLAUDE.md rule | Skip. Optionally suggest deleting the stale memory. |
| **Needs promotion** | Appears 2+ times as separate memories, OR describes a high-impact pattern | Propose adding as a CLAUDE.md rule |
| **Needs enforcement** | A matching CLAUDE.md rule exists but git history shows violations | Propose adding a hook/guard |
| **One-off** | Single occurrence, low impact | Keep as memory, don't promote |

To check if a memory matches an existing rule:
- Extract key phrases from the memory (e.g., "feature branch", "notebook outputs", "atomic commits")
- Search CLAUDE.md for those phrases
- If found, classify as "already a rule"

To check for repeated patterns:
- Group memories by theme (git workflow, testing, code style, etc.)
- If 2+ memories share a theme, that theme needs promotion

### Step 4: Propose changes

**Maximum 3 changes per run.** Each change is one atomic commit.

Change types (in priority order):
1. **Hook/guard** for rules that exist but are violated (highest value — prevents repeat friction)
2. **CLAUDE.md rule** for repeated feedback patterns (captures durable knowledge)
3. **Stale memory cleanup** for memories that duplicate existing rules (reduces noise)

For each proposed change:
1. Explain what the change is and why it's needed
2. Show the user the exact diff
3. Wait for user confirmation before writing

If more than 3 changes are identified, list the remainder in a "Deferred improvements" section for the next run.

### Step 5: Execute approved changes

1. Verify you are NOT on main: `git branch --show-current`
2. If on main, create branch: `git checkout -b chore/self-improve-$(date +%Y-%m-%d)`
3. For each approved change, make the edit and commit atomically
4. Run verification: Run the project's lint and typecheck commands (detect from Makefile, package.json, or pyproject.toml — same detection as /ci-fix Step 0)
5. Reset session counter: `echo 0 > .claude/.session-count`

### Step 6: Report

Show the user:
- What was changed (commit log)
- What was deferred (if any)
- Current feedback memory count (should be lower after cleanup)
- Offer to open a PR via `/pr`

## When nothing needs to change

If all feedback memories are already covered by existing rules and no friction patterns are found:

```
Self-improve: all feedback memories are covered by existing CLAUDE.md rules.
No new improvements needed. Session counter reset.

Current state: N rules, M hooks, P skills, Q feedback memories.
Consider deleting stale memories that duplicate rules: [list any]
```

## CLAUDE.md Integration

Add this to the Slash Commands section of CLAUDE.md:
```
- `/self-improve` — analyze feedback memories and propose promotions to CLAUDE.md rules or hooks (promotion ladder: memory → rule → hook)
```
