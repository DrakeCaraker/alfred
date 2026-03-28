# Changelog

All notable changes to Alfred are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

## [0.2.0] - 2026-03-28

### Added
- **Plugin installable**: Install via `/plugin marketplace add DrakeCaraker/alfred` — works in any project
- **Encrypted collective learning**: Anonymized corrections shared across users via end-to-end encrypted GitHub issues → private repo storage
- **CI autofix pipeline**: Claude Code automatically fixes CI failures and resolves merge conflicts
- **Security audit** (`/audit`, `make audit`): Checks for injection, secrets, cleanup traps, sync, doc-code drift
- **7-layer automation stack**: PostToolUse sync → pre-commit block → pre-push audit → CI → autofix → conflict resolution → weekly scan
- **Prompting guides**: Domain-specific prompting tips in all 6 personas + standalone `docs/PROMPTING_GUIDE.md`
- **Smart suggestions**: All 19 commands have contextual trigger conditions and explanations
- **Progressive disclosure**: Prompting tips surface during `/teach` lessons and early sessions
- **Branch hygiene nudge**: Session-start warns when branch has 10+ commits ahead
- **Pre-flight checks**: `/commit` and `/pr` run `make check` before any git operations
- **192 tests**: 126 structural + 7 encryption + 10 aggregator + 12 hook output + 16 anonymizer + 21 PII scanner
- **`make fix`**: Auto-syncs commands + hooks + permissions in one command
- **User-friendly hook messages**: Stop hooks show "Alfred: saving..." not raw instructions

### Changed
- Unified consent model: one opt-out covers telemetry + collective signals (was separate opt-in)
- `validate.sh` now checks hook sync alongside command sync
- CLAUDE.md expanded to 8 non-negotiable rules (was 6)
- All docs synchronized: README, AI_ASSISTED_DEV_GUIDE, GETTING_STARTED

### Fixed
- CI injection vulnerability in workflow_dispatch custom prompt
- Temp file cleanup traps in collective-sync.sh (prevented plaintext leaks)
- Python variable injection in shell scripts (collective-sync, alfred-config, pilot-telemetry)
- Auto-consent now creates identity file (telemetry was silently failing)
- Race condition: removed dual push-pending from both Stop and SessionStart hooks
- hooks/ directory was massively out of sync with .claude/hooks/
- Missing commands in commands/ directory (github-account-setup, vet)
- PII scanner false positive on .pilot/README.md (privacy policy mentions "patient")
- macOS compatibility: head -n -1, Gist filename, heredoc quoting

### Security
- RSA-4096 + AES-256-CBC hybrid encryption for collective signal transport
- Public key shipped with plugin, private key in repo secret
- Title-based workflow trigger (community users can't add labels)
- Body size guard on signal ingestion (50-65000 chars)
- Doc-code consistency checks prevent information drift

## [0.1.0] - 2026-03-27

### Added
- Initial release: 6 personas, 8 habits, progressive teaching with graduation
- 11 slash commands: bootstrap, teach, status, commit, new-work, ci-fix, self-improve, health-check, safe-refactor, experiment-summary, pr
- Session hooks: format-on-write, session-start, session-bookmark, feedback-capture, pre-compact
- Pilot telemetry with 6-layer PII defense
- Persona intelligence: custom roles, fit detection, generation
- Self-improvement loop: feedback memory → CLAUDE.md rule → automated hook
- CI workflow with structural validation, shellcheck, smoke tests
- Plugin scaffold: .claude-plugin/plugin.json, hooks/hooks.json
