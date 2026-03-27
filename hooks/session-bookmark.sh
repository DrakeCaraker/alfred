#!/bin/bash
# Stop hook: prompt Claude to save session context for next-session resume
echo '{"systemMessage": "Session ending. Save a session bookmark to .claude/.session-bookmark.json with: current task description, progress summary, branch name, files modified, and next steps. Read the existing bookmark first to preserve context. Format as JSON with keys: timestamp, task, progress, branch, files_modified, next_steps."}'
