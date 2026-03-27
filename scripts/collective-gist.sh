#!/usr/bin/env bash
# collective-gist.sh — Gist-based transport for Alfred collective learning signals.
#
# Usage:
#   collective-gist.sh init                  Create a new shared Gist
#   collective-gist.sh contribute <signals>  Contribute local signals JSON to the Gist
#   collective-gist.sh ingest [persona]      Read signals from the Gist, optionally filter by persona
#   collective-gist.sh status                Show Gist info and signal count
#
# Configuration: reads gist_id from .claude/alfred.yaml (collective.gist_id)
# or ALFRED_COLLECTIVE_GIST_ID environment variable.
set -euo pipefail

ALFRED_YAML=".claude/alfred.yaml"
GIST_FILENAME="alfred-signals.json"

# --- Helpers ---

die() { echo "ERROR: $*" >&2; exit 1; }

check_gh_auth() {
  if ! gh auth status >/dev/null 2>&1; then
    die "GitHub CLI not authenticated. Run 'gh auth login' or use /github-account-setup."
  fi
}

get_gist_id() {
  # Priority: env var > alfred.yaml
  if [ -n "${ALFRED_COLLECTIVE_GIST_ID:-}" ]; then
    echo "$ALFRED_COLLECTIVE_GIST_ID"
    return
  fi
  if [ -f "$ALFRED_YAML" ]; then
    local gist_id
    gist_id=$(grep -E '^\s*gist_id:' "$ALFRED_YAML" 2>/dev/null | head -1 | sed 's/.*gist_id:\s*//' | tr -d '"' | tr -d "'" | xargs)
    if [ -n "$gist_id" ]; then
      echo "$gist_id"
      return
    fi
  fi
  echo ""
}

save_gist_id() {
  local gist_id="$1"
  if [ ! -f "$ALFRED_YAML" ]; then
    cat > "$ALFRED_YAML" <<YAML
# Alfred project configuration
collective:
  gist_id: "$gist_id"
YAML
  elif grep -q "gist_id:" "$ALFRED_YAML" 2>/dev/null; then
    # Update existing gist_id
    sed -i.bak "s|gist_id:.*|gist_id: \"$gist_id\"|" "$ALFRED_YAML"
    rm -f "$ALFRED_YAML.bak"
  else
    # Append collective section
    cat >> "$ALFRED_YAML" <<YAML

collective:
  gist_id: "$gist_id"
YAML
  fi
}

# --- Commands ---

cmd_init() {
  check_gh_auth

  local existing_id
  existing_id=$(get_gist_id)
  if [ -n "$existing_id" ]; then
    echo "Collective Gist already configured: $existing_id"
    echo "To create a new one, remove gist_id from $ALFRED_YAML first."
    return 0
  fi

  echo "Creating new Alfred Collective Gist..."

  # Create with empty signals array
  local empty_signals
  empty_signals='{"schema_version":"1.0","signals":[],"last_updated":"'"$(date +%Y-%m-%d)"'"}'
  local tmp_dir
  tmp_dir=$(mktemp -d)
  echo "$empty_signals" > "$tmp_dir/$GIST_FILENAME"

  local gist_url
  gist_url=$(gh gist create "$tmp_dir/$GIST_FILENAME" --desc "Alfred Collective Learning Signals" 2>&1)
  rm -rf "$tmp_dir"

  # Extract Gist ID from URL
  local gist_id
  gist_id=$(echo "$gist_url" | grep -oE '[a-f0-9]{20,}' | head -1)

  if [ -z "$gist_id" ]; then
    die "Failed to create Gist. Output: $gist_url"
  fi

  save_gist_id "$gist_id"

  echo ""
  echo "Collective Gist created."
  echo "  ID:  $gist_id"
  echo "  URL: https://gist.github.com/$gist_id"
  echo ""
  echo "Share this ID with teammates. They add it to their .claude/alfred.yaml:"
  echo "  collective:"
  echo "    gist_id: \"$gist_id\""
}

cmd_contribute() {
  local signals_file="${1:-}"
  if [ -z "$signals_file" ] || [ ! -f "$signals_file" ]; then
    die "Usage: collective-gist.sh contribute <signals.json>"
  fi

  check_gh_auth

  local gist_id
  gist_id=$(get_gist_id)
  if [ -z "$gist_id" ]; then
    die "No Gist configured. Run: collective-gist.sh init"
  fi

  echo "Reading current collective signals..."

  # Fetch current Gist content to a temp file (avoids heredoc quoting issues)
  local current_file
  current_file=$(mktemp)
  gh gist view "$gist_id" --filename "$GIST_FILENAME" > "$current_file" 2>/dev/null || echo '{"signals":[]}' > "$current_file"

  # Merge signals using Python (handles deduplication)
  local merged_file
  merged_file=$(mktemp)
  local today
  today=$(date +%Y-%m-%d)

  local stats
  stats=$(python3 -c "
import json, sys, hashlib

def signal_id(s):
    key = s.get('category','') + ':' + s.get('pattern','')[:100].lower()
    return hashlib.sha256(key.encode()).hexdigest()[:16]

with open('$current_file') as f:
    current = json.load(f)
existing = {signal_id(s): s for s in current.get('signals', [])}

with open('$signals_file') as f:
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
        s['contributed_at'] = '$today'
        existing[sid] = s
        added += 1

output = {
    'schema_version': '1.0',
    'last_updated': '$today',
    'signals': list(existing.values()),
}
with open('$merged_file', 'w') as f:
    json.dump(output, f, indent=2)
print(f'{added} new, {updated} updated, {len(existing)} total')
")
  rm -f "$current_file"

  # Write merged content back to Gist
  gh gist edit "$gist_id" --filename "$GIST_FILENAME" "$merged_file" >/dev/null 2>&1
  rm -f "$merged_file"

  echo "Contributed to collective: $stats"
  echo ""
  echo "Signals are anonymized. No file paths, code, or identifiers were shared."
}

cmd_ingest() {
  local filter_persona="${1:-}"

  check_gh_auth

  local gist_id
  gist_id=$(get_gist_id)
  if [ -z "$gist_id" ]; then
    die "No Gist configured. Run: collective-gist.sh init"
  fi

  echo "Fetching collective signals..."

  local content
  content=$(gh gist view "$gist_id" --filename "$GIST_FILENAME" 2>/dev/null)

  if [ -z "$content" ]; then
    echo "No signals found in collective."
    return 0
  fi

  # Filter and display using Python
  echo "$content" | python3 -c "
import json, sys

data = json.load(sys.stdin)
signals = data.get('signals', [])

if not signals:
    print('No signals in collective yet.')
    sys.exit(0)

# Filter by project type (persona maps to project type loosely)
filter_type = '$filter_persona'

# Sort by global_occurrences descending
signals.sort(key=lambda s: s.get('global_occurrences', 1), reverse=True)

# Categorize
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
"
}

cmd_status() {
  local gist_id
  gist_id=$(get_gist_id)

  if [ -z "$gist_id" ]; then
    echo "Collective: not configured"
    echo ""
    echo "Run: /collective init — to create a shared Gist"
    echo "Or add a gist_id to .claude/alfred.yaml to join an existing collective."
    return 0
  fi

  check_gh_auth

  echo "Collective Gist: $gist_id"
  echo "URL: https://gist.github.com/$gist_id"

  local content
  content=$(gh gist view "$gist_id" --filename "$GIST_FILENAME" 2>/dev/null || echo '{"signals":[]}')

  echo "$content" | python3 -c "
import json, sys
data = json.load(sys.stdin)
signals = data.get('signals', [])
updated = data.get('last_updated', 'unknown')
strong = sum(1 for s in signals if s.get('global_occurrences', 1) >= 3)
print(f'Last updated: {updated}')
print(f'Total signals: {len(signals)}')
print(f'Recommended (3+): {strong}')
categories = {}
for s in signals:
    c = s.get('category', 'unknown')
    categories[c] = categories.get(c, 0) + 1
if categories:
    print('By category:')
    for c, n in sorted(categories.items(), key=lambda x: -x[1]):
        print(f'  {c}: {n}')
"
}

# --- Main ---

cmd="${1:-status}"
shift || true

case "$cmd" in
  init)       cmd_init ;;
  contribute) cmd_contribute "$@" ;;
  ingest)     cmd_ingest "$@" ;;
  status)     cmd_status ;;
  *)
    echo "Usage: collective-gist.sh <init|contribute|ingest|status>"
    echo ""
    echo "  init                 Create a new shared Gist for your team"
    echo "  contribute <file>    Contribute local signals to the collective"
    echo "  ingest [persona]     Read and display collective signals"
    echo "  status               Show Gist info and signal count"
    exit 2
    ;;
esac
