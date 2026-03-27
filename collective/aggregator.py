#!/usr/bin/env python3
"""
Aggregator: converts feedback memories into anonymized collective learning signals.

Reads feedback memory files, classifies each correction, anonymizes the pattern,
and outputs structured signals ready for local preview or remote transmission.

Usage:
    python3 aggregator.py <memory_dir>           # generate signals from memories
    python3 aggregator.py <memory_dir> --preview  # preview without saving
    python3 aggregator.py <memory_dir> --save <output_file>  # save signals to file
"""

import json
import os
import re
import sys
from pathlib import Path
from datetime import date

# Import anonymizer from same directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from anonymizer import anonymize


# Category classification keywords
CATEGORY_KEYWORDS = {
    "git_workflow": [
        "branch", "commit", "push", "merge", "rebase", "main", "feature",
        "pull request", "PR", "git", "checkout", "stash"
    ],
    "formatting": [
        "format", "lint", "ruff", "black", "prettier", "indent", "style",
        "whitespace", "line length"
    ],
    "testing": [
        "test", "pytest", "jest", "coverage", "assert", "mock", "fixture",
        "TDD", "regression", "unit test"
    ],
    "code_style": [
        "naming", "variable", "function", "class", "import", "type hint",
        "docstring", "comment", "convention", "pattern"
    ],
    "safety": [
        "secret", "credential", "password", "token", "PII", "security",
        "injection", "vulnerability", "permission", "guard"
    ],
    "explanation": [
        "explain", "verbose", "brief", "detail", "understand", "know",
        "skip", "obvious", "already", "don't explain"
    ],
    "tooling": [
        "tool", "command", "script", "hook", "CI", "pipeline", "build",
        "deploy", "install", "dependency"
    ],
}


def classify_category(text: str) -> str:
    """Classify a feedback memory into a signal category."""
    text_lower = text.lower()
    scores = {}
    for category, keywords in CATEGORY_KEYWORDS.items():
        score = sum(1 for kw in keywords if kw.lower() in text_lower)
        if score > 0:
            scores[category] = score
    if scores:
        return max(scores, key=scores.get)
    return "tooling"  # default


def extract_pattern(text: str) -> str:
    """Extract the core correction pattern from a feedback memory."""
    # Remove frontmatter
    text = re.sub(r'^---.*?---\s*', '', text, flags=re.DOTALL)

    # Take the first substantive line as the pattern
    lines = [l.strip() for l in text.strip().split('\n') if l.strip() and not l.startswith('#')]

    if not lines:
        return ""

    # Use the first line, truncated to 200 chars
    pattern = lines[0]
    if len(pattern) > 200:
        pattern = pattern[:197] + "..."

    return anonymize(pattern)


def detect_promotion(text: str) -> str:
    """Detect what the correction was promoted to."""
    text_lower = text.lower()
    if "hook" in text_lower or "guard" in text_lower:
        return "hook"
    if "rule" in text_lower or "claude.md" in text_lower:
        return "rule"
    return "memory"


def process_memories(memory_dir: str) -> list[dict]:
    """Process all feedback memories in a directory into signals."""
    memory_path = Path(memory_dir)
    signals = []

    feedback_files = sorted(memory_path.glob("feedback_*.md"))
    if not feedback_files:
        return signals

    # Detect project type from alfred.yaml if available
    project_type = "unknown"
    alfred_yaml = Path(".claude/alfred.yaml")
    if alfred_yaml.exists():
        content = alfred_yaml.read_text()
        m = re.search(r'type:\s*(\w+)', content)
        if m:
            project_type = m.group(1)

    # Group by theme to count occurrences
    patterns_seen: dict[str, int] = {}

    for f in feedback_files:
        try:
            text = f.read_text()
        except OSError:
            continue

        pattern = extract_pattern(text)
        if not pattern:
            continue

        category = classify_category(text)
        promoted_to = detect_promotion(text)

        # Track occurrences of similar patterns
        pattern_key = pattern[:50].lower()
        patterns_seen[pattern_key] = patterns_seen.get(pattern_key, 0) + 1

        signals.append({
            "category": category,
            "pattern": pattern,
            "local_occurrences": patterns_seen[pattern_key],
            "promoted_to": promoted_to,
            "project_type": project_type,
        })

    # Update occurrence counts (final pass)
    for signal in signals:
        key = signal["pattern"][:50].lower()
        signal["local_occurrences"] = patterns_seen.get(key, 1)

    return signals


def main():
    if len(sys.argv) < 2:
        print("Usage: aggregator.py <memory_dir> [--preview | --save <file>]", file=sys.stderr)
        sys.exit(2)

    memory_dir = sys.argv[1]

    if not os.path.isdir(memory_dir):
        print(f"Error: directory not found: {memory_dir}", file=sys.stderr)
        sys.exit(1)

    signals = process_memories(memory_dir)

    if not signals:
        print("No feedback memories found to aggregate.")
        sys.exit(0)

    output = {
        "schema_version": "1.0",
        "generated_date": str(date.today()),
        "signal_count": len(signals),
        "signals": signals,
    }

    if "--preview" in sys.argv:
        print(f"=== Signal Preview ({len(signals)} signals) ===\n")
        for i, s in enumerate(signals, 1):
            print(f"{i}. [{s['category']}] {s['pattern']}")
            print(f"   Occurrences: {s['local_occurrences']}, Promoted to: {s['promoted_to']}, Project: {s['project_type']}")
            print()
        print("These signals are anonymized. No file paths, code, or identifiers are included.")
        print("Run without --preview to save, or with --save <file> to write to disk.")

    elif "--save" in sys.argv:
        idx = sys.argv.index("--save")
        if idx + 1 >= len(sys.argv):
            print("Error: --save requires an output file path", file=sys.stderr)
            sys.exit(2)
        output_file = sys.argv[idx + 1]
        with open(output_file, 'w') as f:
            json.dump(output, f, indent=2)
        print(f"Saved {len(signals)} signals to {output_file}")

    else:
        print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
