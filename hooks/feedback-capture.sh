#!/bin/bash
# Stop hook: safety net for CLAUDE.md rule #6 (immediate feedback capture)
# Reminds Claude to check for any uncaptured user corrections before session ends.
echo '{"systemMessage": "Before ending this session, check if any user corrections from this session still need to be saved as feedback memories (CLAUDE.md rule #6). Only capture genuine approach corrections, not routine requests. Check existing memories first to avoid duplicates."}'
