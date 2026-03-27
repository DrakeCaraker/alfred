# Collective Learning

Preview, contribute, ingest, or manage anonymized learning signals from your feedback memories.

## Arguments

$ARGUMENTS — subcommand:
- `preview` → preview signals without sending (default if no argument)
- `init` → create a new shared Gist for your team
- `contribute` → anonymize local signals and contribute to the shared Gist
- `ingest` → read collective signals and suggest rule adoptions
- `status` → show Gist info and signal count
- `delete` → delete all locally generated signals

## Algorithm

### Preview (default)

1. Detect memory directory:
   ```bash
   project_key=$(pwd | sed 's|/|-|g; s|^-||')
   memory_dir="$HOME/.claude/projects/-${project_key}/memory"
   ```

2. Run the aggregator in preview mode:
   ```bash
   python3 collective/aggregator.py "$memory_dir" --preview
   ```

3. If no feedback memories exist, say: "No feedback memories found. Use Alfred and receive corrections to build up signals."

4. Show the preview output. Emphasize:
   - All signals are anonymized — no file paths, code, or identifiers
   - Signals are generated locally — nothing has been sent anywhere
   - Run `/collective contribute` to share with your team

### Init

1. Run: `bash scripts/collective-gist.sh init`
2. This creates a new secret GitHub Gist to store collective signals
3. The Gist ID is saved to `.claude/alfred.yaml`
4. Show the user the Gist ID and URL
5. Explain: "Share this Gist ID with teammates. They add it to their `.claude/alfred.yaml` under `collective.gist_id`."

### Contribute

1. Check that `gh auth status` succeeds. If not, point to `/github-account-setup`.

2. Check that a Gist ID is configured (run `bash scripts/collective-gist.sh status`). If not, ask if they want to create one (`/collective init`).

3. Preview signals first (same as Preview above) and ask: "These signals will be contributed. They're anonymized — no file paths, code, or identifiers. Proceed? (y/n)"

4. If yes, generate signals to a temp file:
   ```bash
   project_key=$(pwd | sed 's|/|-|g; s|^-||')
   memory_dir="$HOME/.claude/projects/-${project_key}/memory"
   python3 collective/aggregator.py "$memory_dir" --save /tmp/alfred-signals.json
   ```

5. Contribute:
   ```bash
   bash scripts/collective-gist.sh contribute /tmp/alfred-signals.json
   ```

6. Clean up temp file. Show results.

### Ingest

1. Run: `bash scripts/collective-gist.sh ingest`

2. This fetches signals from the shared Gist and categorizes them:
   - **Recommended (3+ occurrences):** Multiple users hit this correction. Suggest adding to CLAUDE.md.
   - **Emerging (2 occurrences):** Growing patterns — watch these.
   - **New (1 occurrence):** Single contributions, not yet patterns.

3. For each recommended signal, ask the user: "Add this as a CLAUDE.md rule?" If yes, append to the Guardrails section of CLAUDE.md.

4. For emerging signals, just list them. Say: "These are growing. They may become recommendations as more users contribute."

### Status

1. Run: `bash scripts/collective-gist.sh status`
2. Shows: Gist ID, URL, total signals, recommended count, breakdown by category.
3. If no Gist configured, suggest `/collective init`.

### Delete

1. Check for locally saved signal files (`.claude/.collective-signals.json`)
2. If found, delete and confirm
3. If not found, say: "No saved signals found."

## Privacy Guarantees

- Signals contain NO file paths, code, project names, or user identities
- The anonymizer (`collective/anonymizer.py`) runs locally and is fully auditable
- You can preview before any data leaves your machine
- Nothing is sent without explicit `/collective contribute` action
- The Gist is a secret Gist — only people with the URL can access it
- You can delete all signals anytime with `/collective delete`
- You can view the raw Gist anytime: `gh gist view <gist_id>`
