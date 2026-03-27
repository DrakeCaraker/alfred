# Collective Learning

Preview, contribute, or manage anonymized learning signals from your feedback memories.

## Arguments

$ARGUMENTS — subcommand:
- `preview` → preview signals without sending (default if no argument)
- `contribute` → send signals to collective backend (Phase 5 — not yet implemented)
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
   - Run `/collective contribute` to opt-in to sharing (Phase 5)

### Contribute (Phase 5 — not yet implemented)

Say: "Collective contribution is not yet available. Your signals are generated and previewed locally only. This feature will be available in a future Alfred release."

### Delete

1. Check for locally saved signal files (`.claude/.collective-signals.json`)
2. If found, delete and confirm
3. If not found, say: "No saved signals found."

## Privacy Guarantees

- Signals contain NO file paths, code, project names, or user identities
- The anonymizer (`collective/anonymizer.py`) runs locally and is fully auditable
- You can preview before any data leaves your machine
- Nothing is sent without explicit `/collective contribute` action
- You can delete all signals anytime with `/collective delete`
