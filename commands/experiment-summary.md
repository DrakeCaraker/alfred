# Experiment / Results Summary

Inventory all result artifacts and format into a summary with full provenance.

## Step 1: Determine scope

Ask the user which results to summarize, or scan automatically:
- "Which results should I summarize?" (If user specifies, use those)
- If no specification: scan `results/`, `output/`, `data/`, and project root for result artifacts

## Step 2: Inventory artifacts

Scan for result files and report what exists:

### Data files
List all JSON, CSV, and Parquet files in result directories with modification dates and sizes.

### Figures
List all image files (.png, .pdf, .svg) in result directories and `figures/` with sizes.

### Other artifacts
List any other output files (HTML reports, markdown summaries, checkpoint files).

Flag any artifacts that appear orphaned (data without corresponding figure, or vice versa).

## Step 3: Read and format results

For each result file:
1. Read the file and extract key metrics or findings
2. Format as a markdown table with clear column headers
3. If the file contains statistical results, include significance levels and effect sizes
4. Optionally produce LaTeX `\begin{tabular}` format if requested

## Step 4: Figure summary

Group figures by analysis/experiment:

| Analysis | Data File | Figure | Last Modified |
|----------|-----------|--------|---------------|
| ... | ... | ... | ... |

Flag any analysis that has data but no figure (incomplete visualization) or a figure but no data (orphaned figure).

## Step 5: Regression check

If CLAUDE.md has a "Key Results" section with reference values:
- Compare current result values against the reference
- Flag any metric that decreased by more than 0.5% from reference
- Note any new metrics not in the reference (may need to update CLAUDE.md)

If no reference values exist, skip this step and suggest adding a "Key Results" section to CLAUDE.md.

## Step 6: Provenance

Label every table and figure entry with:
- **Source**: file path the data came from
- **Modified**: file modification timestamp
- **Config**: any configuration values used (read from the file or from project config)
- **Git state**: current branch and last commit SHA

## Rules
- Never modify result files — only read and report
- If a result file cannot be parsed, report the error and continue with other files
- Always include provenance (Step 6) — results without provenance are untrustworthy
- If results look suspicious (e.g., all zeros, identical values), flag for human review
