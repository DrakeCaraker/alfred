#!/bin/bash
# SessionStart hook: full warm-up for Alfred development sessions
# Prints status info to stderr so it appears as hook output

echo "=== Alfred Session Warm-Up ===" >&2

# Read configured main branch from alfred.yaml (default: main)
# Detect Alfred root: CLAUDE_PLUGIN_ROOT > walk-up marker > .alfred-root file
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
    if [ -z "$ALFRED_ROOT" ] && [ -f ".claude/.alfred-root" ]; then
        ALFRED_ROOT=$(cat ".claude/.alfred-root" 2>/dev/null)
    fi
fi
MAIN_BRANCH=$("$ALFRED_ROOT/scripts/alfred-config.sh" git.main_branch main 2>/dev/null)

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
if [ "$branch" = "$MAIN_BRANCH" ]; then
    echo "" >&2
    if [ "$coding_level" = "beginner" ]; then
        echo "NOTE: You're on the '$MAIN_BRANCH' branch — that's the official copy of your project." >&2
        echo "  Before making changes, run /new-work to create a safe workspace." >&2
        echo "  (This keeps your original safe while you experiment.)" >&2
    else
        echo "WARNING: You are on $MAIN_BRANCH. Create a feature branch before making changes:" >&2
        echo "  git checkout -b feat/<topic>" >&2
        echo "  Or run /new-work to set up a new task." >&2
    fi
fi

# 3. Branch drift check (skip for beginners — too noisy)
if [ "$coding_level" != "beginner" ]; then
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

# 4.5. Plugin update check (at most once per day, background fetch only)
# Notification is handled by the using-alfred skill (hook stderr isn't reliably visible)
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "$ALFRED_ROOT/.claude-plugin/plugin.json" ]; then
    cache_file="$HOME/.claude/.alfred-update-check"
    should_check=false

    if [ ! -f "$cache_file" ]; then
        should_check=true
    else
        last_check=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        now=$(date +%s)
        if [ $((now - last_check)) -gt 86400 ]; then
            should_check=true
        fi
    fi

    if [ "$should_check" = true ]; then
        (curl -s --max-time 5 "https://raw.githubusercontent.com/DrakeCaraker/alfred/main/.claude-plugin/plugin.json" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])" > "$cache_file" 2>/dev/null) &
    fi
fi

# 5a. Consent check — re-consent inline if stale, remind if missing
if [ -f ".claude/.pilot-consent.json" ]; then
    consent_ver=$(python3 -c "import json; print(json.load(open('.claude/.pilot-consent.json')).get('schema_version','1.0'))" 2>/dev/null || echo "1.0")
    # Read current required version from signal schema (single source of truth)
    required_ver=$(python3 -c "
import re
for line in open('${CLAUDE_PLUGIN_ROOT:-$ALFRED_ROOT}/collective/signal_schema.yaml'):
    m = re.match(r'schema_version:\s*[\"'\''](.*?)[\"'\'']', line)
    if m: print(m.group(1)); break
" 2>/dev/null || echo "2.0")
    if [ "$consent_ver" != "$required_ver" ]; then
        # Invalidate immediately — stop collecting until re-consented
        python3 -c "
import json
with open('.claude/.pilot-consent.json') as f:
    d = json.load(f)
d['consented'] = False
d['stale_reason'] = 'schema_version ' + d.get('schema_version','1.0') + ' < 3.0'
with open('.claude/.pilot-consent.json', 'w') as f:
    json.dump(d, f, indent=2)
" 2>/dev/null
        # Show re-consent question (Claude will process the user's response)
        echo "" >&2
        echo "=== Alfred Data Collection Update ===" >&2
        echo "" >&2
        echo "Alfred's data collection has expanded. Previously: corrections only." >&2
        echo "Now also includes (all anonymized and encrypted):" >&2
        echo "  - Which habits you graduate and how many sessions it takes" >&2
        echo "  - What CLAUDE.md rules you create (company names removed)" >&2
        echo "  - What automations you build (purpose only, no code)" >&2
        echo "" >&2
        echo "Still NEVER collected: your code, file paths, project names, or identity." >&2
        echo "" >&2
        echo "Do you consent to the expanded collection? (yes/no)" >&2
        echo "======================================" >&2
    fi
elif [ -f ".claude/.onboarding-state.json" ]; then
    echo "" >&2
    echo "Alfred: data collection not configured. Run /alfred:bootstrap or /pilot-consent." >&2
fi

# 5a.5. Persona fit nudge (one-time, at session 3+)
if [ -f ".claude/.onboarding-state.json" ] && [ ! -f ".claude/.persona-fit-nudged" ]; then
    fit_checked=$(python3 -c "import json; print(json.load(open('.claude/.onboarding-state.json')).get('persona_fit_checked', False))" 2>/dev/null)
    if [ "$fit_checked" != "True" ] && [ "$session_count" -ge 3 ] 2>/dev/null; then
        echo "" >&2
        if [ "$coding_level" = "beginner" ]; then
            echo "Quick check: Is Alfred using the right kind of examples for your work? Run /persona check" >&2
        else
            echo "Tip: Run /persona check to see if your current persona fits your work" >&2
        fi
        touch ".claude/.persona-fit-nudged"
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
project_key=$(pwd | sed 's|[/._]|-|g; s|^-||')
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

# 6.5. GitHub connection check
gh_user=$(gh auth status 2>&1 | grep -oP '(?<=Logged in to github.com account )\S+' | tr -d '()')
if [ -n "$gh_user" ]; then
    remote_url=$(git remote get-url origin 2>/dev/null)
    if [ -n "$remote_url" ]; then
        echo "" >&2
        echo "GitHub: $gh_user | repo: $remote_url" >&2
    else
        echo "" >&2
        echo "GitHub: $gh_user | no remote — run /github-account-setup to create a repo" >&2
    fi
else
    echo "" >&2
    echo "GitHub: not connected — run /github-account-setup to set up" >&2
fi

# 7. Onboarding status
if [ -f "$state_file" ]; then
    persona=$(python3 -c "import json; d=json.load(open('$state_file')); print(d.get('persona','unknown'))" 2>/dev/null)
    graduated=$(python3 -c "import json; d=json.load(open('$state_file')); print(sum(1 for p in d.get('patterns',{}).values() if p.get('graduated')))" 2>/dev/null)
    total_habits=8
    echo "" >&2
    if [ "$coding_level" = "beginner" ]; then
        echo "Alfred: $persona | Skills learned: $graduated of $total_habits" >&2
    else
        echo "Alfred: $persona ($coding_level) | Habits: $graduated/$total_habits graduated" >&2
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

# 8.5. Branch hygiene nudge
if [ "$branch" != "$MAIN_BRANCH" ] && [ "$branch" != "HEAD" ]; then
    commits_ahead=$(git rev-list --count "origin/$MAIN_BRANCH..HEAD" 2>/dev/null || echo 0)
    if [ "$commits_ahead" -ge 10 ]; then
        echo "" >&2
        echo "Branch hygiene: '$branch' is $commits_ahead commits ahead of $MAIN_BRANCH." >&2
        echo "  Consider opening a PR for what's done and starting a new branch." >&2
    fi
fi

# 8.7. Contextual prompting tips (sessions 2-5 only, one per session)
if [ "$session_count" -ge 2 ] && [ "$session_count" -le 5 ]; then
    tip_index=$(( (session_count - 2) % 4 ))
    case "$tip_index" in
        0) echo "" >&2; echo "Prompting tip: Describe what you want, not how to build it. State constraints upfront." >&2 ;;
        1) echo "" >&2; echo "Prompting tip: Say 'vet this' before committing to a plan. It catches issues early." >&2 ;;
        2) echo "" >&2; echo "Prompting tip: Ask for 2-3 approaches with trade-offs before picking one." >&2 ;;
        3) echo "" >&2; echo "Prompting tip: Say 'audit this' after completing work. It catches what you missed." >&2 ;;
    esac
fi

# 9. Proactive recommendations
if [ -f "$state_file" ]; then
    if [ "$graduated" = "0" ] && [ "$session_count" -le 3 ]; then
        echo "" >&2
        if [ "$coding_level" = "beginner" ]; then
            echo "Tip: Run /teach for a short lesson, or just tell me what you want to build!" >&2
        else
            echo "Tip: Run /teach to learn your first development habit" >&2
        fi
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

# 10. Push pending collective signals (silent, non-blocking)
# push-pending handles both paths: encrypted direct push (if key set) or
# RSA-encrypted issue submission (if no key). Don't gate on key here.
if [ -f ".claude/.collective-pending.json" ]; then
    bash "$ALFRED_ROOT/scripts/collective-sync.sh" push-pending >/dev/null 2>&1 &
fi

echo "" >&2
echo "=================================" >&2

exit 0
