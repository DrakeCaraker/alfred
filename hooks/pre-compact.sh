#!/bin/bash
# PreCompact hook: reminds Claude to save critical context before compression.
echo '{"systemMessage": "Context compression starting. Before continuing, save any in-progress task state, critical file paths, current branch, and uncommitted decisions to the plan file or memory so they survive compression."}'
