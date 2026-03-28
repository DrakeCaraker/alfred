#!/usr/bin/env bash
# dev-publish.sh — Push Alfred changes and refresh the local plugin cache.
# Run from the Alfred repo after making changes.
# Usage: make publish   (or: bash scripts/dev-publish.sh)
set -euo pipefail

MARKETPLACE_ID="alfred-marketplace"
PLUGIN_CACHE="$HOME/.claude/plugins/cache"
MARKETPLACE_CACHE="$HOME/.claude/plugins/marketplaces"
REPO_URL="https://github.com/DrakeCaraker/alfred.git"

echo "=== Alfred Dev Publish ==="
echo ""

# 1. Push to remote
echo "1. Pushing to remote..."
git push origin main --no-verify 2>/dev/null || git push origin HEAD --no-verify 2>/dev/null || echo "   (nothing to push)"

# 2. Refresh marketplace cache (re-clone from remote)
echo "2. Refreshing marketplace cache..."
marketplace_dir=""
for d in "$MARKETPLACE_CACHE"/*/; do
    if [ -f "$d/.claude-plugin/marketplace.json" ]; then
        name=$(python3 -c "import json; print(json.load(open('$d/.claude-plugin/marketplace.json'))['name'])" 2>/dev/null || echo "")
        if [ "$name" = "$MARKETPLACE_ID" ]; then
            marketplace_dir="$d"
            break
        fi
    fi
done

if [ -n "$marketplace_dir" ]; then
    echo "   Found cache at: $marketplace_dir"
    cd "$marketplace_dir"
    git fetch origin 2>/dev/null && git reset --hard origin/main 2>/dev/null
    cd - >/dev/null
    echo "   Updated to latest"
else
    echo "   Marketplace not cached — install via: /plugin marketplace add $REPO_URL"
fi

# 3. Refresh plugin cache (copy from marketplace)
echo "3. Refreshing plugin cache..."
plugin_dir=$(find "$PLUGIN_CACHE" -name "plugin.json" -path "*/alfred/*" 2>/dev/null | head -1 | xargs dirname 2>/dev/null | xargs dirname 2>/dev/null || echo "")
if [ -n "$plugin_dir" ] && [ -n "$marketplace_dir" ]; then
    # Copy fresh files from marketplace cache to plugin cache
    rsync -a --delete \
        --exclude '.git' \
        --exclude '.claude/.onboarding-state.json' \
        --exclude '.claude/.pilot-*' \
        --exclude '.claude/.session-*' \
        --exclude '.claude/.collective-*' \
        "$marketplace_dir/" "$plugin_dir/"
    echo "   Plugin cache refreshed"
else
    echo "   Plugin not cached — install via: /plugin install alfred@$MARKETPLACE_ID"
fi

echo ""
echo "Done. Restart your Claude Code session to pick up changes."
echo "(In Claude Code: /exit, then: claude)"
