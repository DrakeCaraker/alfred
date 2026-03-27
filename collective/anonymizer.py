#!/usr/bin/env python3
"""
Anonymizer for collective learning signals.
Strips file paths, code tokens, identifiers, URLs, and project names
from feedback memory text before it becomes a signal.

Usage:
    python3 anonymizer.py "text to anonymize"
    echo "text" | python3 anonymizer.py --stdin
    python3 anonymizer.py --test  # run self-tests
"""

import re
import sys


def anonymize(text: str) -> str:
    """Remove PII, paths, code tokens, and identifiers from text."""

    # File paths (Unix and Windows)
    text = re.sub(r'/Users/[^\s/]+(/[^\s]*)?', '[PATH]', text)
    text = re.sub(r'/home/[^\s/]+(/[^\s]*)?', '[PATH]', text)
    text = re.sub(r'C:\\Users\\[^\s\\]+(\\[^\s]*)?', '[PATH]', text)
    text = re.sub(r'(/[a-zA-Z_][a-zA-Z0-9_-]*/){2,}[a-zA-Z_][a-zA-Z0-9_.-]*', '[PATH]', text)
    text = re.sub(r'\b\w+\.(py|js|ts|jsx|tsx|rs|go|r|sql|sh|yaml|yml|json|toml|cfg|ini|md)\b', '[FILE]', text)

    # URLs
    text = re.sub(r'https?://[^\s]+', '[URL]', text)

    # Email addresses
    text = re.sub(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', '[EMAIL]', text)

    # IP addresses (keep localhost)
    def replace_ip(m):
        ip = m.group(0)
        if ip in ('127.0.0.1', '0.0.0.0'):
            return ip
        return '[IP]'
    text = re.sub(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', replace_ip, text)

    # Auth tokens and secrets
    text = re.sub(r'sk-[a-zA-Z0-9]{20,}', '[TOKEN]', text)
    text = re.sub(r'Bearer\s+\S+', 'Bearer [TOKEN]', text)
    text = re.sub(r'(api_key|password|secret|token)\s*[=:]\s*\S+', r'\1=[REDACTED]', text, flags=re.I)

    # Git commit hashes (7+ hex chars that look like SHAs)
    text = re.sub(r'\b[0-9a-f]{7,40}\b', '[HASH]', text)

    # Variable/function names that look like identifiers (camelCase, snake_case with 3+ segments)
    text = re.sub(r'\b[a-z]+(?:_[a-z]+){3,}\b', '[IDENT]', text)
    text = re.sub(r'\b[a-z]+(?:[A-Z][a-z]+){3,}\b', '[IDENT]', text)

    # Specific project/repo names (heuristic: org/repo patterns)
    text = re.sub(r'\b[A-Za-z0-9_-]+/[A-Za-z0-9_-]+\b(?!\.)', '[REPO]', text)

    # Collapse multiple [REDACTED] markers
    text = re.sub(r'(\[(?:PATH|FILE|URL|EMAIL|IP|TOKEN|HASH|IDENT|REPO|REDACTED)\]\s*){2,}',
                  lambda m: m.group(0).split(']')[0] + '] ', text)

    return text.strip()


def run_tests():
    """Self-test suite for anonymizer."""
    tests = [
        # (input, should_not_contain, description)
        ("/Users/drake/project/src/main.py", "drake", "user path removed"),
        ("/home/ubuntu/.ssh/key", "ubuntu", "linux path removed"),
        ("file at src/utils/helpers.py", "helpers.py", "file reference removed"),
        ("https://github.com/DrakeCaraker/alfred", "DrakeCaraker", "URL removed"),
        ("email user@company.com for details", "user@company.com", "email removed"),
        ("IP is 192.168.1.100", "192.168.1.100", "IP removed"),
        ("token sk-abc123def456ghi789jkl012mno345pqr678stu", "sk-abc", "API key removed"),
        ("Bearer eyJhbGciOiJIUzI1NiJ9.xyz", "eyJhbG", "bearer token removed"),
        ("api_key = supersecret123", "supersecret", "api key value removed"),
        ("commit abc1234def", "abc1234def", "git hash removed"),
        ("function get_user_profile_data_from_api", "get_user_profile_data_from_api", "long identifier removed"),
        ("in DrakeCaraker/alfred repo", "DrakeCaraker", "repo reference removed"),
    ]

    passed = 0
    failed = 0
    for input_text, should_not_contain, desc in tests:
        result = anonymize(input_text)
        if should_not_contain.lower() in result.lower():
            print(f"  [FAIL] {desc}: '{should_not_contain}' still in: {result}")
            failed += 1
        else:
            print(f"  [PASS] {desc}")
            passed += 1

    # Preservation tests — these should pass through
    preserve_tests = [
        ("Never modify test files to fix failing tests", "Never modify test files"),
        ("Always lint before pushing", "Always lint before pushing"),
        ("Use conventional commits", "conventional commits"),
        ("127.0.0.1 is fine", "127.0.0.1"),
    ]
    for input_text, should_contain, *rest in preserve_tests:
        desc = rest[0] if rest else f"preserves '{should_contain}'"
        result = anonymize(input_text)
        if should_contain in result:
            print(f"  [PASS] preserves: {desc}")
            passed += 1
        else:
            print(f"  [FAIL] lost: {desc} → got: {result}")
            failed += 1

    print(f"\n{passed} passed, {failed} failed")
    return failed == 0


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        success = run_tests()
        sys.exit(0 if success else 1)
    elif len(sys.argv) > 1 and sys.argv[1] == "--stdin":
        text = sys.stdin.read()
        print(anonymize(text))
    elif len(sys.argv) > 1:
        print(anonymize(" ".join(sys.argv[1:])))
    else:
        print("Usage: anonymizer.py <text> | --stdin | --test", file=sys.stderr)
        sys.exit(2)
