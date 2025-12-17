#!/bin/bash
# Hook: pre-commit-verification
# Event: PreToolUse (Bash)
# Purpose: Ensure tests and linting pass before git commits

set -e

INPUT=$(cat)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process Bash tool with git commit commands
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# Check if this is a git commit command
if ! echo "$COMMAND" | grep -qE '\bgit\s+commit\b'; then
    exit 0
fi

# Check for state file indicating verification already completed
STATE_DIR="$PROJECT_DIR/.claude/hooks/.state"
mkdir -p "$STATE_DIR"
VERIFICATION_FILE="$STATE_DIR/commit-verified"

# If verification was completed recently (within last 5 minutes), allow commit
if [ -f "$VERIFICATION_FILE" ]; then
    VERIFIED_TIME=$(cat "$VERIFICATION_FILE" 2>/dev/null || echo 0)
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - VERIFIED_TIME))

    if [ "$TIME_DIFF" -lt 300 ]; then
        # Verification is recent, allow commit
        exit 0
    fi
fi

# Detect project type and available tools
VERIFICATION_COMMANDS=""
DETECTED_TOOLS=""

# TypeScript/JavaScript (pnpm preferred per tech strategy)
if [ -f "$PROJECT_DIR/package.json" ]; then
    if [ -f "$PROJECT_DIR/pnpm-lock.yaml" ]; then
        PKG_MGR="pnpm"
    elif [ -f "$PROJECT_DIR/package-lock.json" ]; then
        PKG_MGR="npm"
    else
        PKG_MGR="pnpm"
    fi

    # Check for scripts in package.json
    if grep -q '"lint"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        DETECTED_TOOLS="$DETECTED_TOOLS lint($PKG_MGR)"
    fi
    if grep -q '"test"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        DETECTED_TOOLS="$DETECTED_TOOLS test($PKG_MGR)"
    fi
    if grep -q '"typecheck\|"tsc\|"type-check"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        DETECTED_TOOLS="$DETECTED_TOOLS typecheck($PKG_MGR)"
    fi

    # Biome (preferred per tech strategy)
    if [ -f "$PROJECT_DIR/biome.json" ] || [ -f "$PROJECT_DIR/biome.jsonc" ]; then
        DETECTED_TOOLS="$DETECTED_TOOLS biome"
    fi
fi

# Python (uv preferred per tech strategy)
if [ -f "$PROJECT_DIR/pyproject.toml" ]; then
    if command -v uv &> /dev/null; then
        PY_MGR="uv run"
    else
        PY_MGR="python -m"
    fi

    # Ruff (preferred per tech strategy)
    if grep -q "ruff" "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
        DETECTED_TOOLS="$DETECTED_TOOLS ruff"
    fi

    # pytest
    if grep -q "pytest" "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
        DETECTED_TOOLS="$DETECTED_TOOLS pytest"
    fi

    # mypy
    if grep -q "mypy" "$PROJECT_DIR/pyproject.toml" 2>/dev/null; then
        DETECTED_TOOLS="$DETECTED_TOOLS mypy"
    fi
fi

# Go
if [ -f "$PROJECT_DIR/go.mod" ]; then
    DETECTED_TOOLS="$DETECTED_TOOLS go-test go-vet"

    # golangci-lint (preferred per tech strategy)
    if command -v golangci-lint &> /dev/null || [ -f "$PROJECT_DIR/.golangci.yml" ]; then
        DETECTED_TOOLS="$DETECTED_TOOLS golangci-lint"
    fi
fi

# Rust
if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
    DETECTED_TOOLS="$DETECTED_TOOLS cargo-test cargo-clippy cargo-fmt"
fi

# Build verification context message
cat << EOF
{
  "hookSpecificOutput": {
    "additionalContext": "
---
[PRE-COMMIT VERIFICATION REQUIRED]

Before committing, you MUST complete these steps:

1. RUN ALL TESTS AND LINTING:
   - Run the project's test suite and ensure all tests pass
   - Run linting/formatting checks and fix any issues
   - Run type checking if available

   Detected tools in this project: ${DETECTED_TOOLS:-none detected - check manually}

2. FIX ALL FAILURES:
   - If tests fail, fix the code until they pass
   - If linting fails, fix the issues
   - Do NOT skip or disable failing checks

3. CRITICAL: NEVER REMOVE OR SKIP TESTS
   - Do NOT delete test files or test cases to make tests pass
   - Do NOT comment out failing tests
   - Do NOT add skip decorators to avoid failures
   - Fix the actual code issues instead

4. AFTER VERIFICATION SUCCEEDS:
   - Mark verification complete: echo \$(date +%s) > $STATE_DIR/commit-verified
   - Then proceed with the git commit

If you cannot fix a test legitimately, STOP and ask the user for guidance.
---"
  }
}
EOF
