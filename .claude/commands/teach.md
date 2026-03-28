# Alfred Teach — Progressive Habit Engine

Teach development habits one at a time, using domain-specific analogies. Each lesson has 4 phases: Context, Demo, Install, Verify.

## Usage

- `/teach` — deliver the next ungraduated habit (in order 1→8)
- `/teach <name>` — deliver a specific habit (e.g., `/teach save-points`)
- `/teach all` — show all 8 habits with graduation status

Habit names (for direct access):
`context-before-action`, `scope-before-work`, `save-points`, `safe-experimentation`,
`one-change-one-test`, `automated-recovery`, `provenance`, `self-improvement`

## Step 1: Load state

1. Read `.claude/.onboarding-state.json`
   - If missing: "Run /bootstrap first to set up your persona."
2. Read the persona file from `.claude/personas/<persona>.md`
   - Extract the Analogy Map section (all 8 pattern analogies)
   - Extract the Error Context section (for contextual examples)
3. Determine which pattern to teach:
   - If `/teach all`: skip to Step 5 (show progress table)
   - If `/teach <name>`: teach that specific pattern regardless of graduation
   - If `/teach` (no args): find the first pattern where `graduated == false`, in this order:
     1. context_before_action
     2. scope_before_work
     3. save_points
     4. safe_experimentation
     5. one_change_one_test
     6. automated_recovery
     7. provenance
     8. self_improvement
   - If all habits are graduated: "All 8 habits graduated! Run /status to see your progress, or /teach <name> to revisit any habit."

## Step 2: Deliver the lesson (4 phases)

### Beginner adaptation

If `coding_level == "beginner"` in onboarding state, apply these rules throughout ALL phases:

1. **Define terms before using them.** The first time you use a technical word (commit, branch, staging, diff, hook, remote, merge), give a one-sentence plain-language definition in parentheses. Example: "This creates a commit (a saved snapshot of your work, like pressing Save in a video game)."
2. **Show, don't tell.** In Phase B, run the actual commands and walk through the output line by line. Don't just describe what would happen.
3. **Use simplified verification prompts.** See the beginner alternatives in the Phase D table below.
4. **Reassure.** End each phase with: "You can always ask 'what does that mean?' if anything is unclear."

### Phase A — CONTEXT ("Why this matters to YOUR work")

Use the persona's analogy for this pattern. Frame it in the user's domain language.

**For beginners**: Before the analogy, add one sentence that names the *problem* this pattern prevents, in concrete terms. Example: "Without this, you might lose an hour of work because you forgot to save — or accidentally break something that was working."

Format:
```
## Habit [N]: [Name]

[For beginners only: one sentence naming the concrete problem this prevents]

[Persona analogy from the Analogy Map — the full text, not abbreviated]

In practice, this means: [one sentence connecting the analogy to what Claude Code does]

**Prompting tip:** [One tip from the persona's Prompting Guide section (Section 10) that's most relevant to this habit. Choose the tip that maps to this habit's concern.]
```

### Phase B — DEMO ("Watch me do it on YOUR project")

Show the actual command or feature in action. Use the user's real project files, not hypothetical examples.

**Per-pattern demo content:**

| # | Pattern | What to demonstrate |
|---|---------|-------------------|
| 1 | context_before_action | Run the session-start hook output. Walk through each section (git status, branch, drift, onboarding progress). Explain what each tells you. |
| 2 | scope_before_work | Walk through `/new-work`: check state, ask scope, create branch, write task list. Show how it prevents half-finished sessions. |
| 3 | save_points | Walk through `/commit`: show safety checks (large files, binaries), generate commit message, show the 3-commit history. Explain checkpointing. |
| 4 | safe_experimentation | Create an actual experimental branch from current state. Show how to make a change, then discard the branch if it doesn't work. Show `git branch -D`. |
| 5 | one_change_one_test | Walk through `/safe-refactor` concept: characterization tests → one change → test → commit or rollback. Don't run a full refactor — just explain the cycle. |
| 6 | automated_recovery | Walk through `/ci-fix` concept: show the detect-fix-test loop. If possible, introduce a small lint error and show the fix loop in action. |
| 7 | provenance | Walk through `/experiment-summary` concept: show how results are inventoried with source, timestamp, and config. Explain why traceability matters. |
| 8 | self_improvement | Walk through `/self-improve` concept: show the promotion ladder (feedback memory → CLAUDE.md rule → hook). Check if any feedback memories exist and show what would be promoted. |

### Phase C — INSTALL ("This is now automated")

Confirm the corresponding command/hook is active:
```
This habit is now part of your workflow:
- Command: [/command-name] — [what it does]
- Hook: [hook name if applicable] — [when it runs]

You don't need to remember to do this manually. The system handles it.
```

### Phase D — VERIFY ("Try it yourself")

Give the user a specific, concrete thing to try:

| # | Pattern | Practice prompt |
|---|---------|----------------|
| 1 | context_before_action | "Start a new Claude Code session and read the warm-up output. What branch are you on?" |
| 2 | scope_before_work | "Run /new-work and scope a small task. Create a branch and task list." |
| 3 | save_points | "Make a small change to any file, stage it, and run /commit." |
| 4 | safe_experimentation | "Create a branch called `experiment/test`, make a change, then delete the branch with `git branch -D experiment/test`." |
| 5 | one_change_one_test | "Pick a small function and describe what /safe-refactor would do to it (don't run it yet if the project is new)." |
| 6 | automated_recovery | "Intentionally add a lint error (e.g., an unused import) and run /ci-fix to watch it fix itself." |
| 7 | provenance | "Run /experiment-summary on any result files in your project (or note there are none yet)." |
| 8 | self_improvement | "Run /self-improve to see if any feedback has accumulated (it's fine if there's nothing yet)." |

**Beginner alternative prompts** — use these instead when `coding_level == "beginner"`:

| # | Pattern | Beginner practice prompt |
|---|---------|------------------------|
| 1 | context_before_action | "Look at the warm-up message that appeared when this session started. Can you tell me: are there any unsaved changes? Don't worry about getting it exactly right." |
| 2 | scope_before_work | "Think of one small thing you'd like to add or change in your project. Tell me what it is, and I'll walk you through /new-work together." |
| 3 | save_points | "Let's save your work together. I'll walk you through /commit step by step — just follow along." |
| 4 | safe_experimentation | "I'll create a test workspace, make a small change, then throw it away. Watch what happens — nothing breaks." |
| 5 | one_change_one_test | "Let's look at one piece of your code together. I'll describe what /safe-refactor would check before changing it." |
| 6 | automated_recovery | "I'll introduce a tiny mistake on purpose, then we'll watch /ci-fix find and fix it automatically." |
| 7 | provenance | "Let's look at your results/ folder together. I'll show you how /experiment-summary connects each result to the code that created it." |
| 8 | self_improvement | "Let's check if the system has learned anything from our conversations. Run /self-improve and I'll explain what it finds." |

After the user completes the practice (or says they understand, or says "skip"):
- Proceed to Step 3

## Step 3: Update graduation state

Read `.claude/.onboarding-state.json` again (it may have changed during the demo).

Update the pattern entry:
```json
{
  "seen": <previous_seen + 1>,
  "graduated": <true if seen >= 3 AND last_asked_why == false>,
  "last_asked_why": false
}
```

**Immediate graduation**: If the user says "I know this", "skip", "I get it", or "just do it" at any point during the lesson, set `graduated: true` immediately regardless of `seen` count.

**"Why?" tracking**: If the user asks "why?" or "why do we do this?" during the lesson, set `last_asked_why: true`. This resets graduation progress — they need to see it 3 more times without asking why.

Write the updated state back to `.claude/.onboarding-state.json`.

## Step 4: Graduation message

If the habit was just graduated (either by seen count or immediate graduation):

```
Habit [N] graduated: [Name] ✓

From now on, [command/hook] will work silently in auto-mode.
You won't see explanations for this habit unless you run /teach [name] again.

[N/8 habits graduated] — [Level name: Beginner (0-3), Practitioner (4-6), Proficient (7-8)]
```

If this is the user's 3rd or 4th graduation, add:
"Tip: There's a full prompting guide in docs/PROMPTING_GUIDE.md if you want to level up faster."
Only show this once — check if `.claude/.prompting-guide-shown` exists. If not, create it after showing.

If the user just graduated ALL 8 habits:
```
All 8 habits graduated! You've reached Proficient level.

The system now operates in full auto-mode — no explanations unless you ask.
Run /status anytime to see your progress, or /teach <name> to revisit.
```

If the habit was NOT graduated:
```
Habit [N]: [Name] — seen [X] time(s). [3-X] more to graduate.
Run /teach anytime to continue, or the system will explain as habits come up naturally.
```

## Step 5: Show all (for `/teach all`)

Display a progress table:

```
Alfred Onboarding — [Persona Name] ([coding level])

  # | Habit                    | Status          | Command
----|--------------------------|-----------------|------------------
  1 | Context before action    | ✓ graduated     | (session-start hook)
  2 | Scope before work        | ○ seen 2x       | /new-work
  3 | Save points              | · not started   | /commit
  4 | Safe experimentation     | · not started   | /new-work (branching)
  5 | One change, one test     | · not started   | /safe-refactor
  6 | Automated recovery       | · not started   | /ci-fix
  7 | Provenance               | · not started   | /experiment-summary
  8 | Self-improvement         | · not started   | /self-improve

Progress: 1/8 graduated | Level: Beginner
Next: Run /teach to learn "Scope before work" (habit #2)
```

## Habit-to-command reference

| # | Key | Friendly name | Command | Hook |
|---|-------------|--------------|---------|------|
| 1 | context_before_action | Context before action | — | session-start.sh |
| 2 | scope_before_work | Scope before work | /new-work | — |
| 3 | save_points | Save points | /commit | — |
| 4 | safe_experimentation | Safe experimentation | /new-work | — |
| 5 | one_change_one_test | One change, one test | /safe-refactor | — |
| 6 | automated_recovery | Automated recovery | /ci-fix | — |
| 7 | provenance | Provenance | /experiment-summary | — |
| 8 | self_improvement | Self-improvement | /self-improve | — |

## Habit-to-prompting-tip mapping

When teaching each habit, include the most relevant prompting tip from the persona's Prompting Guide (Section 10). Use this mapping to select the right tip:

| # | Habit | Tip theme |
|---|-------|-----------|
| 1 | Context before action | "Ask for deeper analysis" / "Challenge results" — teach users to request context |
| 2 | Scope before work | "State constraints upfront" / "Frame as hypotheses" — teach users to scope requests |
| 3 | Save points | "Scope experiments explicitly" / "Define dimensions upfront" — teach users to make atomic requests |
| 4 | Safe experimentation | "Ask for trade-offs" / "Give me 2-3 approaches" — teach users to explore before committing |
| 5 | One change, one test | "Challenge results" / "Request sanity checks" — teach users to verify each step |
| 6 | Automated recovery | "Use depth signals" / "Request failure modes" — teach users to ask for robustness |
| 7 | Provenance | "Demand provenance" / "Request methodology review" — teach users to trace results |
| 8 | Self-improvement | "Challenge before merging" / "Vet this" — teach users to audit their own work |

Read the persona's Section 10 and select the specific tip text that best matches the habit being taught. The tip should feel like natural advice for the habit, not a separate topic.

## Rules
- Always read onboarding state before teaching
- Always update onboarding state after teaching
- Never skip Phase A (Context) — the analogy is what makes it stick
- Phase B (Demo) should use real project files when possible, but gracefully handle empty projects
- If the user interrupts with "I know" or "skip", respect it and graduate immediately
- If the user asks "why?", respect it and reset graduation progress for that pattern
- Teaching a graduated pattern replays the full lesson but doesn't change graduation status
