---
name: smart-suggestions
description: Use when the user seems stuck or could benefit from an Alfred command they haven't tried yet
---

# Smart Suggestions

## When to Suggest

- User has uncommitted changes on main → suggest `/new-work`
- User is debugging CI failures manually → suggest `/ci-fix`
- User is refactoring without tests → suggest `/safe-refactor`
- User has 5+ feedback memories → suggest `/self-improve`
- User hasn't learned any patterns yet → suggest `/teach`
- User is doing multi-file changes → suggest `/commit` for save points

## How to Suggest

Keep suggestions brief and non-intrusive. One line, framed as a question:

> "Would `/ci-fix` help here? It auto-loops through lint/test failures."

Never repeat a suggestion the user has dismissed in the same session.
