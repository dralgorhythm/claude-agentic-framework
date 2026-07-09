#!/bin/bash
# Stop hook for swarm completion validation
# Ensures clean handoff and state sync before session ends

INPUT=$(cat)

# jq is required to parse tool input; fail open if unavailable (hooks are
# guardrails, not a security boundary)
command -v jq >/dev/null 2>&1 || exit 0

STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)

# Prevent infinite loops
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/hooks/.state"
LOCK_DIR="$PROJECT_DIR/.claude/hooks/.locks"
SESSION_SHORT=$(echo "$SESSION_ID" | cut -c1-8)

# Release any file locks held by this session
if [ -d "$LOCK_DIR" ]; then
    for lock_file in "$LOCK_DIR"/*.lock; do
        [ -f "$lock_file" ] || continue
        LOCK_SESSION=$(jq -r '.session_id // empty' <"$lock_file" 2>/dev/null || true)
        if [ "$LOCK_SESSION" = "$SESSION_ID" ]; then
            rm -f "$lock_file"
        fi
    done
fi

# Clean up session state
rm -f "$STATE_DIR/session_$SESSION_SHORT.json"

# Check for uncommitted changes
if [ -d "$PROJECT_DIR/.git" ]; then
    UNCOMMITTED=$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo "
---
[SESSION CLEANUP REMINDER]
- Uncommitted changes detected: $UNCOMMITTED files
- Consider: git add && git commit before ending
- Or track remaining work in the task tracker / GitHub Issues
---"
    fi
fi

exit 0
