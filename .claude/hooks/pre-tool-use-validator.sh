#!/bin/bash
# Pre-tool-use validator for swarm consistency
# Validates file operations to prevent conflicts in multi-agent environments

set -e

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Exit if not a file operation
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOCK_DIR="$PROJECT_DIR/.claude/hooks/.locks"
mkdir -p "$LOCK_DIR"

# Get relative path for lock file naming
if [[ "$FILE_PATH" == "$PROJECT_DIR"* ]]; then
    REL_PATH="${FILE_PATH#$PROJECT_DIR/}"
else
    REL_PATH="$FILE_PATH"
fi

# Create safe lock file name
LOCK_FILE="$LOCK_DIR/$(echo "$REL_PATH" | tr '/' '_').lock"

# Check for concurrent edits (swarm conflict prevention)
if [ -f "$LOCK_FILE" ]; then
    LOCK_SESSION=$(cat "$LOCK_FILE" 2>/dev/null | jq -r '.session_id // empty')
    LOCK_TIME=$(cat "$LOCK_FILE" 2>/dev/null | jq -r '.timestamp // 0')
    CURRENT_TIME=$(date +%s)

    # Lock expires after 60 seconds
    if [ $((CURRENT_TIME - LOCK_TIME)) -lt 60 ] && [ "$LOCK_SESSION" != "$SESSION_ID" ]; then
        echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"File '$REL_PATH' is being edited by another agent. Wait for completion or coordinate via Beads.\"}}"
        exit 0
    fi
fi

# Block edits to critical system files
# Note: .claude/settings.json and .claude/rules/ are user-configurable
PROTECTED_PATTERNS=(
    ".beads/beads.db"
    ".beads/daemon"
    ".git/"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$REL_PATH" == *"$pattern"* ]]; then
        echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"Cannot modify protected file: $REL_PATH. Use appropriate commands or escalate.\"}}"
        exit 0
    fi
done

# Validate no secrets in Write/Edit content
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

    # Check for potential secrets
    if echo "$CONTENT" | grep -qiE '(api[_-]?key|secret|password|token|credential).*[=:][[:space:]]*["\x27]?[a-zA-Z0-9+/]{20,}'; then
        echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Potential secret detected in content. Please verify this is not sensitive data.\"}}"
        exit 0
    fi
fi

# Acquire lock for this file
echo "{\"session_id\": \"$SESSION_ID\", \"timestamp\": $(date +%s), \"tool\": \"$TOOL_NAME\"}" > "$LOCK_FILE"

exit 0
