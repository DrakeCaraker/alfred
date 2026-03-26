#!/bin/bash
# SessionStart hook: full warm-up for Alfred development sessions
# Prints status info to stderr so it appears as hook output

echo "=== Alfred Session Warm-Up ===" >&2

# Detect coding level for beginner-friendly output
state_file=".claude/.onboarding-state.json"
coding_level="intermediate"
if [ -f "$state_file" ]; then
    coding_level=$(python3 -c "import json; d=json.load(open('$state_file')); print(d.get('coding_level','intermediate'))" 2>/dev/null || echo "intermediate")
fi

# 1. Git status — uncommitted changes
dirty=$(git status --porcelain 2>/dev/null | head -20)
if [ -n "$dirty" ]; then
    count=$(echo "$dirty" | wc -l)
    echo "" >&2
    if [ "$coding_level" = "beginner" ]; then
        echo "You have $count unsaved change(s) from last time." >&2
        echo "  (These are files you edited but haven't committed yet.)" >&2
        echo "  Run /commit when you're ready to save them." >&2
    else
        echo "Git: $count uncommitted change(s):" >&2
        echo "$dirty" >&2
    fi
else
    echo "" >&2
    if [ "$coding_level" = "beginner" ]; then
        echo "All your work is saved. Clean slate!" >&2
    else
        echo "Git: working tree clean" >&2
    fi
fi

# 2. Branch safety check (/new-work guard)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$branch" = "main" ]; then
    echo "" >&2
    if [ "$coding_level" = "beginner" ]; then
        echo "NOTE: You're on the 'main' branch — that's the official copy of your project." >&2
        echo "  Before making changes, run /new-work to create a safe workspace." >&2
        echo "  (This keeps your original safe while you experiment.)" >&2
    else
        echo "WARNING: You are on main. Create a feature branch before making changes:" >&2
        echo "  git checkout -b feat/<topic>" >&2
        echo "  Or run /new-work to set up a new task." >&2
    fi
fi

# 3. Branch drift check (skip for beginners — too noisy)
if [ "$coding_level" != "beginner" ]; then
    if [ "$branch" != "main" ] && [ "$branch" != "HEAD" ]; then
        git fetch origin main --quiet 2>/dev/null
        if git rev-parse origin/main >/dev/null 2>&1; then
            behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
            if [ "$behind" -gt 0 ]; then
                echo "" >&2
                echo "Drift: branch '$branch' is $behind commit(s) behind origin/main" >&2
                echo "  Rebase before pushing: git rebase origin/main" >&2
            else
                echo "" >&2
                echo "Drift: up to date with origin/main" >&2
            fi
        fi
    fi
fi

# 4. Verify git hooks are active (skip for beginners — they don't manage hooks)
if [ "$coding_level" != "beginner" ]; then
    hooks_path=$(git config core.hooksPath 2>/dev/null)
    if [ "$hooks_path" = ".githooks" ]; then
        echo "" >&2
        echo "Git hooks: active (.githooks)" >&2
    else
        echo "" >&2
        echo "Git hooks: NOT ACTIVE — run: git config core.hooksPath .githooks" >&2
    fi
fi

# 5. Session counter + self-improvement nudge
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
    echo "Improvement: $feedback_count feedback memories accumulated. Consider running /self-improve to promote recurring patterns to CLAUDE.md rules or hooks." >&2
elif [ "$session_count" -ge 10 ]; then
    echo "" >&2
    echo "Improvement: $session_count sessions since last /self-improve. Consider running /self-improve to check for new improvements." >&2
fi

# 7. Onboarding status
if [ -f "$state_file" ]; then
    persona=$(python3 -c "import json; d=json.load(open('$state_file')); print(d.get('persona','unknown'))" 2>/dev/null)
    graduated=$(python3 -c "import json; d=json.load(open('$state_file')); print(sum(1 for p in d.get('patterns',{}).values() if p.get('graduated')))" 2>/dev/null)
    total_patterns=8
    echo "" >&2
    if [ "$coding_level" = "beginner" ]; then
        echo "Alfred: $persona | Skills learned: $graduated of $total_patterns" >&2
    else
        echo "Alfred: $persona ($coding_level) | Patterns: $graduated/$total_patterns graduated" >&2
    fi
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
        if [ "$coding_level" = "beginner" ]; then
            echo "Tip: Run /teach for a short lesson, or just tell me what you want to build!" >&2
        else
            echo "Tip: Run /teach to learn your first development pattern" >&2
        fi
    elif [ "$graduated" -lt "$total_patterns" ]; then
        next_pattern=$(python3 -c "
import json
order = ['context_before_action','scope_before_work','save_points','safe_experimentation','one_change_one_test','automated_recovery','provenance','self_improvement']
names = {'context_before_action':'Context before action','scope_before_work':'Scope before work','save_points':'Save points','safe_experimentation':'Safe experimentation','one_change_one_test':'One change one test','automated_recovery':'Automated recovery','provenance':'Provenance','self_improvement':'Self-improvement'}
d = json.load(open('$state_file'))
for p in order:
    if not d.get('patterns',{}).get(p,{}).get('graduated',False):
        print(names.get(p,p)); break
" 2>/dev/null)
        echo "" >&2
        echo "Next pattern: $next_pattern — run /teach to continue" >&2
    elif [ "$graduated" = "$total_patterns" ]; then
        echo "" >&2
        echo "All patterns graduated! Run /health-check to assess project maturity." >&2
    fi
fi

echo "" >&2
echo "=================================" >&2

exit 0
