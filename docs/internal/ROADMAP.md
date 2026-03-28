# Alfred Roadmap

*Internal planning document. Updated 2026-03-28.*

## Current State

- **Version:** 0.2.0
- **Stars:** 1 (creator only)
- **Real users:** 0 (untested outside Alfred repo)
- **Tests:** 192 (126 structural + 29 unit + 16 anonymizer + 21 PII scanner)
- **Commands:** 19
- **Personas:** 6
- **CLAUDE.md rules:** 8

## Phase 1: Validate (Target: 2026-04-04)

Priority: Prove Alfred works as a plugin before any distribution.

- [ ] Test plugin install in dash-shap: `/plugin marketplace add DrakeCaraker/alfred`
- [ ] Dog-food 3+ sessions with Alfred as a plugin in dash-shap
- [ ] Document every friction point (missing features, broken paths, confusing UX)
- [ ] Fix all P0 issues found during dog-fooding
- [ ] Verify collective signal auto-submission works from a plugin project
- [ ] Add `CLAUDE_ENABLED=true` repo variable to activate CI autofix

**Exit criteria:** Alfred works end-to-end as a plugin in a real project with zero manual workarounds.

## Phase 2: Distribute (Target: 2026-04-11)

Priority: Get Alfred in front of people who want it.

- [ ] Submit to official Claude Code plugin marketplace (claude.ai/settings/plugins/submit)
  - ⚠️ Verify URL works and understand acceptance criteria
- [ ] Submit PR to awesome-claude-code (hesreallyhim/awesome-claude-code)
  - Differentiate clearly from learn-faster-kit (already listed with similar positioning)
  - Use the draft in docs/internal/AWESOME_SUBMISSION.md
- [ ] Share in relevant communities (Claude Code Discord, data science Slack)
- [ ] Add CHANGELOG.md link to README
- [ ] Add docs/WHO_ITS_FOR.md link to README

**Exit criteria:** Alfred discoverable by people actively looking for Claude Code plugins.

## Phase 3: First Users (Target: 2026-04-25)

Priority: Get 5 real users and learn from them.

- [ ] Monitor collective signal submissions (GitHub issues on DrakeCaraker/alfred)
- [ ] Track: which personas are chosen, which habits graduate first, which commands are used
- [ ] Respond to any GitHub issues within 24 hours
- [ ] Run `/self-improve` weekly to capture emerging patterns
- [ ] Collect qualitative feedback (DM anyone who installs)

**Exit criteria:** 5 users have completed `/bootstrap` and used Alfred for 3+ sessions.

## Phase 4: Iterate (Target: 2026-05-15)

Priority: Respond to real usage data.

- [ ] If feedback shows occurrence count is insufficient → add correction confidence scoring
- [ ] If feedback shows personas are wrong → create/modify personas based on collective signals
- [ ] If collective signals show consistent patterns → promote to default CLAUDE.md rules
- [ ] Write blog post about behavioral science approach (only after user validation)
- [ ] Consider cross-tool adapter (export to .cursorrules, copilot-instructions.md) if demand exists

**Exit criteria:** Alfred's design has been validated or revised based on real user feedback.

## Deferred (No timeline)

- Cross-tool config adapter (Cursor, Copilot, etc.)
- Correction confidence scoring (0.60-0.95 scale like claude-reflect)
- Additional personas (security engineering, mobile dev, DevOps)
- Team analytics dashboard
- Marketing website

## Competitive Watch

- **claude-reflect** (861 stars): If they add teaching or personas, Alfred's differentiation narrows. Alfred's defense: collective learning (network effects).
- **learn-faster-kit** (139 stars): General learning tool, already in awesome-claude-code. Alfred's differentiation: development habits specifically + 6 professional personas.
- **SuperClaude** (22K stars): Power-user tool, different audience. Don't compete.

## Key Metrics (once users exist)

| Metric | Target | How to measure |
|--------|--------|----------------|
| Plugin installs | 50 in first month | GitHub traffic + collective signal submissions |
| Bootstrap completions | 30 | Collective signals with persona data |
| Habits graduated | 3+ avg per user | Collective signals with graduation data |
| Corrections submitted | 100 total | GitHub issues with collective-signal label |
| Session retention | 5+ sessions per user | Telemetry session count |
