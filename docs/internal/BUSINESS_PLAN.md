# Alfred Business Plan

*Internal document. Updated 2026-03-30.*

## Product

Alfred is a Claude Code plugin that teaches AI-assisted development habits progressively, adapts to 7 professional domains, and compounds user corrections into team-wide automation. It's the only tool that combines teaching, personas, and self-improvement in one system.

## Market Thesis

People fail at AI-assisted development because of missing habits, not missing AI capabilities. AI coding tools help developers write code faster but don't teach how to: scope work, save progress, experiment safely, trace results, or enforce standards. Alfred fills this gap.

## Market Segments (ranked by entry strategy)

### 1. Academic researchers (wedge market)

**Why first:**
- Proven demand: pedrohcgs (784 stars, 1,485 forks) for a static LaTeX template
- Low friction: individual decision, no procurement
- High word-of-mouth: labs, papers, students
- Burning pain: reproducibility requirements from NIH, NSF
- Students → professionals: seeds enterprise market

**How to reach them:**
- Plugin marketplace listing
- awesome-claude-code listing (33K stars)
- Posts in academic data science communities
- "How to make AI-assisted research reproducible" content

### 2. Data professionals (volume market)

**Why second:**
- Adjacent to academics (many came from research)
- 5 of 7 Alfred personas built for them
- High-value roles ($120-200K salaries = budget for tools)
- Work in companies that become enterprise prospects

**How to reach them:**
- Community signals from Phase 1
- Data science communities (r/datascience, dbt Slack, ML discords)
- Conference talks (if traction proves thesis)

### 3. Enterprise AI adoption teams (revenue market)

**Why third (not first):**
- Need credibility (500+ users, case studies) before enterprise sales
- 6-12 month procurement cycles
- Alfred's collective learning IS the enterprise pitch: "corrections compound into team standards"

**The pitch:**
"Your developers use AI coding tools but produce inconsistent work. Alfred teaches the habits that make AI-assisted development reliable, and compounds corrections into team-wide standards that enforce themselves."

## Business Model

Open-core with team tier (proven model: GitLab, Sentry, PostHog).

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | All commands, personas, habits, self-improvement, collective contribution |
| Team | $10/user/month | CLAUDE.md governance (admin-controlled, auditable, rollback-able), team-wide correction patterns ("8 of 10 hit the same mistake"), onboarding acceleration (new hires inherit accumulated guardrails), priority support |
| Enterprise | $30/user/month | SSO, custom personas, private collective, compliance reporting |

Free tier builds community. Team tier monetizes governance, onboarding speed, and collective intelligence — things engineering managers already buy. Enterprise tier is real revenue.

**Team tier value prop must map to existing manager concerns:**
- Code quality → "systematic mistakes prevented" (not "habits graduated")
- Onboarding speed → "new hire inherits team's accumulated corrections as guardrails"
- Consistency → "CLAUDE.md governance: one admin controls what every team member gets"

Do NOT pitch habit analytics. Pitch governance, quality, and onboarding.

## Validation Milestones (revenue projections deferred until PMF confirmed)

No dollar figures until paying design partners exist. Revenue projections based on zero data points create false confidence.

| Year | Goal | Success metric |
|------|------|----------------|
| 2026 (H2) | Validate product-market fit | 10+ returning users (3+ sessions each) |
| 2027 | Test willingness-to-pay | 3 teams running paid pilots |
| 2028 | Build paid tier (if WTP confirmed) | First paying customers |

**Why no revenue projections:** Previous projections ($50K-150K in 2027 from 20-50 teams) required 21-25 users per team — all using Claude Code, all paying $10/month for habit analytics. That math doesn't work for a plugin on someone else's platform. Revisit projections only after 3+ teams express willingness to pay.

## Competitive Moat

1. **Behavioral science** — scaffolding, analogical transfer, choice architecture. Hard to replicate without understanding learning theory.
2. **Collective learning network effects** — each user's corrections strengthen the system for everyone.
3. **7 deep domain personas** — not generic, not configurable — purpose-built translations.
4. **Full pipeline** — teaching → graduation → correction → rule → hook → collective. No competitor has all pieces.

### Key competitors to watch

| Competitor | Threat | Alfred's defense |
|-----------|--------|-----------------|
| claude-reflect (861 stars) | Adds teaching/personas | Collective learning (network effects) |
| Claude Code native features | Builds in corrections/memory | Behavioral science depth, personas |
| SuperClaude (22K stars) | None (different audience) | Don't compete |

## Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| **Platform risk (Anthropic builds it in)** | **Existential** | Cross-tool support is Phase 2, not deferred. Cursor `.cursorrules`, Copilot `copilot-instructions.md`, Windsurf `.windsurfrules` exports expand TAM 10x and de-risk Anthropic dependency. Behavioral science is tool-agnostic. |
| "Designed to disappear" = anti-retention | High | After graduation, Alfred shifts from teacher to ongoing quality enforcer. Expand habit library with domain-specific advanced habits. Make collective learning the continuous value. |
| No product-market fit | High | Phase 1-2 designed to test cheaply; pivot if 0 users after distribution |
| Academic wedge = low revenue | Medium | Academics validate adoption, not revenue. Revenue comes from data professionals and enterprise (segments 2-3). Don't over-invest in academic-specific features. |
| Solo founder scaling | Medium | AI-assisted development is the force multiplier; Alfred helps build Alfred |
| claude-reflect catches up | Medium | Network effects from collective learning; deeper behavioral science |

**Platform risk is the #1 threat.** Every platform eventually absorbs its most popular plugin patterns. Anthropic's roadmap likely includes native memory/corrections, user profiles, progressive onboarding, and team config management. Cross-tool support is the insurance policy — and it must ship before Anthropic absorbs any of these.

## Go/No-Go Decision Points

| Milestone | If YES | If NO |
|-----------|--------|-------|
| 50 installs after marketplace listing | Proceed to Phase 3 | Reassess positioning and distribution |
| 5 active users (3+ sessions) | Build team dashboard prototype | Reassess product-market fit |
| Enterprise interest (inbound inquiry) | Run free pilot | Focus on community growth |
| 500 active users | Launch team tier | Stay free, grow community |

## Key Insight

Don't build a business yet. Build a community. The most expensive mistake in developer tools is building the enterprise product before validating the product-market fit. Every business model depends on one thing: **do people actually want AI development coaching?** Phase 1-3 answers this question at near-zero cost.

## Comparable Outcomes

| Tool | Revenue model | Annual revenue | How they started |
|------|-------------|---------------|-----------------|
| Tabnine | Freemium | ~$30M | Free autocomplete → team features |
| Qodo | Enterprise | ~$10M | Open-source code review → enterprise |
| CodeRabbit | Freemium | ~$5M | Free for OSS → pro tier |

All started free, built community, then monetized team/enterprise features. None tried to charge before having users.

**Important caveat:** These are all platforms that own their stack. Alfred is a plugin on someone else's platform. A plugin's revenue ceiling is fundamentally lower unless it becomes cross-platform.

## Alternative Exit Paths

Alfred's best outcome may not be an independent $1M ARR business. Consider:

1. **Acqui-hire / feature acquisition** — Anthropic acquires the approach. Alfred becomes Claude Code's native onboarding system. Behavioral science, personas, and graduation tracking become platform features.
2. **Feature licensing** — other AI coding tools (Cursor, Windsurf, Copilot) license the persona and teaching system for their own onboarding.
3. **Consulting/training** — use Alfred as a demonstration of AI-assisted development coaching, sell expertise to enterprises directly.

Build toward optionality, not a single path.
