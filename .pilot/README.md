# Alfred Pilot Telemetry

## Privacy Policy

This directory contains **anonymized, opt-in** usage telemetry from Alfred pilot testers.

- **No PII or PHI is collected.** All fields are enumerated values, counts, or random UUIDs.
- **Consent is required.** Run `/pilot-consent` to opt in or out at any time.
- **You own your data.** View, export, or delete it at any time.

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

## What's Never Collected

- Names, emails, employee IDs
- File paths, file contents, project names
- Git messages, branch names, PR titles
- Exact timestamps or durations
- IP addresses, hostnames
- Health data (patient info, diagnoses, prescriptions)
- Database queries, credentials

## Your Data Rights

- **View your data**: `cat .pilot/telemetry/<your-uuid>.json`
- **Delete locally**: Run `/pilot-delete local`
- **Delete from repo**: Run `/pilot-delete remote` (opens a PR)
- **Revoke consent**: Run `/pilot-consent revoke`
- **Complete history removal**: Documented in deletion PR

## Schema Version

Current: `1.0`

## Guard Layers

1. Schema design — fields are enumerated/numeric, PII can't enter
2. Claude scrubber — PII patterns replaced with `[REDACTED]` in feedback
3. Pre-commit hook — `pii-scanner.sh` blocks PII in staged `.pilot/` files
4. Pre-push hook — second-chance PII scan
5. CI workflow — catches `--no-verify` bypasses
6. Branch protection — requires CI to pass before merge
