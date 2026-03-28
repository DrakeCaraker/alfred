#!/usr/bin/env bash
# Read a value from .claude/alfred.yaml
# Usage: alfred-config.sh <key.path> [default]
# Examples:
#   alfred-config.sh formatting.tool none
#   alfred-config.sh git.main_branch main
#   alfred-config.sh blocked_extensions ".pkl|.pt"

CONFIG_FILE=".claude/alfred.yaml"
KEY="${1:-}"
DEFAULT="${2:-}"

if [ -z "$KEY" ]; then
    echo "Usage: alfred-config.sh <key.path> [default]" >&2
    exit 2
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "$DEFAULT"
    exit 0
fi

python3 -c "
import re, sys

config_file = sys.argv[1]
key = sys.argv[2]
default = sys.argv[3] if len(sys.argv) > 3 else ''

try:
    with open(config_file) as f:
        text = f.read()

    # Build flat dict from two-level YAML (no PyYAML needed)
    d = {}
    section = None
    for line in text.split('\n'):
        stripped = line.rstrip()
        if not stripped or stripped.startswith('#'):
            continue
        if not stripped.startswith(' '):
            m = re.match(r'(\w[\w_-]*):\s*(.*)', stripped)
            if m:
                section = m.group(1)
                val = m.group(2).strip()
                if val.startswith('[') and val.endswith(']'):
                    items = re.findall(r'\"([^\"]*)\"', val)
                    if not items:
                        items = re.findall(r\"'([^']*)'\", val)
                    if not items:
                        items = [x.strip() for x in val[1:-1].split(',')]
                    d[section] = '|'.join(items)
                elif val and not val.startswith('#'):
                    d[section] = val.strip('\"').strip(\"'\")
        elif section:
            m = re.match(r'\s+(\w[\w_-]*):\s*(.*)', stripped)
            if m:
                k = f'{section}.{m.group(1)}'
                val = m.group(2).strip()
                if val.startswith('[') and val.endswith(']'):
                    # Parse YAML list: [\".pkl\", \".pt\"] -> .pkl|.pt
                    items = re.findall(r'\"([^\"]*)\"', val)
                    if not items:
                        items = re.findall(r\"'([^']*)'\", val)
                    if not items:
                        items = [x.strip() for x in val[1:-1].split(',')]
                    d[k] = '|'.join(items)
                elif val and not val.startswith('#'):
                    d[k] = val.strip('\"').strip(\"'\")

    print(d.get(key, default))
except Exception:
    print(default)
" "$CONFIG_FILE" "$KEY" "$DEFAULT"
