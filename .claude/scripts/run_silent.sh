#!/bin/bash
set -e  # Exit immediately if any command fails

# Helper functions for running commands with clean output
# Used by Makefile to reduce verbosity while preserving error information

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if verbose mode is enabled
VERBOSE=${VERBOSE:-0}

# Run command silently, show output only on failure
run_silent() {
    local description="$1"
    local command="$2"

    if [ "$VERBOSE" = "1" ]; then
        echo "  → Running: $command"
        eval "$command"
        return $?
    fi

    local tmp_file=$(mktemp)
    if eval "$command" > "$tmp_file" 2>&1; then
        printf "  ${GREEN}✓${NC} %s\n" "$description"
        rm -f "$tmp_file"
        return 0
    else
        local exit_code=$?
        printf "  ${RED}✗${NC} %s\n" "$description"
        printf "${RED}Command failed: %s${NC}\n" "$command"
        cat "$tmp_file"
        rm -f "$tmp_file"
        return $exit_code
    fi
}

# Run go test command and extract test count from -json output
run_silent_with_test_count() {
    local description="$1"
    local command="$2"

    if [ "$VERBOSE" = "1" ]; then
        echo "  → Running: $command"
        eval "$command"
        return $?
    fi

    local tmp_file=$(mktemp)
    if eval "$command" > "$tmp_file" 2>&1; then
        local test_count=$(grep '"Action":"pass"' "$tmp_file" | grep -c '"Test":' 2>/dev/null || true)
        if [ "$test_count" -gt 0 ]; then
            printf "  ${GREEN}✓${NC} %s (%s tests)\n" "$description" "$test_count"
        else
            printf "  ${GREEN}✓${NC} %s\n" "$description"
        fi
        rm -f "$tmp_file"
        return 0
    else
        local exit_code=$?
        printf "  ${RED}✗${NC} %s\n" "$description"
        printf "${RED}Command failed: %s${NC}\n" "$command"
        cat "$tmp_file"
        rm -f "$tmp_file"
        return $exit_code
    fi
}

# Print section header
print_header() {
    local module="$1"
    local description="$2"
    printf "\n${BLUE}[%s]${NC} %s:\n" "$module" "$description"
}

# Print main section header
print_main_header() {
    local title="$1"
    printf "\n=== %s ===\n\n" "$title"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install golangci-lint if needed (used by Go targets)
ensure_golangci_lint() {
    if ! command_exists golangci-lint; then
        echo "  Installing golangci-lint..."
        brew install golangci-lint >/dev/null 2>&1 || {
            echo "  ${RED}Failed to install golangci-lint${NC}"
            return 1
        }
    fi
}

# Removed tracking functionality - doesn't work across sub-makes
