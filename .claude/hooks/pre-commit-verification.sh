#!/bin/bash
# Hook: pre-commit-verification
# Event: PreToolUse (Bash)
# Purpose: Ensure tests and linting pass before git commits

INPUT=$(cat)

# jq is required to parse tool input; fail open if unavailable (hooks are
# guardrails, not a security boundary)
command -v jq >/dev/null 2>&1 || exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

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
    [[ "$VERIFIED_TIME" =~ ^[0-9]+$ ]] || VERIFIED_TIME=0
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - VERIFIED_TIME))

    if [ "$TIME_DIFF" -lt 300 ]; then
        # Verification is recent, allow commit
        exit 0
    fi
fi

# Detect project type and available gates — detection lives in gate-lib.sh
# (artifacts/plan_framework_hardening.md, unit U5a): one shared function
# emits invocable commands per gate; this hook only needs the human labels
# for its advisory text below, reconstructed here in the same order and
# format ("<label>" tokens space-joined) as before the extraction, so the
# advisory output stays byte-identical.
# shellcheck source=gate-lib.sh
# shellcheck disable=SC1091  # dynamic path (BASH_SOURCE-relative); the
# above source= directive documents it for anyone re-running with `-x`
source "$(dirname "${BASH_SOURCE[0]}")/gate-lib.sh"
gate_lib_detect "$PROJECT_DIR"

DETECTED_TOOLS=""
for _gate_label in "${GATE_LABELS[@]}"; do
    DETECTED_TOOLS="$DETECTED_TOOLS $_gate_label"
done

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
