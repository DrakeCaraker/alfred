#!/usr/bin/env bash
# audit.sh — Security and quality linting beyond shellcheck.
# Catches patterns that caused real bugs in Alfred's audit history.
set -euo pipefail

errors=0
warnings=0

warn() { echo "WARN: $*"; warnings=$((warnings + 1)); }
fail() { echo "FAIL: $*"; errors=$((errors + 1)); }

# --- 1. GitHub Actions injection ---
echo "==> Checking for GitHub Actions injection patterns..."
for f in .github/workflows/*.yml; do
  [ -f "$f" ] || continue
  # Check for ${{ }} inside run: blocks (potential injection)
  # Safe pattern: ${{ inputs.* }} in env: blocks. Unsafe: in run: blocks directly.
  if grep -n 'run:' "$f" | while read -r line_info; do
    line_num=$(echo "$line_info" | cut -d: -f1)
    # Scan the next 20 lines after each run: for direct ${{ inputs. or ${{ github.event.
    sed -n "$((line_num + 1)),$((line_num + 20))p" "$f" | grep -qE '\$\{\{\s*(inputs\.|github\.event\.)' && echo "$f:$line_num"
  done | grep -q .; then
    fail "$f: \${{ inputs.* }} or \${{ github.event.* }} found inside run: block (use env: instead)"
  fi
done
if [ "$errors" -eq 0 ]; then
  echo "No injection patterns found"
fi

# --- 2. mktemp without trap ---
echo ""
echo "==> Checking for mktemp without cleanup traps..."
for sh in scripts/*.sh .claude/hooks/*.sh; do
  [ -f "$sh" ] || continue
  if grep -q 'mktemp' "$sh"; then
    if ! grep -q 'trap.*cleanup\|trap.*rm\|trap.*EXIT' "$sh"; then
      fail "$sh: uses mktemp but has no trap for cleanup"
    fi
  fi
done
if [ "$errors" -eq 0 ]; then
  echo "All mktemp usage has cleanup traps"
fi

# --- 3. Python shell injection ---
echo ""
echo "==> Checking for shell variable injection in Python blocks..."
prev_errors=$errors
for sh in scripts/*.sh .claude/hooks/*.sh; do
  [ -f "$sh" ] || continue
  # Skip hooks that only use internal paths (not user input) — low injection risk
  case "$sh" in
    *session-start.sh|*session-bookmark.sh) continue ;;
  esac
  # Look for python3 -c blocks containing '$VARIABLE' (shell var in Python string)
  # Safe pattern: sys.argv[N]. Unsafe: '$var' or "$var" inside Python code.
  if grep -n "python3 -c" "$sh" | while read -r match; do
    line_num=$(echo "$match" | cut -d: -f1)
    # Check next 30 lines for '$SHELL_VAR' pattern (single-quoted shell var in Python)
    block=$(sed -n "$((line_num)),$((line_num + 30))p" "$sh")
    # Match patterns like open('$var') or = '$var' but not sys.argv
    if echo "$block" | grep -qE "'\\\$[A-Z_]+" && ! echo "$block" | grep -q "sys.argv"; then
      echo "$sh:$line_num"
    fi
  done | grep -q .; then
    fail "$sh: Python -c block uses '\$VAR' instead of sys.argv (injection risk)"
  fi
done
if [ "$errors" -eq "$prev_errors" ]; then
  echo "No Python injection patterns found"
fi

# --- 4. Command sync completeness ---
echo ""
echo "==> Checking command sync completeness..."
prev_errors=$errors
for f in .claude/commands/*.md; do
  base=$(basename "$f")
  if [ ! -f "commands/$base" ]; then
    fail "commands/$base missing (exists in .claude/commands/)"
  fi
done
for f in commands/*.md; do
  base=$(basename "$f")
  if [ ! -f ".claude/commands/$base" ]; then
    warn "commands/$base exists but not in .claude/commands/ (orphan?)"
  fi
done
if [ "$errors" -eq "$prev_errors" ]; then
  echo "All command copies present"
fi

# --- 5. Hook sync completeness ---
echo ""
echo "==> Checking hook sync completeness..."
prev_errors=$errors
for f in .claude/hooks/*.sh; do
  base=$(basename "$f")
  if [ ! -f "hooks/$base" ]; then
    fail "hooks/$base missing (exists in .claude/hooks/)"
  elif ! diff -q "$f" "hooks/$base" > /dev/null 2>&1; then
    fail "hooks/$base is out of sync with .claude/hooks/$base"
  fi
done
if [ "$errors" -eq "$prev_errors" ]; then
  echo "All hook copies in sync"
fi

# --- 6. Hardcoded paths ---
echo ""
echo "==> Checking for hardcoded user paths..."
prev_errors=$errors
for f in scripts/*.sh .claude/hooks/*.sh .claude/commands/*.md; do
  [ -f "$f" ] || continue
  # Skip test files and documentation (they legitimately contain example paths)
  case "$f" in
    *test-pii*|*smoke-test*|*pilot-report*|*anonymizer*) continue ;;
  esac
  if grep -nE '/Users/[a-zA-Z]|/home/[a-zA-Z]|C:\\Users\\' "$f" | grep -v '# ' | grep -v 'grep.*Users' | grep -v 'REDACT' | grep -v '\[PATH\]' | grep -v 'example\|Example\|pattern' | head -1 | grep -q .; then
    fail "$f: contains hardcoded user path"
  fi
done
if [ "$errors" -eq "$prev_errors" ]; then
  echo "No hardcoded paths found"
fi

# --- 7. Secrets in tracked files ---
echo ""
echo "==> Checking for potential secrets..."
prev_errors=$errors
for f in $(git ls-files 2>/dev/null); do
  [ -f "$f" ] || continue
  case "$f" in
    *.enc|*.pyc|*.git*) continue ;;
  esac
  if grep -lE 'sk-[a-zA-Z0-9]{20,}|AKIA[A-Z0-9]{16}|password\s*=\s*["\x27][^"\x27]{8,}' "$f" 2>/dev/null | grep -v 'anonymizer\|pii-scanner\|test-pii\|README' | head -1 | grep -q .; then
    fail "$f: potential secret or API key"
  fi
done
if [ "$errors" -eq "$prev_errors" ]; then
  echo "No secrets found"
fi

# --- 8. Doc-code consistency ---
echo ""
echo "==> Checking doc-code consistency..."
prev_errors=$errors

# Command count in README should match commands/ directory
readme_cmds=$(grep -c '| `/[a-z]' README.md 2>/dev/null || echo 0)
actual_cmds=$(ls commands/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$readme_cmds" -ne "$actual_cmds" ]; then
  fail "README lists $readme_cmds commands but commands/ has $actual_cmds files"
fi

# CLAUDE.md command table should mention /audit
if ! grep -q '/audit' CLAUDE.md 2>/dev/null; then
  fail "CLAUDE.md command table missing /audit"
fi

# All hooks in .claude/hooks/ should be listed in CLAUDE.md
for f in .claude/hooks/*.sh; do
  name=$(basename "$f" .sh)
  # Convert to a search-friendly form (session-start → session.start or session)
  short=$(echo "$name" | cut -d- -f1)
  if ! grep -qi "$short" CLAUDE.md 2>/dev/null; then
    warn "CLAUDE.md may not mention hook: $name"
  fi
done

# Version consistency: plugin.json and package.json should match
plugin_ver=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "?")
package_ver=$(python3 -c "import json; print(json.load(open('package.json'))['version'])" 2>/dev/null || echo "?")
if [ "$plugin_ver" != "$package_ver" ]; then
  fail "Version mismatch: plugin.json=$plugin_ver, package.json=$package_ver"
fi

if [ "$errors" -eq "$prev_errors" ]; then
  echo "All doc-code checks passed"
fi

# --- Result ---
echo ""
echo "================================="
echo "Audit: $errors failures, $warnings warnings"
if [ "$errors" -gt 0 ]; then
  echo "Run 'make fix' for sync issues, or fix manually for security issues."
  exit 1
fi
echo "All checks passed."
