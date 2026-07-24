#!/bin/bash
# Pre-tool-use validator for swarm consistency
# Validates file operations to prevent conflicts in multi-agent environments

INPUT=$(cat)

# jq is required to parse tool input; fail open if unavailable (hooks are
# guardrails, not a security boundary)
command -v jq >/dev/null 2>&1 || exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)

# detect_secret: shared secret-shape scan for both Write/Edit content (below)
# and Bash commands that redirect/heredoc content into a file. Sets
# SECRET_DETECTED / SECRET_TYPE as a side effect rather than echoing a
# classification back through a subshell.
detect_secret() {
    local text="$1"
    SECRET_DETECTED=false
    SECRET_TYPE=""

    # Generic secrets (API keys, passwords, tokens)
    # `-e` on every pattern below (not just this one) is deliberate: a
    # pattern beginning with a literal `-` (the private-key one, below) gets
    # parsed as an option by BSD grep without it, erroring out instead of
    # matching — `-e` marks the argument as a pattern unconditionally, so
    # this holds regardless of what a pattern happens to start with.
    if echo "$text" | grep -qiE -e '(api[_-]?key|secret|password|token|credential).*[=:][[:space:]]*["\x27]?[a-zA-Z0-9+/]{20,}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="generic secret"
    fi

    # AWS access keys (AKIA followed by 16 alphanumeric chars)
    if echo "$text" | grep -qE -e 'AKIA[0-9A-Z]{16}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="AWS access key"
    fi

    # JWT tokens (three base64 segments separated by dots)
    if echo "$text" | grep -qE -e 'eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'; then
        SECRET_DETECTED=true
        SECRET_TYPE="JWT token"
    fi

    # Environment variable exports with secrets
    if echo "$text" | grep -qiE -e 'export\s+(API_KEY|SECRET|PASSWORD|TOKEN|CREDENTIAL|AWS_|PRIVATE_KEY)=["\x27]?[a-zA-Z0-9+/]{20,}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="exported secret"
    fi

    # GitHub personal access tokens
    if echo "$text" | grep -qE -e 'ghp_[a-zA-Z0-9]{36}'; then
        SECRET_DETECTED=true
        SECRET_TYPE="GitHub personal access token"
    fi

    # Private keys (PEM format) — this pattern starts with a literal `-----`;
    # without `-e` above, BSD grep (macOS) treats that as option flags and
    # errors out instead of matching, silently never detecting a real
    # private key on those systems.
    if echo "$text" | grep -qE -e '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'; then
        SECRET_DETECTED=true
        SECRET_TYPE="private key"
    fi
}

# Bash secret-write scan: a redirect or heredoc can write secret-shaped
# content straight to disk without ever going through Write/Edit, bypassing
# the detection below entirely (e.g. a heredoc'd .env write). Ask — never
# deny, this hook can't tell a real secret from a placeholder — when the
# command both writes to a file and contains secret-shaped content. This
# covers the pre-commit, redirect-syntax path only; Trivy's CI secret-scan
# job remains the backstop for anything this and the Write/Edit scan below
# both miss (see docs/hooks.md's Secret Detection section).
if [ "$TOOL_NAME" = "Bash" ]; then
    # Named TOOL_COMMAND, not BASH_COMMAND: the latter is bash's own special
    # variable (always reflects "the command currently being executed") —
    # assigning to it here would silently get clobbered by the shell on the
    # very next statement, not hold the extracted value.
    TOOL_COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
    if echo "$TOOL_COMMAND" | grep -qE '(>>|<<|>)'; then
        detect_secret "$TOOL_COMMAND"
        if [ "$SECRET_DETECTED" = true ]; then
            echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Potential $SECRET_TYPE detected in a Bash command that writes to a file (redirect/heredoc). Please verify this is not sensitive data.\"}}"
        fi
    fi
    exit 0
fi

# Exit if not a file operation
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOCK_DIR="$PROJECT_DIR/.claude/hooks/.locks"
mkdir -p "$LOCK_DIR"

# Get relative path for lock file naming
if [[ "$FILE_PATH" == "$PROJECT_DIR"* ]]; then
    REL_PATH="${FILE_PATH#"$PROJECT_DIR"/}"
else
    REL_PATH="$FILE_PATH"
fi

# Create safe lock file name
LOCK_FILE="$LOCK_DIR/$(echo "$REL_PATH" | tr '/' '_').lock"

# Check for concurrent edits (swarm conflict prevention)
if [ -f "$LOCK_FILE" ]; then
    LOCK_SESSION=$(jq -r '.session_id // empty' <"$LOCK_FILE" 2>/dev/null || true)
    LOCK_TIME=$(jq -r '.timestamp // 0' <"$LOCK_FILE" 2>/dev/null || echo 0)
    [[ "$LOCK_TIME" =~ ^[0-9]+$ ]] || LOCK_TIME=0
    CURRENT_TIME=$(date +%s)

    # Lock expires after 120 seconds
    if [ $((CURRENT_TIME - LOCK_TIME)) -lt 120 ] && [ "$LOCK_SESSION" != "$SESSION_ID" ]; then
        echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"File '$REL_PATH' is being edited by another agent. Wait for completion or coordinate via the task tracker.\"}}"
        exit 0
    fi
fi

# Block edits to critical system files
PROTECTED_PATTERNS=(
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

# Config-write ask-gate: these paths carry /tailor's propose-only contract
# (.claude/skills/tailor/SKILL.md — "/tailor proposes only, it never
# silently writes to .claude/rules/, .claude/settings.json, CLAUDE.md, or
# any other tracked config file"). A direct Write/Edit bypasses that review
# step, so ask rather than silently proceeding — deliberately "ask", not
# "deny": a legitimate direct edit (including this hardening plan's own
# commits) should still be able to proceed once confirmed.
case "$REL_PATH" in
    .claude/settings.json|.claude/rules/*|CLAUDE.md)
        echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Editing $REL_PATH changes tracked framework configuration that /tailor normally proposes for review rather than writing directly (see tailor/SKILL.md's Output Contract). Confirm this direct edit is intentional.\"}}"
        exit 0
        ;;
esac

# Skip secret detection for test files
if [[ "$REL_PATH" == *.test.ts ]] || [[ "$REL_PATH" == *.spec.ts ]] || \
   [[ "$REL_PATH" == *.test.tsx ]] || [[ "$REL_PATH" == *.spec.tsx ]] || \
   [[ "$REL_PATH" == *.test.js ]] || [[ "$REL_PATH" == *.spec.js ]]; then
    # Test files may contain mock secrets — skip detection
    :
elif [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null || true)

    detect_secret "$CONTENT"

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
