# Safe Commit

## Beginner mode

If `coding_level == "beginner"` in `.claude/.onboarding-state.json`, preface the commit workflow with a brief explanation:

```
Committing saves a snapshot of your work — like pressing "Save" in a game.
You can always come back to this exact point if something goes wrong later.

I'll check your files for safety first, then save everything with a short
description of what changed.
```

After the commit succeeds, explain the output:
```
Your work is saved! Here's what just happened:
- [commit hash] is a unique ID for this save point (like a receipt number)
- The message "[commit message]" describes what changed
- You can see your last 3 saves above

You're doing great. Keep working — run /commit again whenever you want to save.
```

## Safety checks

Before committing, run these safety checks:

1. Run `git status` to see staged and unstaged changes
2. Check for blocked file extensions in staged changes. Read blocked extensions from `.claude/alfred.yaml` (`blocked_extensions` field) if available; otherwise default to `.pkl`. Run: `git diff --cached --name-only | grep -E '\.(pkl|pt|pth|h5|joblib|ckpt|safetensors)$'`
   - If any match, **STOP** and warn the user. Do not commit.
3. Check for large files (>500KB) in staged changes:
   ```
   git diff --cached --name-only | while read f; do
     if [ -f "$f" ]; then
       size=$(stat -c%s "$f" 2>/dev/null)
       if [ "$size" -gt 512000 ]; then
         echo "WARNING: $f is $((size / 1024))KB"
       fi
     fi
   done
   ```
   - If any large files found, warn and ask before proceeding.
4. Check for checkpoint files: `git diff --cached --name-only | grep -i checkpoint`
   - If matches, warn the user.

If all checks pass:
- Generate a concise commit message from the diff (or use the user's message if provided)
- Create the commit
- Show `git log --oneline -3` after committing
- Do NOT push unless the user asks
