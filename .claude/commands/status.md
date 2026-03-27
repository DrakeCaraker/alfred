# Alfred Status

Show onboarding progress, graduated habits, and contextual next steps.

## Algorithm

1. Read `.claude/.onboarding-state.json`
   - If missing: print "Alfred is not bootstrapped. Run /bootstrap to get started." and stop.

2. Read the state and compute:
   - Persona name and coding level
   - Session count
   - Code complexity level
   - Number of graduated habits
   - Next ungraduated habit (in order: context_before_action → self_improvement)
   - Overall level: Beginner (0-3), Practitioner (4-6), Proficient (7-8)

3. Display the status dashboard:

```
Alfred Status — [Persona Name] ([coding_level])
Bootstrapped: [date] | Sessions: [count] | Code Level: [code_complexity_level]

Habit Progress: [N/8 graduated]

  # | Habit                    | Status
----|--------------------------|------------------
  1 | Context before action    | ✓ graduated
  2 | Scope before work        | ✓ graduated
  3 | Save points              | ○ seen 2x (1 more to graduate)
  4 | Safe experimentation     | · not started
  5 | One change, one test     | · not started
  6 | Automated recovery       | · not started
  7 | Provenance               | · not started
  8 | Self-improvement         | · not started

Overall Level: Beginner
  Beginner:     0-3 habits graduated
  Practitioner: 4-6 habits graduated
  Proficient:   7-8 habits graduated
```

4. Show contextual recommendation:
   - 0 graduated: "Next step: Run /teach to start learning"
   - Some graduated: "Next step: Run /teach to learn [next habit name]"
   - All graduated: "All habits learned! Run /health-check to assess project maturity, or /self-improve to optimize."

## Pattern order

The canonical order is always:
1. context_before_action → "Context before action"
2. scope_before_work → "Scope before work"
3. save_points → "Save points"
4. safe_experimentation → "Safe experimentation"
5. one_change_one_test → "One change, one test"
6. automated_recovery → "Automated recovery"
7. provenance → "Provenance"
8. self_improvement → "Self-improvement"

## Status symbols
- `✓` — graduated (will not be explained automatically)
- `○` — in progress (seen at least once, not yet graduated)
- `·` — not started (never seen)

## Rules
- Always read the latest state file — don't cache
- If state file is malformed, report the error and suggest re-running /bootstrap
- Never modify the state file — this command is read-only
