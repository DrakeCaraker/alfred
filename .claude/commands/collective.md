# Collective Learning

Preview, contribute, ingest, or manage encrypted anonymized learning signals.

## Arguments

$ARGUMENTS — subcommand:
- `preview` → preview signals without sending (default if no argument)
- `init` → create the private collective repo
- `contribute` → encrypt and push local signals to the private repo
- `ingest` → decrypt and display collective signals, suggest rule adoptions
- `status` → show repo info, encryption status, and signal count
- `opt-out` → revoke consent (alias for `/pilot-consent revoke`)
- `delete` → delete all locally generated signals

## Algorithm

### Detect Alfred root

Before running any script, detect where Alfred is installed:
```bash
ALFRED_ROOT="${CLAUDE_PLUGIN_ROOT:-$(pwd)}"
```
Use `$ALFRED_ROOT` as the prefix for all Alfred script paths below. User project files (`.claude/`, `.pilot/`) are always relative to CWD.

### Preview (default)

1. Detect memory directory:
   ```bash
   project_key=$(pwd | sed 's|/|-|g; s|^-||')
   memory_dir="$HOME/.claude/projects/-${project_key}/memory"
   ```
   Also check parent: `$HOME/.claude/projects/-$(echo $HOME | sed 's|/|-|g; s|^-||')/memory`

2. Run the aggregator in preview mode:
   ```bash
   python3 "$ALFRED_ROOT/collective/aggregator.py" "$memory_dir" --preview
   ```

3. If no feedback memories exist, say: "No feedback memories found. Use Alfred and receive corrections to build up signals."

4. Show the preview output. Emphasize:
   - All signals are anonymized — no file paths, code, or identifiers
   - Signals are generated locally — nothing has been sent anywhere
   - Run `/collective contribute` to encrypt and push to the private repo

### Init

1. Run: `bash "$ALFRED_ROOT/scripts/collective-sync.sh" init`
2. This creates a private GitHub repo for encrypted collective signals
3. Show the user the repo URL and next steps (set encryption key)

### Contribute

1. Check that `gh auth status` succeeds. If not, point to `/github-account-setup`.

2. Check that `ALFRED_COLLECTIVE_KEY` is set. If not, explain:
   "Set your encryption key: `export ALFRED_COLLECTIVE_KEY='your-passphrase'`
   Add to your shell profile (~/.zshrc or ~/.bashrc) for persistence."

3. Check that the repo exists (run `bash "$ALFRED_ROOT/scripts/collective-sync.sh" status`). If not, ask if they want to create one (`/collective init`).

4. Preview signals first and ask: "These signals will be encrypted and pushed. They're anonymized — no file paths, code, or identifiers. Proceed? (y/n)"

5. If yes, generate signals to a temp file:
   ```bash
   python3 "$ALFRED_ROOT/collective/aggregator.py" "$memory_dir" --save /tmp/alfred-signals.json
   ```

6. Contribute:
   ```bash
   bash "$ALFRED_ROOT/scripts/collective-sync.sh" contribute /tmp/alfred-signals.json
   ```

7. Clean up temp file. Show results.

### Ingest

1. Run: `bash "$ALFRED_ROOT/scripts/collective-sync.sh" ingest`

2. This pulls the private repo, decrypts all signal batches, and categorizes them:
   - **Recommended (3+ occurrences):** Multiple users hit this correction. Suggest adding to CLAUDE.md.
   - **Emerging (2 occurrences):** Growing patterns — watch these.
   - **New (1 occurrence):** Single contributions, not yet patterns.

3. For each recommended signal, ask the user: "Add this as a CLAUDE.md rule?" If yes, append to the Guardrails section of CLAUDE.md.

### Status

1. Run: `bash "$ALFRED_ROOT/scripts/collective-sync.sh" status`
2. Shows: repo URL, key configured (yes/no), batch count, pending signals.

### Opt-Out

1. Same as `/pilot-consent revoke` — stops all anonymized data collection (telemetry and collective signals).

### Delete

1. Check for locally saved signal files (`.claude/.collective-pending.json`)
2. If found, delete and confirm
3. If not found, say: "No pending signals found."

## Privacy & Security

- Signals contain NO file paths, code, project names, or user identities
- The anonymizer (`collective/anonymizer.py`) runs locally and is fully auditable
- Signals are encrypted with AES-256-CBC before leaving your machine
- Only collaborators on the private repo can access the encrypted files
- Only people with the passphrase (`ALFRED_COLLECTIVE_KEY`) can decrypt
- You can preview before any data leaves your machine
- Nothing is sent without explicit `/collective contribute` or automatic session-end collection
- You can opt out anytime: `/collective opt-out` or `/pilot-consent revoke`
- You can delete pending signals: `/collective delete`

## Automatic Collection

When consent is active (default opt-out):
- **Session end:** Feedback memories are aggregated locally to `.claude/.collective-pending.json`
- **Next session start:** Pending signals are encrypted and pushed to the private repo (if `ALFRED_COLLECTIVE_KEY` is set)
- If the key is not set, signals queue locally and are never pushed
