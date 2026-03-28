#!/usr/bin/env bash
# Stop hook: systemMessage telling Claude to record pilot telemetry
# This outputs a systemMessage that Claude reads at session end

# Only fire if user has consented
if [ ! -f ".claude/.pilot-consent.json" ]; then
    exit 0
fi

consented=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1])).get('consented', False))" ".claude/.pilot-consent.json" 2>/dev/null)
if [ "$consented" != "True" ]; then
    exit 0
fi

# Read identity
if [ ! -f ".claude/.pilot-identity.json" ]; then
    exit 0
fi

uuid=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1]))['anonymous_id'])" ".claude/.pilot-identity.json" 2>/dev/null)
if [ -z "$uuid" ]; then
    exit 0
fi

# Detect Alfred root for script references
ALFRED_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

# Calculate duration bucket
duration_bucket="unknown"
if [ -f ".claude/.pilot-session-start" ]; then
    start_epoch=$(cat ".claude/.pilot-session-start" 2>/dev/null)
    now_epoch=$(date +%s)
    if [ -n "$start_epoch" ]; then
        elapsed=$(( now_epoch - start_epoch ))
        if [ "$elapsed" -lt 300 ]; then
            duration_bucket="short"
        elif [ "$elapsed" -lt 1800 ]; then
            duration_bucket="medium"
        else
            duration_bucket="long"
        fi
    fi
fi

# Read onboarding state for context
persona="unknown"
coding_level="unknown"
code_complexity_level=1
if [ -f ".claude/.onboarding-state.json" ]; then
    persona=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1])).get('persona','unknown'))" ".claude/.onboarding-state.json" 2>/dev/null)
    coding_level=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1])).get('coding_level','unknown'))" ".claude/.onboarding-state.json" 2>/dev/null)
    code_complexity_level=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1])).get('code_complexity_level',1))" ".claude/.onboarding-state.json" 2>/dev/null)
fi

# Determine branch type
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
branch_type="other"
case "$branch" in
    feat/*|feature/*) branch_type="feat" ;;
    fix/*|bugfix/*|hotfix/*) branch_type="fix" ;;
    chore/*) branch_type="chore" ;;
    refactor/*) branch_type="refactor" ;;
    main|master) branch_type="main" ;;
esac

today=$(date +%Y-%m-%d)
telemetry_file=".pilot/telemetry/${uuid}.json"

# Get current session number
session_number=1
if [ -f "$telemetry_file" ]; then
    session_number=$(python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
print(len(d.get('sessions', [])) + 1)
" "$telemetry_file" 2>/dev/null || echo 1)
fi

# Output systemMessage for Claude to act on
cat >&2 << SYSMSG
PILOT TELEMETRY — Record session data now.

Update or create $telemetry_file with this session's data:
- anonymous_id: $uuid
- persona: $persona
- coding_level: $coding_level
- code_complexity_level: $code_complexity_level
- session_number: $session_number
- date: $today
- duration_bucket: $duration_bucket
- branch_type: $branch_type

Append a new session entry to the sessions array. Include:
- commands_used: list of /slash commands used this session (names only, no arguments)
- graduated_this_session: pattern names graduated this session (check .claude/.onboarding-state.json)
- patterns_state: current state of all patterns from .claude/.onboarding-state.json
- feedback_memory_count: count of feedback memories saved this session
- bookmark_saved: whether a bookmark was saved

Update the aggregates object:
- total_sessions: length of sessions array
- total_patterns_graduated: count of graduated patterns
- graduation_order: ordered list of graduated pattern names
- most_used_commands: top commands across all sessions
- days_active: count of unique dates in sessions
- first_graduation_session: session_number of first graduation (or null)

Also include these persona intelligence fields:
- used_custom_role: true if custom_role_description exists in onboarding state, false otherwise
- persona_fit: value of persona_fit from onboarding state (true/false/null if not yet checked)
- custom_role_category: value of custom_role_category from onboarding state (enum from collective/role-categories.yaml, or null)

Schema must include: _schema_version "1.1", _collected_by "alfred-pilot-telemetry", _privacy_notice.
NEVER include file paths, branch names, commit messages, project names, free-text descriptions, or any PII/PHI.
NEVER include custom_role_description or persona_gap — these are local-only fields.
SYSMSG

# Aggregate collective signals locally (no network call — fast)
# These will be pushed on next session start by session-start.sh
# Scan all project memory dirs for feedback files (handles path variations)
active_memory_dir=""
while IFS= read -r feedback_file; do
    active_memory_dir=$(dirname "$feedback_file")
    break
done < <(find "$HOME/.claude/projects" -name "feedback_*.md" -type f 2>/dev/null | head -1)

if [ -n "$active_memory_dir" ] && [ -f "$ALFRED_ROOT/collective/aggregator.py" ]; then
    python3 "$ALFRED_ROOT/collective/aggregator.py" "$active_memory_dir" --save .claude/.collective-pending.json >/dev/null 2>&1 || true
fi

exit 0
