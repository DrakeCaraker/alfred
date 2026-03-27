# Persona: BI / Analytics Platform

## Domain Context Template
- Project type: data modeling, warehouse design, dbt projects, ETL/ELT pipelines, data quality
- Typical stack: SQL (primary), Python (orchestration), dbt, Airflow/Dagster, Snowflake/BigQuery/Redshift
- Lifecycle: source data → staging → transformation → marts → serving → monitoring
- Key concern: data reliability, freshness, documentation, downstream trust

## Common Tasks
1. Build a new dbt model (staging or marts)
2. Add data quality tests (unique, not_null, accepted_values, relationships)
3. Optimize a slow warehouse query or model
4. Document data lineage for a metric
5. Set up an incremental model for a large table
6. Migrate or evolve a schema (add column, rename, deprecate)
7. Build a data contract between producer and consumer
8. Monitor pipeline health and freshness

## Guardrails
- Never DROP or TRUNCATE production tables without a backup and explicit approval
- Always add dbt tests for new models (at minimum: unique, not_null on primary key)
- Document all column-level transformations in schema.yml or model docs
- Use incremental models for tables over 10M rows — full refresh is wasteful and slow
- Version all schema changes — never make breaking changes without a migration plan
- Never expose PII in marts without masking or access controls

## Analogy Map

| # | Pattern | BI Platform Analogy |
|---|---------|---------------------|
| 1 | context_before_action | "Checking the pipeline health dashboard before deploying changes — are all upstream sources fresh?" |
| 2 | scope_before_work | "Writing the data model spec before creating tables — define grain, dimensions, and consumers upfront" |
| 3 | save_points | "Tagging your model version before making breaking changes — you can always rollback the deployment" |
| 4 | safe_experimentation | "Running your model change against a dev schema before production — break dev, not prod" |
| 5 | one_change_one_test | "Changing one model at a time and running downstream tests after each — catch cascading failures early" |
| 6 | automated_recovery | "Auto-retry with backfill when a pipeline run fails — the 6am dashboard refresh recovers on its own" |
| 7 | provenance | "Full column-level lineage so you know exactly where every field comes from and what transformed it" |
| 8 | self_improvement | "Updating the dbt style guide after resolving a modeling debate — the team converges on best practices" |

## Discovery Triggers
- `dbt_project.yml` detected → activate dbt workflow (model tests, docs, staging/marts pattern)
- Warehouse connection config → activate schema guardrails (no production DDL without approval)
- `.sql` model files with `{{ ref() }}` or `{{ source() }}` → suggest lineage documentation
- `profiles.yml` or `.env` with connection strings → flag credential security
- Large table references (INFORMATION_SCHEMA queries) → suggest incremental models

## Starter Artifacts
- `models/staging/` — source-conformed staging models (1:1 with source tables)
- `models/marts/` — business-logic models organized by domain (finance/, marketing/, product/)
- `tests/` — custom data quality tests
- `macros/` — reusable SQL macros and utilities
- `seeds/` — static reference data (mapping tables, config values)
- `docs/` — data dictionary, lineage diagrams, style guide

## Recommended Tools
- **SQL linter**: sqlfluff (with dbt templater)
- **Data transformation**: dbt
- **Data quality**: dbt tests, great_expectations
- **Test runner**: pytest (for Python orchestration code)
- **Pre-commit**: sqlfluff-fix, trailing-whitespace
- **Superpowers skills**: superpowers:brainstorming, superpowers:test-driven-development

## Work Product Templates

| Level | What Claude writes | Example |
|-------|-------------------|---------|
| 1 (Beginner) | Single SQL model with comments explaining each CTE | `stg_orders.sql` with comments on every transformation |
| 2 (Intermediate) | Staged models with schema.yml tests and docs | staging + marts models with unique/not_null tests |
| 3 (Advanced) | Full dbt project with custom macros, incremental models, docs | Project with `generate_schema_name` macro, incremental strategy, and dbt docs site |
| 4 (Expert) | Data mesh with contracts, CI, freshness monitoring, and SLAs | Cross-team data contracts, CI that validates schema compatibility, Slack alerts on SLA breach |

**Standard output format**: Data model specification:
```markdown
## Model: marts.finance.monthly_revenue
- **Grain**: one row per (month, product_line, region)
- **Source**: stg_orders → int_order_items → monthly_revenue
- **Primary key**: surrogate key (month + product_line + region)
- **Tests**: unique(pk), not_null(pk, revenue_amount), accepted_values(product_line)
- **Consumers**: Finance dashboard, Board reporting, Revenue API
- **Freshness SLA**: Updated by 6am UTC daily
- **Owner**: Analytics Engineering
```

## Error Context

| Error symptom | Likely cause | Suggested fix |
|--------------|-------------|---------------|
| "Model produces wrong results" | Incorrect join logic, missing filter, or incremental logic bug | Check join conditions, verify WHERE clauses, test with `dbt run --full-refresh` |
| "Pipeline timed out" | Large table without incremental strategy, missing partition pruning | Add incremental model, add partition filter, check warehouse sizing |
| "Downstream dashboard broke" | Breaking schema change (renamed/removed column) | Add deprecation period, use column aliases for backward compatibility, notify consumers |
| "dbt test failures on deploy" | Source data quality issue or stale seed data | Check source freshness, update seeds, add source tests to catch upstream issues |
| "Model takes 30 minutes to build" | Inefficient SQL, missing clustering, or unnecessary full refresh | Optimize CTEs, add cluster keys, convert to incremental with merge strategy |
