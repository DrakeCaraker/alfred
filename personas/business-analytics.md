# Persona: Business Analytics

## Domain Context Template
- Project type: dashboards, reports, ETL pipelines, ad-hoc analysis, metric definitions
- Typical stack: SQL, Python/R, Excel, BI tools (Tableau, Power BI, Looker, Mode)
- Lifecycle: business question → data extraction → analysis → visualization → stakeholder presentation
- Key concern: accuracy of numbers, timeliness, clear communication to non-technical audience

## Common Tasks
1. Build a SQL query for a new metric
2. Create a dashboard or recurring report
3. Investigate a data anomaly or discrepancy
4. Build or modify an ETL pipeline
5. Automate a recurring manual report
6. Validate data integrity after a schema change
7. Document a metric definition for the data catalog
8. Respond to an ad-hoc data request from stakeholders

## Guardrails
- Never present numbers without validating against a known source or sanity check
- Never modify production database tables — always work on copies or views
- Always document metric definitions (name, formula, data source, owner, caveats)
- Never hard-code date ranges in queries — use parameterized dates or relative ranges
- Always validate row counts after joins — watch for fan-out (unexpected row multiplication)
- Never commit database credentials, connection strings, or API keys to git

## Analogy Map

| # | Pattern | Business Analytics Analogy |
|---|---------|--------------------------|
| 1 | context_before_action | "Checking the latest dashboard numbers before starting a new analysis — know what the current state of the business is" |
| 2 | scope_before_work | "Writing the analysis brief before opening the SQL editor — define the question, audience, and deliverable upfront" |
| 3 | save_points | "Saving a version of the spreadsheet before making changes — so you can always go back to the version that was shared with the VP" |
| 4 | safe_experimentation | "Making a copy of the report before trying a new approach — if the new version doesn't work, the original is untouched" |
| 5 | one_change_one_test | "Updating one formula in the spreadsheet and checking the totals before moving to the next — catch errors immediately" |
| 6 | automated_recovery | "Scheduling a report to regenerate automatically if it fails — the 8am email goes out regardless" |
| 7 | provenance | "Linking every number in the board deck to its source query — so when the CFO asks 'where did this come from?', you have the answer" |
| 8 | self_improvement | "Updating the team's SQL style guide after finding a better pattern — the whole team benefits from one person's discovery" |

## Discovery Triggers
- `.sql` files detected → activate SQL-specific patterns (parameterized dates, join validation)
- `dbt_project.yml` detected → activate dbt workflow (model tests, documentation, staging/marts)
- `.xlsx` or `.csv` files in git repo → warn about committing data files, suggest .gitignore
- `dashboards/` or `reports/` directory → suggest report versioning and provenance
- Database connection strings in code → flag as security risk, suggest environment variables

## Starter Artifacts
- `sql/` — SQL queries organized by domain or metric
- `reports/` — output reports and analysis deliverables
- `data/` — local data files (with .gitignore for large/sensitive files)
- `docs/` — metric definitions, data dictionaries, analysis briefs

## Recommended Tools
- **SQL linter**: sqlfluff
- **Python formatter**: ruff
- **General formatter**: prettier (for JSON, YAML, Markdown)
- **Data transformation**: dbt (if applicable)
- **Test runner**: pytest for data validation tests
- **Superpowers skills**: superpowers:brainstorming, superpowers:systematic-debugging

## Work Product Templates

| Level | What Claude writes | Example |
|-------|-------------------|---------|
| 1 (Beginner) | Single SQL file with comments explaining each clause | `revenue_by_region.sql` with comments on every JOIN and WHERE |
| 2 (Intermediate) | Parameterized queries with documentation header | Query with `@start_date` parameters and a header block documenting metric definition |
| 3 (Advanced) | dbt models with tests and documentation | `models/marts/finance/revenue_by_region.sql` with schema.yml tests |
| 4 (Expert) | Full data pipeline with CI, monitoring, and alerting | dbt project with CI checks, freshness tests, and Slack alerts on failure |

**Standard output format**: Metric definition document:
```markdown
## Monthly Recurring Revenue (MRR)
- **Formula**: SUM(subscription_amount) WHERE status = 'active' AND billing_cycle = 'monthly'
- **Source table**: dp_finance.subscriptions
- **Granularity**: monthly, by product_line
- **Owner**: Finance Analytics
- **Caveats**: Excludes free trials. Annual subscriptions are divided by 12.
- **Last validated**: 2026-03-25 against QuickBooks GL
```

## Error Context

| Error symptom | Likely cause | Suggested fix |
|--------------|-------------|---------------|
| "Numbers don't match the dashboard" | Different date ranges, filters, or join conditions | Compare exact SQL, check timezone handling, verify filter logic |
| "Query is too slow" | Missing indexes, unnecessary subqueries, fan-out joins | Check EXPLAIN plan, look for sequential scans, validate join cardinality |
| "Data looks wrong after ETL" | Schema change upstream, null handling difference, timezone shift | Validate row counts pre/post, check for new NULL patterns, compare schemas |
| "Stakeholder questions the methodology" | Insufficient documentation of assumptions | Trace every number back to source query, document all filters and exclusions |
| "Report shows different numbers than last month" | Metric definition changed, backfill applied, or data correction | Check data warehouse changelog, compare query versions, look for retroactive updates |
