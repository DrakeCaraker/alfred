# Security Audit

Run a deep security and quality audit of the project, present findings, and offer to fix them.

## Algorithm

### Detect Alfred root

Before running any script, detect where Alfred is installed:
```bash
ALFRED_ROOT="${CLAUDE_PLUGIN_ROOT:-$(pwd)}"
```
Use `$ALFRED_ROOT` as the prefix for all Alfred script paths below. User project files (`.claude/`, `.pilot/`) are always relative to CWD.

1. Run the audit:
   ```bash
   bash "$ALFRED_ROOT/scripts/audit.sh"
   ```

2. If all checks pass, say: "Security audit passed. No issues found."

3. If any checks fail, for each failure:
   - Explain what the issue means in plain language
   - Explain why it matters (what could go wrong)
   - Offer to fix it if it's auto-fixable (`make fix` for sync issues)
   - For security issues, explain the fix and ask for permission

4. After presenting all findings, offer:
   - "Run `make fix` to resolve sync issues automatically?"
   - For remaining issues, propose specific code changes

5. If fixes were applied, re-run the audit to confirm resolution.

## When to Suggest

Smart Suggestions should recommend `/audit`:
- Before creating a PR from a feature branch
- After a large implementation session (5+ commits)
- When `/self-improve` finds friction patterns related to security
- When the weekly security scan opens a GitHub issue
