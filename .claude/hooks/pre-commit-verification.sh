#!/bin/bash
# Hook: pre-commit-verification
# Event: PreToolUse (Bash)
# Purpose: Run the project's detected quality gates before git commits and
# block the commit on failure.
#
# Enforcement rewrite (artifacts/plan_framework_hardening.md, unit U5b): this
# hook used to only ever print advisory text and trust a time-only stamp the
# AGENT was instructed to write by hand — self-attestation, not verification
# (see the plan's Design Principles). It now runs the gates itself. A stamp
# is trusted only when BOTH fresh (<=5 min) AND content-bound: its recorded
# tree-hash must equal the current `git write-tree` output, so a change
# staged seconds ago forces a re-run even if the last stamp is a minute old
# (review F8 — a time-only stamp rides post-edit changes). The stamp file is
# hook-authored only; nothing in this file's own output ever instructs the
# agent to write it.

INPUT=$(cat)

# jq is required to parse tool input; fail open if unavailable (hooks are
# guardrails, not a security boundary). This path is byte-for-byte the same
# as before this rewrite — no gates ever ran on the jq-absent path, and none
# do now either.
command -v jq >/dev/null 2>&1 || exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

# Only process Bash tool with git commit commands
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

if ! echo "$COMMAND" | grep -qE '\bgit\s+commit\b'; then
    exit 0
fi

STATE_DIR="$PROJECT_DIR/.claude/hooks/.state"
mkdir -p "$STATE_DIR"
STAMP_FILE="$STATE_DIR/commit-verified"

# Escape hatch: unconditional, checked before the stamp or any gate ever
# runs, and always disclosed — never a silent skip.
if [ "${CLAUDE_SKIP_GATE_HOOK:-}" = "1" ]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "additionalContext": "[GATE HOOK SKIPPED] CLAUDE_SKIP_GATE_HOOK=1 is set — quality gates were NOT run for this commit. Unset it to restore enforcement."
  }
}
EOF
    exit 0
fi

# Detect project type and available gates — detection lives in gate-lib.sh
# (unit U5a): one shared function emits invocable commands plus the human
# label the advisory has always shown.
# shellcheck source=gate-lib.sh
# shellcheck disable=SC1091  # dynamic path (BASH_SOURCE-relative); the
# above source= directive documents it for anyone re-running with `-x`
source "$(dirname "${BASH_SOURCE[0]}")/gate-lib.sh"

# A stamp is trusted only if BOTH fresh (<5 min) AND content-bound to the
# CURRENT index — computed once, up front, before we even know whether there
# are gates to trust it for.
CURRENT_TREE=$(git -C "$PROJECT_DIR" write-tree 2>/dev/null || true)

if [ -f "$STAMP_FILE" ] && [ -n "$CURRENT_TREE" ]; then
    STAMP_EPOCH=""
    STAMP_TREE=""
    read -r STAMP_EPOCH STAMP_TREE < "$STAMP_FILE" 2>/dev/null || true
    [[ "$STAMP_EPOCH" =~ ^[0-9]+$ ]] || STAMP_EPOCH=0
    NOW=$(date +%s)
    AGE=$((NOW - STAMP_EPOCH))
    if [ "$AGE" -lt 300 ] && [ "$STAMP_TREE" = "$CURRENT_TREE" ]; then
        exit 0
    fi
fi

gate_lib_detect "$PROJECT_DIR"

# No gates detected: nothing for the hook to run automatically — keep
# today's advisory guidance (manual verification is the only check that
# happens here; the stamp stays hook-authored-only in every branch, so this
# text no longer tells the agent to write it by hand).
if [ "${#GATE_LABELS[@]}" -eq 0 ]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "additionalContext": "
---
[PRE-COMMIT VERIFICATION REQUIRED]

Before committing, you MUST complete these steps:

1. RUN ALL TESTS AND LINTING:
   - Run the project's test suite and ensure all tests pass
   - Run linting/formatting checks and fix any issues
   - Run type checking if available

   Detected tools in this project: none detected - check manually

2. FIX ALL FAILURES:
   - If tests fail, fix the code until they pass
   - If linting fails, fix the issues
   - Do NOT skip or disable failing checks

3. CRITICAL: NEVER REMOVE OR SKIP TESTS
   - Do NOT delete test files or test cases to make tests pass
   - Do NOT comment out failing tests
   - Do NOT add skip decorators to avoid failures
   - Fix the actual code issues instead

4. AFTER VERIFICATION SUCCEEDS:
   - Proceed with the git commit. No gates were detected for this project,
     so this manual pass is the only verification that happens — nothing
     here is written or re-checked automatically.

If you cannot fix a test legitimately, STOP and ask the user for guidance.
---"
  }
}
EOF
    exit 0
fi

# Gates detected: run each one under its own timeout, from PROJECT_DIR,
# logging to its own file. Fail-fast on the first red or timed-out gate —
# the reason names exactly one gate, matching the plan's fixtures.
GATE_TIMEOUT="${CLAUDE_GATE_TIMEOUT_SECS:-120}"
FAILED_LABEL=""
FAILED_LOG=""
TIMED_OUT_LABEL=""

for _gate_i in "${!GATE_LABELS[@]}"; do
    _gate_label="${GATE_LABELS[$_gate_i]}"
    _gate_cmd="${GATE_COMMANDS[$_gate_i]}"
    _gate_log="$STATE_DIR/gate-${_gate_label//\//_}.log"
    ( cd "$PROJECT_DIR" && timeout "$GATE_TIMEOUT" bash -c "$_gate_cmd" </dev/null ) >"$_gate_log" 2>&1
    _gate_rc=$?
    if [ "$_gate_rc" -eq 124 ]; then
        TIMED_OUT_LABEL="$_gate_label"
        break
    elif [ "$_gate_rc" -ne 0 ]; then
        FAILED_LABEL="$_gate_label"
        FAILED_LOG="$_gate_log"
        break
    fi
done

if [ -n "$TIMED_OUT_LABEL" ]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "ask",
    "permissionDecisionReason": "Quality gate '$TIMED_OUT_LABEL' exceeded its ${GATE_TIMEOUT}s budget and was stopped — gates did not finish, so nothing was verified either way. Run them manually before committing; no evidence stamp was written."
  }
}
EOF
    exit 0
fi

if [ -n "$FAILED_LABEL" ]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Quality gate '$FAILED_LABEL' failed. See $FAILED_LOG for details. Do not delete or weaken tests to force a pass — fix the issue or ask the user."
  }
}
EOF
    exit 0
fi

# All gates green: hook-authored stamp only, content-bound to the index we
# actually checked — no instruction anywhere tells the agent to write this
# file itself.
if [ -n "$CURRENT_TREE" ]; then
    echo "$(date +%s) $CURRENT_TREE" > "$STAMP_FILE"
fi
exit 0
