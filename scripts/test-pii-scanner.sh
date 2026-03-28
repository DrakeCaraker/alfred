#!/usr/bin/env bash
# Test suite for pii-scanner.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCANNER="$SCRIPT_DIR/pii-scanner.sh"
PASS=0
FAIL=0
TMPFILES=()
cleanup() { rm -f "${TMPFILES[@]}"; }
trap cleanup EXIT

expect_block() {
    local desc="$1"
    local input="$2"
    echo "$input" | "$SCANNER" --stdin "$desc" >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "  [PASS] BLOCKED: $desc"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] Expected BLOCK: $desc"
        FAIL=$((FAIL + 1))
    fi
}

expect_clean() {
    local desc="$1"
    local input="$2"
    echo "$input" | "$SCANNER" --stdin "$desc" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "  [PASS] CLEAN: $desc"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] Expected CLEAN: $desc"
        FAIL=$((FAIL + 1))
    fi
}

expect_warn_feedback() {
    local desc="$1"
    local input="$2"
    local tmpfile
    tmpfile=$(mktemp)
    TMPFILES+=("$tmpfile")
    echo "$input" > "$tmpfile"
    output=$("$SCANNER" --feedback "$tmpfile" 2>&1)
    exit_code=$?
    rm -f "$tmpfile"
    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "WARNING"; then
        echo "  [PASS] WARNING: $desc"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] Expected WARNING (exit 0): $desc (got exit $exit_code)"
        FAIL=$((FAIL + 1))
    fi
}

echo "PII Scanner Test Suite"
echo "======================"
echo ""

# --- Must-detect (hard blocks) ---
echo "Hard blocks (must detect):"
expect_block "email address" "user@company.com"
expect_block "SSN" "123-45-6789"
expect_block "IP address" "192.168.1.100"
expect_block "user path (macOS)" "/Users/drake.caraker/project"
expect_block "user path (Linux)" "/home/ubuntu/.ssh/key"
expect_block "API key token" "sk-abc123def456ghi789jkl012mno345pqr678stu"
expect_block "Bearer token" "Bearer eyJhbGciOiJIUzI1NiJ9"
expect_block "api_key assignment" 'api_key = "abc123"'
expect_block "hard PHI - patient diagnosis" "patient diagnosis confirmed"
expect_block "hard PHI - medical record" "medical record number"
echo ""

# --- Must-pass (clean) ---
echo "Clean inputs (must pass):"
expect_clean "valid telemetry JSON" '{"anonymous_id":"a1b2c3d4","persona":"ml-ds","sessions":[]}'
expect_clean "decimal number" "The stability was 0.977"
expect_clean "version string" '"1.0"'
expect_clean "date (not SSN)" "2026-03-25"
expect_clean "command reference" "Run /teach to learn save-points"
expect_clean "pattern reference" "Pattern #5: One change, one test"
expect_clean "localhost IP" "127.0.0.1"
expect_clean "zero IP" "0.0.0.0"
echo ""

# --- Warnings ---
echo "Warnings (exit 0 with warning):"
expect_warn_feedback "heart rate (feedback mode)" "heart rate analysis"
expect_warn_feedback "HRV (feedback mode)" "HRV-based sleep staging"
echo ""

# --- Summary ---
echo "======================"
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
    echo "STATUS: FAIL"
    exit 1
else
    echo "STATUS: PASS"
    exit 0
fi
