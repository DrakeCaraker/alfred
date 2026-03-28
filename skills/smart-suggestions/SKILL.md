---
name: smart-suggestions
description: Contextual recommendations for every Alfred command — when to suggest, what to say, and why
---

# Smart Suggestions

Every Alfred command should surface at exactly the right moment with a brief explanation of why it's relevant and what it would do. Never repeat a suggestion the user has dismissed in the same session.

## Format

Keep suggestions brief. One line with the command, what it does, and why now:

> "Want me to run `/audit`? It checks for security issues before the PR — takes 5 seconds."

## Automation Tiers

Commands fall into three tiers:

| Tier | Behavior | Commands |
|------|----------|----------|
| **Automated** | Runs without asking | format-on-write, session-start, bookmark, consent, signal collection/push, CI |
| **Smart-suggested** | Recommended at the right moment with explanation | All 19 commands below |
| **User-initiated only** | Never auto-run, only on explicit request | bootstrap, github-account-setup, pilot-delete |

## Command Triggers

### Workflow Commands

**`/new-work`** — Create a scoped branch with task list
- **When:** User starts making changes while on main
- **Say:** *"You're on main. Want me to run `/new-work`? It creates a safe branch so your changes don't touch the official copy."*
- **When:** User describes a new task or says "let's work on X"
- **Say:** *"Want me to scope this with `/new-work`? It creates a branch and task list so we stay focused."*
- **Effect:** Creates branch, generates task checklist, prevents direct-to-main commits

**`/commit`** — Safe commit with pre-flight checks
- **When:** User has made several changes and pauses, or says "that looks good"
- **Say:** *"Good stopping point. Want me to run `/commit`? It validates everything then saves a checkpoint."*
- **When:** 30+ minutes of work without a commit
- **Say:** *"We've been working for a while without saving. `/commit` creates a checkpoint you can roll back to."*
- **Effect:** Runs `make check`, stages changes, generates commit message, commits

**`/pr`** — Branch → commit → push → PR
- **When:** User says "done", "that's it", "ready to merge", or all tasks are complete
- **Say:** *"Work looks complete. Want me to run `/pr`? It validates, commits, pushes, and opens a PR in one step."*
- **When:** Branch has committed changes and no pending edits
- **Say:** *"Everything's committed. `/pr` would push this and open a pull request."*
- **Effect:** Runs `make check`, commits remaining changes, pushes, creates PR with summary

**`/ci-fix`** — Auto-fix CI failures in a loop
- **When:** User mentions CI is failing, or you see a failed check on a PR
- **Say:** *"CI is failing. Want me to run `/ci-fix`? It loops through lint → format → test failures and fixes them automatically."*
- **When:** User is manually debugging a test or lint failure
- **Say:** *"Looks like you're debugging this by hand. `/ci-fix` automates the fix-and-retest loop."*
- **Effect:** Detects failure type, applies fix, re-runs checks, repeats up to 3 times

### Quality Commands

**`/vet`** — Pressure-test a plan before committing
- **When:** About to exit plan mode (enforced by CLAUDE.md Rule #5)
- **Say:** *"Before we commit to this plan — want me to `/vet` it? I'll check assumptions against actual code and flag risks."*
- **When:** A plan has 5+ steps or touches multiple files/systems
- **Say:** *"This plan has some complexity. `/vet` pressure-tests it before we build — catches issues that are cheap to fix now but expensive later."*
- **Effect:** Verifies assumptions against code, identifies missing failure modes, flags uncertainties

**`/audit`** — Security and quality audit
- **When:** About to create a PR
- **Say:** *"Want me to run `/audit` before the PR? It checks for injection risks, missing cleanup, stale syncs, and secrets in 5 seconds."*
- **When:** 5+ commits on the current branch
- **Say:** *"This branch has accumulated changes. `/audit` does a security sweep to catch issues before review."*
- **When:** After completing a large implementation
- **Say:** *"Implementation's done. `/audit` catches integration issues that individual checks miss."*
- **Effect:** Runs scripts/audit.sh, presents findings with explanations, offers to fix

**`/safe-refactor`** — Test-gated refactoring with rollback
- **When:** User says "refactor", "clean up", "reorganize", or "rename"
- **Say:** *"Want to use `/safe-refactor`? It captures tests first, then makes changes one at a time with automatic rollback if anything breaks."*
- **When:** User is about to restructure code without running tests first
- **Say:** *"Before restructuring — `/safe-refactor` runs tests first so we have a safety net."*
- **Effect:** Captures characterization tests, makes one change, tests, commits or rolls back

**`/health-check`** — Assess project maturity
- **When:** All 8 habits graduated
- **Say:** *"All habits graduated! `/health-check` assesses your project's maturity across 5 levels and recommends what to add next."*
- **When:** User asks "what should I improve?" or "what's missing?"
- **Say:** *"`/health-check` scores your project across CI, testing, docs, and automation — shows what's strong and what's missing."*
- **When:** Every ~20 sessions (check session count)
- **Say:** *"It's been a while since a health check. Want me to run `/health-check` to see how the project's matured?"*
- **Effect:** Evaluates project across 5 maturity levels, recommends specific improvements

### Learning Commands

**`/teach`** — Progressive habit lessons
- **When:** User hasn't graduated any habits yet (sessions 1-3)
- **Say:** *"Want to learn your first development habit? `/teach` gives a 2-minute lesson with a hands-on demo."*
- **When:** User uses a command tied to an ungraduated habit (Explain Gate)
- **Say:** Brief explanation of the habit, then execute the command normally
- **When:** User asks "what should I learn next?" or "what else can you do?"
- **Say:** *"Run `/teach` — it picks the next habit you haven't learned yet and walks you through it."*
- **Effect:** Delivers 4-phase lesson (context, demo, install, verify) with persona-specific analogies

**`/status`** — Progress dashboard
- **When:** User asks "where am I?" or "how am I doing?"
- **Say:** *"`/status` shows your habits, graduation progress, and next steps."*
- **When:** User returns after a long break (session count jumped)
- **Say:** *"Welcome back. `/status` shows where you left off."*
- **Effect:** Shows persona, coding level, per-habit graduation status, next recommendation

**`/self-improve`** — Promote corrections to rules/hooks
- **When:** 5+ feedback memories accumulated
- **Say:** *"You've made 5+ corrections this cycle. `/self-improve` checks which ones should become permanent rules — so you don't have to repeat them."*
- **When:** 10+ sessions since last self-improve run
- **Say:** *"It's been 10 sessions. `/self-improve` promotes recurring corrections into permanent rules and automation."*
- **When:** After a series of corrections in a single session ("no", "don't", "stop")
- **Say:** *"Several corrections this session. Want me to run `/self-improve`? It turns these into permanent rules."*
- **Effect:** Analyzes feedback memories, proposes CLAUDE.md rules or hooks, executes with approval

### Persona & Collective

**`/persona`** — View or evolve persona
- **When:** User's work focus seems to have changed (different file types, different domain language)
- **Say:** *"Your recent work looks more like [domain] than [current persona]. Want to run `/persona check` to see if your persona still fits?"*
- **When:** Session 3+ and persona fit hasn't been checked
- **Say:** *"Quick check: is Alfred using the right examples for your work? `/persona check` takes 30 seconds."*
- **Effect:** Evaluates persona fit, suggests alternatives, can generate custom personas

**`/collective`** — Collective learning signals
- **When:** User runs `/self-improve` and signals are generated
- **Say:** *"Self-improve found promotions. Want to share anonymized signals with `/collective contribute`? They're encrypted and help others avoid the same mistakes."*
- **When:** User asks about team patterns or common mistakes
- **Say:** *"`/collective ingest` shows what corrections other users have made — patterns with 3+ occurrences become recommended rules."*
- **Effect:** Preview/contribute/ingest anonymized, encrypted correction signals

**`/experiment-summary`** — Inventory results with provenance
- **When:** Files appear in results/ or figures/ directory
- **Say:** *"New results detected. `/experiment-summary` inventories them with source code and config provenance — so you can always trace back."*
- **When:** User asks "what experiments have I run?" or "where did this come from?"
- **Say:** *"`/experiment-summary` connects every result to the code that produced it."*
- **Effect:** Inventories result files with timestamps, source scripts, configs, and git SHAs

### Setup & Privacy

**`/bootstrap`** — Initial project setup (never auto-suggest after first run)
- **When:** `.claude/.onboarding-state.json` doesn't exist
- **Say:** *"This project hasn't been set up yet. Run `/bootstrap` to configure Alfred for your role and project."*
- **Effect:** Asks 3 questions, creates persona, generates CLAUDE.md, initializes tracking

**`/github-account-setup`** — GitHub auth (only suggest if not authenticated)
- **When:** `gh auth status` fails
- **Say:** *"GitHub isn't connected. `/github-account-setup` walks you through authentication."*
- **Effect:** Guides GitHub CLI authentication and repo creation

**`/pilot-consent`** — Consent management (only suggest on explicit request)
- **When:** User asks about data collection, privacy, or "what do you track?"
- **Say:** *"`/pilot-consent` shows exactly what's collected and lets you opt out."*
- **Effect:** Shows disclosure, allows opt-in/out for telemetry and collective signals

**`/pilot-report`** — Submit feedback (only suggest when user has feedback)
- **When:** User expresses frustration or says "this doesn't work" or "I have feedback"
- **Say:** *"Want to submit that as feedback? `/pilot-report` scrubs PII and sends it anonymously."*
- **Effect:** Collects feedback, scrubs PII, writes to .pilot/feedback/

**`/pilot-delete`** — Delete data (never auto-suggest)
- **When:** User explicitly asks to delete their data
- **Say:** *"`/pilot-delete` removes your telemetry and signals locally or from the repo."*
- **Effect:** Deletes telemetry files and/or opens a PR to remove from repo

## Branch-Level Suggestions

**Branch splitting:**
- **When:** Branch has 10+ commits or spans 3+ distinct features
- **Say:** *"This branch has [N] commits across several features. Consider opening a PR for what's done and starting fresh — smaller PRs are easier to review."*

**Security requirements:**
- **When:** Building any feature that stores, moves, or exposes data externally
- **Say:** *"Before I build this — who should have access? Does this need encryption? Asking now saves rework later."*

## Rules

1. Never suggest a command the user has dismissed in the same session
2. Never suggest `/bootstrap` after onboarding is complete
3. Never auto-run destructive commands (`/pilot-delete`, `git reset`, etc.)
4. Suggest at most one command per response — don't overwhelm
5. If the user says "just do it" or "stop suggesting", respect it for the rest of the session
6. The Explain Gate (CLAUDE.md) takes precedence — when using a command tied to an ungraduated habit, explain the habit briefly before executing
