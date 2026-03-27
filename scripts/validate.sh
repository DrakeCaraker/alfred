#!/usr/bin/env bash
# validate.sh — Structural validation checks shared by CI and local `make check`.
# Covers: conflict markers, JSON, YAML, command sync, shell syntax.
# Shellcheck and smoke tests are handled separately (Makefile lint/test targets).
set -euo pipefail

errors=0

# --- Conflict markers ---
echo "==> Checking for merge conflict markers..."
# Build pattern from parts so this file doesn't match itself
marker="<""<""<""<""<""<""< "
if grep -rl "$marker" --include="*.md" --include="*.sh" --include="*.json" --include="*.yaml" --include="*.yml" . 2>/dev/null | grep -v ".git/"; then
  echo "ERROR: Merge conflict markers found in tracked files"
  errors=1
else
  echo "No conflict markers found"
fi

# --- JSON validation ---
echo ""
echo "==> Validating JSON files..."
json_files=(
  .claude/settings.json
  .claude-plugin/plugin.json
  package.json
  hooks/hooks.json
)
for f in "${json_files[@]}"; do
  if [ -f "$f" ]; then
    if python3 -m json.tool "$f" > /dev/null 2>&1; then
      echo "$f: valid"
    else
      echo "ERROR: $f is invalid JSON"
      errors=1
    fi
  fi
done

# --- YAML validation ---
echo ""
echo "==> Validating YAML files..."
if python3 -c "import yaml" 2>/dev/null; then
  python3 -c "
import yaml, sys
files = [
    'personas/_schema.yaml',
    'personas/_default.yaml',
    'alfred.schema.yaml',
    'collective/signal_schema.yaml',
    'collective/role-categories.yaml',
]
ok = True
for f in files:
    try:
        yaml.safe_load(open(f))
        print(f'{f}: valid')
    except FileNotFoundError:
        pass
    except Exception as e:
        print(f'{f}: INVALID — {e}')
        ok = False
if not ok:
    sys.exit(1)
" || errors=1
else
  echo "SKIP: pyyaml not installed (pip install pyyaml). CI will still validate."
fi

# --- Command copy sync ---
echo ""
echo "==> Verifying command copies in sync..."
for f in .claude/commands/*.md; do
  base=$(basename "$f")
  if [ -f "commands/$base" ]; then
    if ! diff -q "$f" "commands/$base" > /dev/null 2>&1; then
      echo "ERROR: commands/$base is out of sync with .claude/commands/$base"
      diff "$f" "commands/$base" | head -20 || true
      errors=1
    fi
  fi
done
if [ "$errors" -eq 0 ]; then
  echo "All command copies in sync"
fi

# --- Shell syntax ---
echo ""
echo "==> Checking shell script syntax..."
for sh in .claude/hooks/*.sh .githooks/pre-push .githooks/pre-commit scripts/*.sh; do
  if [ -f "$sh" ]; then
    if bash -n "$sh" 2>/dev/null; then
      echo "$sh: syntax OK"
    else
      echo "ERROR: $sh has syntax errors"
      errors=1
    fi
  fi
done

# --- Result ---
echo ""
if [ "$errors" -ne 0 ]; then
  echo "Validation FAILED. Run 'make fix' to auto-fix deterministic issues."
  exit 1
fi
echo "All validation checks passed."
