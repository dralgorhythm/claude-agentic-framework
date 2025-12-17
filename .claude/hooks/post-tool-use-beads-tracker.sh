#!/bin/bash
# Post-tool-use hook for Beads integration
# Auto-tracks significant file changes and updates issue context

set -e

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
TOOL_RESPONSE=$(echo "$INPUT" | jq -r '.tool_response // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Exit if not a file operation or no file path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TRACKER_FILE="$PROJECT_DIR/.claude/hooks/.file-tracker.log"
LOCK_DIR="$PROJECT_DIR/.claude/hooks/.locks"

# Get relative path
if [[ "$FILE_PATH" == "$PROJECT_DIR"* ]]; then
    REL_PATH="${FILE_PATH#$PROJECT_DIR/}"
else
    REL_PATH="$FILE_PATH"
fi

# Skip tracking for certain files
SKIP_PATTERNS=(
    ".claude/hooks/"
    ".beads/"
    ".git/"
    "*.log"
    "*.lock"
    "node_modules/"
)

for pattern in "${SKIP_PATTERNS[@]}"; do
    if [[ "$REL_PATH" == $pattern* ]] || [[ "$REL_PATH" == *"$pattern"* ]]; then
        exit 0
    fi
done

# Log file modification with session context
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
SESSION_SHORT=$(echo "$SESSION_ID" | cut -c1-8)
echo "[$TIMESTAMP] [$SESSION_SHORT] $TOOL_NAME: $REL_PATH" >> "$TRACKER_FILE"

# Release file lock
LOCK_FILE="$LOCK_DIR/$(echo "$REL_PATH" | tr '/' '_').lock"
if [ -f "$LOCK_FILE" ]; then
    LOCK_SESSION=$(cat "$LOCK_FILE" 2>/dev/null | jq -r '.session_id // empty')
    if [ "$LOCK_SESSION" = "$SESSION_ID" ]; then
        rm -f "$LOCK_FILE"
    fi
fi

# Keep tracker file manageable
if [ -f "$TRACKER_FILE" ]; then
    tail -n 500 "$TRACKER_FILE" > "$TRACKER_FILE.tmp" 2>/dev/null && mv "$TRACKER_FILE.tmp" "$TRACKER_FILE"
fi

# Auto-update Beads if editing an issue-related file
if command -v bd &> /dev/null && [ -d "$PROJECT_DIR/.beads" ]; then
    # Check if there's an active issue in progress
    ACTIVE_ISSUE=$(bd list --status in_progress --json 2>/dev/null | jq -r '.[0].id // empty' 2>/dev/null)

    if [ -n "$ACTIVE_ISSUE" ]; then
        # Add file to issue context (as a comment if bd supports it)
        # For now, just log that this file was modified during the issue
        echo "  -> Issue $ACTIVE_ISSUE context: $REL_PATH" >> "$TRACKER_FILE"
    fi
fi

exit 0
