#!/bin/bash
# Post-tool-use tracker: file logging and lock release

INPUT=$(cat)

# jq is required to parse tool input; fail open if unavailable (hooks are
# guardrails, not a security boundary)
command -v jq >/dev/null 2>&1 || exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)

# Exit if not a file operation
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Compute relative path
if [[ "$FILE_PATH" == "$PROJECT_DIR"* ]]; then
    REL_PATH="${FILE_PATH#"$PROJECT_DIR"/}"
else
    REL_PATH="$FILE_PATH"
fi

# Skip noisy directories and file types (case is faster than array loop)
case "$REL_PATH" in
    .claude/hooks/*|.git/*|node_modules/*)
        exit 0
        ;;
    *.log|*.lock)
        exit 0
        ;;
esac

TRACKER_FILE="$PROJECT_DIR/.claude/hooks/.file-tracker.log"
LOCK_DIR="$PROJECT_DIR/.claude/hooks/.locks"

# Log file modification with session context
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
SESSION_SHORT=$(echo "$SESSION_ID" | cut -c1-8)
echo "[$TIMESTAMP] [$SESSION_SHORT] $TOOL_NAME: $REL_PATH" >> "$TRACKER_FILE"

# Release file lock if held by this session
LOCK_FILE="$LOCK_DIR/$(echo "$REL_PATH" | tr '/' '_').lock"
if [ -f "$LOCK_FILE" ]; then
    LOCK_SESSION=$(jq -r '.session_id // empty' <"$LOCK_FILE" 2>/dev/null || true)
    if [ "$LOCK_SESSION" = "$SESSION_ID" ]; then
        rm -f "$LOCK_FILE"
    fi
fi

# Hysteresis truncation: only trim when file exceeds 600 lines, keep last 500
if [ -f "$TRACKER_FILE" ]; then
    LINE_COUNT=$(wc -l < "$TRACKER_FILE" 2>/dev/null || echo 0)
    if [ "$LINE_COUNT" -gt 600 ]; then
        tail -n 500 "$TRACKER_FILE" > "$TRACKER_FILE.tmp" && mv "$TRACKER_FILE.tmp" "$TRACKER_FILE"
    fi
fi

exit 0
