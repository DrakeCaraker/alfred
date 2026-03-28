# Prompting Guide — How to Get the Most from Claude Code

This guide distills effective prompting patterns observed in real development sessions. Each pattern is domain-general; persona-specific examples follow.

## Core Principles

### 1. State What, Not How
Describe the outcome you want, not the implementation. Let Claude choose the approach.
- Instead of: "Write a SQL query joining users and events"
- Try: "What's driving the drop in Q3 retention?"

### 2. Scope Before You Start
State constraints, requirements, and success criteria upfront. This prevents rework.
- "Must work with PostgreSQL 14 and our existing auth middleware"
- "Target AUC-ROC > 0.85, evaluate on holdout set"
- "This dashboard is for the VP of Marketing — weekly KPIs only"

### 3. Ask for Alternatives
Before committing to an approach, ask for options with trade-offs.
- "Give me 2-3 approaches with pros and cons"
- "What are the trade-offs between X and Y?"

### 4. Use Depth Signals
Control how deeply Claude analyzes before acting.
- **Default**: Normal response — good for straightforward tasks
- **"Think about this carefully"**: Claude considers edge cases, alternatives, failure modes
- **"Vet this"**: Full pressure-test — checks assumptions, identifies risks, flags uncertainties
- **"Audit this"**: Post-implementation review — security, quality, integration issues

### 5. Challenge Before Merging
Always audit completed work before considering it done.
- "What could go wrong with this approach?"
- "What did I miss?"
- "Run /audit before we open the PR"

### 6. Let Corrections Compound
When Claude gets something wrong, correct it explicitly. Alfred's self-improvement loop promotes corrections into permanent rules and automated enforcement.
- "No, don't do X" → gets saved as a feedback memory
- Repeated corrections → promoted to CLAUDE.md rules
- Persistent violations → promoted to automated hooks/guards

## Prompting by Habit

Each of Alfred's 8 habits has a corresponding prompting pattern:

| Habit | Prompting Pattern | Example |
|-------|-------------------|---------|
| Context before action | Ask for analysis before code | "What's the current state of X before we change it?" |
| Scope before work | State constraints upfront | "This needs to work with Y and handle Z edge cases" |
| Save points | Make atomic requests | "Change only X, keep everything else the same" |
| Safe experimentation | Ask for alternatives | "Give me 2-3 approaches before we pick one" |
| One change, one test | Verify each step | "Does this look right? What could break?" |
| Automated recovery | Request robustness | "What happens if this fails? Add appropriate error handling" |
| Provenance | Demand traceability | "Show me the pipeline from raw data to this result" |
| Self-improvement | Audit completed work | "Vet this plan" / "Audit the implementation" |

## Prompting by Domain

### ML / Data Science
- State the hypothesis before asking for code
- Specify metrics and thresholds (AUC-ROC > 0.85, p < 0.05)
- Request reproducibility (seed=42, log hyperparameters)
- Ask "Could this be data leakage?" when results look too good
- Scope experiments: "Change only the learning rate"

### Academic Research
- Specify statistical tests and significance levels upfront
- State the research question, not the implementation
- Always ask for effect sizes and confidence intervals
- Request methodology review: "What threats to validity am I missing?"
- Demand complete provenance from raw data to figures

### Business Analytics
- Lead with the business question, not the query
- Specify the audience and their decision context
- Ask for assumptions to be stated explicitly
- Request sanity checks against prior periods and benchmarks
- Ask for the narrative: "What should a stakeholder take from this?"

### Product Analytics
- Frame requests as testable hypotheses
- Specify the full funnel you're analyzing
- Request segment breakdowns (new/returning, mobile/desktop)
- Ask for statistical power calculations before A/B tests
- Challenge correlation vs causation

### Data Platform / BI
- Describe data contracts, not implementations
- Specify scale and performance requirements
- Ask for idempotency and failure mode analysis
- Specify SLAs for data freshness
- Ask "How would we detect silent data quality issues?"

### General Software Development
- Describe user-facing behavior, not implementation details
- State constraints before starting (existing stack, compatibility)
- Ask for trade-offs between approaches
- Request edge case analysis (empty input, concurrent users, network failure)
- Use depth signals: "think carefully" for complex work, "just do it" for obvious tasks

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| "Write a function that does X" | "I need X behavior. What's the best approach?" |
| Accept the first answer | "What could go wrong with this?" |
| Give implementation instructions | State the outcome and constraints |
| Skip the audit | "Vet this before we merge" |
| Assume it's right | "Sanity check: does this number make sense?" |
| Over-specify | State constraints, let Claude choose implementation |

## Quick Reference

```
Before starting work:    "What's the current state?" (Habit 1)
Before coding:           "Here are the constraints: ..." (Habit 2)
After each change:       "Does this look right?" (Habit 5)
Before committing:       /commit (Habit 3, runs make check)
Before PR:               /audit (Habit 8)
When something's wrong:  Correct explicitly — it compounds (Habit 8)
```
