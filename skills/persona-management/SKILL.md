---
name: persona-management
description: Use when the user wants to view, modify, or reset their Alfred persona, or when running /persona
---

# Persona Management

Manages the user's evolving persona stored in `.claude/alfred-persona.yaml`.

## When to Use

- User runs `/persona` or asks about their persona
- User says "show my persona" or "what does Alfred know about me"
- User wants to adjust autonomy, explain level, or known concepts

## Algorithm

### View Persona

1. Read `.claude/alfred-persona.yaml`
2. If missing, say: "No persona file yet. It will be created automatically after your first `/self-improve` run, or you can run `/persona init` to create one now."
3. Display the persona in a readable format:

```
=== Your Alfred Persona ===
Name: <name or "not yet named">
Domain: <primary> (+ <secondary list>)
Explain level: <level>
Autonomy: <autonomy>
Known concepts: <list or "none yet">
Custom rules: <count> rules learned
Corrections received: <count>
Last evolved: <date or "never">
```

### Initialize Persona (`/persona init`)

1. Read `.claude/.onboarding-state.json` for persona and coding_level
2. Read `.claude/alfred.yaml` for project type and tools
3. Create `.claude/alfred-persona.yaml` from defaults:

```yaml
name: ""
domain:
  primary: "<from onboarding persona>"
  secondary: []
explain:
  level: "<from coding_level: beginner→novice, intermediate→intermediate, advanced→expert>"
  known_concepts: []
behavior:
  autonomy: suggest-then-do
  commit_style: conventional
patterns:
  preferred_tools: ["<from alfred.yaml formatting.tool>"]
  avoided_tools: []
  custom_rules: []
evolution:
  correction_count: 0
  last_evolved: null
```

### Modify Persona

Users can adjust specific fields:

- `/persona autonomy just-do-it` → set `behavior.autonomy`
- `/persona explain expert` → set `explain.level`
- `/persona know SHAP cross-validation` → add to `explain.known_concepts`
- `/persona forget SHAP` → remove from `explain.known_concepts`
- `/persona prefer ruff pytest` → add to `patterns.preferred_tools`
- `/persona avoid jupyter` → add to `patterns.avoided_tools`
- `/persona name "The Notebook Hater"` → set `name`

After any modification:
1. Read current `.claude/alfred-persona.yaml`
2. Apply the change
3. Write back
4. Confirm: "Persona updated: <field> → <new value>"

### Reset Persona (`/persona reset`)

1. Ask: "This will reset your persona to defaults. Your correction history will be preserved. Continue? (yes/no)"
2. If yes, regenerate from defaults (same as init)
3. Confirm: "Persona reset to defaults."

## Important

- Never create the persona file without user action (init, self-improve, or explicit modify)
- The persona file is gitignored — it's local to each user
- Known concepts are never removed automatically — only the user can `/persona forget`
- Autonomy changes require explicit user request — auto-evolution only suggests
