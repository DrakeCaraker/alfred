---
name: persona-evolve
description: Use during self-improve to automatically evolve the user persona based on accumulated corrections and usage patterns
---

# Persona Evolution

Analyzes feedback memories and usage patterns to suggest persona adjustments. Runs as part of `/self-improve` — never runs independently.

## Evolution Rules

### Concept Learning
**Trigger**: User says "I know what X is", "don't explain X", "I already understand X"
**Action**: Add X to `explain.known_concepts`
**Auto-apply**: Yes (low risk — only affects explanation verbosity)

### Autonomy Nudge Up
**Trigger**: 18+ out of last 20 suggestions were accepted (approved without pushback)
**Action**: Suggest nudging `behavior.autonomy` one level up:
  - `ask-first` → `suggest-then-do`
  - `suggest-then-do` → `just-do-it`
**Auto-apply**: No — always ask user. Show: "You've approved 18/20 recent suggestions. Want me to act more autonomously? (yes/no)"

### Autonomy Nudge Down
**Trigger**: 5+ out of last 20 suggestions were rejected ("no", "don't", "stop", "undo")
**Action**: Suggest nudging `behavior.autonomy` one level down:
  - `just-do-it` → `suggest-then-do`
  - `suggest-then-do` → `ask-first`
**Auto-apply**: No — always ask user.

### Tool Preference Learning
**Trigger**: User says "use X not Y", "prefer X", "don't use Y"
**Action**: Add X to `patterns.preferred_tools`, add Y to `patterns.avoided_tools`
**Auto-apply**: Yes (clear user directive)

### Custom Rule Learning
**Trigger**: Feedback memory promoted to CLAUDE.md rule via self-improve
**Action**: Add the rule text to `patterns.custom_rules`
**Auto-apply**: Yes (already user-approved during self-improve)

### Persona Fit Detection
**Trigger**: 5+ corrections that overlap with a DIFFERENT persona's guardrails (across 3+ sessions)
**Action**: Note in persona YAML: `evolution.fit_signal: "platform-bi"` (the better-fitting persona)
**Auto-apply**: Yes (silent note only — does NOT switch personas or alert user)
**Purpose**: Pre-computes fit data so `/persona suggest` can give instant results instead of re-scanning all memories

### Persona Naming (Emergence)
**Trigger**: 5+ entries in `patterns.custom_rules`
**Action**: Analyze the custom rules, preferred/avoided tools, and domain to suggest a persona name
**Auto-apply**: No — show suggestion, ask user to confirm or edit

Example suggestions based on rule clusters:
- Rules about notebooks + ML domain → "ML engineer who prefers scripts over notebooks"
- Rules about testing + strict git → "Test-driven developer with strict git hygiene"
- Rules about SQL + dashboards → "Dashboard builder who thinks in SQL"

## Integration with Self-Improve

Add this after Step 5 (execute approved changes) in `/self-improve`:

### Step 5b: Persona Evolution

1. Check if `.claude/alfred-persona.yaml` exists
   - If not, and this is the first self-improve run, create it (same as `/persona init`)
   - If not and user hasn't bootstrapped, skip

2. Scan feedback memories for evolution triggers:
   - Grep for "I know", "don't explain", "already understand" → concept learning
   - Grep for "use X not Y", "prefer X", "don't use Y" → tool preferences
   - Count approvals vs rejections in recent history → autonomy signal

3. Apply auto-apply changes silently (concepts, tools, custom rules)

4. For non-auto changes (autonomy, naming), ask the user

5. Update `evolution.correction_count` and `evolution.last_evolved`

6. Report persona changes:
   ```
   Persona evolved:
   - Added to known concepts: SHAP, cross-validation
   - Added preferred tool: ruff
   - Custom rules: 3 new (7 total)
   - Autonomy: unchanged (suggest-then-do)
   ```

## Privacy

- Persona files are local only (gitignored)
- When sharing anonymized personas (Phase 5), strip:
  - `name` field
  - Any entries in `known_concepts` that could identify the user
  - `evolution.correction_count` and `evolution.last_evolved`
- Keep: `domain`, `explain.level`, `behavior`, `patterns.custom_rules` (after anonymizer pass)
