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

    # Check for unpushed commits — remote-aware. A repo with zero remotes
    # configured skips this section entirely: counting "commits not on any
    # remote" without that guard warns on every commit in every local-only
    # repo, which is noise, not a reminder.
    REMOTES=$(git -C "$PROJECT_DIR" remote 2>/dev/null)
    if [ -n "$REMOTES" ]; then
        UPSTREAM_REF=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)
        if [ -n "$UPSTREAM_REF" ]; then
            # Has a configured upstream: count commits it doesn't have yet.
            AHEAD=$(git -C "$PROJECT_DIR" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
            [[ "$AHEAD" =~ ^[0-9]+$ ]] || AHEAD=0
            if [ "$AHEAD" -gt 0 ]; then
                echo "
---
[UNPUSHED WORK REMINDER]
- $AHEAD commit(s) ahead of $UPSTREAM_REF
- Push before ending: git push
---"
            fi
        else
            # No upstream tracking branch configured at all: count commits
            # unreachable from any remote-tracking ref.
            CURRENT_BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "your-branch")
            UNPUSHED=$(git -C "$PROJECT_DIR" rev-list --count HEAD --not --remotes 2>/dev/null || echo 0)
            [[ "$UNPUSHED" =~ ^[0-9]+$ ]] || UNPUSHED=0
            if [ "$UNPUSHED" -gt 0 ]; then
                echo "
---
[UNPUSHED WORK REMINDER]
- $UNPUSHED commit(s) with no upstream tracking branch configured
- Push and set upstream: git push -u origin $CURRENT_BRANCH
---"
            fi
        fi
    fi
fi

exit 0
