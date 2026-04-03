#!/usr/bin/env bash
# Stop hook: write session telemetry directly (no Claude action needed)
# Fires after each Claude response. Writes JSON to .pilot/telemetry/

# Only fire if user has consented
if [ ! -f ".claude/.pilot-consent.json" ]; then
    exit 0
fi

consented=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1])).get('consented', False))" ".claude/.pilot-consent.json" 2>/dev/null)
if [ "$consented" != "True" ]; then
    exit 0
fi

# Read identity (support both "anonymous_id" and legacy "id" key)
if [ ! -f ".claude/.pilot-identity.json" ]; then
    exit 0
fi

uuid=$(python3 -c "import json, sys; d=json.load(open(sys.argv[1])); print(d.get('anonymous_id', d.get('id', '')))" ".claude/.pilot-identity.json" 2>/dev/null)
if [ -z "$uuid" ]; then
    exit 0
fi

# Detect Alfred root for script references
# Priority: CLAUDE_PLUGIN_ROOT > walk-up marker > .alfred-root file
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    ALFRED_ROOT="$CLAUDE_PLUGIN_ROOT"
else
    _dir="$(cd "$(dirname "$0")" && pwd)"
    ALFRED_ROOT=""
    while [ "$_dir" != "/" ]; do
        if [ -f "$_dir/collective/signal_schema.yaml" ]; then
            ALFRED_ROOT="$_dir"
            break
        fi
        _dir="$(dirname "$_dir")"
    done
    # Fallback: read stored path from bootstrap
    if [ -z "$ALFRED_ROOT" ] && [ -f ".claude/.alfred-root" ]; then
        ALFRED_ROOT=$(cat ".claude/.alfred-root" 2>/dev/null)
    fi
    # If still not found, hooks that need ALFRED_ROOT will silently skip
    if [ -z "$ALFRED_ROOT" ]; then
        ALFRED_ROOT=""
    fi
fi

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

# Read onboarding state
persona="unknown"
coding_level="unknown"
code_complexity_level=1
patterns_graduated=0
if [ -f ".claude/.onboarding-state.json" ]; then
    persona=$(python3 -c "import json; print(json.load(open('.claude/.onboarding-state.json')).get('persona','unknown'))" 2>/dev/null)
    coding_level=$(python3 -c "import json; print(json.load(open('.claude/.onboarding-state.json')).get('coding_level','unknown'))" 2>/dev/null)
    code_complexity_level=$(python3 -c "import json; print(json.load(open('.claude/.onboarding-state.json')).get('code_complexity_level',1))" 2>/dev/null)
    patterns_graduated=$(python3 -c "import json; d=json.load(open('.claude/.onboarding-state.json')); print(sum(1 for p in d.get('patterns',{}).values() if p.get('graduated')))" 2>/dev/null || echo 0)
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

# Count feedback memory files on disk
project_key=$(pwd | sed 's|[/._]|-|g; s|^-||')
memory_dir="$HOME/.claude/projects/-${project_key}/memory"
feedback_files_on_disk=$(ls "$memory_dir"/feedback_*.md 2>/dev/null | wc -l | tr -d ' ')

# Write telemetry directly via Python — no Claude action needed
mkdir -p .pilot/telemetry
export TELEM_FILE="$telemetry_file" TELEM_UUID="$uuid" TELEM_PERSONA="$persona" \
       TELEM_CODING_LEVEL="$coding_level" TELEM_CODE_COMPLEXITY="$code_complexity_level" \
       TELEM_DURATION="$duration_bucket" TELEM_BRANCH_TYPE="$branch_type" \
       TELEM_DATE="$today" TELEM_FEEDBACK_COUNT="$feedback_files_on_disk" \
       TELEM_PATTERNS_GRADUATED="$patterns_graduated"

python3 << 'PYEOF'
import json, os

tf = os.environ["TELEM_FILE"]
uuid = os.environ["TELEM_UUID"]
today = os.environ["TELEM_DATE"]

# Load existing or create new
if os.path.exists(tf):
    with open(tf) as f:
        data = json.load(f)
else:
    data = {
        "_schema_version": "1.1",
        "_collected_by": "alfred-pilot-telemetry",
        "_privacy_notice": "No file paths, branch names, commit messages, project names, or PII/PHI collected.",
        "anonymous_id": uuid,
        "persona": os.environ["TELEM_PERSONA"],
        "coding_level": os.environ["TELEM_CODING_LEVEL"],
        "code_complexity_level": int(os.environ["TELEM_CODE_COMPLEXITY"]),
        "sessions": [],
        "aggregates": {}
    }

# One entry per date (Stop fires after every response — deduplicate)
existing_dates = [s.get("date") for s in data.get("sessions", [])]
if today in existing_dates:
    # Update mutable fields only
    for s in data["sessions"]:
        if s.get("date") == today:
            s["duration_bucket"] = os.environ["TELEM_DURATION"]
            s["feedback_memory_count"] = int(os.environ["TELEM_FEEDBACK_COUNT"])
            break
else:
    data["sessions"].append({
        "session_number": len(data["sessions"]) + 1,
        "date": today,
        "duration_bucket": os.environ["TELEM_DURATION"],
        "branch_type": os.environ["TELEM_BRANCH_TYPE"],
        "commands_used": [],
        "graduated_this_session": [],
        "feedback_memory_count": int(os.environ["TELEM_FEEDBACK_COUNT"]),
        "bookmark_saved": os.path.exists(".claude/.session-bookmark.json")
    })

# Update aggregates
sessions = data.get("sessions", [])
data["aggregates"] = {
    "total_sessions": len(sessions),
    "total_patterns_graduated": int(os.environ["TELEM_PATTERNS_GRADUATED"]),
    "days_active": len(set(s.get("date") for s in sessions)),
}

with open(tf, "w") as f:
    json.dump(data, f, indent=2)
PYEOF

# Aggregate collective signals from current project's feedback memories
# Use project_key (already computed above) to scope to this project only
if [ -n "$ALFRED_ROOT" ] && [ -d "$memory_dir" ] && [ -f "$ALFRED_ROOT/collective/aggregator.py" ]; then
    python3 "$ALFRED_ROOT/collective/aggregator.py" "$memory_dir" --save .claude/.collective-pending.json >/dev/null 2>&1 || true
fi

# Push pending signals with 30-minute debounce (Stop fires after every response)
if [ -n "$ALFRED_ROOT" ] && [ -f ".claude/.collective-pending.json" ]; then
    should_push=false
    push_marker=".claude/.last-signal-push"
    if [ ! -f "$push_marker" ]; then
        should_push=true
    else
        last_push=$(cat "$push_marker" 2>/dev/null || echo 0)
        now_epoch=$(date +%s)
        if [ $((now_epoch - last_push)) -gt 1800 ]; then
            should_push=true
        fi
    fi
    if [ "$should_push" = true ]; then
        bash "$ALFRED_ROOT/scripts/collective-sync.sh" push-pending >/dev/null 2>&1 &
        date +%s > "$push_marker"
    fi
fi

exit 0
