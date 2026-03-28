#!/usr/bin/env bash
# Test encryption roundtrip for collective learning signals
set -euo pipefail

PASS=0
FAIL=0
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass() { echo "  [PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL + 1)); }

PUBLIC_KEY="collective/keys/public.pem"

echo "Encryption Tests"
echo "================"

# Generate test signal JSON
cat > "$TMP/signals.json" << 'JSON'
{
  "schema_version": "1.0",
  "signals": [
    {"category": "testing", "pattern": "Test signal for encryption roundtrip", "local_occurrences": 1, "promoted_to": "memory", "project_type": "python"}
  ]
}
JSON

# Test 1: AES-256-CBC roundtrip
echo ""
echo "1. AES-256-CBC roundtrip"
openssl rand 32 > "$TMP/aes_key.bin"
openssl enc -aes-256-cbc -salt -pbkdf2 -pass "file:$TMP/aes_key.bin" -in "$TMP/signals.json" -out "$TMP/encrypted.bin" 2>/dev/null
openssl enc -d -aes-256-cbc -pbkdf2 -pass "file:$TMP/aes_key.bin" -in "$TMP/encrypted.bin" -out "$TMP/decrypted.json" 2>/dev/null
if diff -q "$TMP/signals.json" "$TMP/decrypted.json" > /dev/null 2>&1; then
    pass "AES encrypt → decrypt preserves content"
else
    fail "AES roundtrip: decrypted content differs from original"
fi

# Test 2: RSA public key can encrypt
echo ""
echo "2. RSA public key encryption"
if [ -f "$PUBLIC_KEY" ]; then
    if openssl pkeyutl -encrypt -pubin -inkey "$PUBLIC_KEY" -in "$TMP/aes_key.bin" -out "$TMP/aes_key.enc" 2>/dev/null; then
        pass "RSA public key encrypts AES key successfully"
        # Verify encrypted key is different from original
        if ! diff -q "$TMP/aes_key.bin" "$TMP/aes_key.enc" > /dev/null 2>&1; then
            pass "Encrypted key differs from plaintext key"
        else
            fail "Encrypted key is identical to plaintext (encryption didn't work)"
        fi
    else
        fail "RSA public key encryption failed"
    fi
else
    fail "Public key not found at $PUBLIC_KEY"
fi

# Test 3: Base64 roundtrip
echo ""
echo "3. Base64 roundtrip"
base64 < "$TMP/encrypted.bin" > "$TMP/encoded.b64"
base64 -d < "$TMP/encoded.b64" > "$TMP/decoded.bin"
if diff -q "$TMP/encrypted.bin" "$TMP/decoded.bin" > /dev/null 2>&1; then
    pass "Base64 encode → decode preserves binary content"
else
    fail "Base64 roundtrip: decoded content differs"
fi

# Test 4: Signal JSON schema validation
echo ""
echo "4. Signal format validation"
if python3 -c "
import json, sys
with open('$TMP/signals.json') as f:
    data = json.load(f)
assert 'schema_version' in data, 'missing schema_version'
assert 'signals' in data, 'missing signals array'
for sig in data['signals']:
    assert 'category' in sig, 'signal missing category'
    assert 'pattern' in sig, 'signal missing pattern'
    assert 'local_occurrences' in sig, 'signal missing local_occurrences'
    assert isinstance(sig['local_occurrences'], int), 'local_occurrences must be int'
    assert len(sig['pattern']) <= 500, 'pattern too long (max 500 chars)'
" 2>/dev/null; then
    pass "Signal JSON has required schema fields"
else
    fail "Signal JSON missing required fields or invalid types"
fi

# Test 5: Different AES keys produce different ciphertext
echo ""
echo "5. Key uniqueness"
openssl rand 32 > "$TMP/aes_key2.bin"
openssl enc -aes-256-cbc -salt -pbkdf2 -pass "file:$TMP/aes_key2.bin" -in "$TMP/signals.json" -out "$TMP/encrypted2.bin" 2>/dev/null
if ! diff -q "$TMP/encrypted.bin" "$TMP/encrypted2.bin" > /dev/null 2>&1; then
    pass "Different AES keys produce different ciphertext"
else
    fail "Different keys produced identical ciphertext"
fi

# Test 6: Wrong key fails to decrypt
echo ""
echo "6. Wrong key rejection"
if openssl enc -d -aes-256-cbc -pbkdf2 -pass "file:$TMP/aes_key2.bin" -in "$TMP/encrypted.bin" -out "$TMP/bad_decrypt.json" 2>/dev/null; then
    # Decryption might "succeed" but produce garbage
    if python3 -c "import json; json.load(open('$TMP/bad_decrypt.json'))" 2>/dev/null; then
        fail "Wrong key produced valid JSON (extremely unlikely but check)"
    else
        pass "Wrong key produces garbage (not valid JSON)"
    fi
else
    pass "Wrong key correctly fails to decrypt"
fi

echo ""
echo "================"
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then exit 1; fi
