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

    # Proper nouns / company names (capitalized words not at sentence start)
    # Preserve common English words and technical terms that happen to be capitalized
    _SAFE_CAPS = {
        'Never', 'Always', 'Do', 'Don', 'The', 'A', 'An', 'In', 'On', 'At',
        'For', 'To', 'Of', 'By', 'With', 'From', 'If', 'Or', 'And', 'But',
        'Not', 'No', 'All', 'Any', 'Each', 'Every', 'Only', 'Run', 'Use',
        'Add', 'Set', 'Get', 'Put', 'Make', 'Check', 'Test', 'Fix', 'Stop',
        'Start', 'Save', 'Load', 'Read', 'Write', 'Create', 'Delete', 'Block',
        'Pin', 'Lock', 'Skip', 'Avoid', 'Ensure', 'Verify', 'Require',
        'Python', 'JavaScript', 'TypeScript', 'Rust', 'Go', 'SQL', 'HTML',
        'CSS', 'JSON', 'YAML', 'XML', 'CSV', 'API', 'REST', 'HTTP', 'HTTPS',
        'CI', 'CD', 'PR', 'Git', 'GitHub', 'Docker', 'Kubernetes', 'AWS',
        'GCP', 'Azure', 'Linux', 'Mac', 'Windows', 'SSH', 'SSL', 'TLS',
        'ML', 'AI', 'GPU', 'CPU', 'RAM', 'SSD', 'CLI', 'IDE', 'UI', 'UX',
        'PostgreSQL', 'MySQL', 'Redis', 'MongoDB', 'Snowflake', 'BigQuery',
        'Airflow', 'Spark', 'Kafka', 'Terraform', 'Ansible',
        'React', 'Vue', 'Angular', 'Node', 'Express', 'Django', 'Flask',
        'PyTorch', 'TensorFlow', 'Pandas', 'NumPy', 'SciPy',
        'LaTeX', 'BibTeX', 'Jupyter', 'RStudio', 'SHAP', 'LIME',
        'True', 'False', 'None', 'NULL', 'OK', 'CRUD', 'ACID',
    }

    def _replace_proper_noun(m):
        word = m.group(0)
        if word in _SAFE_CAPS:
            return word
        return '[NAME]'

    # Match capitalized words (2+ chars) that aren't at sentence start
    # Split into sentences, then check non-initial capitalized words
    sentences = re.split(r'(?<=[.!?])\s+', text)
    cleaned = []
    for sent in sentences:
        words = sent.split()
        new_words = []
        for i, w in enumerate(words):
            # Skip first word of sentence and words inside brackets
            if i == 0 or w.startswith('['):
                new_words.append(w)
            elif re.match(r'^[A-Z][a-z]+$', w) and w not in _SAFE_CAPS:
                new_words.append('[NAME]')
            else:
                new_words.append(w)
        cleaned.append(' '.join(new_words))
    text = ' '.join(cleaned)

    # Collapse multiple [REDACTED] markers
    text = re.sub(r'(\[(?:PATH|FILE|URL|EMAIL|IP|TOKEN|HASH|IDENT|REPO|REDACTED|NAME)\]\s*){2,}',
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
        # Proper noun / company name tests
        ("Never commit Acme Corp API credentials", "Acme", "company name removed"),
        ("Don't modify the Contoso database", "Contoso", "proper noun removed"),
        ("Check with Johnson before merging", "Johnson", "person name removed"),
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
        # Technical terms should survive proper noun filter
        ("Use Python and PyTorch for training", "Python and PyTorch"),
        ("Run Docker on Linux", "Docker on Linux"),
        ("Never skip Git hooks", "Git hooks"),
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
