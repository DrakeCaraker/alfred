# Data Collection Consent Management

Manage consent for all Alfred anonymized data collection (telemetry + collective learning signals).

## Arguments

$ARGUMENTS — optional: `revoke` to revoke consent, `status` to check current state

## Algorithm

1. **Check for revoke request**:
   - If argument is `revoke`, go to step 6

2. **Show disclosure**:
   Print the following exactly:

   ```
   === Alfred Data Collection ===

   Alfred collects two types of anonymized data (both under one consent):

   TELEMETRY (session metadata):
     • Anonymous UUID (random, not tied to identity)
     • Persona and coding level (from /bootstrap)
     • Session count, date (no time), duration bucket (short/medium/long)
     • Branch type category (feat/fix/chore/refactor/other)
     • Command names used (no arguments)
     • Pattern graduation progress
     • Feedback memory count, bookmark saved (bool)

   COLLECTIVE SIGNALS (anonymized corrections):
     • Correction category (git_workflow, formatting, testing, etc.)
     • Anonymized pattern text (max 200 chars, no code/paths/identifiers)
     • Occurrence count and promotion level (memory/rule/hook)
     • Project type (python/js/ts/etc.)
     • Encrypted with AES-256 before leaving your machine

   WHAT WE NEVER COLLECT:
     • Names, emails, employee IDs
     • File paths, file contents, project names
     • Git messages, branch names, PR titles
     • Exact timestamps or durations
     • IP addresses, hostnames, credentials
     • Health data (patient info, diagnoses, prescriptions)

   YOUR RIGHTS:
     • View telemetry: cat .pilot/telemetry/<your-uuid>.json
     • View pending signals: cat .claude/.collective-pending.json
     • Delete locally: /pilot-delete local
     • Delete from repo: /pilot-delete remote (opens a PR)
     • Revoke consent: /pilot-consent revoke
     • Complete history removal: documented in deletion PR

   GUARD LAYERS:
     All data passes through 6 guard layers including PII scanning,
     pre-commit hooks, CI checks, and AES-256 encryption.
     See .pilot/README.md for details.
   ```

3. **Check current consent status**:
   - Read `.claude/.pilot-consent.json` if it exists
   - If already consented, show: "You are currently opted IN (schema v2.0). Consent covers telemetry and collective signals."
   - If `schema_version` is "1.0", explain: "Your consent was granted under v1.0 (telemetry only). It now also covers encrypted collective signals under v2.0."
   - If revoked, show: "You previously revoked consent on <date>. No data is being collected."
   - If no file, show: "Consent is granted by default at session start. You have not explicitly opted out."

4. **Ask for action**:
   - If consented: "Want to keep consent active, or revoke? (keep/revoke)"
   - If not consented: "Would you like to opt in? (yes/no)"

5. **Grant consent**:
   - Generate a UUID v4 using: `python3 -c "import uuid; print(uuid.uuid4())"`
   - If `.claude/.pilot-identity.json` exists, reuse the existing UUID
   - Write `.claude/.pilot-identity.json`: `{"anonymous_id": "<uuid>", "created_date": "<today>"}`
   - Write `.claude/.pilot-consent.json`: `{"consented": true, "consent_date": "<today>", "schema_version": "2.0"}`
   - Confirm: "Consent granted. Telemetry + collective signals will be collected. Signals are encrypted with AES-256 before leaving your machine."

6. **Revoke consent**:
   - Read `.claude/.pilot-consent.json`
   - If not consented or file missing, say: "No active consent to revoke."
   - Update to: `{"consented": false, "revoked_date": "<today>", "schema_version": "2.0"}`
   - Delete `.claude/.collective-pending.json` if it exists
   - Keep `.claude/.pilot-identity.json` intact (for data continuity if re-consent)
   - Confirm: "Consent revoked. No further data will be collected (telemetry or collective signals). Your data remains in .pilot/ — run /pilot-delete to remove it."
