# Persona: ML / Data Science

## Domain Context Template
[For CLAUDE.md "About" section]
- Project type: model development, feature engineering, experiment pipelines
- Typical stack: Python, pandas, scikit-learn/XGBoost/PyTorch, Jupyter notebooks
- Data lifecycle: raw data → feature engineering → train/val/test split → model training → evaluation → deployment
- Key concern: reproducibility of experiments, model versioning

## Common Tasks
1. Train and evaluate a model
2. Run a hyperparameter sweep
3. Add a new feature to the pipeline
4. Debug a failing experiment
5. Generate experiment results summary
6. Refactor pipeline code
7. Set up CI for model tests
8. Profile and optimize training performance

## Guardrails
- Never commit .pkl, .pt, .h5, .joblib, or checkpoint files to git
- Never clear outputs of canonical/published notebooks — they are empirical records
- Always use a fixed random seed for reproducibility (default: seed=42)
- Always separate code branches from result/data branches
- Never train on test data — enforce 4-way splits (train, val, explain, test)
- Pin dependency versions in requirements.txt or pyproject.toml

## Analogy Map

| # | Pattern | ML/DS Analogy |
|---|---------|---------------|
| 1 | context_before_action | "Reading the experiment log before starting a new run — know what's been tried and what state the codebase is in" |
| 2 | scope_before_work | "Writing the experiment protocol before touching code — define hypothesis, metrics, and stopping criteria upfront" |
| 3 | save_points | "Checkpointing your experiment so you can resume from any epoch — each commit is a checkpoint you can return to" |
| 4 | safe_experimentation | "Hyperparameter sweep in isolation — each config runs in its own sandbox so a bad config doesn't corrupt your baseline" |
| 5 | one_change_one_test | "Ablation study — change one variable, measure the effect, then decide whether to keep it" |
| 6 | automated_recovery | "Auto-restarting a training run from the last checkpoint after a crash — the system recovers without manual intervention" |
| 7 | provenance | "Experiment tracking with MLflow — every result links back to the exact code, config, and data that produced it" |
| 8 | self_improvement | "Updating your experiment template after discovering a better practice — the team learns from each project" |

## Discovery Triggers
- `.ipynb` files detected → suggest notebook management patterns (canonical outputs, size checks)
- ML libraries in dependencies (sklearn, torch, tensorflow, xgboost) → activate ML-specific guardrails
- `checkpoints/` or `models/` directory exists → activate checkpoint guardrails (never commit .pkl)
- `experiments/` or `configs/` directory exists → suggest experiment tracking and provenance
- Large data files in repo → suggest .gitignore additions and data/code branch separation

## Starter Artifacts
Directories created by /bootstrap for this persona:
- `notebooks/` — interactive exploration and experiment notebooks
- `src/` or `<project_name>/` — Python package with pipeline code
- `tests/` — pytest test suite
- `configs/` — experiment configuration files (YAML/JSON)
- `results/` — experiment outputs (JSON tables, figures)

## Recommended Tools
- **Formatter**: ruff (Python)
- **Type checker**: mypy
- **Test runner**: pytest
- **Optional**: DVC (data versioning), MLflow (experiment tracking)
- **Superpowers skills**: superpowers:brainstorming, superpowers:test-driven-development, superpowers:systematic-debugging

## Work Product Templates

| Level | What Claude writes | Example |
|-------|-------------------|---------|
| 1 (Beginner) | Simple scripts with hardcoded values and heavy comments explaining every line | `train.py` with inline comments, hardcoded paths, no functions |
| 2 (Intermediate) | Functions with docstrings, basic parameters, named variables | `train(data_path, n_estimators=100)` with docstrings |
| 3 (Advanced) | Modules, config files, CLI arguments, imports across files | `pipeline/train.py` reading from `configs/experiment.yaml` |
| 4 (Expert) | Packages with tests, CI, type hints, experiment tracking | Full package with `pyproject.toml`, typed API, pytest suite, MLflow integration |

**Standard output format**: Experiment results JSON with `_meta` provenance block:
```json
{
  "experiment": "linear_sweep",
  "results": { ... },
  "_meta": {
    "timestamp": "2026-03-25T14:00:00Z",
    "git_sha": "abc1234",
    "config": { "seed": 42, "n_reps": 50 }
  }
}
```

## Error Context

| Error symptom | Likely cause | Suggested fix |
|--------------|-------------|---------------|
| "Model won't train" or NaN loss | Bad data splits, wrong feature types, missing values | Check dtypes, look for NaN/inf in features, verify train/test split |
| "Results aren't reproducible" | Missing random seed, non-deterministic data ordering, floating point | Set all seeds (numpy, torch, random), sort data before split, pin library versions |
| "Notebook too large to commit" | Embedded outputs (images, dataframes) bloating file | Clear outputs before commit, use checkpoint pattern for large results |
| "Tests pass locally but fail in CI" | Environment mismatch, missing deps, GPU vs CPU | Pin dependency versions, use same Python version, mock GPU-dependent tests |
| "Import error: module not found" | Package not installed or wrong environment | Check virtual env activation, verify `pip install -e .` for local package |

## 10. Prompting Guide

Effective prompting patterns for ML/DS work:

- **State the hypothesis before asking for code.** "I want to test whether feature X improves model accuracy by >2%" gets better results than "add feature X to the model."
- **Specify metrics and thresholds.** "Evaluate with AUC-ROC, target >0.85" gives Claude a concrete success criterion.
- **Ask for deeper analysis.** When results look surprising, say "think about this carefully — what could explain this?" Claude will check for data leakage, distribution shift, and common ML pitfalls.
- **Scope experiments explicitly.** "Change only the learning rate, keep everything else fixed" prevents Claude from making multiple changes that confound results.
- **Request reproducibility.** "Set seed=42 and log all hyperparameters" should be your default ask.
- **Challenge results.** "Vet this — what could be wrong with this analysis?" catches issues before they reach a paper or stakeholder.
