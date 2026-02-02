#!/bin/bash
# Pre-tool-use validator for swarm consistency
# Validates file operations to prevent conflicts in multi-agent environments

set -eo pipefail

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

    # Lock expires after 120 seconds
    if [ $((CURRENT_TIME - LOCK_TIME)) -lt 120 ] && [ "$LOCK_SESSION" != "$SESSION_ID" ]; then
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
    ".env"
    ".mcp.json"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$REL_PATH" == *"$pattern"* ]]; then
        echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"Cannot modify protected file: $REL_PATH. Use appropriate commands or escalate.\"}}"
        exit 0
    fi
done

# Skip secret detection for test files
if [[ "$REL_PATH" == *.test.ts ]] || [[ "$REL_PATH" == *.spec.ts ]] || \
   [[ "$REL_PATH" == *.test.tsx ]] || [[ "$REL_PATH" == *.spec.tsx ]] || \
   [[ "$REL_PATH" == *.test.js ]] || [[ "$REL_PATH" == *.spec.js ]]; then
    # Test files may contain mock secrets — skip detection
    :
elif [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

    # Check for potential secrets - multiple patterns
    SECRET_DETECTED=false
    SECRET_TYPE=""

    # Generic secrets (API keys, passwords, tokens)
    if echo "$CONTENT" | grep -qiE '(api[_-]?key|secret|password|token|credential).*[=:][[:space:]]*["\x27]?[a-zA-Z0-9+/]{20,}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="generic secret"
    fi

    # AWS access keys (AKIA followed by 16 alphanumeric chars)
    if echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="AWS access key"
    fi

    # JWT tokens (three base64 segments separated by dots)
    if echo "$CONTENT" | grep -qE 'eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'; then
        SECRET_DETECTED=true
        SECRET_TYPE="JWT token"
    fi

    # Environment variable exports with secrets
    if echo "$CONTENT" | grep -qiE 'export\s+(API_KEY|SECRET|PASSWORD|TOKEN|CREDENTIAL|AWS_|PRIVATE_KEY)=["\x27]?[a-zA-Z0-9+/]{20,}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="exported secret"
    fi

    # GitHub personal access tokens
    if echo "$CONTENT" | grep -qE 'ghp_[a-zA-Z0-9]{36}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="GitHub personal access token"
    fi

    # Private keys (PEM format)
    if echo "$CONTENT" | grep -qE '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'; then
        SECRET_DETECTED=true
        SECRET_TYPE="private key"
    fi

    if [ "$SECRET_DETECTED" = true ]; then
        echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Potential $SECRET_TYPE detected in content. Please verify this is not sensitive data.\"}}"
        exit 0
    fi
fi

# Acquire lock for this file atomically using mkdir
LOCK_DIR_ATOMIC="$LOCK_FILE.lock"
if mkdir "$LOCK_DIR_ATOMIC" 2>/dev/null; then
    # Successfully acquired lock
    echo "{\"session_id\": \"$SESSION_ID\", \"timestamp\": $(date +%s), \"tool\": \"$TOOL_NAME\"}" > "$LOCK_FILE"
    rmdir "$LOCK_DIR_ATOMIC"
else
    # Failed to acquire lock - deny instead of proceeding
    echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"Failed to acquire file lock - another agent may be editing this file. Wait and retry.\"}}"
    exit 0
fi

exit 0
