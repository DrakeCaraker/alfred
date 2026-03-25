# Persona: General Software Development

## Domain Context Template
- Project type: web apps, CLI tools, libraries, APIs, microservices
- Typical stack: varies — JavaScript/TypeScript, Python, Go, Rust, Java, and others
- Lifecycle: requirements → design → implement → test → deploy → maintain
- Key concern: code quality, maintainability, test coverage, deployment reliability

## Common Tasks
1. Implement a new feature
2. Fix a bug (reproduce, diagnose, fix, verify)
3. Refactor a module for clarity or performance
4. Add tests for untested code
5. Update dependencies and resolve breaking changes
6. Set up or improve CI/CD pipeline
7. Write an API endpoint with validation
8. Deploy to staging or production

## Guardrails
- Never commit .env files, credentials, API keys, or secrets to git
- Always run tests before pushing — never push broken code to shared branches
- One concern per PR — don't mix features, fixes, and refactors
- Document breaking changes in commit messages and changelogs
- Pin dependency versions — lock files must be committed
- Never force-push to main/master without team agreement

## Analogy Map

| # | Pattern | Software Development Analogy |
|---|---------|------------------------------|
| 1 | context_before_action | "Running `git status` and checking recent commits before starting work — know the state of the codebase" |
| 2 | scope_before_work | "Creating a ticket or writing a brief task description before writing code — prevents scope creep" |
| 3 | save_points | "Committing your work frequently so you can always get back to a known-good state" |
| 4 | safe_experimentation | "Working on a feature branch so your experiments don't break main for everyone else" |
| 5 | one_change_one_test | "Making one change at a time and running tests between each — bisectable history if something breaks later" |
| 6 | automated_recovery | "Letting CI catch and auto-fix formatting issues — machines handle the mechanical stuff" |
| 7 | provenance | "Every deployed artifact traces back to a specific commit, PR, and code review" |
| 8 | self_improvement | "Turning repeated code review feedback into a linter rule — automate what humans keep catching" |

## Discovery Triggers
- `package.json` detected → activate JavaScript/TypeScript patterns (prettier, eslint, jest)
- `Cargo.toml` detected → activate Rust patterns (cargo clippy, cargo fmt, cargo test)
- `go.mod` detected → activate Go patterns (go vet, gofmt, go test)
- `Dockerfile` detected → activate container guardrails (no secrets in image, multi-stage builds)
- `pyproject.toml` or `setup.py` → activate Python patterns (ruff, mypy, pytest)
- `.github/workflows/` → CI already exists, suggest improvements

## Starter Artifacts
- `src/` — source code (or language-appropriate equivalent)
- `tests/` — test suite
- `docs/` — documentation

## Recommended Tools
- **Formatter**: detected at bootstrap (ruff, prettier, gofmt, rustfmt, etc.)
- **Linter**: detected at bootstrap (ruff, eslint, clippy, go vet, etc.)
- **Test runner**: detected at bootstrap (pytest, jest, cargo test, go test, etc.)
- **Superpowers skills**: superpowers:brainstorming, superpowers:test-driven-development, superpowers:systematic-debugging, superpowers:requesting-code-review

## Work Product Templates

| Level | What Claude writes | Example |
|-------|-------------------|---------|
| 1 (Beginner) | Simple script with comments explaining each step | `server.py` with inline comments, minimal structure |
| 2 (Intermediate) | Functions with documentation, error handling, basic tests | Modular code with docstrings, try/except, and a test file |
| 3 (Advanced) | Modules with tests, type annotations, and configuration | Multi-file project with typed interfaces and pytest/jest suite |
| 4 (Expert) | Package with CI, types, comprehensive tests, and deployment | Full project with CI pipeline, 80%+ coverage, Docker, and deploy scripts |

**Standard output format**: Feature implementation summary:
```markdown
## Feature: User Authentication Endpoint
- **Endpoint**: POST /api/auth/login
- **Input validation**: email format, password min length
- **Error handling**: 401 on bad credentials, 422 on validation failure
- **Tests**: unit tests for validation logic, integration test for full flow
- **Dependencies added**: none (uses existing JWT library)
- **Breaking changes**: none
```

## Error Context

| Error symptom | Likely cause | Suggested fix |
|--------------|-------------|---------------|
| "Tests fail" | Recent code change broke something | Read the error message, check git diff for recent changes, run failing test in isolation |
| "Build fails" | Dependency issue, version mismatch, or missing config | Check lock file, verify Node/Python/Go version, look for missing env vars |
| "Deploy fails" | Config mismatch between local and production | Check environment variables, verify secrets are set, compare local vs deployed config |
| "Import/module not found" | Wrong package version or missing install | Check package.json/requirements.txt, run install, verify virtual env or node_modules |
| "Type errors after upgrade" | Breaking change in dependency | Read changelog for breaking changes, update types, run type checker |
