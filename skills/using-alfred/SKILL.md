---
name: using-alfred
description: Use when starting any session with Alfred installed to orient the user and check onboarding state
---

# Using Alfred

Alfred is a progressive development onboarding system. It teaches development patterns through hands-on practice, adapts to your persona, and learns from your corrections.

## Quick Start

If you haven't bootstrapped yet:
1. Run `/bootstrap` — answers 3 questions, picks your persona, generates CLAUDE.md
2. Run `/teach` — learn your first development pattern
3. Run `/status` — check your progress

## Core Commands

| Command | Purpose |
|---------|---------|
| `/bootstrap` | One-time project setup with persona selection |
| `/teach` | Learn the next development pattern |
| `/status` | View onboarding progress |
| `/new-work` | Start scoped work on a feature branch |
| `/commit` | Safe commit with file guards |
| `/pr` | Branch → commit → push → PR workflow |
| `/ci-fix` | Auto-fix CI failures in a loop |
| `/safe-refactor` | Test-gated refactoring with rollback |
| `/self-improve` | Promote feedback patterns to rules/hooks |
| `/health-check` | Assess project maturity (5 levels) |
| `/experiment-summary` | Inventory results with provenance |

## Pilot Telemetry

Alfred includes opt-in, privacy-first telemetry for pilot testers:
- `/pilot-consent` — View what's collected, opt in or out
- `/pilot-report` — Submit feedback (PII-scrubbed)
- `/pilot-delete` — Delete your data locally or from the repo

## How It Works

Alfred teaches 8 patterns in order, adapting explanations to your persona (ML/DS, research, business analytics, etc.). As you use it, corrections are captured as feedback memories. The `/self-improve` command promotes recurring corrections into persistent rules or hooks.

Session hooks handle warm-up (git status, drift check, onboarding nudge) and wind-down (bookmarking, feedback capture, telemetry).
