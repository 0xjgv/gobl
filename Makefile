# Use bash for shell commands (required for 'source' builtin)
SHELL := /bin/bash

# Silent helper (set VERBOSE=1 for full output)
SILENT_HELPER := source .claude/scripts/run_silent.sh

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "Available commands:\n"} /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf "\n  Set VERBOSE=1 for full command output (e.g., make test VERBOSE=1)\n"

##@ Development

.PHONY: build
build: ## Build the gobl CLI binary (via mage)
	@$(SILENT_HELPER) && run_silent "Build CLI" "mage build"

.PHONY: install
install: ## Install gobl binary to GOPATH/bin (via mage)
	@$(SILENT_HELPER) && run_silent "Install CLI" "mage install"

.PHONY: generate
generate: ## Run all code generation (schemas, regimes, addons, catalogues, currencies)
	@$(SILENT_HELPER) && run_silent "Generate" "go generate ."

##@ Code Quality

.PHONY: lint
lint: ## Run golangci-lint
	@$(SILENT_HELPER) && ensure_golangci_lint && run_silent "Lint" "golangci-lint run"

.PHONY: fix
fix: ## Run golangci-lint with --fix
	@$(SILENT_HELPER) && ensure_golangci_lint && run_silent "Lint fix" "golangci-lint run --fix"

.PHONY: check
check: ## Run lint, test, and verify generated files are up to date
	@$(SILENT_HELPER) && print_main_header "Running Full Check"
	@$(MAKE) lint
	@$(MAKE) generate
	@$(MAKE) test
	@$(SILENT_HELPER) && \
		if git diff --quiet data/; then \
			printf "  $${GREEN}✓$${NC} Generated files up to date\n"; \
		else \
			printf "  $${RED}✗$${NC} Generated files out of date — run 'make generate' and commit\n"; \
			exit 1; \
		fi

##@ Testing

.PHONY: test
test: ## Run all tests
	@$(SILENT_HELPER) && run_silent_with_test_count "Run tests" "go test -json ./..."

.PHONY: test-race
test-race: ## Run all tests with race detector
	@$(SILENT_HELPER) && run_silent_with_test_count "Run tests (race)" "go test -race -json ./..."

.PHONY: test-cover
test-cover: ## Run tests with coverage report
	@$(SILENT_HELPER) && run_silent_with_test_count "Run tests (coverage)" "go test -json -coverprofile=coverage.out ./..." && \
		go tool cover -func=coverage.out | tail -1

.PHONY: test-examples
test-examples: ## Update example JSON snapshots
	@$(SILENT_HELPER) && run_silent "Update examples" "go test -run TestConvertExamplesToJSON -update"

##@ Pre-commit

.PHONY: pre-commit
pre-commit: ## Run lint + test (for git hook)
	@$(SILENT_HELPER) && print_main_header "Running Pre-commit Checks"
	@$(MAKE) lint
	@$(MAKE) test

##@ Setup

.PHONY: hooks
hooks: ## Install git pre-commit hook
	@printf '#!/bin/sh\nmake pre-commit\n' > .git/hooks/pre-commit && \
		chmod +x .git/hooks/pre-commit && \
		echo "✓ Installed pre-commit hook"
