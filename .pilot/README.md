# Alfred Data Collection

## Privacy Policy

This directory contains **anonymized** usage telemetry from Alfred users.
Alfred also collects **encrypted collective learning signals** stored in a separate private repo.

- **No PII or PHI is collected.** All fields are enumerated values, counts, or random UUIDs.
- **Consent is opt-out.** A banner is shown at first session start. Opt out anytime: `/pilot-consent revoke`.
- **You own your data.** View, export, or delete it at any time.
- **Collective signals are encrypted** with AES-256-CBC before leaving your machine.

## What's Collected

| Field | Type | Example |
|-------|------|---------|
| anonymous_id | UUID v4 | `a1b2c3d4-...` |
| persona | enum | `"ml-ds"` |
| coding_level | enum | `"intermediate"` |
| code_complexity_level | int 1-4 | `2` |
| session_number | int | `5` |
| date | date only | `"2026-03-26"` |
| duration_bucket | enum | `"medium"` |
| branch_type | enum | `"feat"` |
| commands_used | string[] | `["commit","teach"]` |
| patterns_state | object | per-pattern counts |
| graduated_this_session | string[] | pattern names |
| feedback_memory_count | int | `1` |
| bookmark_saved | bool | `true` |
| used_custom_role | bool | `false` |
| persona_fit | bool/null | `true` |
| custom_role_category | enum/null | `"devops-sre"` |

## What's Never Collected

- Names, emails, employee IDs
- File paths, file contents, project names
- Git messages, branch names, PR titles
- Exact timestamps or durations
- IP addresses, hostnames
- Health data (patient info, diagnoses, prescriptions)
- Database queries, credentials
- Free-text role descriptions (custom_role_description)
- Free-text persona gap descriptions (persona_gap)

## Your Data Rights

- **View your data**: `cat .pilot/telemetry/<your-uuid>.json`
- **Delete locally**: Run `/pilot-delete local`
- **Delete from repo**: Run `/pilot-delete remote` (opens a PR)
- **Revoke consent**: Run `/pilot-consent revoke`
- **Complete history removal**: Documented in deletion PR

## Collective Learning Signals

In addition to session telemetry, Alfred collects anonymized correction patterns:

| Field | Type | Example |
|-------|------|---------|
| category | enum | `"git_workflow"` |
| pattern | string (max 200) | `"Never modify test files to fix failing tests"` |
| global_occurrences | int | `3` |
| promoted_to | enum | `"rule"` |
| project_type | enum | `"python"` |
| contributed_at | date | `"2026-03-27"` |

Collective signals are:
- Anonymized locally by `collective/anonymizer.py` (strips paths, code, identifiers)
- Encrypted with AES-256-CBC before leaving the machine
- Stored in a private GitHub repo accessible only to authorized collaborators
- Decryptable only with the shared passphrase (`ALFRED_COLLECTIVE_KEY`)

## Schema Version

Current: `2.0`

Changes in 2.0:
- Unified consent: one opt-out covers telemetry + collective signals
- Added collective learning signals (encrypted, private repo)
- Consent is now opt-out (banner at session start) instead of explicit opt-in

Changes in 1.1:
- Added `used_custom_role` (bool), `persona_fit` (bool/null), `custom_role_category` (enum/null)
- Categories are from `collective/role-categories.yaml` — a fixed taxonomy, not free text

## Guard Layers

1. Schema design — fields are enumerated/numeric, PII can't enter
2. Claude scrubber — PII patterns replaced with `[REDACTED]` in feedback
3. Pre-commit hook — `pii-scanner.sh` blocks PII in staged `.pilot/` files
4. Pre-push hook — second-chance PII scan
5. CI workflow — catches `--no-verify` bypasses
6. Branch protection — requires CI to pass before merge
7. AES-256-CBC encryption — collective signals encrypted before transmission
