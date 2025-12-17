#!/bin/bash
# Post-tool-use tracker for file modifications
# Tracks edited files and logs them for reference

set -e

# Read input from stdin
INPUT=$(cat)

# Extract tool name and file path from JSON input
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Exit if no file path (not a file operation)
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Skip markdown files and documentation
if [[ "$FILE_PATH" == *.md ]]; then
    exit 0
fi

# Get project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TRACKER_FILE="$PROJECT_DIR/.claude/hooks/.file-tracker.log"

# Get timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Determine relative path
if [[ "$FILE_PATH" == "$PROJECT_DIR"* ]]; then
    REL_PATH="${FILE_PATH#$PROJECT_DIR/}"
else
    REL_PATH="$FILE_PATH"
fi

# Log the file modification
echo "[$TIMESTAMP] $TOOL_NAME: $REL_PATH" >> "$TRACKER_FILE"

# Keep only last 100 entries to prevent file bloat
if [ -f "$TRACKER_FILE" ]; then
    tail -n 100 "$TRACKER_FILE" > "$TRACKER_FILE.tmp" && mv "$TRACKER_FILE.tmp" "$TRACKER_FILE"
fi

exit 0
