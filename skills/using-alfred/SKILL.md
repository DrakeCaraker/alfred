---
name: using-alfred
description: Use when starting any session with Alfred installed to orient the user and check onboarding state
---

# Using Alfred

Alfred teaches development habits in your domain's language and turns your corrections into permanent infrastructure.

## FIRST MESSAGE CHECK — Do this before anything else

**IMPORTANT: Do these checks SILENTLY. Never tell the user about the checks themselves. Never say "consent matches" or "no update needed" or "checking version." Only speak to the user if action is required (re-consent or update available). Otherwise, skip directly to greeting them and answering their question.**

On your FIRST response in every session, check consent version:

1. Read the CURRENT required version from `${CLAUDE_PLUGIN_ROOT}/collective/signal_schema.yaml` (the `schema_version` field). If `CLAUDE_PLUGIN_ROOT` is not set, try `collective/signal_schema.yaml` in CWD.
2. Read `.claude/.pilot-consent.json` if it exists.
3. If the consent file's `schema_version` does NOT match the signal schema's `schema_version`, ask the user to re-consent BEFORE answering their question:

> "Quick note: Alfred's data collection has been updated. All signals are anonymized and encrypted — no code, paths, PII, or company names. Do you consent to data collection? (yes/no)"

- **yes**: Write `{"consented": true, "consent_date": "<today>", "schema_version": "<CURRENT_VERSION>"}` to `.claude/.pilot-consent.json` (in the PROJECT directory, not ~/.claude/). Say "Consent updated." Then answer their question.
- **no**: Write `{"consented": false, "declined_date": "<today>", "schema_version": "<CURRENT_VERSION>"}` to `.claude/.pilot-consent.json` (in the PROJECT directory). Say "No problem." Then answer their question.
- **User ignores**: Remind once. If ignored again, write `{"consented": false, "schema_version": "<CURRENT_VERSION>"}` and proceed.

If the file doesn't exist or already matches the current version, skip this check silently.

## UPDATE CHECK

After the consent check, compare the installed plugin version against the cached latest:

1. Read installed version: `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` → `version` field
2. Read cached latest: `~/.claude/.alfred-update-check` (if it exists)
3. If they differ and cached version is not empty, ask the user:

> "Alfred update available: [installed] → [latest]. Update now? (yes/no)"

- **yes**: Run these commands in sequence:
  ```
  /plugin marketplace remove alfred-marketplace
  /plugin marketplace add https://github.com/DrakeCaraker/alfred.git
  /plugin install alfred@alfred-marketplace
  /reload-plugins
  ```
  Then say: "Alfred updated to [latest]. Restart the session (`/exit` then `claude`) to activate all changes."
- **no**: Say "OK, skipping update." and continue normally.

Only ask once per session. If the cache file doesn't exist or versions match, skip silently — do NOT mention the update check to the user. Just proceed to greeting them.

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
