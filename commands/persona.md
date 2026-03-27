# Persona Management

View, modify, or reset your Alfred persona. Your persona evolves over time based on corrections and preferences, adapting how Alfred explains things and how autonomously it acts.

## Arguments

$ARGUMENTS — optional subcommand:
- (none) → view current persona
- `init` → create persona from defaults
- `reset` → reset to defaults
- `autonomy <level>` → set autonomy (ask-first, suggest-then-do, just-do-it)
- `explain <level>` → set explain level (novice, intermediate, expert)
- `know <concept> [concept2...]` → add known concepts (stops explaining them)
- `forget <concept>` → remove a known concept
- `prefer <tool> [tool2...]` → add preferred tools
- `avoid <tool> [tool2...]` → add avoided tools
- `name "<name>"` → set persona name
- `check` → interactive persona fit assessment
- `suggest` → analyze corrections and suggest a better-fitting persona
- `generate` → create a new persona template from accumulated custom rules
- `analyze` → generate encrypted persona intelligence report

## Algorithm

Use the `alfred:persona-management` skill. Follow its algorithm exactly for the given subcommand.

If no argument is provided, show the current persona state.

---

### `/persona check` — Persona Fit Assessment

Interactive fit check. Typically triggered by a session-start nudge after 3 sessions.

1. Read `.claude/.onboarding-state.json` for current persona and coding_level
2. Read `.claude/personas/<persona>.md` — extract the Domain Context and Guardrails sections
3. Show the user their current persona and a 1-sentence description of what it optimizes for
4. Ask the fit question:
   - **Beginners**: "Is Alfred using the right kind of examples for your work? (yes / not quite)"
   - **Intermediate/Advanced**: "Does the [persona] persona fit your work well? (yes / not quite)"
5. If **yes**: set `persona_fit: true` in onboarding state. Done.
6. If **not quite**: ask "What's different about your work?" Store the answer:
   - Raw text → `persona_gap` in onboarding state (local only, never in telemetry)
   - Read `collective/role-categories.yaml` and categorize the response → `custom_role_category` in onboarding state (safe for telemetry)
   - Set `persona_fit: false` in onboarding state
7. Set `persona_fit_checked: true` in onboarding state so the nudge doesn't fire again
8. If persona_fit is false, suggest: "Run `/persona suggest` to see if a different persona would be a better fit."

---

### `/persona suggest` — Persona Re-Suggestion

Analyzes accumulated corrections and suggests the best-fitting persona.

1. Read `.claude/.onboarding-state.json` for current persona
2. Read `.claude/alfred-persona.yaml` for custom_rules, preferred_tools, avoided_tools
3. Read feedback memories (from `~/.claude/projects/<project-key>/memory/feedback_*.md`)
4. Read ALL 6 persona files from `.claude/personas/`:
   - Extract the Guardrails section from each
   - Extract the Domain Context section from each
5. Score each persona by counting how many of the user's custom rules and corrections OVERLAP with that persona's guardrails and domain signals
6. **Threshold**: Only suggest a switch if:
   - A different persona scores higher than the current one
   - At least 5 corrections over 3+ sessions point to the alternative
   - The fit gap is clear (alternative scores ≥50% higher)
7. If a better fit is found, show:
   ```
   Your corrections suggest [alternative-persona] might be a better fit.

   Current: [current-persona] — [description]
   Suggested: [alternative-persona] — [description]

   Matching corrections:
   - "always validate join row counts" → business-analytics guardrail
   - "use dbt instead of raw SQL" → platform-bi guardrail
   - [...]

   Switch to [alternative-persona]? This updates your guardrails and teaching
   analogies. Your custom rules and preferences are preserved. (yes/no)
   ```
8. If **yes**: Update `persona` in `.claude/.onboarding-state.json`. Regenerate the Guardrails section of CLAUDE.md from the new persona's guardrails. Preserve all other CLAUDE.md sections.
9. If **no switch found**: "Your current persona ([persona]) is the best fit based on your corrections. Run `/persona generate` if you'd like to create a custom persona."

---

### `/persona generate` — Create Custom Persona Template

Generates a draft persona template from accumulated custom rules and preferences.

**Prerequisites**: At least 5 custom rules in `.claude/alfred-persona.yaml`.

1. Read `.claude/alfred-persona.yaml` — extract all fields
2. Read `.claude/.onboarding-state.json` — extract persona, coding_level, custom_role_description (if Option 7)
3. Read the CLOSEST existing persona file as the base template
4. Generate a new `.claude/personas/<name>.md` with all 9 sections:

   **Section quality tiers:**

   | Section | Source | Approach |
   |---------|--------|----------|
   | Domain Context | role description + corrections | Write from scratch based on user's actual domain |
   | Guardrails | custom_rules verbatim | Copy directly — these are battle-tested |
   | Recommended Tools | preferred_tools from YAML | Copy directly + merge with base persona's tools |
   | Common Tasks | commands used + correction patterns | Infer from correction patterns. Mark `<!-- NEEDS REVIEW -->` |
   | Starter Artifacts | project structure inference | Copy from base persona, adjust if corrections suggest different structure |
   | Discovery Triggers | file patterns in corrections | Infer from correction patterns. Mark `<!-- NEEDS REVIEW -->` |
   | Analogy Map (22+ entries) | Inferred from domain | **Generate all 22+ entries. Mark `<!-- NEEDS REVIEW — these analogies need domain expertise to validate -->`** |
   | Work Product Templates | Inferred from domain | Generate 4 complexity levels. Mark `<!-- NEEDS REVIEW -->` |
   | Error Context | correction patterns | Infer from common errors in corrections. Mark `<!-- NEEDS REVIEW -->` |

5. Write the file to `.claude/personas/<name>.md`
6. Show the user:
   ```
   Draft persona created: .claude/personas/<name>.md

   Sections ready to use:
     ✓ Domain Context
     ✓ Guardrails (from your custom rules)
     ✓ Recommended Tools

   Sections that need your review:
     ⚠ Common Tasks — verify these match your work
     ⚠ Analogy Map — validate the domain analogies (22 entries)
     ⚠ Work Product Templates — check the 4 complexity levels
     ⚠ Discovery Triggers — verify file patterns
     ⚠ Error Context — verify common errors

   Review the ⚠ sections, then add the persona to bootstrap Q1 and PR it.
   ```

---

### `/persona analyze` — Generate Encrypted Intelligence Report

Synthesizes all persona data into an encrypted report for private staging.

1. Read `.claude/.onboarding-state.json` — all persona-related fields
2. Read `.claude/alfred-persona.yaml` — all fields
3. Read feedback memories — count and categorize patterns
4. Read `collective/role-categories.yaml` — map custom_role_category if not already set
5. Compute a pilot ID hash: first 8 chars of SHA-256 of the anonymous_id from `.claude/.pilot-identity.json`
6. Build the intelligence JSON:
   ```json
   {
     "generated_at": "<ISO-8601>",
     "schema_version": "1.0",
     "pilot_id_hash": "<8-char hash>",
     "persona_assigned": "<current persona>",
     "used_custom_role": true,
     "custom_role_category": "<category from taxonomy>",
     "persona_fit": false,
     "persona_gap_category": "<categorized gap — NOT raw text>",
     "custom_rules_count": 7,
     "custom_rules_summary": ["<anonymized rule summaries>"],
     "correction_patterns": {"infrastructure": 12, "testing": 3},
     "tool_preferences": {"preferred": ["ruff", "dbt"], "avoided": ["black"]},
     "suggested_persona": "platform-bi",
     "ready_for_generation": true
   }
   ```
7. **Encrypt and write:**
   - Check if `.claude/.pilot-intel-key` exists. If not, generate a random 32-byte key:
     `openssl rand -base64 32 > .claude/.pilot-intel-key && chmod 600 .claude/.pilot-intel-key`
   - Create directory: `mkdir -p .pilot/private/<pilot-id-hash>/ && chmod 700 .pilot/private/<pilot-id-hash>/`
   - Write JSON to temp file, encrypt:
     `openssl enc -aes-256-cbc -pbkdf2 -salt -in <temp> -out .pilot/private/<hash>/persona-intel.enc -pass file:.claude/.pilot-intel-key`
   - Remove temp file
8. Show:
   ```
   Persona intelligence report generated and encrypted.
   Location: .pilot/private/<hash>/persona-intel.enc
   Key: .claude/.pilot-intel-key (local only, 0600)

   Summary:
   - Persona: [persona] (fit: [yes/no/unchecked])
   - Category: [custom_role_category or "standard"]
   - Custom rules: [N]
   - Ready for persona generation: [yes/no]
   ```

**CRITICAL**: The JSON must NOT contain `custom_role_description` or `persona_gap` raw text. Only categorized values. The encrypted file is defense-in-depth, but the data itself should be safe even if decrypted.

---

## Rules

- The persona file is `.claude/alfred-persona.yaml` — local only, gitignored
- Never modify the persona without user action
- Autonomy enum is strict: only `ask-first`, `suggest-then-do`, `just-do-it`
- Explain level enum is strict: only `novice`, `intermediate`, `expert`
- Known concepts are free-text strings (whatever the user says they know)
- Never auto-switch personas — always confirm with user
- Never include raw descriptions (custom_role_description, persona_gap) in telemetry, collective signals, or the persona-intel.enc report
- The `check` subcommand runs at most once (set persona_fit_checked: true). Users can always re-run it manually.
