# Vet This Plan

Pressure-test the current plan, proposal, or implementation strategy before committing to it.

## Process

Work through each step methodically. Use tools to verify — don't just reason from memory.

### 1. Extract claims, assumptions, and decisions

Read the plan (from conversation context, plan mode, or the user's description) and list:
- **Claims**: statements of fact ("this file exports X", "the API returns Y")
- **Assumptions**: things taken as true but not yet verified ("this won't break Z", "the existing tests cover this")
- **Decisions**: choices made ("use approach A instead of B", "put this in file X")

### 2. Verify claims against actual code

For each claim, use Read/Grep/Glob to check it against the codebase. Report:
- ✅ Verified — matches reality
- ❌ Wrong — actual state differs (explain how)
- ⚠️ Unverifiable — can't confirm from code alone

### 3. Challenge each decision

For each decision in the plan:
- What's the alternative that was implicitly rejected?
- Is there a reason the alternative is actually better?
- What's the cost of being wrong about this choice?

### 4. Find what's missing

- What failure modes aren't addressed?
- What edge cases are ignored?
- Are there dependencies or ordering constraints not mentioned?
- What would break if the plan's assumptions are wrong?
- For academic work: are there statistical validity concerns, reproducibility gaps, or missing controls?

### 5. Skeptical reviewer pass

Ask: "If a careful reviewer (or a thesis committee member) read this plan, what would they push back on?" List the top 3 objections.

### 6. Revise

Produce a revised plan that:
- Fixes any wrong claims
- Addresses the strongest objections
- Makes remaining uncertainties explicit (marked with ⚠️)
- Preserves what was already solid

### 7. Verdict

End with one of:
- **Ready** — plan is solid, proceed with confidence
- **Ready with caveats** — proceed, but watch the flagged items
- **Needs rework** — specific issues must be resolved first

## Output format

```
## Vet Report

### Claims & Assumptions
| # | Statement | Type | Status |
|---|-----------|------|--------|
| 1 | ...       | Claim | ✅/❌/⚠️ |

### Decisions Challenged
- **Decision**: ...
  - Alternative: ...
  - Risk if wrong: ...

### Missing / Failure Modes
- ...

### Skeptical Reviewer Objections
1. ...
2. ...
3. ...

### Revised Plan
(updated plan here)

### Verdict: Ready / Ready with caveats / Needs rework
(summary)
```
