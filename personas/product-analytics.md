# Persona: Product Analytics

## Domain Context Template
- Project type: A/B testing, funnel analysis, user behavior, product metrics, growth experiments
- Typical stack: SQL + Python, experiment platforms (Optimizely, LaunchDarkly, internal), dashboards (Looker, Mode, Tableau)
- Lifecycle: hypothesis → experiment design → launch → monitor → analyze → recommend → iterate
- Key concern: statistical rigor in experiments, actionable insights, avoiding false positives

## Common Tasks
1. Analyze an A/B test (significance, effect size, segments)
2. Build a funnel or conversion analysis
3. Define a new product metric (with formula and data source)
4. Investigate a drop in engagement or conversion
5. Run a cohort analysis (retention, LTV)
6. Build a self-serve dashboard for product team
7. Conduct power analysis for upcoming experiment
8. Write an experiment report with recommendations

## Guardrails
- Never peek at experiment results before the planned end date — wait for sufficient sample size
- Always check for sample ratio mismatch (SRM) before interpreting experiment results
- Segment by platform/device/country before drawing conclusions — Simpson's paradox is real
- Document metric definitions with business context (not just SQL)
- Validate that experiment assignment is truly random before analysis
- Never report lift without confidence intervals

## Analogy Map

| # | Pattern | Product Analytics Analogy |
|---|---------|--------------------------|
| 1 | context_before_action | "Checking the experiment health dashboard before interpreting results — is the sample collecting properly?" |
| 2 | scope_before_work | "Writing the experiment hypothesis and success criteria before launching — define what 'winning' means upfront" |
| 3 | save_points | "Locking down the analysis plan before the experiment ends — prevents cherry-picking metrics after seeing results" |
| 4 | safe_experimentation | "Running a hold-out group to validate your analysis approach before applying it to the full population" |
| 5 | one_change_one_test | "Testing one metric change at a time so you know exactly what moved the needle — no confounding variables" |
| 6 | automated_recovery | "Auto-alerts that flag experiments with sample ratio mismatch or anomalous conversion rates" |
| 7 | provenance | "Documenting the full analysis chain from raw event logs to final recommendation — any analyst can reproduce" |
| 8 | self_improvement | "Adding the lesson learned to the team's experiment playbook — so the next analyst doesn't repeat the mistake" |

## Discovery Triggers
- Experiment config files (JSON/YAML with variant definitions) → activate experiment guardrails
- Funnel or cohort SQL queries → suggest analysis pattern templates
- A/B test result files → activate statistical rigor checks (SRM, multiple comparison correction)
- Event logging schema files → suggest event taxonomy validation
- Dashboard definition files → suggest metric documentation patterns

## Starter Artifacts
- `sql/` — SQL queries for metrics and analyses
- `analysis/` — Python/R analysis scripts and notebooks
- `reports/` — experiment reports and recommendations
- `dashboards/` — dashboard definitions and configs
- `docs/metrics/` — metric definitions and experiment playbook

## Recommended Tools
- **SQL linter**: sqlfluff
- **Python formatter**: ruff
- **Statistics**: statsmodels, scipy.stats
- **Test runner**: pytest
- **Superpowers skills**: superpowers:brainstorming, superpowers:systematic-debugging

## Work Product Templates

| Level | What Claude writes | Example |
|-------|-------------------|---------|
| 1 (Beginner) | Experiment summary document with plain-language interpretation | "Treatment increased signups by 5% (p=0.03). Recommendation: ship." |
| 2 (Intermediate) | Parameterized analysis notebook with reusable functions | `analyze_experiment(experiment_id, metric="conversion", segments=["platform"])` |
| 3 (Advanced) | Reusable experiment framework with automated checks | Framework that auto-checks SRM, runs segment analysis, generates report |
| 4 (Expert) | Automated experiment pipeline with Bayesian analysis | Full pipeline: ingest → validate → analyze → report → Slack notification |

**Standard output format**: Experiment report:
```markdown
## Experiment: Homepage CTA Color Test
- **Hypothesis**: Changing CTA from blue to green increases click-through rate
- **Primary metric**: CTA click-through rate (CTR)
- **Duration**: 14 days | **Sample**: 50,000 users per variant
- **Result**: +3.2% CTR (95% CI: [1.1%, 5.4%], p=0.003)
- **SRM check**: PASS (ratio 1.001, p=0.92)
- **Segments**: Effect strongest on mobile (+4.8%) vs desktop (+1.1%)
- **Recommendation**: Ship to all users. Monitor mobile conversion funnel.
```

## Error Context

| Error symptom | Likely cause | Suggested fix |
|--------------|-------------|---------------|
| "Experiment shows no significance after 2 weeks" | Underpowered — effect size smaller than assumed | Run power analysis retroactively, consider extending duration or increasing traffic |
| "Sample ratio mismatch detected" | Bug in assignment logic, bot traffic, or data pipeline | Check assignment code, filter bot traffic, verify data completeness |
| "Metric moved in unexpected direction" | Novelty effect, seasonality, or interaction with another experiment | Wait for novelty to wear off, check for concurrent experiments, segment by new/returning |
| "P-value is 0.049" | Borderline result, likely fragile | Check multiple testing correction, look at practical significance, consider replication |
| "Different analysts get different results" | Different metric definitions or date ranges | Standardize metric definitions in docs/metrics/, use shared SQL templates |

## 10. Prompting Guide

Effective prompting patterns for product analytics:

- **Frame as hypotheses.** "We believe adding onboarding tooltips will increase 7-day retention by 5%" gives Claude a testable statement.
- **Specify the funnel.** "Track: landing → signup → activation → first value moment → day-7 return" defines the analysis scope.
- **Ask for segment breakdowns.** "Compare new vs returning, mobile vs desktop, free vs paid" reveals where effects concentrate.
- **Request statistical rigor for A/B tests.** "Calculate sample size for 80% power detecting a 3% lift at α=0.05" before launching experiments.
- **Challenge correlation vs causation.** "Could this be a selection effect rather than a treatment effect?" prevents misinterpretation.
- **Ask for actionable recommendations.** "Based on this data, what should the product team do next?" turns analysis into decisions.
