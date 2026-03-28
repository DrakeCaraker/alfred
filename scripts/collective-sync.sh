#!/usr/bin/env bash
# collective-sync.sh — Encrypted private-repo transport for Alfred collective learning signals.
#
# Usage:
#   collective-sync.sh init                  Create the private repo
#   collective-sync.sh contribute <signals>  Encrypt and push local signals (auto-detects path)
#   collective-sync.sh submit <signals>      Submit signals as GitHub issue (no key needed)
#   collective-sync.sh ingest                Decrypt and display collective signals
#   collective-sync.sh push-pending          Push .collective-pending.json (called by session-start hook)
#   collective-sync.sh status                Show repo info and signal count
#
# Environment:
#   ALFRED_COLLECTIVE_KEY   — Encryption passphrase (required for push/pull)
#   ALFRED_COLLECTIVE_REPO  — Private repo (default: DrakeCaraker/alfred-collective)
set -euo pipefail

COLLECTIVE_REPO="${ALFRED_COLLECTIVE_REPO:-DrakeCaraker/alfred-collective}"
ALFRED_PUBLIC_REPO="${ALFRED_PUBLIC_REPO:-DrakeCaraker/alfred}"
PENDING_FILE=".claude/.collective-pending.json"

# --- Helpers ---

die() { echo "ERROR: $*" >&2; exit 1; }

check_gh_auth() {
  if ! gh auth status >/dev/null 2>&1; then
    die "GitHub CLI not authenticated. Run 'gh auth login' or use /github-account-setup."
  fi
}

check_key() {
  if [ -z "${ALFRED_COLLECTIVE_KEY:-}" ]; then
    die "ALFRED_COLLECTIVE_KEY not set. Add to your shell profile: export ALFRED_COLLECTIVE_KEY='your-passphrase'"
  fi
}

encrypt_file() {
  local input="$1" output="$2"
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:ALFRED_COLLECTIVE_KEY -in "$input" -out "$output"
}

decrypt_file() {
  local input="$1" output="$2"
  openssl enc -d -aes-256-cbc -pbkdf2 -pass env:ALFRED_COLLECTIVE_KEY -in "$input" -out "$output"
}

clone_repo() {
  local dest="$1"
  gh repo clone "$COLLECTIVE_REPO" "$dest" -- --depth 1 2>/dev/null
}

today() {
  date +%Y-%m-%d
}

# --- Commands ---

cmd_init() {
  local tmp_dir=""
  cleanup() { rm -rf "$tmp_dir"; }
  trap cleanup EXIT

  check_gh_auth

  # Check if repo already exists
  if gh repo view "$COLLECTIVE_REPO" >/dev/null 2>&1; then
    echo "Collective repo already exists: $COLLECTIVE_REPO"
    echo "URL: https://github.com/$COLLECTIVE_REPO"
    cleanup
    trap - EXIT
    return 0
  fi

  echo "Creating private collective repo: $COLLECTIVE_REPO..."

  gh repo create "$COLLECTIVE_REPO" --private --description "Alfred Collective Learning Signals (encrypted)" 2>&1

  # Clone, add structure, push
  tmp_dir=$(mktemp -d)
  clone_repo "$tmp_dir"
  mkdir -p "$tmp_dir/signals"

  cat > "$tmp_dir/README.md" <<'README'
# Alfred Collective Learning Signals

Encrypted, anonymized correction patterns from Alfred users.

## Decrypting

```bash
export ALFRED_COLLECTIVE_KEY='<passphrase>'
openssl enc -d -aes-256-cbc -pbkdf2 -pass env:ALFRED_COLLECTIVE_KEY -in signals/YYYY-MM-DD.enc
```

## Access

Only GitHub collaborators on this repo can see the encrypted files.
Only people with the passphrase can decrypt them.

## Signal Format

Each decrypted file is a JSON array of signals:
```json
{
  "schema_version": "1.0",
  "signals": [
    {
      "category": "git_workflow|formatting|testing|code_style|safety|explanation|tooling",
      "pattern": "The anonymized correction (max 200 chars)",
      "global_occurrences": 1,
      "promoted_to": "memory|rule|hook",
      "project_type": "python|js|ts|rust|go|r|mixed",
      "contributed_at": "YYYY-MM-DD"
    }
  ]
}
```

Signals contain NO file paths, code, project names, or user identities.
README

  cat > "$tmp_dir/.gitignore" <<'GITIGNORE'
*.dec
*.json
!package.json
GITIGNORE

  touch "$tmp_dir/signals/.gitkeep"

  cd "$tmp_dir"
  git add -A
  git commit -m "init: Alfred Collective Learning repository" >/dev/null 2>&1
  git push >/dev/null 2>&1
  cd - >/dev/null

  cleanup
  trap - EXIT

  echo ""
  echo "Collective repo created: https://github.com/$COLLECTIVE_REPO"
  echo ""
  echo "Next steps:"
  echo "  1. Set encryption key: export ALFRED_COLLECTIVE_KEY='your-passphrase'"
  echo "  2. Add to shell profile (~/.zshrc or ~/.bashrc)"
  echo "  3. Run /collective contribute to push your first signals"
}

cmd_submit() {
  local signals_file="${1:-}"
  if [ -z "$signals_file" ] || [ ! -f "$signals_file" ]; then
    die "Usage: collective-sync.sh submit <signals.json>"
  fi

  check_gh_auth

  echo "Submitting anonymized signals to Alfred collective..."

  # Validate signal format
  local count
  count=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
signals = data.get('signals', [])
# Verify all signals have required fields
for s in signals:
    assert 'category' in s, 'missing category'
    assert 'pattern' in s, 'missing pattern'
    assert len(s['pattern']) <= 200, 'pattern too long'
print(len(signals))
" "$signals_file" 2>&1) || die "Invalid signal format: $count"

  # Read the JSON content
  local body
  body=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
# Add metadata
data['submitted_at'] = '$(date +%Y-%m-%d)'
print(json.dumps(data, indent=2))
" "$signals_file")

  # Create a GitHub issue on the public Alfred repo
  gh issue create \
    --repo "$ALFRED_PUBLIC_REPO" \
    --title "collective-signal: $count signals $(date +%Y-%m-%d)" \
    --label "collective-signal" \
    --body "\`\`\`json
$body
\`\`\`" >/dev/null 2>&1

  echo "Submitted $count anonymized signals to Alfred collective."
  echo ""
  echo "Signals are anonymized — no code, paths, or identifiers."
  echo "A maintainer will review and ingest them."
}

cmd_contribute() {
  local tmp_dir=""
  local merged_file=""
  cleanup() { rm -rf "$tmp_dir" "$merged_file"; }
  trap cleanup EXIT

  local signals_file="${1:-}"
  if [ -z "$signals_file" ] || [ ! -f "$signals_file" ]; then
    die "Usage: collective-sync.sh contribute <signals.json>"
  fi

  check_gh_auth

  # Auto-detect contribution path
  if [ -z "${ALFRED_COLLECTIVE_KEY:-}" ] || ! gh repo view "$COLLECTIVE_REPO" >/dev/null 2>&1; then
    # Community path: submit via GitHub issue on public repo
    cmd_submit "$signals_file"
    cleanup
    trap - EXIT
    return 0
  fi

  # Owner path: direct encrypted push (continues below)
  echo "Syncing with collective repo..."

  tmp_dir=$(mktemp -d)
  clone_repo "$tmp_dir"
  mkdir -p "$tmp_dir/signals"

  local batch_date
  batch_date=$(today)
  local enc_file="$tmp_dir/signals/${batch_date}.enc"
  merged_file=$(mktemp)

  # If today's batch exists, decrypt and merge
  if [ -f "$enc_file" ]; then
    local existing_file
    existing_file=$(mktemp)
    decrypt_file "$enc_file" "$existing_file"

    # Merge existing + new signals (dedup by hash)
    python3 -c "
import json, sys, hashlib

existing_file = sys.argv[1]
signals_file = sys.argv[2]
batch_date = sys.argv[3]
merged_file = sys.argv[4]

def signal_id(s):
    key = s.get('category','') + ':' + s.get('pattern','')[:100].lower()
    return hashlib.sha256(key.encode()).hexdigest()[:16]

with open(existing_file) as f:
    existing_data = json.load(f)
existing = {signal_id(s): s for s in existing_data.get('signals', [])}

with open(signals_file) as f:
    new_data = json.load(f)

added = 0
updated = 0
for s in new_data.get('signals', []):
    sid = signal_id(s)
    if sid in existing:
        existing[sid]['global_occurrences'] = existing[sid].get('global_occurrences', 1) + s.get('local_occurrences', 1)
        levels = {'memory': 0, 'rule': 1, 'hook': 2}
        if levels.get(s.get('promoted_to',''), 0) > levels.get(existing[sid].get('promoted_to',''), 0):
            existing[sid]['promoted_to'] = s['promoted_to']
        updated += 1
    else:
        s['global_occurrences'] = s.get('local_occurrences', 1)
        s['contributed_at'] = batch_date
        existing[sid] = s
        added += 1

output = {
    'schema_version': '1.0',
    'last_updated': batch_date,
    'signals': list(existing.values()),
}
with open(merged_file, 'w') as f:
    json.dump(output, f, indent=2)
print(f'{added} new, {updated} updated, {len(existing)} total')
" "$existing_file" "$signals_file" "$batch_date" "$merged_file"
    rm -f "$existing_file"
  else
    # No existing batch — use new signals directly
    cp "$signals_file" "$merged_file"
    local count
    count=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    print(len(json.load(f).get('signals',[])))
" "$merged_file")
    echo "$count new, 0 updated, $count total"
  fi

  # Encrypt and commit
  encrypt_file "$merged_file" "$enc_file"

  cd "$tmp_dir"
  git add "signals/${batch_date}.enc"
  git commit -m "signals: update ${batch_date}" >/dev/null 2>&1
  git push >/dev/null 2>&1
  cd - >/dev/null

  cleanup
  trap - EXIT

  echo "Encrypted signals pushed to $COLLECTIVE_REPO"
  echo ""
  echo "Signals are anonymized and encrypted. Only authorized users can decrypt."
}

cmd_push_pending() {
  # Called by session-start hook — push pending signals silently
  if [ ! -f "$PENDING_FILE" ]; then
    exit 0
  fi

  if [ -z "${ALFRED_COLLECTIVE_KEY:-}" ]; then
    # No encryption key — submit via issue instead
    cmd_submit "$PENDING_FILE" >/dev/null 2>&1 && rm -f "$PENDING_FILE"
    exit 0
  fi

  if ! gh auth status >/dev/null 2>&1; then
    exit 0
  fi

  if ! gh repo view "$COLLECTIVE_REPO" >/dev/null 2>&1; then
    exit 0
  fi

  # Push pending signals (silent — errors are swallowed)
  cmd_contribute "$PENDING_FILE" >/dev/null 2>&1 && rm -f "$PENDING_FILE"
}

cmd_ingest() {
  local tmp_dir=""
  local all_signals=""
  cleanup() { rm -rf "$tmp_dir" "$all_signals"; }
  trap cleanup EXIT

  check_gh_auth
  check_key

  echo "Fetching collective signals..."

  tmp_dir=$(mktemp -d)
  clone_repo "$tmp_dir"

  # Decrypt all batches and merge
  all_signals=$(mktemp)
  echo '{"signals":[]}' > "$all_signals"

  local found=0
  for enc_file in "$tmp_dir"/signals/*.enc; do
    [ -f "$enc_file" ] || continue
    found=1

    local dec_file
    dec_file=$(mktemp)
    decrypt_file "$enc_file" "$dec_file"

    # Merge into all_signals
    python3 -c "
import json, sys, hashlib

all_signals_file = sys.argv[1]
dec_file = sys.argv[2]

def signal_id(s):
    key = s.get('category','') + ':' + s.get('pattern','')[:100].lower()
    return hashlib.sha256(key.encode()).hexdigest()[:16]

with open(all_signals_file) as f:
    all_data = json.load(f)
existing = {signal_id(s): s for s in all_data.get('signals', [])}

with open(dec_file) as f:
    batch = json.load(f)

for s in batch.get('signals', []):
    sid = signal_id(s)
    if sid in existing:
        existing[sid]['global_occurrences'] = max(
            existing[sid].get('global_occurrences', 1),
            s.get('global_occurrences', 1)
        )
    else:
        existing[sid] = s

output = {'signals': list(existing.values())}
with open(all_signals_file, 'w') as f:
    json.dump(output, f)
" "$all_signals" "$dec_file"
    rm -f "$dec_file"
  done

  rm -rf "$tmp_dir"
  tmp_dir=""

  if [ "$found" -eq 0 ]; then
    echo "No signals found in collective."
    cleanup
    trap - EXIT
    return 0
  fi

  # Display signals
  python3 -c "
import json, sys

all_signals_file = sys.argv[1]

with open(all_signals_file) as f:
    data = json.load(f)
signals = data.get('signals', [])

if not signals:
    print('No signals in collective yet.')
    sys.exit(0)

signals.sort(key=lambda s: s.get('global_occurrences', 1), reverse=True)

strong = [s for s in signals if s.get('global_occurrences', 1) >= 3]
emerging = [s for s in signals if 1 < s.get('global_occurrences', 1) < 3]
new = [s for s in signals if s.get('global_occurrences', 1) <= 1]

if strong:
    print('=== Recommended (3+ occurrences) ===')
    print('These corrections were made by multiple users. Consider adding to your CLAUDE.md.\n')
    for i, s in enumerate(strong, 1):
        print(f\"  {i}. [{s['category']}] {s['pattern']}\")
        print(f\"     Occurrences: {s.get('global_occurrences',1)} | Promoted to: {s.get('promoted_to','memory')} | Type: {s.get('project_type','?')}\")
        print()

if emerging:
    print('=== Emerging (2 occurrences) ===')
    print('Growing patterns — watch these.\n')
    for s in emerging:
        print(f\"  - [{s['category']}] {s['pattern']}\")
    print()

if new:
    print(f'=== New ({len(new)} signals with 1 occurrence) ===')
    print('Single contributions — not yet patterns.\n')
    for s in new[:5]:
        print(f\"  - [{s['category']}] {s['pattern']}\")
    if len(new) > 5:
        print(f'  ... and {len(new)-5} more')
    print()

print(f'Total: {len(signals)} signals ({len(strong)} recommended, {len(emerging)} emerging, {len(new)} new)')
print()
print('To adopt a recommended signal, add it as a rule in your CLAUDE.md')
print('or run /self-improve to auto-promote.')
" "$all_signals"
  cleanup
  trap - EXIT
}

cmd_status() {
  local tmp_dir=""
  cleanup() { rm -rf "$tmp_dir"; }
  trap cleanup EXIT

  echo "Collective repo: $COLLECTIVE_REPO"

  if ! gh repo view "$COLLECTIVE_REPO" >/dev/null 2>&1; then
    echo "Status: not created"
    echo ""
    echo "Run: /collective init"
    cleanup
    trap - EXIT
    return 0
  fi

  echo "URL: https://github.com/$COLLECTIVE_REPO"
  echo "Key configured: $([ -n "${ALFRED_COLLECTIVE_KEY:-}" ] && echo "yes" || echo "no")"

  check_gh_auth

  # Count batches
  tmp_dir=$(mktemp -d)
  clone_repo "$tmp_dir"

  local batch_count=0
  local latest=""
  for enc_file in "$tmp_dir"/signals/*.enc; do
    [ -f "$enc_file" ] || continue
    batch_count=$((batch_count + 1))
    latest=$(basename "$enc_file" .enc)
  done

  cleanup
  trap - EXIT

  echo "Batches: $batch_count"
  if [ -n "$latest" ]; then
    echo "Latest: $latest"
  fi

  if [ -f "$PENDING_FILE" ]; then
    local pending_count
    pending_count=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    print(len(json.load(f).get('signals',[])))
" "$PENDING_FILE" 2>/dev/null || echo "?")
    echo "Pending (local): $pending_count signals"
  fi
}

# --- Main ---

cmd="${1:-status}"
shift || true

case "$cmd" in
  init)          cmd_init ;;
  contribute)    cmd_contribute "$@" ;;
  submit)        cmd_submit "$@" ;;
  push-pending)  cmd_push_pending ;;
  ingest)        cmd_ingest "$@" ;;
  status)        cmd_status ;;
  *)
    echo "Usage: collective-sync.sh <init|contribute|submit|push-pending|ingest|status>"
    echo ""
    echo "  init                 Create the private collective repo"
    echo "  contribute <file>    Encrypt and push signals to the repo (auto-detects path)"
    echo "  submit <file>        Submit signals as a GitHub issue (no key needed)"
    echo "  push-pending         Push pending signals (called by session-start hook)"
    echo "  ingest               Decrypt and display collective signals"
    echo "  status               Show repo info"
    exit 2
    ;;
esac
