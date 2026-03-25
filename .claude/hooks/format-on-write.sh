#!/usr/bin/env bash
# PostToolUse hook: auto-format files after Write|Edit
# Reads tool input JSON from stdin to get the file path

f=$(jq -r '.tool_input.file_path // empty')
[ -z "$f" ] && exit 0

# Python: prefer ruff, fall back to black
if [[ "$f" == *.py ]]; then
    [[ "$f" == */notebooks/* ]] && exit 0  # skip notebook-generated files
    command -v ruff >/dev/null 2>&1 && { ruff format "$f" 2>/dev/null; exit 0; }
    command -v black >/dev/null 2>&1 && { black -q "$f" 2>/dev/null; exit 0; }
    exit 0
fi

# JavaScript/TypeScript: prettier
if [[ "$f" =~ \.(js|ts|jsx|tsx)$ ]]; then
    command -v prettier >/dev/null 2>&1 && { prettier --write "$f" 2>/dev/null; exit 0; }
    exit 0
fi

# Go: gofmt
if [[ "$f" == *.go ]]; then
    command -v gofmt >/dev/null 2>&1 && { gofmt -w "$f" 2>/dev/null; exit 0; }
    exit 0
fi

# Rust: rustfmt
if [[ "$f" == *.rs ]]; then
    command -v rustfmt >/dev/null 2>&1 && { rustfmt "$f" 2>/dev/null; exit 0; }
    exit 0
fi

# R: styler
if [[ "$f" == *.R ]] || [[ "$f" == *.r ]]; then
    command -v Rscript >/dev/null 2>&1 && { Rscript -e "styler::style_file('$f')" 2>/dev/null; exit 0; }
    exit 0
fi

# SQL: sqlfluff
if [[ "$f" == *.sql ]]; then
    command -v sqlfluff >/dev/null 2>&1 && { sqlfluff fix "$f" --force 2>/dev/null; exit 0; }
    exit 0
fi

exit 0
