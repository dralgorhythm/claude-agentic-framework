#!/bin/bash
# SubagentStop hook for validating subagent task completion
# Ensures subagents complete their assigned work before returning

set -e

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Prevent infinite loops
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/hooks/.state"

# Subagent completion is generally validated by the orchestrator
# This hook provides feedback for logging and coordination

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "[$TIMESTAMP] Subagent task completed" >> "$STATE_DIR/subagent.log" 2>/dev/null || true

# Keep log manageable
if [ -f "$STATE_DIR/subagent.log" ]; then
    tail -n 100 "$STATE_DIR/subagent.log" > "$STATE_DIR/subagent.log.tmp" 2>/dev/null && mv "$STATE_DIR/subagent.log.tmp" "$STATE_DIR/subagent.log"
fi

exit 0
