# Pilot Telemetry Consent Management

Manage opt-in consent for Alfred pilot telemetry.

## Arguments

$ARGUMENTS — optional: `revoke` to revoke consent

## Algorithm

1. **Check for revoke request**:
   - If argument is `revoke`, go to step 6

2. **Show disclosure**:
   Print the following exactly:

   ```
   === Alfred Pilot Telemetry ===

   WHAT WE COLLECT (all anonymized):
     • Anonymous UUID (random, not tied to identity)
     • Persona and coding level (from /bootstrap)
     • Session count, date (no time), duration bucket (short/medium/long)
     • Branch type category (feat/fix/chore/refactor/other)
     • Command names used (no arguments)
     • Pattern graduation progress
     • Feedback memory count, bookmark saved (bool)

   WHAT WE NEVER COLLECT:
     • Names, emails, employee IDs
     • File paths, file contents, project names
     • Git messages, branch names, PR titles
     • Exact timestamps or durations
     • IP addresses, hostnames, credentials
     • Health data (patient info, diagnoses, prescriptions)

   YOUR RIGHTS:
     • View your data: cat .pilot/telemetry/<your-uuid>.json
     • Delete locally: /pilot-delete local
     • Delete from repo: /pilot-delete remote (opens a PR)
     • Revoke consent: /pilot-consent revoke
     • Complete history removal: documented in deletion PR

   GUARD LAYERS:
     All data passes through 6 guard layers including PII scanning,
     pre-commit hooks, and CI checks. See .pilot/README.md for details.
   ```

3. **Check current consent status**:
   - Read `.claude/.pilot-consent.json` if it exists
   - If already consented, show: "You are currently opted IN. Your anonymous ID: <uuid>"
   - If revoked, show: "You previously revoked consent on <date>."
   - If no file, show: "You have not opted in yet."

4. **Ask for consent**:
   - Ask: "Would you like to opt in to pilot telemetry? (yes/no)"
   - If no, say: "No problem. You can opt in anytime with /pilot-consent."
   - Stop.

5. **Grant consent**:
   - Generate a UUID v4 using: `python3 -c "import uuid; print(uuid.uuid4())"`
   - If `.claude/.pilot-identity.json` exists, reuse the existing UUID
   - Write `.claude/.pilot-identity.json`: `{"anonymous_id": "<uuid>", "created_date": "<today>"}`
   - Write `.claude/.pilot-consent.json`: `{"consented": true, "consent_date": "<today>", "schema_version": "1.0"}`
   - Confirm: "Consent granted. Anonymous ID: <uuid>. Telemetry will be recorded at session end."
   - Stop.

6. **Revoke consent**:
   - Read `.claude/.pilot-consent.json`
   - If not consented or file missing, say: "No active consent to revoke."
   - Update to: `{"consented": false, "revoked_date": "<today>", "schema_version": "1.0"}`
   - Keep `.claude/.pilot-identity.json` intact (for data continuity if re-consent)
   - Confirm: "Consent revoked. No further telemetry will be collected. Your data remains in .pilot/ — run /pilot-delete to remove it."
   - Stop.
