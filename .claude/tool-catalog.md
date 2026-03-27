# Alfred Tool Catalog

Reference mapping between slash commands, development habits, hooks, and state files.

For habit details, see [`docs/AI_ASSISTED_DEV_GUIDE.md`](../docs/AI_ASSISTED_DEV_GUIDE.md).

## Slash Commands

| Command | Pattern Taught | Description |
|---------|---------------|-------------|
| /bootstrap | — | Persona-aware project setup |
| /teach | All 8 | Progressive pattern lessons |
| /status | — | Onboarding progress dashboard |
| /commit | #3 Save points | Safe commit with file guards |
| /new-work | #2 Scope, #4 Experimentation | Branch hygiene + scoped work |
| /ci-fix | #6 Automated recovery | Auto-fix CI failures in a loop |
| /self-improve | #8 Self-improvement | Promote feedback to rules/hooks |
| /health-check | — | Project maturity assessment |
| /safe-refactor | #5 One change, one test | Test-gated refactoring with rollback |
| /experiment-summary | #7 Provenance | Result inventory with provenance |
| /pr | — | Branch → commit → push → PR |
| /persona | — | View or change active persona |
| /collective | — | Preview collective team corrections |
| /pilot-consent | — | View what's collected, opt in or out |
| /pilot-report | — | Submit feedback (PII-scrubbed) |
| /pilot-delete | — | Delete pilot data locally or from repo |

## Hooks

| Hook | File | Trigger | Purpose |
|------|------|---------|---------|
| Format on write | .claude/hooks/format-on-write.sh | PostToolUse (Write\|Edit) | Auto-format files by language |
| Session start | .claude/hooks/session-start.sh | SessionStart | Context warm-up + onboarding status |
| Session bookmark | .claude/hooks/session-bookmark.sh | Stop | Save task context for next session |
| Feedback capture | .claude/hooks/feedback-capture.sh | Stop | Capture user corrections as memories |
| Pre-compact | .claude/hooks/pre-compact.sh | PreCompact | Preserve context before compression |
| Pre-push | .githooks/pre-push | git push | Block binaries + main pushes |

## Pattern → External Skill Mapping

| Pattern | Built-in Command | External Superpowers Skill |
|---------|-----------------|---------------------------|
| Scope before work | /new-work | superpowers:brainstorming, superpowers:writing-plans |
| Safe experimentation | /new-work | superpowers:using-git-worktrees |
| One change, one test | /safe-refactor | superpowers:test-driven-development |
| Automated recovery | /ci-fix | superpowers:verification-before-completion |
| Provenance | /experiment-summary | superpowers:requesting-code-review |
| (debugging) | — | superpowers:systematic-debugging |

## State Files (created at runtime)

| File | Created By | Read By |
|------|-----------|---------|
| .claude/.onboarding-state.json | /bootstrap | /teach, /status, session-start hook |
| .claude/.session-bookmark.json | session-bookmark hook | session-start hook |
| .claude/.session-count | session-start hook | session-start hook, /self-improve |
