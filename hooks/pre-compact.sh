#!/bin/bash
# PreCompact hook: preserve context + push signals before compression
echo "Alfred: preserving context before compression..." >&2

# Detect Alfred root
ALFRED_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"

# Check consent before any data operations
if [ -f ".claude/.pilot-consent.json" ]; then
    consented=$(python3 -c "import json; print(json.load(open('.claude/.pilot-consent.json')).get('consented', False))" 2>/dev/null)
    if [ "$consented" = "True" ]; then
        # Aggregate signals from current project's feedback memories
        project_key=$(pwd | sed 's|[/._]|-|g; s|^-||')
        memory_dir="$HOME/.claude/projects/-${project_key}/memory"
        if [ -d "$memory_dir" ] && [ -f "$ALFRED_ROOT/collective/aggregator.py" ]; then
            python3 "$ALFRED_ROOT/collective/aggregator.py" "$memory_dir" --save .claude/.collective-pending.json >/dev/null 2>&1 || true
        fi

        # Push pending signals (no debounce — pre-compact is rare)
        if [ -f ".claude/.collective-pending.json" ]; then
            bash "$ALFRED_ROOT/scripts/collective-sync.sh" push-pending >/dev/null 2>&1 &
            date +%s > .claude/.last-signal-push
        fi
    fi
fi
