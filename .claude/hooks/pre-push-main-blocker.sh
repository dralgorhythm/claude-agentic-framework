#!/bin/bash
# Hook: pre-push-main-blocker
# Event: PreToolUse (Bash)
# Purpose: Block pushing directly to main branch
#
# Rules:
# - Commits on main: ALLOWED (may commit)
# - Push to non-main branches: ALLOWED
# - Push to main: BLOCKED

set -e

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process Bash tool
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# Only check git push commands
if ! echo "$COMMAND" | grep -qE '\bgit\s+push\b'; then
    exit 0
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# Check if pushing to main
# Patterns to detect:
# - git push (on main branch, pushes to upstream main)
# - git push origin main
# - git push origin main:main
# - git push -u origin main
# - git push --set-upstream origin main

IS_PUSH_TO_MAIN=false

# Check for explicit main/master in push command
if echo "$COMMAND" | grep -qE '\bgit\s+push\b.*\b(main|master)\b'; then
    IS_PUSH_TO_MAIN=true
fi

# Check for push without explicit branch while on main
# This catches: git push, git push origin, git push -u origin
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    # If no branch specified in push command, it will push current branch
    if ! echo "$COMMAND" | grep -qE '\bgit\s+push\b.*\s+[a-zA-Z0-9_-]+\s+[a-zA-Z0-9_/-]+'; then
        # No explicit remote/branch pair - will push current branch
        # Check if it's just "git push" or "git push origin" without branch
        if echo "$COMMAND" | grep -qE '\bgit\s+push\s*$' || \
           echo "$COMMAND" | grep -qE '\bgit\s+push\s+(--[a-z-]+\s+)*[a-zA-Z0-9_-]+\s*$'; then
            IS_PUSH_TO_MAIN=true
        fi
    fi
fi

# Block if pushing to main
if [ "$IS_PUSH_TO_MAIN" = true ]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "BLOCKED: Cannot push directly to main branch. Trunk-based development requires:\\n\\n1. Create a feature branch: git checkout -b feature/your-change\\n2. Commit your changes on the branch\\n3. Push the branch: git push -u origin feature/your-change\\n4. Create a PR for review\\n\\nCurrent branch: $CURRENT_BRANCH"
  }
}
EOF
    exit 0
fi

# Allow all other push commands
exit 0
