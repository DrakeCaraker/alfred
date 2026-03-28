# Alfred Business Plan

*Internal document. Updated 2026-03-28.*

## Product

Alfred is a Claude Code plugin that teaches AI-assisted development habits progressively, adapts to 6 professional domains, and compounds user corrections into team-wide automation. It's the only tool that combines teaching, personas, and self-improvement in one system.

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
- 4 of 6 Alfred personas built for them
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
| Team | $10/user/month | Collective dashboard, team analytics, admin controls, priority support |
| Enterprise | $30/user/month | SSO, custom personas, private collective, compliance reporting |

Free tier builds community. Team tier monetizes collective learning. Enterprise tier is real revenue.

## Revenue Projections (conservative)

| Year | Free users | Paid teams | Revenue |
|------|-----------|-----------|---------|
| 2026 (H2) | 100-500 | 0 | $0 |
| 2027 | 1,000-5,000 | 20-50 | $50K-150K |
| 2028 | 5,000-20,000 | 100-300 | $300K-1M |

Projections assume product-market fit is validated by end of 2026.

## Competitive Moat

1. **Behavioral science** — scaffolding, analogical transfer, choice architecture. Hard to replicate without understanding learning theory.
2. **Collective learning network effects** — each user's corrections strengthen the system for everyone.
3. **6 deep domain personas** — not generic, not configurable — purpose-built translations.
4. **Full pipeline** — teaching → graduation → correction → rule → hook → collective. No competitor has all pieces.

### Key competitors to watch

| Competitor | Threat | Alfred's defense |
|-----------|--------|-----------------|
| claude-reflect (861 stars) | Adds teaching/personas | Collective learning (network effects) |
| Claude Code native features | Builds in corrections/memory | Behavioral science depth, personas |
| SuperClaude (22K stars) | None (different audience) | Don't compete |

## Risks

| Risk | Mitigation |
|------|-----------|
| Platform risk (Anthropic builds it in) | Cross-tool support as insurance; behavioral science is platform-independent |
| No product-market fit | Phase 1-2 designed to test cheaply; pivot if 0 users after distribution |
| Solo founder scaling | AI-assisted development is the force multiplier; Alfred helps build Alfred |
| claude-reflect catches up | Network effects from collective learning; deeper behavioral science |

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
