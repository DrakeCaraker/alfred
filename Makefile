.PHONY: setup test lint validate fix check

## setup: Activate git hooks and verify prerequisites
setup:
	@git config core.hooksPath .githooks
	@echo "✓ Git hooks activated (.githooks)"
	@command -v python3 >/dev/null 2>&1 && echo "✓ Python 3 found" || echo "✗ Python 3 not found — needed for hooks"
	@command -v claude >/dev/null 2>&1 && echo "✓ Claude Code found" || echo "✗ Claude Code not found — install from https://docs.anthropic.com/en/docs/claude-code"
	@echo ""
	@echo "Ready. Run 'claude' then '/bootstrap' to get started."

## test: Run the smoke test suite (structural validation)
test:
	@bash scripts/smoke-test.sh

## lint: Run shellcheck on all shell scripts
lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Running shellcheck..."; \
		shellcheck -S warning .claude/hooks/*.sh .githooks/pre-push .githooks/pre-commit scripts/smoke-test.sh scripts/aggregate-pilot.sh scripts/pii-scanner.sh scripts/validate.sh scripts/collective-sync.sh 2>&1; \
		echo "shellcheck: passed"; \
	else \
		echo "shellcheck not installed — install with: brew install shellcheck (macOS) or apt-get install shellcheck (Linux)"; \
		exit 1; \
	fi

## validate: Run all CI-equivalent structural checks (JSON, YAML, conflict markers, sync, shell syntax)
validate:
	@bash scripts/validate.sh

## fix: Auto-fix deterministic issues (sync commands, permissions)
fix:
	@for f in .claude/commands/*.md; do \
		base=$$(basename "$$f"); \
		if [ -f "commands/$$base" ]; then \
			cp "$$f" "commands/$$base"; \
		fi; \
	done
	@chmod +x .claude/hooks/*.sh .githooks/pre-push .githooks/pre-commit scripts/*.sh 2>/dev/null || true
	@echo "Fixed: command sync + permissions"

## check: Run all validations (validate + lint + test)
check: validate lint test
	@echo ""
	@echo "All checks passed."
