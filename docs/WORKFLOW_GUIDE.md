# Workflow Guide — Alfred's Complete Automation Stack

## Overview

Alfred automates development workflows through 7 layers, from instant auto-fixes to weekly security scans. Each layer catches issues the previous one missed.

## The 7 Layers

### Layer 1: PostToolUse Hook (every edit)
**Trigger:** Every time Claude writes or edits a file
**What it does:**
- Auto-formats code (ruff, prettier, gofmt, etc.)
- Auto-syncs `.claude/commands/` → `commands/` and `.claude/hooks/` → `hooks/`
**You see:** Nothing — it's invisible and instant

### Layer 2: Pre-commit Hook (every commit)
**Trigger:** `git commit`
**What it does:**
- Blocks commits if command/hook mirrors are out of sync
- PII scans all `.pilot/` files
- Validates telemetry JSON schema
**You see:** Error message if something's wrong, with fix instructions

### Layer 3: Pre-push Hook (every push)
**Trigger:** `git push`
**What it does:**
- Blocks pushes directly to main
- Runs security audit (injection, secrets, cleanup traps, sync)
- PII scans all `.pilot/` files in the push range
- Blocks binary artifacts and large files
**You see:** "BLOCKED" message with the specific issue

### Layer 4: CI Validation (every PR)
**Trigger:** Pull request or push to main
**What it does:**
- Structural validation (JSON, YAML, conflict markers, command/hook sync)
- Shellcheck on all scripts
- Smoke test (123 structural checks)
- Security audit
**You see:** Green/red check on your PR

### Layer 5: CI Auto-fix (on CI failure)
**Trigger:** CI fails on a PR
**What it does:**
- Claude Code reads the failure logs
- Fixes the code (up to 3 attempts)
- Pushes the fix and re-triggers CI
- If it can't fix it, comments on the PR with instructions
**Loop protection:** Skips if last commit was by alfred-bot

### Layer 6: Conflict Resolution (on push to main)
**Trigger:** Any push to main
**What it does:**
- Checks all open PRs for merge conflicts
- Claude resolves each conflict in parallel (matrix job)
- Pushes the resolution and comments on the PR

### Layer 7: Weekly Security Scan
**Trigger:** Monday 9am UTC (or manual)
**What it does:**
- Runs the full security audit
- Opens a GitHub issue if anything fails
- Updates existing issue if one is already open

## Commands Reference

### Workflow Commands
| Command | What it does | When to use |
|---------|-------------|-------------|
| `/new-work` | Create a scoped branch with task list | Starting any new task |
| `/commit` | Safe commit with pre-flight checks | After making changes (runs make check first) |
| `/pr` | Branch → commit → push → PR | When work is ready for review (runs make check first) |
| `/ci-fix` | Auto-fix CI failures in a loop | When CI is red and you want to fix it locally |

### Quality Commands
| Command | What it does | When to use |
|---------|-------------|-------------|
| `/vet` | Pressure-test a plan | Before implementing anything complex |
| `/audit` | Security and quality audit | Before creating a PR, after large implementations |
| `/safe-refactor` | Test-gated refactoring with rollback | When changing code structure |
| `/health-check` | Assess project maturity (5 levels) | Periodically, to see what's missing |

### Learning Commands
| Command | What it does | When to use |
|---------|-------------|-------------|
| `/teach` | Learn the next development habit | When prompted, or anytime you want to learn |
| `/status` | See your progress and graduated habits | To check where you are |
| `/self-improve` | Promote corrections to rules/hooks | When feedback memories accumulate |

### Persona & Collective
| Command | What it does | When to use |
|---------|-------------|-------------|
| `/persona` | View or evolve your persona | When your work focus changes |
| `/collective` | Preview, contribute, or ingest shared signals | To share learnings or adopt team patterns |
| `/pilot-consent` | Manage data collection consent | To view/revoke consent |

### Setup
| Command | What it does | When to use |
|---------|-------------|-------------|
| `/bootstrap` | Initial persona-aware project setup | First time only |
| `/github-account-setup` | Connect to GitHub | If not authenticated |

## Makefile Targets

```bash
make setup     # Activate git hooks, verify prerequisites
make check     # Full CI-equivalent validation (validate + lint + test)
make audit     # Deep security lint (injection, secrets, traps, sync)
make fix       # Auto-fix sync + permissions
make test      # Smoke test only (123 structural checks)
make lint      # Shellcheck only
make validate  # Structural validation only (JSON, YAML, sync)
```

## The Self-Improvement Loop

```
You correct Claude → saved as feedback memory
                     ↓ (2+ occurrences or high-impact)
              Promoted to CLAUDE.md rule
                     ↓ (rule still violated)
              Promoted to automated hook/guard
```

Run `/self-improve` periodically to trigger promotions. The system gets smarter every session.

## Collective Learning

Corrections from individual users can be shared as anonymized, encrypted signals:

1. `/collective init` — create a private repo for your team
2. Set `ALFRED_COLLECTIVE_KEY` in your shell profile
3. Signals auto-collect on session end, auto-push on next session start
4. `/collective ingest` — see what the team is learning
5. Signals with 3+ occurrences are recommended as CLAUDE.md rules

All signals are anonymized locally, encrypted with AES-256, and stored in a private GitHub repo.

## Environment Variables

| Variable | Purpose | Required? |
|----------|---------|-----------|
| `ALFRED_COLLECTIVE_KEY` | Encryption passphrase for collective signals | No — signals queue locally without it |
| `ALFRED_COLLECTIVE_REPO` | Private repo for signals | No — defaults to owner/alfred-collective |
| `ALFRED_PROJECT_TYPE` | Project type for signal categorization | No — defaults to "unknown" |
