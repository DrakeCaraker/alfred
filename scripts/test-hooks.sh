#!/usr/bin/env bash
# Test that hook output is user-friendly, not raw Claude instructions
set -euo pipefail

PASS=0
FAIL=0

pass() { echo "  [PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL + 1)); }

echo "Hook Output Tests"
echo "=================="

# Test each message hook for user-friendly output
for hook in .claude/hooks/session-bookmark.sh .claude/hooks/feedback-capture.sh .claude/hooks/pre-compact.sh; do
    name=$(basename "$hook")

    if [ ! -f "$hook" ]; then
        fail "$name: file not found"
        continue
    fi

    output=$(bash "$hook" 2>&1 || true)

    # Should contain "Alfred:" prefix
    if echo "$output" | grep -q "Alfred:"; then
        pass "$name: has user-friendly 'Alfred:' prefix"
    else
        fail "$name: missing 'Alfred:' prefix — got: $output"
    fi

    # Should NOT contain systemMessage (old format)
    if echo "$output" | grep -qi "systemMessage"; then
        fail "$name: contains raw systemMessage (should be user-friendly)"
    else
        pass "$name: no raw systemMessage"
    fi

    # Should NOT contain implementation details
    for bad_word in ".json" "Format as JSON" "keys:" "Save a session" "check if any user corrections"; do
        if echo "$output" | grep -qi "$bad_word"; then
            fail "$name: contains implementation detail: '$bad_word'"
        fi
    done
    pass "$name: no implementation details leaked"
done

# Test that plugin hooks match .claude/hooks
echo ""
echo "Hook sync check:"
for hook in hooks/session-bookmark.sh hooks/feedback-capture.sh hooks/pre-compact.sh; do
    name=$(basename "$hook")
    claude_hook=".claude/hooks/$name"
    if [ -f "$hook" ] && [ -f "$claude_hook" ]; then
        if diff -q "$hook" "$claude_hook" > /dev/null 2>&1; then
            pass "$name: plugin hook matches .claude/ hook"
        else
            fail "$name: plugin hook differs from .claude/ hook"
        fi
    fi
done

echo ""
echo "=================="
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then exit 1; fi
