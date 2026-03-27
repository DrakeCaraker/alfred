#!/bin/bash
# SessionStart hook: full warm-up for Alfred development sessions
# Prints status info to stderr so it appears as hook output

echo "=== Alfred Session Warm-Up ===" >&2

# Read configured main branch from alfred.yaml (default: main)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MAIN_BRANCH=$("$REPO_ROOT/scripts/alfred-config.sh" git.main_branch main 2>/dev/null)

# 1. Git status — uncommitted changes
dirty=$(git status --porcelain 2>/dev/null | head -20)
if [ -n "$dirty" ]; then
    count=$(echo "$dirty" | wc -l)
    echo "" >&2
    echo "Git: $count uncommitted change(s):" >&2
    echo "$dirty" >&2
else
    echo "" >&2
    echo "Git: working tree clean" >&2
fi

# 2. Branch safety check (/new-work guard)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$branch" = "$MAIN_BRANCH" ]; then
    echo "" >&2
    echo "WARNING: You are on $MAIN_BRANCH. Create a feature branch before making changes:" >&2
    echo "  git checkout -b feat/<topic>" >&2
    echo "  Or run /new-work to set up a new task." >&2
fi

# 3. Branch drift check
if [ "$branch" != "$MAIN_BRANCH" ] && [ "$branch" != "HEAD" ]; then
    git fetch origin "$MAIN_BRANCH" --quiet 2>/dev/null
    if git rev-parse "origin/$MAIN_BRANCH" >/dev/null 2>&1; then
        behind=$(git rev-list --count "HEAD..origin/$MAIN_BRANCH" 2>/dev/null || echo 0)
        if [ "$behind" -gt 0 ]; then
            echo "" >&2
            echo "Drift: branch '$branch' is $behind commit(s) behind origin/$MAIN_BRANCH" >&2
            echo "  Rebase before pushing: git rebase origin/$MAIN_BRANCH" >&2
        else
            echo "" >&2
            echo "Drift: up to date with origin/$MAIN_BRANCH" >&2
        fi
    fi
fi

# 4. Verify git hooks are active
hooks_path=$(git config core.hooksPath 2>/dev/null)
if [ "$hooks_path" = ".githooks" ]; then
    echo "" >&2
    echo "Git hooks: active (.githooks)" >&2
else
    echo "" >&2
    echo "Git hooks: NOT ACTIVE — run: git config core.hooksPath .githooks" >&2
fi

# 5a. Pilot consent nudge (sessions 1, 3, 5 only)
if [ -f ".claude/.onboarding-state.json" ] && [ ! -f ".claude/.pilot-consent.json" ]; then
    nudge_file=".claude/.pilot-nudge-count"
    nudge_count=0
    if [ -f "$nudge_file" ]; then
        nudge_count=$(cat "$nudge_file" 2>/dev/null || echo 0)
    fi
    if [ "$nudge_count" -lt 5 ]; then
        # Show nudge on counts 0, 2, 4 (sessions 1, 3, 5)
        if [ "$((nudge_count % 2))" -eq 0 ]; then
            echo "" >&2
            echo "Pilot: Alfred has opt-in telemetry. Run /pilot-consent to learn what's collected." >&2
        fi
        echo "$((nudge_count + 1))" > "$nudge_file"
    fi
fi

# 5b. Session start timestamp for duration bucketing
date +%s > .claude/.pilot-session-start 2>/dev/null

# 5c. Session counter + self-improvement nudge
count_file=".claude/.session-count"
if [ -f "$count_file" ]; then
    session_count=$(cat "$count_file")
else
    session_count=0
fi
session_count=$((session_count + 1))
echo "$session_count" > "$count_file"

# Dynamic memory path
project_key=$(pwd | sed 's|/|-|g; s|^-||')
memory_dir="$HOME/.claude/projects/-${project_key}/memory"

# 6. Feedback memory accumulation check
feedback_count=$(ls "$memory_dir"/feedback_*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$feedback_count" -ge 5 ]; then
    echo "" >&2
    echo "Improvement: $feedback_count feedback memories accumulated. Consider running /self-improve to promote recurring corrections to CLAUDE.md rules or hooks." >&2
elif [ "$session_count" -ge 10 ]; then
    echo "" >&2
    echo "Improvement: $session_count sessions since last /self-improve. Consider running /self-improve to check for new improvements." >&2
fi

# 7. Onboarding status
state_file=".claude/.onboarding-state.json"
if [ -f "$state_file" ]; then
    persona=$(python3 -c "import json; d=json.load(open('$state_file')); print(d.get('persona','unknown'))" 2>/dev/null)
    coding_level=$(python3 -c "import json; d=json.load(open('$state_file')); print(d.get('coding_level','unknown'))" 2>/dev/null)
    graduated=$(python3 -c "import json; d=json.load(open('$state_file')); print(sum(1 for p in d.get('patterns',{}).values() if p.get('graduated')))" 2>/dev/null)
    total_habits=8
    echo "" >&2
    echo "Alfred: $persona ($coding_level) | Habits: $graduated/$total_habits graduated" >&2
else
    echo "" >&2
    echo "Alfred: Not bootstrapped. Run /bootstrap to get started." >&2
fi

# 8. Session bookmark resume
bookmark_file=".claude/.session-bookmark.json"
if [ -f "$bookmark_file" ]; then
    task=$(python3 -c "import json; d=json.load(open('$bookmark_file')); print(d.get('task','(no task recorded)'))" 2>/dev/null)
    bookmark_branch=$(python3 -c "import json; d=json.load(open('$bookmark_file')); print(d.get('branch','unknown'))" 2>/dev/null)
    echo "" >&2
    echo "Last session: $task (branch: $bookmark_branch)" >&2
    echo "  Continue where you left off, or start fresh with /new-work" >&2
fi

# 9. Proactive recommendations
if [ -f "$state_file" ]; then
    if [ "$graduated" = "0" ] && [ "$session_count" -le 3 ]; then
        echo "" >&2
        echo "Tip: Run /teach to learn your first development habit" >&2
    elif [ "$graduated" -lt "$total_habits" ]; then
        next_habit=$(python3 -c "
import json
order = ['context_before_action','scope_before_work','save_points','safe_experimentation','one_change_one_test','automated_recovery','provenance','self_improvement']
names = {'context_before_action':'Context before action','scope_before_work':'Scope before work','save_points':'Save points','safe_experimentation':'Safe experimentation','one_change_one_test':'One change one test','automated_recovery':'Automated recovery','provenance':'Provenance','self_improvement':'Self-improvement'}
d = json.load(open('$state_file'))
for p in order:
    if not d.get('patterns',{}).get(p,{}).get('graduated',False):
        print(names.get(p,p)); break
" 2>/dev/null)
        echo "" >&2
        echo "Next habit: $next_habit — run /teach to continue" >&2
    elif [ "$graduated" = "$total_habits" ]; then
        echo "" >&2
        echo "All habits graduated! Run /health-check to assess project maturity." >&2
    fi
fi

echo "" >&2
echo "=================================" >&2

exit 0
