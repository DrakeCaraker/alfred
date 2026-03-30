# Who Alfred Is For

Alfred adapts to how you work. Here's what it does for your specific role.

---

## Researchers & Academics

**Your pain:** You got a great result but can't reproduce it. Your analysis script works on your laptop but breaks on your advisor's. You forgot which version of the data produced Figure 3.

**What Alfred does:**
- Teaches you to trace every result back to its source code, data, and configuration
- Guards raw data as read-only — forces you to work on processed copies
- Versions your paper drafts (v1, v2, v3) so you never overwrite
- Blocks PII/PHI from being committed to git
- Uses your language: "Sign a lab notebook page" instead of "make a commit"

**Start:** Install Alfred, run `/alfred:bootstrap` (or `/bootstrap` if using Alfred as a standalone project), pick "Research."

> *Alfred's research persona is strictly better than static templates like [claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) — it teaches, adapts, and learns from your corrections.*

---

## ML / Data Science

**Your pain:** You ran an experiment but forgot the hyperparameters. You committed a 2GB model file. Your notebook works but the script doesn't. You can't tell which model produced which results.

**What Alfred does:**
- Teaches experiment checkpointing: save state so you can resume or compare
- Blocks `.pkl`, `.pt`, `.h5`, `.joblib` from git (configurable)
- Enforces fixed random seeds and pinned dependencies
- Teaches 4-way data splits (train/val/explain/test)
- Uses your language: "Checkpoint your experiment" instead of "commit your code"

**Start:** Install Alfred, run `/alfred:bootstrap` (or `/bootstrap` if using Alfred as a standalone project), pick "ML / Data Science."

---

## Business Analytics

**Your pain:** You hardcoded last quarter's dates and forgot. Your dashboard shows wrong numbers because a join exploded. The VP asks "where did this number come from?" and you're not sure.

**What Alfred does:**
- Teaches you to parameterize dates and validate join row counts
- Guards against overwriting production reports
- Traces every metric back to the query and data that produced it
- Uses your language: "Save a version of the spreadsheet" instead of "create a branch"

**Start:** Install Alfred, run `/alfred:bootstrap` (or `/bootstrap` if using Alfred as a standalone project), pick "Business Analytics."

---

## Product Analytics

**Your pain:** You peeked at A/B test results before the planned end date. Your funnel analysis mixed new and returning users. You can't remember which experiment had which control group.

**What Alfred does:**
- Teaches experiment discipline: don't peek, define metrics upfront
- Enforces segment definitions and cohort boundaries
- Traces experiment results to configurations and code
- Uses your language: "Run a test on a small group before rolling out" instead of "create a feature branch"

**Start:** Install Alfred, run `/alfred:bootstrap` (or `/bootstrap` if using Alfred as a standalone project), pick "Product Analytics."

---

## Data Platform / BI Engineering

**Your pain:** A pipeline silently produced wrong data for a week. You dropped a production table during testing. Your dbt model works locally but fails in CI.

**What Alfred does:**
- Teaches idempotent pipeline design and failure mode analysis
- Guards against destructive operations on production
- Enforces SLA-aware data freshness monitoring
- Uses your language: "Take a snapshot before making changes" instead of "commit before refactoring"

**Start:** Install Alfred, run `/alfred:bootstrap` (or `/bootstrap` if using Alfred as a standalone project), pick "BI Platform."

---

## General Software Development

**Your pain:** You pushed directly to main and broke the build. You refactored three files at once and can't tell which change caused the bug. You lost work because you forgot to commit.

**What Alfred does:**
- Teaches atomic changes: one change, one test, one commit
- Blocks pushes to main, enforces branch-based workflow
- Auto-formats on every edit, auto-fixes CI failures
- Uses your language: "Save your work" instead of "stage and commit to a feature branch"

**Start:** Install Alfred, run `/alfred:bootstrap` (or `/bootstrap` if using Alfred as a standalone project), pick "General."

---

## Writers & Editors

**Your pain:** Your folder has `FINAL_v3_REAL_FINAL.docx`. You can't tell which version the client approved. You lost a paragraph during revisions and don't know when. Your export formatting breaks every time.

**What Alfred does:**
- Teaches version control for prose — seal draft versions so you can always go back
- Guards approved drafts from being overwritten
- Tracks why each revision was made (not just what changed)
- Enforces style consistency with Vale/proselint
- Automates export with pandoc — same formatting every time
- Uses your language: "Seal a draft" instead of "tag a release"

**Start:** Install Alfred, run `/alfred:bootstrap` (or `/bootstrap` if using Alfred as a standalone project), pick "Writer / Editor."

---

## For Teams

Alfred is per-project but team-aware. Each member runs `/bootstrap` with their own persona and coding level. Guardrails are shared (via CLAUDE.md in the repo); explanations are personalized.

**The flywheel:** One person corrects Alfred → it becomes a feedback memory → `/self-improve` promotes it to a team rule in CLAUDE.md → the whole team benefits. One person's discovery becomes everyone's guardrail.

**Collective learning:** Anonymized corrections are encrypted and shared. When 3+ team members hit the same correction, it becomes a recommended rule. Zero setup for contributors.

---

## Install

```
/plugin marketplace add DrakeCaraker/alfred
/plugin install alfred@alfred-marketplace
/reload-plugins
```

Then run `/alfred:bootstrap` in any project.
