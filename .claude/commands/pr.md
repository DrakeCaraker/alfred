# Create Pull Request

Standardized branch-to-PR workflow. Prevents pushing to main and enforces lint checks.

## Steps

1. **Verify branch safety:**
   ```
   git branch --show-current
   ```
   - If on `main`, **STOP immediately**. Tell the user:
     > You're on main. Create a feature branch first: `git checkout -b feat/<topic>`
   - Do not proceed until on a non-main branch.

2. **Run fast lint checks:**
   Run the project's lint/format/typecheck commands. Detect from Makefile targets, package.json scripts, or pyproject.toml config. Skip any that don't exist for this project.
   - If any check fails, **STOP**. Show the errors and fix them before continuing.
   - Do NOT run tests here — tests run via CI or manual `make test-fast`.

3. **Stage relevant files:**
   - Use `git status` to review changes.
   - Stage files individually by name. **Never use `git add -A` or `git add .`**.
   - Skip binary artifacts (check .gitignore patterns) and files >500KB (warn the user if found).

4. **Commit:**
   - If the user provided a description via `$ARGUMENTS`, use it for the commit message.
   - Otherwise, generate a concise atomic commit message from the diff.
   - One concern per commit. If changes span multiple concerns, create separate commits.

5. **Push:**
   ```
   git push -u origin $(git branch --show-current)
   ```

6. **Create PR:**
   - Use `gh pr create` with a structured body:
     ```
     gh pr create --title "<short title>" --body "$(cat <<'EOF'
     ## Summary
     <1-3 bullet points describing the change>

     ## Test plan
     - [ ] CI passes (lint, typecheck, test)
     - [ ] <additional verification steps>
     EOF
     )"
     ```
   - Base branch should be `main` unless the user specifies otherwise.

7. **Return the PR URL** so the user can review it.
