#!/bin/bash
# Session start hook for swarm context loading
# Loads project context, beads status, and swarm state

set -eo pipefail

INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/hooks/.state"
mkdir -p "$STATE_DIR"

# Clean up session files older than 24 hours
find "$STATE_DIR" -name "session_*.json" -type f -mtime +1 -delete 2>/dev/null || true

# Initialize session tracking
SESSION_SHORT=$(echo "$SESSION_ID" | cut -c1-8)
echo "{\"session_id\": \"$SESSION_ID\", \"started\": \"$(date -Iseconds)\", \"source\": \"$SOURCE\"}" > "$STATE_DIR/session_$SESSION_SHORT.json"

# Build context message
CONTEXT=""

# Load Beads status if available
if command -v bd &> /dev/null && [ -d "$PROJECT_DIR/.beads" ]; then
    READY_COUNT=$(bd ready --json 2>/dev/null | jq 'length' 2>/dev/null || echo "0")
    OPEN_COUNT=$(bd list --status open --json 2>/dev/null | jq 'length' 2>/dev/null || echo "0")

    if [ "$OPEN_COUNT" != "0" ] || [ "$READY_COUNT" != "0" ]; then
        CONTEXT="$CONTEXT
[BEADS STATUS]
- Open issues: $OPEN_COUNT
- Ready to work: $READY_COUNT
- Run 'bd ready' to see unblocked issues
- Run 'bd list --status open' for all open issues"
    fi
fi

# Check for active swarm agents
ACTIVE_AGENTS=$(ls -1 "$STATE_DIR"/session_*.json 2>/dev/null | wc -l | tr -d ' ')
if [ "$ACTIVE_AGENTS" -gt 1 ]; then
    CONTEXT="$CONTEXT

[SWARM STATUS]
- Active agents in project: $ACTIVE_AGENTS
- Coordinate via Beads to avoid conflicts
- Use 'bd create' to track new work items
- Check file locks before major edits"
fi

# Check for pending work from previous sessions
if [ -f "$STATE_DIR/handoff.json" ]; then
    HANDOFF=$(cat "$STATE_DIR/handoff.json")
    HANDOFF_MSG=$(echo "$HANDOFF" | jq -r '.message // empty')
    if [ -n "$HANDOFF_MSG" ]; then
        CONTEXT="$CONTEXT

[HANDOFF FROM PREVIOUS SESSION]
$HANDOFF_MSG"
        # Clear handoff after reading
        rm -f "$STATE_DIR/handoff.json"
    fi
fi

# Output context if any
if [ -n "$CONTEXT" ]; then
    echo "$CONTEXT"
fi

exit 0
