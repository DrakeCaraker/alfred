# Persona: Research Scientist

## Domain Context Template
- Project type: academic research, statistical analysis, paper writing
- Typical stack: Python/R, LaTeX, Jupyter/RMarkdown, statistical packages (scipy, statsmodels, lme4)
- Lifecycle: literature review → hypothesis → data collection → analysis → writing → submission → revision
- Key concern: rigor, reproducibility, citation accuracy, IRB compliance

## Common Tasks
1. Run a statistical analysis (t-test, regression, ANOVA)
2. Generate a publication-quality figure
3. Write or edit a paper section (intro, methods, results, discussion)
4. Respond to reviewer comments with evidence
5. Check analysis reproducibility end-to-end
6. Add a new dataset to the study
7. Update literature review with recent papers
8. Prepare supplementary materials

## Guardrails
- Never modify raw data files — always work on processed copies in a separate directory
- Always report statistical significance tests with effect sizes and confidence intervals
- Document the complete analysis pipeline from raw data to final figure
- Use relative paths only — never hardcode absolute paths (breaks reproducibility)
- Version paper drafts explicitly (v1, v2, v3) — never overwrite previous versions
- Never commit participant-identifiable data (PII, PHI) to git

## Analogy Map

| # | Pattern | Research Analogy |
|---|---------|-----------------|
| 1 | context_before_action | "Reading your lab notebook before starting today's experiment — know what was done yesterday and what's pending" |
| 2 | scope_before_work | "Writing the methods section before running the experiment — define your protocol so you don't drift" |
| 3 | save_points | "Signing and dating a lab notebook page — creating an immutable record that can't be altered after the fact" |
| 4 | safe_experimentation | "Running a pilot study before committing to the full experiment — test your procedure without wasting resources" |
| 5 | one_change_one_test | "Changing one variable at a time — the fundamental principle of experimental design that isolates cause and effect" |
| 6 | automated_recovery | "Having a lab protocol so any team member can restart the procedure from any step if something goes wrong" |
| 7 | provenance | "Citing your sources — every claim in your paper traces back to data, and every figure traces back to a script" |
| 8 | self_improvement | "Updating the lab protocol after discovering a better technique — the lab gets better with every project" |

## Discovery Triggers
- `.tex` files detected → activate LaTeX guardrails (compile checks, BibTeX validation)
- `paper/` or `manuscript/` directory → suggest paper workflow (draft versioning, figure management)
- `.bib` files detected → suggest citation management patterns
- `data/raw/` directory exists → activate raw data protection (never modify originals)
- `.R` or `.Rmd` files → suggest R-specific tools (styler, testthat, renv)

## Starter Artifacts
- `data/raw/` — original, unmodified data files (read-only by convention)
- `data/processed/` — cleaned, transformed data ready for analysis
- `analysis/` — analysis scripts (numbered: 01_clean.py, 02_analyze.py, 03_visualize.py)
- `paper/` — manuscript source (LaTeX or Markdown)
- `figures/` — publication-quality figures with provenance
- `results/` — analysis outputs (tables, statistics, intermediate results)

## Recommended Tools
- **Python formatter**: ruff or black
- **R formatter**: styler
- **Document tools**: LaTeX + BibTeX, pandoc
- **Test runner**: pytest (Python) or testthat (R)
- **Superpowers skills**: superpowers:brainstorming, superpowers:systematic-debugging

## Work Product Templates

| Level | What Claude writes | Example |
|-------|-------------------|---------|
| 1 (Beginner) | Analysis script with heavy comments explaining each statistical test | `analysis.py` with inline comments explaining what a t-test is |
| 2 (Intermediate) | Parameterized analysis functions with docstrings | `run_analysis(data_path, alpha=0.05, method="holm")` |
| 3 (Advanced) | Reproducible pipeline with Makefile (data → analysis → figures → paper) | `make figures` rebuilds all figures from raw data |
| 4 (Expert) | Package with tests, CI, and automated reproducibility checks | Full pipeline that runs on any machine with `make all` |

**Standard output format**: Figure with provenance caption:
```
Figure 3: Mean response time by condition (N=120).
  Source: analysis/03_visualize.py
  Data: data/processed/experiment_1_clean.csv
  Generated: 2026-03-25 | Git SHA: abc1234
```

## Error Context

| Error symptom | Likely cause | Suggested fix |
|--------------|-------------|---------------|
| "Analysis results changed between runs" | Different data version, unseeded randomness, package update | Pin package versions (renv/pip freeze), set random seeds, version data files |
| "LaTeX won't compile" | Missing references, unmatched braces, missing packages | Run `chktex`, check for undefined `\ref{}` or `\cite{}`, verify `\usepackage` |
| "Reviewer says results aren't reproducible" | Incomplete pipeline documentation | Provide full pipeline from raw data to figures with `make all` or equivalent |
| "Figure looks different on different machines" | Backend/font differences in matplotlib/ggplot | Specify backend explicitly, embed fonts in PDF, pin plotting library version |
| "Statistical test gives unexpected p-value" | Wrong test for data distribution, violated assumptions | Check normality, consider non-parametric alternatives, verify sample sizes |

## 10. Prompting Guide

Effective prompting patterns for academic research:

- **Specify the statistical test and significance level upfront.** "Run a two-tailed t-test at α=0.05 with Bonferroni correction" gets precise results.
- **State the research question, not the implementation.** "Is there a significant difference between groups A and B on measure X?" is better than "run a t-test on columns 3 and 4."
- **Ask for effect sizes and confidence intervals.** "Always report Cohen's d and 95% CI alongside p-values" should be standard.
- **Request methodology review.** "Vet this analysis plan — what threats to validity am I missing?" catches design flaws early.
- **Demand provenance.** "Show me the complete pipeline from raw data to this figure" ensures reproducibility.
- **Challenge interpretations.** "What alternative explanations exist for this result?" prevents confirmation bias.
