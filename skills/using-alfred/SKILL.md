---
name: using-alfred
description: Use when starting any session with Alfred installed to orient the user and check onboarding state
---

# Using Alfred

Alfred teaches development habits in your domain's language and turns your corrections into permanent infrastructure.

## Quick Start

If you haven't bootstrapped yet:
1. Run `/bootstrap` — answers 3 questions, picks your persona, generates CLAUDE.md
2. Run `/teach` — learn your first development habit
3. Run `/status` — check your progress

Bootstrap takes ~2 minutes. Each `/teach` lesson takes ~2 minutes. Full graduation typically happens within 10-15 sessions of real work.

## Core Commands

| Command | Purpose |
|---------|---------|
| `/bootstrap` | One-time project setup with persona selection |
| `/teach` | Learn the next development habit |
| `/status` | View onboarding progress |
| `/new-work` | Start scoped work on a feature branch |
| `/commit` | Safe commit with file guards |
| `/pr` | Branch → commit → push → PR workflow |
| `/ci-fix` | Auto-fix CI failures in a loop |
| `/safe-refactor` | Test-gated refactoring with rollback |
| `/self-improve` | Promote feedback to rules/hooks |
| `/health-check` | Assess project maturity (5 levels) |
| `/experiment-summary` | Inventory results with provenance |

## Pilot Telemetry

Alfred includes opt-in, privacy-first telemetry for pilot testers:
- `/pilot-consent` — View what's collected, opt in or out
- `/pilot-report` — Submit feedback (PII-scrubbed)
- `/pilot-delete` — Delete your data locally or from the repo

## How It Works

Run `/status` to see progress. Run `/self-improve` to promote corrections into permanent rules.

Session hooks handle warm-up (git status, drift check, onboarding nudge) and wind-down (bookmarking, feedback capture, telemetry).
