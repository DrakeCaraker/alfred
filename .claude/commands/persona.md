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

## Algorithm

Use the `alfred:persona-management` skill. Follow its algorithm exactly for the given subcommand.

If no argument is provided, show the current persona state.

## Rules

- The persona file is `.claude/alfred-persona.yaml` — local only, gitignored
- Never modify the persona without user action
- Autonomy enum is strict: only `ask-first`, `suggest-then-do`, `just-do-it`
- Explain level enum is strict: only `novice`, `intermediate`, `expert`
- Known concepts are free-text strings (whatever the user says they know)
