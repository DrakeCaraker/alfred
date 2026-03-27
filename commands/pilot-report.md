# Pilot Feedback Report

Submit manual feedback about your Alfred experience. Feedback is PII-scrubbed and saved to `.pilot/feedback/`.

## Arguments

$ARGUMENTS — optional free-text feedback (or will be prompted)

## Algorithm

1. **Check consent**:
   - Read `.claude/.pilot-consent.json`
   - If not consented or file missing:
     - Say: "Pilot telemetry is not enabled. Run /pilot-consent to opt in first."
     - Stop.

2. **Get feedback**:
   - If $ARGUMENTS is provided, use it as the feedback text
   - Otherwise, ask: "What feedback would you like to share about your Alfred experience?"

3. **Read identity**:
   - Read UUID from `.claude/.pilot-identity.json`
   - If missing, say: "Identity file missing. Run /pilot-consent to set up." Stop.

4. **Scrub PII from feedback text**:
   Replace these patterns with `[REDACTED]`:
   - Email addresses: `*@*.*`
   - File paths: `/Users/*`, `/home/*`, `C:\Users\*`
   - IP addresses: `N.N.N.N` (except 127.0.0.1, 0.0.0.0)
   - Auth tokens: `sk-*`, `Bearer *`
   - SSN-like: `NNN-NN-NNNN` (except dates)
   - Any text matching `api_key=*`, `password=*`, `secret=*`

5. **Show scrubbed version for confirmation**:
   - Display the scrubbed feedback to the user
   - Ask: "This is what will be saved (PII has been scrubbed). Confirm? (yes/no)"
   - If no, stop.

6. **Write feedback file**:
   - Filename: `.pilot/feedback/<uuid>-<today's date>.md`
   - If file already exists (multiple reports same day), append a counter: `<uuid>-<date>-2.md`
   - Content format:
     ```
     ---
     anonymous_id: <uuid>
     date: <today>
     schema_version: "1.0"
     ---

     <scrubbed feedback text>
     ```

7. **Validate with PII scanner**:
   - Run: `scripts/pii-scanner.sh --feedback .pilot/feedback/<filename>`
   - If scanner finds PII (exit 1):
     - Delete the file
     - Show the scanner output
     - Say: "PII detected in scrubbed feedback. Please rephrase without personal information and try again."
     - Stop.
   - If scanner warns (exit 0 with warnings):
     - Show warnings to user
     - Say: "Health-related terms detected (warnings only, not blocked). The feedback has been saved."

8. **Confirm**:
   - Say: "Feedback saved to .pilot/feedback/<filename>"
   - Say: "It will be included when .pilot/ changes are committed and pushed."
