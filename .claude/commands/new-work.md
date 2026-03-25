# New Work

Use this at the start of any session that involves code changes. Enforces branch hygiene and scopes the session before touching any files.

## Steps

1. **Check current state**
   ```bash
   git branch --show-current
   git status
   git log --oneline -3
   ```

2. **Ensure main is up to date**
   ```bash
   git checkout main && git pull origin main
   ```

3. **Ask the user** (if not already provided):
   - What is the purpose of this work? (one sentence)
   - Which type fits: `feat/`, `fix/`, `perf/`, `chore/`, `results/`?

4. **Create a descriptive branch**
   ```bash
   git checkout -b <type>/<topic>
   ```
   Examples: `feat/add-variance-decomp-plot`, `fix/california-checkpoint-resume`, `chore/update-deps`

5. **Write a bounded task list as a numbered checklist in the conversation, or use TodoWrite if available** — list every discrete step needed to complete the work. This is the most important step: it creates a checkpoint if the session ends early and prevents scope creep.

6. **Confirm scope with the user** before starting implementation:
   - Show the task list
   - Flag any tasks that look out of scope or belong on a separate branch
   - Ask: "Does this look right, or should we split anything off?"

## Rules

- Never skip step 4 (branch creation) even for "small" changes
- Never skip step 5 (task list) — this is what prevents sessions from ending mid-implementation
- If you realize mid-session that a task belongs on a different branch, stop and flag it rather than mixing concerns
- The branch name should be readable as a one-line description of the PR that will result from it
