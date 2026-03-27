# Secure Collective Learning Design

**Date:** 2026-03-27
**Status:** Approved
**Goal:** Encrypted, access-controlled collective learning with unified consent and automatic collection.

## Context

Alfred's collective learning system aggregates anonymized correction signals from feedback memories. The initial implementation used a secret GitHub Gist for transport. This design upgrades to:
- Unified consent (one opt-in/out for all anonymized data)
- Encrypted storage in a private GitHub repo
- Automatic collection on session end + push on session start
- Curated access list (GitHub collaborators)

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Consent model | Opt-out via session-start banner | Low friction; one decision covers telemetry + collective |
| Storage | Private GitHub repo (`alfred-collective`) | Access controlled via collaborators; clean separation from source |
| Encryption | openssl AES-256-CBC with shared passphrase | Pre-installed everywhere; portable; adequate for team scale |
| Key distribution | `ALFRED_COLLECTIVE_KEY` env var | Shared out-of-band; rotation is re-encrypt + redistribute |
| Collection timing | Stop hook (local) + SessionStart hook (push) | Stop is fast (no network); SessionStart has time for git push |
| Unified consent | Single `.pilot-consent.json` gates all anonymized data | Avoids two separate consent flows for the same class of data |

## Architecture

### Consent Flow

**New users (no consent state):** Session-start hook shows a one-time banner:

```
Alfred collects anonymized learning signals to improve team rules.
Signals contain no code, file paths, or identifiers.
See .pilot/README.md for full details.

To opt out: /pilot-consent revoke
```

The session-start hook writes consent state immediately after showing the banner (no user action required — displaying the banner with opt-out instructions constitutes notice). State written to `.claude/.pilot-consent.json`:
```json
{"consented": true, "consent_date": "2026-03-27", "schema_version": "2.0"}
```

**Existing users with pilot consent:** Already consented. No change needed — `schema_version` bumped to 2.0 and consent now covers collective signals.

**Opted-out users:** No banner, no collection, silent.

**Revoking:** `/pilot-consent revoke` stops both telemetry and collective signal collection.

### Storage

**Repository:** `DrakeCaraker/alfred-collective` (private).

```
alfred-collective/
├── README.md              # What this repo is, how to decrypt
├── signals/
│   └── YYYY-MM-DD.enc     # Encrypted signal batches, one per day
└── .gitignore
```

**Access:** GitHub collaborator list. Currently Drake only. Add users via `gh api repos/DrakeCaraker/alfred-collective/collaborators/USERNAME -X PUT`.

### Encryption

**Encrypt:** Signal JSON → `openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:ALFRED_COLLECTIVE_KEY -out signals/YYYY-MM-DD.enc`

**Decrypt:** `openssl enc -d -aes-256-cbc -pbkdf2 -pass env:ALFRED_COLLECTIVE_KEY -in signals/YYYY-MM-DD.enc`

**Key:** Shared passphrase stored in user's shell profile as `ALFRED_COLLECTIVE_KEY`. Distributed via secure channel (Signal, 1Password, etc.).

**No key set:** Signals collected locally but never encrypted or pushed. No error, no warning.

### Auto-Collection Flow

```
Session End (Stop hook):
  → pilot-telemetry.sh fires
  → Check consent: .claude/.pilot-consent.json
  → If consented:
    → Record pilot telemetry (existing behavior)
    → Run aggregator on feedback memories
    → Write anonymized signals to .claude/.collective-pending.json
  → If not consented: skip

Next Session Start (SessionStart hook):
  → session-start.sh fires
  → Check for .claude/.collective-pending.json
  → If exists AND ALFRED_COLLECTIVE_KEY is set AND gh auth valid:
    → Clone/pull alfred-collective repo to temp dir
    → Decrypt today's batch if exists → merge with pending signals (dedup by hash)
    → Encrypt merged signals → commit → push
    → Delete .claude/.collective-pending.json
  → If key not set or no pending: skip silently
```

### Key Rotation

When removing a user's access:

1. Remove collaborator: `gh api repos/DrakeCaraker/alfred-collective/collaborators/USERNAME -X DELETE`
2. Generate new passphrase
3. Re-encrypt all existing `.enc` files:
   ```bash
   # Script: decrypt with old key, re-encrypt with new key
   for f in signals/*.enc; do
     openssl enc -d -aes-256-cbc -pbkdf2 -pass env:OLD_KEY -in "$f" | \
     openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:NEW_KEY -out "$f.new"
     mv "$f.new" "$f"
   done
   ```
4. Commit and force push
5. Distribute new key to remaining users

### Graceful Degradation

| Condition | Behavior |
|-----------|----------|
| No `ALFRED_COLLECTIVE_KEY` | Signals queued locally, never pushed |
| No `gh` auth | Same — local only |
| Private repo doesn't exist | `collective init` creates it |
| Network offline | Pending signals queue, push on next session start |
| Push fails | Pending file preserved, retry next session |
| Stop hook timeout | Aggregation is fast (~1s); no network call |

## Files Changed

| File | Change |
|------|--------|
| `.claude/hooks/session-start.sh` | Add consent banner for new users; push pending signals |
| `.claude/hooks/pilot-telemetry.sh` | Extend Stop hook to aggregate collective signals locally |
| `.claude/commands/pilot-consent.md` | Update disclosure to cover collective signals |
| `.claude/commands/collective.md` | Update init/contribute/ingest for encrypted private repo |
| `scripts/collective-gist.sh` | Rename to `scripts/collective-sync.sh`; rewrite for private repo + encryption |
| `.pilot/README.md` | Update privacy policy to cover collective signals |

## Files Deleted

| File | Reason |
|------|--------|
| `.claude/alfred.yaml` | Gist ID no longer needed; config moves to env vars |

## Configuration

| Env var | Purpose | Default |
|---------|---------|---------|
| `ALFRED_COLLECTIVE_KEY` | Encryption passphrase | (none — signals stay local) |
| `ALFRED_COLLECTIVE_REPO` | Private repo for signals | `DrakeCaraker/alfred-collective` |

## Scope Boundary

This design covers:
- Unified consent model
- Encrypted signal storage and transport
- Automatic collection and push lifecycle
- Access control via GitHub collaborators

This design does NOT cover:
- Ingestion-to-rule-promotion automation (existing `/self-improve` handles this)
- Team dashboard or analytics
- Signal schema changes (v1.0 schema is unchanged)

## Privacy Impact

**What changes from current state:**
- Consent is now opt-out (banner shown, continuing = consent) instead of explicit opt-in
- Collective signals are now covered under the same consent as pilot telemetry
- Signals are encrypted before leaving the local machine
- Only collaborators on the private repo can access encrypted data
- Only people with the passphrase can decrypt

**What stays the same:**
- Anonymizer runs locally before any data leaves
- Signal schema: no code, no paths, no identifiers
- PII scanner guards still active
- User can view, delete, and revoke at any time
