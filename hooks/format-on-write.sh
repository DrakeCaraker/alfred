#!/usr/bin/env bash
# PostToolUse hook: auto-format files after Write|Edit
# Reads tool input JSON from stdin to get the file path
# Reads formatting.tool from .claude/alfred.yaml if available

f=$(jq -r '.tool_input.file_path // empty')
[ -z "$f" ] && exit 0

# Auto-sync: if a .claude/commands/ or .claude/hooks/ file was edited, sync the mirror
case "$f" in
  */.claude/commands/*.md)
    base=$(basename "$f")
    dest="$(dirname "$f")/../../commands/$base"
    [ -f "$dest" ] || dest="commands/$base"
    cp "$f" "$dest" 2>/dev/null || true
    ;;
  */.claude/hooks/*.sh)
    base=$(basename "$f")
    dest="$(dirname "$f")/../../hooks/$base"
    [ -f "$dest" ] || dest="hooks/$base"
    cp "$f" "$dest" 2>/dev/null || true
    ;;
esac

# Read preferred formatter from alfred.yaml (if configured)
ALFRED_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
preferred=$("$ALFRED_ROOT/scripts/alfred-config.sh" formatting.tool auto 2>/dev/null)

# If a specific formatter is configured, use it directly
if [ "$preferred" != "auto" ] && [ "$preferred" != "none" ]; then
    case "$preferred" in
        ruff)
            [[ "$f" == *.py ]] && command -v ruff >/dev/null 2>&1 && { ruff format "$f" 2>/dev/null; exit 0; }
            ;;
        black)
            [[ "$f" == *.py ]] && command -v black >/dev/null 2>&1 && { black -q "$f" 2>/dev/null; exit 0; }
            ;;
        prettier)
            [[ "$f" =~ \.(js|ts|jsx|tsx|css|json|md)$ ]] && command -v prettier >/dev/null 2>&1 && { prettier --write "$f" 2>/dev/null; exit 0; }
            ;;
        gofmt)
            [[ "$f" == *.go ]] && command -v gofmt >/dev/null 2>&1 && { gofmt -w "$f" 2>/dev/null; exit 0; }
            ;;
        rustfmt)
            [[ "$f" == *.rs ]] && command -v rustfmt >/dev/null 2>&1 && { rustfmt "$f" 2>/dev/null; exit 0; }
            ;;
        none)
            exit 0
            ;;
    esac
fi

# Auto-detect by file extension (fallback when no alfred.yaml or tool=auto)

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
