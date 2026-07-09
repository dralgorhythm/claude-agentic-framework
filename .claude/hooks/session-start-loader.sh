#!/bin/bash
# Session start hook for swarm context loading
# Loads project context and swarm state

INPUT=$(cat)

# jq is required to parse tool input; fail open if unavailable (hooks are
# guardrails, not a security boundary)
command -v jq >/dev/null 2>&1 || exit 0

SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"' 2>/dev/null || echo "startup")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/hooks/.state"
LOCK_DIR="$PROJECT_DIR/.claude/hooks/.locks"
mkdir -p "$STATE_DIR" "$LOCK_DIR" 2>/dev/null || true

# Clean up session files older than 24 hours
find "$STATE_DIR" -name "session_*.json" -type f -mtime +1 -delete 2>/dev/null || true

# Clean stale locks (>5 min old)
if [ -d "$LOCK_DIR" ]; then
    find "$LOCK_DIR" -name "*.lock" -mmin +5 -delete 2>/dev/null || true
fi

# Initialize session tracking
SESSION_SHORT=$(echo "$SESSION_ID" | cut -c1-8)
echo "{\"session_id\": \"$SESSION_ID\", \"started\": \"$(date -Iseconds)\", \"source\": \"$SOURCE\"}" > "$STATE_DIR/session_$SESSION_SHORT.json"

# Build context message
CONTEXT=""

# Check for active swarm agents
ACTIVE_AGENTS=$(ls -1 "$STATE_DIR"/session_*.json 2>/dev/null | wc -l | tr -d ' ')
if [ "$ACTIVE_AGENTS" -gt 1 ]; then
    CONTEXT="$CONTEXT

[SWARM STATUS]
- Active agents in project: $ACTIVE_AGENTS
- Coordinate via the task tracker to avoid conflicts
- Check file locks before major edits"
fi

# Check for pending work from previous sessions
if [ -f "$STATE_DIR/handoff.json" ]; then
    HANDOFF=$(cat "$STATE_DIR/handoff.json" 2>/dev/null || true)
    HANDOFF_MSG=$(echo "$HANDOFF" | jq -r '.message // empty' 2>/dev/null || true)
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
