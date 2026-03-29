# Persona: Writer / Editor

## Domain Context Template
- Project type: manuscripts, articles, documentation, books, content creation
- Typical stack: Markdown, pandoc, Vale/proselint, LaTeX, static site generators
- Lifecycle: research → outline → draft → revise → edit → export → publish
- Key concern: version integrity, revision provenance, style consistency, audience clarity

## Common Tasks
1. Draft a new chapter, article, or section from an outline
2. Revise a draft based on editor or client feedback
3. Restructure a manuscript (reorder sections, split/merge chapters)
4. Export to a deliverable format (PDF, DOCX, HTML, EPUB)
5. Maintain voice and style consistency across a long document
6. Incorporate research notes and sources into prose
7. Compare two versions of a draft to see what changed
8. Prepare a manuscript for submission or publication

## Guardrails
- Never overwrite an approved or submitted draft — create a new version (v1, v2, v3)
- Tag every export with the version and date it was generated from
- Don't commit client feedback or editor notes verbatim to git (may contain confidential direction)
- Include the reason for each revision in commit messages (not just "updated draft")
- Version explicitly — never rename `draft.md` in place; use `draft-v1.md`, `draft-v2.md`
- Keep research notes and source material separate from the manuscript directory

## Analogy Map

| # | Pattern | Writing Analogy |
|---|---------|----------------|
| 1 | context_before_action | "Re-reading your last few paragraphs before starting today's writing session — pick up the thread without contradicting yourself" |
| 2 | scope_before_work | "Writing an outline before drafting — know the structure so you don't wander off-topic" |
| 3 | save_points | "Sealing a draft version — marking a clean copy so you can always return to it if revisions go sideways" |
| 4 | safe_experimentation | "Writing an alternate opening on a separate sheet — try a new angle without losing the original" |
| 5 | one_change_one_test | "Revising for one thing at a time — first structure, then clarity, then style — so you don't lose track of what you changed" |
| 6 | automated_recovery | "Keeping a master copy in a fireproof safe — if your working copy gets coffee-stained, you start fresh from the master" |
| 7 | provenance | "Citing your sources — every claim traces back to a reference, and every revision traces back to a reason" |
| 8 | self_improvement | "Updating your style guide after learning what works — your next project starts stronger than the last" |

## Discovery Triggers
- `.md` files with 500+ lines detected → suggest manuscript workflow (draft versioning, section splitting)
- `manuscript/` or `drafts/` directory → activate draft protection (never overwrite approved versions)
- `.bib` or `references/` detected → suggest citation management patterns
- `style/` directory or Vale config detected → activate style enforcement
- `exports/` directory → suggest export versioning and provenance tagging

## Starter Artifacts
- `manuscript/` — active drafts and chapters (versioned: draft-v1.md, draft-v2.md)
- `notes/` — research notes, interview transcripts, reference material
- `outlines/` — structural outlines and content plans
- `exports/` — generated deliverables (PDF, DOCX, EPUB) with version tags
- `style/` — style guides, Vale rules, voice and tone references

## Recommended Tools
- **Prose linter**: Vale or proselint
- **Document tools**: pandoc, LaTeX + BibTeX
- **Formatter**: prettier (for Markdown)
- **Diff tool**: `git diff --word-diff` (shows changes at the word level, not line level)
- **Superpowers skills**: superpowers:brainstorming, superpowers:systematic-debugging

## Work Product Templates

| Level | What Claude writes | Example |
|-------|-------------------|---------|
| 1 (Beginner) | Drafts with inline comments explaining structural choices | `draft-v1.md` with comments like "This paragraph establishes the main argument" |
| 2 (Intermediate) | Clean drafts with revision notes in commit messages | Commit: "Restructure intro to lead with the anecdote per editor feedback" |
| 3 (Advanced) | Manuscript with Makefile for automated export pipeline | `make pdf` builds final PDF from Markdown via pandoc with style template |
| 4 (Expert) | Multi-format publishing pipeline with style checks and CI | Vale lint + pandoc export + version tagging on every commit |

**Standard output format**: Export with provenance:
```
manuscript-v3.pdf
  Source: manuscript/draft-v3.md
  Style: style/house-style.yaml
  Generated: 2026-03-29 | Git SHA: abc1234
  Word count: 12,450
```

## Error Context

| Error symptom | Likely cause | Suggested fix |
|--------------|-------------|---------------|
| "The latest draft lost changes I made last week" | Overwrote file instead of creating new version | Always version drafts (v1, v2, v3); use git log to find lost content |
| "Pandoc export looks different from the Markdown" | Missing or wrong template, unsupported Markdown extensions | Pin pandoc version, use explicit `--template`, check for extension compatibility |
| "Style is inconsistent between chapters" | Multiple writing sessions without style reference | Create a style guide in `style/`, run Vale/proselint before finalizing |
| "Can't tell which version the client approved" | No version tagging on exports | Tag approved versions with `git tag approved-v2`, name exports with version |
| "Editor's tracked changes don't match my draft" | Working from different base versions | Always confirm which version feedback applies to; use `git diff` to reconcile |

## 10. Prompting Guide

Effective prompting patterns for writing and editing:

- **Describe your audience and tone first.** "This is a blog post for technical managers, conversational but authoritative" gives Claude the voice to match.
- **State the scope of the revision.** "Tighten the introduction — it should be half as long" is better than "make this better."
- **Ask for structural feedback before polish.** "Does this argument flow logically?" before "Fix the grammar" saves rework.
- **Request consistency checks.** "Are the character names consistent across chapters?" or "Does the terminology match the glossary?" catches drift.
- **Use depth signals.** "Give me three alternative openings for this section" produces options; "Rewrite this paragraph" produces one guess.
- **Challenge the structure.** "What's the weakest section in this draft and why?" surfaces problems you're too close to see.
