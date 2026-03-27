# Safe Commit

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
