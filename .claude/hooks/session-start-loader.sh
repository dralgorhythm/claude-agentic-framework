#!/bin/bash
# Session start hook for swarm context loading
# Loads project context and swarm state

INPUT=$(cat)

# jq is required to parse tool input past this point. Rather than failing
# silently when it's missing (hooks are guardrails, not a security boundary
# — but a silent gap is worse than a visible one), surface exactly what
# degrades so the current session knows what it can't rely on.
if ! command -v jq >/dev/null 2>&1; then
    cat << 'EOF'

[HOOK DEGRADATION]
jq is not installed — the following guardrails are degraded for this session:
- Secret detection & file-lock coordination (pre-tool-use-validator.sh): skipped entirely
- Dangerous-command warnings (dangerous-command-guard.sh): skipped entirely
- Pre-commit verification reminders (pre-commit-verification.sh): skipped entirely
Unaffected: pre-push-main-blocker.sh's branch-block does not depend on jq and
keeps working either way; permissions.deny (.claude/settings.json) is
enforced at the permission layer regardless of jq or any hook.
Install jq to restore full hook coverage.
EOF
    exit 0
fi

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

# Post-compaction / resume re-orientation: on "compact", prior context was
# just summarized away; on "resume", this is picking up a session from
# scratch. Either way, don't trust what's already "known" — re-check state
# before continuing (see debugging-protocol.md's Stale Context Check).
if [ "$SOURCE" = "compact" ] || [ "$SOURCE" = "resume" ]; then
    CONTEXT="$CONTEXT

[POST-COMPACTION RE-ORIENTATION]
- Check the native task list for in-flight work before starting anything new
- If a plan artifact is active (artifacts/plan_*.md), re-read it before continuing
- Re-read any file before editing it — do not trust memory of its contents (Stale Context Check, .claude/rules/debugging-protocol.md)"
fi

# Check for active swarm agents
ACTIVE_AGENTS=$(find "$STATE_DIR" -maxdepth 1 -name 'session_*.json' -type f 2>/dev/null | wc -l | tr -d ' ')
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
