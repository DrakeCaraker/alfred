#!/usr/bin/env bash
# PostToolUse hook: track slash command usage for telemetry
# Fires on every Skill invocation, appends skill name to session log
# Read by pilot-telemetry.sh at session end for reliable command tracking

skill=$(jq -r '.tool_input.skill // empty')
[ -z "$skill" ] && exit 0

# Append to session log (one name per line, deduped at read time)
echo "$skill" >> .claude/.commands-this-session 2>/dev/null

exit 0
