# /safe-refactor — Test-Gated Refactoring with Automatic Rollback

Enables test-driven refactoring with automatic rollback on test failure. Each change is isolated, tested, and committed atomically. If tests fail, the change is rolled back and an alternative approach is attempted.

## Usage

```
/safe-refactor <target>
```

**target**: module path, file path, or description

**Examples**:
- `/safe-refactor src/utils/helpers.py`
- `/safe-refactor checkpoint system`
- `/safe-refactor api.py`

## Implementation

Safe refactoring follows three phases: **Characterize**, **Refactor**, and **Cleanup**. Each phase has explicit stopping conditions and rollback procedures.

---

## Phase 1: Characterize (Read-Only — No Source Changes)

Characterization captures the **current behavior** of the target before any refactoring begins. This creates a regression tripwire: if a refactoring change breaks existing behavior, tests will fail immediately and trigger automatic rollback.

### 1A. Create a new branch

```bash
git checkout -b refactor/<target-name-slugified>
```

**Slugify the target**: lowercase, spaces → hyphens, slashes → hyphens.

Examples:
- `src/utils/helpers.py` → `refactor/src-utils-helpers`
- `auth module` → `refactor/auth-module`
- `api.py` → `refactor/api`

### 1B. Read the target thoroughly

Read every file in scope. List all public functions/classes (anything not starting with `_`).

Identify:
- Public API surface (functions, classes, constants)
- Key behaviors and edge cases
- Current data flows and dependencies

### 1C. Write characterization tests

**File**: `tests/test_<target_slug>_characterization.py`

These tests capture **CURRENT behavior — not correctness**. They are regression tripwires, not correctness checks. If the code currently has bugs, the tests will reflect those bugs.

**Pattern**:

```python
"""Characterization tests for <target> — temporary scaffolding, deleted after refactoring."""
import pytest

def test_<function>_current_behavior():
    """Capture current behavior of <function>."""
    from <module> import <function>
    result = <function>(<representative_input>)
    assert result == <actual_current_output>  # captured from running the function

def test_<function>_edge_case():
    """Capture edge case behavior."""
    from <module> import <function>
    result = <function>(<edge_case_input>)
    assert result == <actual_current_output>
```

**For common output types**:

- NumPy arrays: `np.testing.assert_array_almost_equal(result, expected)`
- Dicts of arrays: assert on keys and individual array values
- Model/complex objects: assert on key attributes (`result.some_attr == expected_attr`)
- Float values: `pytest.approx(result) == expected_float`

**To get actual current outputs**, run:

```bash
python3 -c "from <module> import <function>; import json; print(json.dumps(<function>(<input>), default=str))"
```

**Coverage**: Every public function/class, happy path + at least one edge case each.

### 1D. Run characterization tests — ALL must pass

```bash
pytest tests/test_<target_slug>_characterization.py -v
```

**STOP condition**: If any test fails before any refactoring:

```
This characterization test failed on the baseline (before any refactoring).
Fix the test to match the actual current output, NOT the code.
Actual output: [show output]
Expected output in test: [show expectation]
```

Repeat: adjust expected values in tests until all pass. Do not modify source code.

### 1E. Commit characterization tests

```bash
git add tests/test_<target_slug>_characterization.py
git commit -m "test: add characterization tests for <target> refactor"
```

---

## Phase 2: Refactor (One Change at a Time)

**Before starting any changes, write out your complete planned change list as a numbered list.** Example:

1. Rename variable `_rp_mod` → `_runner_module` in `run.py`
2. Extract `_validate_budget()` helper into its own function
3. Add type hints to public API functions

Only start step 2A after this list is written. Work through the list in order. Phase 2 is complete when all items are checked off.

---

For **EACH planned change**, repeat this cycle exactly:

### 2A. State the change

One sentence describing exactly what you are changing.

Example: "Extract `_validate_threshold()` into a separate utility function in `utils/validation.py`."

### 2B. Apply the change to ONE file only

Make exactly one logical change. If your plan involves multiple files or multiple changes, apply them sequentially in separate iterations, not all at once.

**Exception**: If the change logically requires creating one new file (e.g., extracting a function into a new helper file), that counts as one logical change affecting two files. Treat both files atomically — rollback both on failure. Do NOT split into two separate commits.

### 2C. Run characterization tests

```bash
pytest tests/test_<target_slug>_characterization.py -v
```

### 2D. Commit or Rollback

**If tests pass**:

```bash
git add <modified_file>
git commit -m "refactor: <one-sentence description>"
```

Continue to the next planned change.

**If tests fail**:

Rollback immediately. The change broke existing behavior.

**Rollback for a modified file**:

```bash
git checkout -- <file>
```

**Rollback for a newly created file**:

- If the new file was staged: `git rm --cached <file> && rm <file>`
- If the new file was NOT yet staged: `rm <file>`

After rollback, explain what broke:

```
Rollback: [file] — [error message].
Reason: [explain why the change broke tests].
Alternative: [try a different approach, or ask for human decision].
```

Then try an alternative approach if one exists.

**STOP condition**: If the same change fails twice with the same error:

```
This change conflicts with existing behavior in a way I cannot resolve without changing the public interface.
Conflict: [describe the underlying issue].
Human decision needed: [describe what would be required to proceed — API change, external dependency, etc.].
```

---

## Phase 3: Cleanup

### 3A. Run the full fast suite

Run the project's fast test command (detect from Makefile, package.json, etc.).

All tests must pass. If any fail, stop and investigate before proceeding.

**If any tests fail**: Characterization tests are still present at this point — re-run them first (`pytest tests/test_<target_slug>_characterization.py -v`) to confirm they still pass. If they fail, the regression was introduced during refactoring. Use `git log --oneline` to identify which commit introduced it, then `git revert <sha>` to undo that specific change. Do NOT delete characterization tests until the full fast suite passes.

### 3B. Delete characterization tests

```bash
git rm tests/test_<target_slug>_characterization.py
git commit -m "chore: remove characterization tests for <target> (refactor complete)"
```

### 3C. Report

```
Safe refactor complete on branch refactor/<target>.
N changes applied, M rollbacks.
```

Then offer to push and open a PR.

---

## Hard Rules

These rules are non-negotiable. Violating any of them invalidates the refactoring.

1. **NEVER make two changes in one step** — one change, run tests, commit or rollback. Always test between changes.

2. **NEVER modify characterization tests to make them pass** — if tests fail after your change, rollback the change instead. Tests capture current behavior; the code is what changes, not the tests.

3. **NEVER use `git reset --hard`** — use `git checkout -- <file>` for modified files. For new files: if staged use `git rm --cached <file> && rm <file>`, if untracked use `rm <file>`. Hard reset loses history and is harder to diagnose.

4. **NEVER change a public API signature without explicit user approval** — if a refactoring requires renaming a public function, changing parameters, or altering return types, STOP and ask first. Example: "Refactoring requires renaming `fit()` to `fit_model()`. Approve? Y/N"

5. **STOP and explain if**:
   - The same change fails twice with the same error, OR
   - Characterization tests fail on the baseline before any refactoring

---

## Example Walkthrough

### Scenario: Refactor `src/utils/helpers.py`

**1A. Create branch**:
```bash
git checkout -b refactor/src-utils-helpers
```

**1B. Read target**: Identify all public functions in `helpers.py`.

**1C. Write characterization tests**:

```python
# tests/test_src_utils_helpers_characterization.py
def test_parse_config_current():
    from src.utils.helpers import parse_config
    result = parse_config({"key": "value", "count": 42})
    assert result["key"] == "value"
    assert result["count"] == 42

def test_parse_config_empty_input():
    from src.utils.helpers import parse_config
    result = parse_config({})
    assert result == {}

def test_validate_input_current():
    from src.utils.helpers import validate_input
    result = validate_input([1, 2, 3])
    assert result is True

def test_validate_input_empty():
    from src.utils.helpers import validate_input
    result = validate_input([])
    assert result is False
```

**1D. Run tests**: All must pass.

**1E. Commit**:
```bash
git add tests/test_src_utils_helpers_characterization.py
git commit -m "test: add characterization tests for helpers.py refactor"
```

**2A. Plan changes**:
1. Extract validation logic into a separate `validate_input()` function
2. Add type hints to public functions
3. Consolidate similar utility functions

**2B–2D. Refactor cycle 1**:

*2A*: "Extract inline validation check into public `validate_input()` function"

*2B*: Create new function, update one caller

*2C*: Run tests
```bash
pytest tests/test_src_utils_helpers_characterization.py -v
```

*2D*: Tests pass → commit
```bash
git add src/utils/helpers.py
git commit -m "refactor: extract input validation into validate_input()"
```

**2B–2D. Refactor cycle 2**:

*2A*: "Add type hints to `parse_config()` signature"

*2B*: Update function signature with `from typing import` imports and type annotations

*2C*: Run tests → tests pass → commit

**Repeat for each planned change.**

**3A. Run full suite**: Run the project's fast test command (detect from Makefile, package.json, etc.).

**3B. Delete characterization tests**:
```bash
git rm tests/test_src_utils_helpers_characterization.py
git commit -m "chore: remove characterization tests for helpers.py (refactor complete)"
```

**3C. Report**:
```
Safe refactor complete on branch refactor/src-utils-helpers.
3 changes applied, 0 rollbacks.

Ready to push and open PR.
```

---

## When to Use This Skill

- Extracting functions or classes
- Renaming internal functions (no public API change)
- Adding type hints
- Reorganizing module structure
- Consolidating duplicated logic
- Improving performance without changing behavior
- Simplifying complex functions while preserving behavior

## When NOT to Use This Skill

- Changing public API signatures (requires explicit approval first)
- Adding new features (use standard PR workflow)
- Fixing bugs (handle separately; characterization tests may capture buggy behavior)
- Large multi-module refactors (break into smaller targets)

---

## Troubleshooting

**Q: A characterization test fails on the baseline (before any refactoring). What do I do?**

A: The test's expected value is wrong. Run the function manually with the input to get the actual current output, then update the test. Do not modify the source code.

**Q: Tests pass but I'm not sure the refactoring is complete. Can I keep the characterization tests?**

A: No. Characterization tests are temporary scaffolding. Delete them after Phase 3. If you want permanent regression tests, write them as part of the main test suite (not characterization tests).

**Q: A change failed twice for the same reason. What now?**

A: STOP. Explain the conflict and ask for a human decision. The conflict may require an API change or external input.

**Q: Can I make multiple changes in one commit?**

A: No. One change = test = commit (or rollback). This enforces atomicity and makes bisecting easier if something breaks later.
