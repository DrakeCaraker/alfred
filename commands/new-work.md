# New Work

Use this at the start of any session that involves code changes. Enforces branch hygiene and scopes the session before touching any files.

## Beginner mode

If `coding_level == "beginner"` in `.claude/.onboarding-state.json`, adapt the workflow:

**At the start**, explain what's about to happen:
```
Before we start coding, let's set up a safe workspace. This takes 30 seconds
and protects your existing work:

1. I'll check what state your project is in
2. I'll create a separate workspace (called a "branch") for this task
3. We'll write a short plan so we know when we're done

This way, if anything goes wrong, your original project is untouched.
```

**For Step 3**, simplify the question — don't ask about branch types:
```
What do you want to work on? Describe it in one sentence.
(Example: "Add a chart showing monthly trends" or "Fix the broken login page")
```
Then infer the branch type automatically (feat/ for new things, fix/ for repairs, chore/ for cleanup).

**For Step 5**, provide a template:
```
Here's our plan. Each step is small enough to save (commit) individually:

1. [First concrete step]
2. [Second concrete step]
3. [Third concrete step]
4. Test that everything works
5. Save and finish

Does this look right? Anything missing?
```

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
   (For beginners: infer the type automatically — see Beginner mode above)

4. **Create a descriptive branch**
   ```bash
   git checkout -b <type>/<topic>
   ```
   Examples: `feat/add-variance-decomp-plot`, `fix/california-checkpoint-resume`, `chore/update-deps`

5. **Write a bounded task list as a numbered checklist in the conversation, or use TodoWrite if available** — list every discrete step needed to complete the work. This is the most important step: it creates a checkpoint if the session ends early and prevents scope creep.
   (For beginners: use the template from Beginner mode above)

6. **Confirm scope with the user** before starting implementation:
   - Show the task list
   - Flag any tasks that look out of scope or belong on a separate branch
   - Ask: "Does this look right, or should we split anything off?"

## Rules

- Never skip step 4 (branch creation) even for "small" changes
- Never skip step 5 (task list) — this is what prevents sessions from ending mid-implementation
- If you realize mid-session that a task belongs on a different branch, stop and flag it rather than mixing concerns
- The branch name should be readable as a one-line description of the PR that will result from it
