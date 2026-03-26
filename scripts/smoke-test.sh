#!/usr/bin/env bash
# Alfred smoke test — validates project structure and content
set -uo pipefail

PASS=0
FAIL=0
WARN=0

check() {
    local desc="$1"
    local result="$2"
    if [ "$result" = "0" ]; then
        echo "  [PASS] $desc"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $desc"
        FAIL=$((FAIL + 1))
    fi
}

warn() {
    local desc="$1"
    echo "  [WARN] $desc"
    WARN=$((WARN + 1))
}

echo "Alfred Smoke Test"
echo "=================="
echo ""

# 1. Required files exist
echo "1. File structure"
for f in \
    README.md \
    CLAUDE.md \
    .gitignore \
    .githooks/pre-push \
    .claude/settings.json \
    .claude/tool-catalog.md \
    .claude/commands/bootstrap.md \
    .claude/commands/teach.md \
    .claude/commands/status.md \
    .claude/commands/commit.md \
    .claude/commands/new-work.md \
    .claude/commands/ci-fix.md \
    .claude/commands/self-improve.md \
    .claude/commands/health-check.md \
    .claude/commands/safe-refactor.md \
    .claude/commands/experiment-summary.md \
    .claude/commands/pr.md \
    .claude/hooks/session-start.sh \
    .claude/hooks/session-bookmark.sh \
    .claude/hooks/feedback-capture.sh \
    .claude/hooks/format-on-write.sh \
    .claude/hooks/pre-compact.sh \
    .claude/personas/ml-ds.md \
    .claude/personas/research.md \
    .claude/personas/business-analytics.md \
    .claude/personas/product-analytics.md \
    .claude/personas/platform-bi.md \
    .claude/personas/general.md \
    docs/AI_ASSISTED_DEV_GUIDE.md \
    scripts/smoke-test.sh \
    scripts/pii-scanner.sh \
    scripts/test-pii-scanner.sh \
    scripts/aggregate-pilot.sh \
    .claude/hooks/pilot-telemetry.sh \
    .claude/commands/pilot-consent.md \
    .claude/commands/pilot-report.md \
    .claude/commands/pilot-delete.md \
    .githooks/pre-commit \
    .pilot/README.md \
    .pilot/telemetry/.gitkeep \
    .pilot/feedback/.gitkeep; do
    test -f "$f"; check "$f exists" "$?"
done
echo ""

# 2. JSON validity
echo "2. JSON validity"
python3 -m json.tool .claude/settings.json > /dev/null 2>&1; check "settings.json is valid JSON" "$?"
echo ""

# 3. Shell script syntax
echo "3. Shell script syntax"
for sh in .claude/hooks/*.sh .githooks/pre-push .githooks/pre-commit; do
    bash -n "$sh" 2>/dev/null; check "$sh syntax OK" "$?"
done
echo ""

# 4. Shell scripts are executable
echo "4. Shell scripts executable"
for sh in .claude/hooks/*.sh .githooks/pre-push .githooks/pre-commit scripts/pii-scanner.sh scripts/test-pii-scanner.sh scripts/aggregate-pilot.sh; do
    test -x "$sh"; check "$sh is executable" "$?"
done
echo ""

# 5. Persona completeness
echo "5. Persona completeness"
for persona in .claude/personas/*.md; do
    name=$(basename "$persona")
    sections=$(grep -c '^## ' "$persona" 2>/dev/null || echo 0)
    if [ "$sections" -ge 9 ]; then
        check "$name has $sections sections (>= 9)" "0"
    else
        check "$name has $sections sections (>= 9)" "1"
    fi
    analogies=$(grep -c '|.*|.*|' "$persona" 2>/dev/null || echo 0)
    if [ "$analogies" -ge 9 ]; then  # 8 data rows + 1 header
        check "$name has $((analogies - 1))+ analogy entries" "0"
    else
        check "$name has $((analogies - 1)) analogy entries (need 8)" "1"
    fi
done
echo ""

# 6. No DASH-SHAP leakage
echo "6. DASH-SHAP content check"
leaks=$(grep -ril "dash.shap\|DASH-SHAP\|dash_shap" --include="*.md" --include="*.sh" .claude/ .githooks/ README.md CLAUDE.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$leaks" = "0" ]; then
    check "No DASH-SHAP references in project files" "0"
else
    check "No DASH-SHAP references in project files ($leaks files have references)" "1"
    grep -ril "dash.shap\|DASH-SHAP\|dash_shap" --include="*.md" --include="*.sh" .claude/ .githooks/ README.md CLAUDE.md 2>/dev/null | while read f; do
        echo "       → $f"
    done
fi
echo ""

# 7. Settings references valid
echo "7. Settings hook paths"
for hook_path in $(python3 -c "
import json
d = json.load(open('.claude/settings.json'))
for event_hooks in d.get('hooks', {}).values():
    for group in event_hooks:
        for h in group.get('hooks', []):
            if h.get('type') == 'command':
                print(h['command'])
" 2>/dev/null); do
    test -f "$hook_path"; check "Hook path $hook_path exists" "$?"
done
echo ""

# 8. No hardcoded user paths
echo "8. Hardcoded path check"
user_paths=$(grep -rl "/Users/drake" --include="*.md" --include="*.sh" --include="*.json" .claude/ .githooks/ README.md CLAUDE.md docs/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$user_paths" = "0" ]; then
    check "No hardcoded user paths" "0"
else
    check "No hardcoded user paths ($user_paths files)" "1"
fi
echo ""

# 9. Plugin structure
echo "9. Plugin structure"
for f in \
    .claude-plugin/plugin.json \
    package.json \
    hooks/hooks.json \
    alfred.schema.yaml \
    personas/_schema.yaml \
    personas/_default.yaml \
    skills/using-alfred/SKILL.md \
    skills/smart-suggestions/SKILL.md \
    skills/persona-management/SKILL.md \
    skills/persona-evolve/SKILL.md \
    skills/collective-contribute/SKILL.md \
    collective/signal_schema.yaml; do
    test -f "$f"; check "Plugin: $f exists" "$?"
done
# Plugin commands mirror .claude/commands
for cmd in bootstrap.md teach.md status.md commit.md new-work.md ci-fix.md self-improve.md health-check.md safe-refactor.md experiment-summary.md pr.md; do
    test -f "commands/$cmd"; check "Plugin command: $cmd exists" "$?"
done
# Plugin hooks mirror .claude/hooks
for hook in session-start.sh format-on-write.sh session-bookmark.sh feedback-capture.sh pre-compact.sh pilot-telemetry.sh; do
    test -f "hooks/$hook"; check "Plugin hook: $hook exists" "$?"
done
# Plugin personas mirror .claude/personas
for p in ml-ds.md research.md business-analytics.md product-analytics.md platform-bi.md general.md; do
    test -f "personas/$p"; check "Plugin persona: $p exists" "$?"
done
# JSON validity for plugin manifests
python3 -m json.tool .claude-plugin/plugin.json > /dev/null 2>&1; check "plugin.json is valid JSON" "$?"
python3 -m json.tool package.json > /dev/null 2>&1; check "package.json is valid JSON" "$?"
python3 -m json.tool hooks/hooks.json > /dev/null 2>&1; check "hooks.json is valid JSON" "$?"
echo ""

# 10. Pilot infrastructure
echo "10. Pilot infrastructure"
# PII scanner test suite
if bash scripts/test-pii-scanner.sh > /dev/null 2>&1; then
    check "PII scanner test suite passes" "0"
else
    check "PII scanner test suite passes" "1"
fi
# pilot-telemetry.sh registered in settings.json
pilot_hook=$(python3 -c "
import json
d = json.load(open('.claude/settings.json'))
for group in d.get('hooks', {}).get('Stop', []):
    for h in group.get('hooks', []):
        if 'pilot-telemetry' in h.get('command', ''):
            print('found')
            break
" 2>/dev/null)
if [ "$pilot_hook" = "found" ]; then
    check "pilot-telemetry.sh registered in Stop hooks" "0"
else
    check "pilot-telemetry.sh registered in Stop hooks" "1"
fi
echo ""

# Summary
echo "=================="
echo "Results: $PASS passed, $FAIL failed, $WARN warnings"
if [ "$FAIL" -gt 0 ]; then
    echo "STATUS: FAIL"
    exit 1
else
    echo "STATUS: PASS"
    exit 0
fi
