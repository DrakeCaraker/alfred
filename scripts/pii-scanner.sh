#!/usr/bin/env bash
# PII/PHI scanner for Alfred pilot telemetry
# Usage:
#   pii-scanner.sh <file>              — scan a file
#   pii-scanner.sh --stdin <label>     — scan stdin, use label in output
#   pii-scanner.sh --feedback <file>   — scan with stricter feedback rules
#
# Exit codes: 0=clean, 1=PII found, 2=usage error

set -uo pipefail

FOUND=0
WARNINGS=0
MODE="standard"
LABEL=""
INPUT_FILE=""

# --- Parse arguments ---
if [ $# -eq 0 ]; then
    echo "Usage: pii-scanner.sh <file> | --stdin <label> | --feedback <file>" >&2
    exit 2
fi

if [ "$1" = "--stdin" ]; then
    if [ $# -lt 2 ]; then
        echo "Error: --stdin requires a label argument" >&2
        exit 2
    fi
    LABEL="$2"
    INPUT_FILE=$(mktemp)
    cat > "$INPUT_FILE"
    trap "rm -f '$INPUT_FILE'" EXIT
elif [ "$1" = "--feedback" ]; then
    if [ $# -lt 2 ]; then
        echo "Error: --feedback requires a file argument" >&2
        exit 2
    fi
    MODE="feedback"
    INPUT_FILE="$2"
    LABEL="$2"
else
    INPUT_FILE="$1"
    LABEL="$1"
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: file not found: $INPUT_FILE" >&2
    exit 2
fi

content=$(cat "$INPUT_FILE")

flag_pii() {
    local category="$1"
    local match="$2"
    echo "PII FOUND [$category] in $LABEL: $match" >&2
    FOUND=$((FOUND + 1))
}

flag_warn() {
    local category="$1"
    local match="$2"
    echo "WARNING [$category] in $LABEL: $match" >&2
    WARNINGS=$((WARNINGS + 1))
}

# --- Hard blocks ---

# Email addresses
while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "EMAIL" "$match"
done <<< "$(echo "$content" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')"

# SSN — skip date-formatted strings (YYYY-MM-DD)
while IFS= read -r match; do
    if [ -n "$match" ]; then
        # Check if this is a date (YYYY-MM-DD where YYYY >= 1900)
        if echo "$match" | grep -qE '^(19|20)[0-9]{2}-[0-1][0-9]-[0-3][0-9]$'; then
            continue
        fi
        flag_pii "SSN" "$match"
    fi
done <<< "$(echo "$content" | grep -oE '[0-9]{3}-[0-9]{2}-[0-9]{4}')"

# IP addresses — whitelist safe values and version strings
while IFS= read -r match; do
    if [ -n "$match" ]; then
        case "$match" in
            0.0.0.0|127.0.0.1) continue ;;
        esac
        # Skip version-like strings (e.g., "1.0" embedded in JSON)
        # Check if it looks like a real IP (all octets 0-255, at least one > 0)
        if echo "$match" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
            # Verify octets are valid IP range and not just version numbers
            valid_ip=true
            IFS='.' read -ra octets <<< "$match"
            for octet in "${octets[@]}"; do
                if [ "$octet" -gt 255 ] 2>/dev/null; then
                    valid_ip=false
                    break
                fi
            done
            if $valid_ip; then
                # Skip if it's a simple version-like pattern (first two octets only significant)
                if [ "${octets[2]}" = "0" ] && [ "${octets[3]}" = "0" ] && [ "${octets[0]}" -le 9 ]; then
                    continue
                fi
                flag_pii "IP_ADDRESS" "$match"
            fi
        fi
    fi
done <<< "$(echo "$content" | grep -oE '\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b')"

# User paths
while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "USER_PATH" "$match"
done <<< "$(echo "$content" | grep -oE '/Users/[^/[:space:]]+|/home/[^/[:space:]]+|C:\\Users\\[^\\[:space:]]+')"

# Auth tokens
while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "AUTH_TOKEN" "$match"
done <<< "$(echo "$content" | grep -oE 'sk-[a-zA-Z0-9]{20,}')"

while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "AUTH_TOKEN" "$match"
done <<< "$(echo "$content" | grep -oE 'Bearer[[:space:]]+\S+')"

while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "AUTH_TOKEN" "$match"
done <<< "$(echo "$content" | grep -oiE 'api_key[[:space:]]*=[[:space:]]*\S+')"

while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "AUTH_TOKEN" "$match"
done <<< "$(echo "$content" | grep -oiE 'password[[:space:]]*=[[:space:]]*\S+')"

while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "AUTH_TOKEN" "$match"
done <<< "$(echo "$content" | grep -oiE 'secret[[:space:]]*=[[:space:]]*\S+')"

# Hard PHI — case-insensitive
while IFS= read -r match; do
    [ -n "$match" ] && flag_pii "HARD_PHI" "$match"
done <<< "$(echo "$content" | grep -oiE '\b(patient|diagnosis|prescription|prognosis|medical record|health insurance|date of birth)\b')"

# --- Warnings (feedback mode or standard) ---

# Phone numbers (US) — always warn
while IFS= read -r match; do
    [ -n "$match" ] && flag_warn "PHONE_US" "$match"
done <<< "$(echo "$content" | grep -oE '\b[0-9]{3}[-.)][[:space:]]*[0-9]{3}[-. ][0-9]{4}\b')"

# Health product terms — warn in feedback mode
if [ "$MODE" = "feedback" ]; then
    while IFS= read -r match; do
        [ -n "$match" ] && flag_warn "HEALTH_TERM" "$match"
    done <<< "$(echo "$content" | grep -oiE '\b(heart rate|HRV|sleep score|readiness score|SpO2|blood pressure|body temperature)\b')"
fi

# --- Result ---
if [ "$FOUND" -gt 0 ]; then
    echo "BLOCKED: $FOUND PII/PHI finding(s) in $LABEL" >&2
    exit 1
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo "CLEAN with $WARNINGS warning(s) in $LABEL" >&2
fi

exit 0
