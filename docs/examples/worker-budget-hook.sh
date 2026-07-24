#!/usr/bin/env bash
#
# worker-budget-hook.sh — illustrative concurrent-worker counter
# (PreToolUse on Task + SubagentStop)
#
# WHAT IT DOES
#   Registered twice — once on PreToolUse (matcher: "Task") and once on
#   SubagentStop — this script tracks how many worker dispatches are
#   currently in flight: it increments a counter file when a Task tool call
#   starts and decrements it when a subagent stops. When the running count
#   exceeds 8 (this repo's documented max-concurrent-workers convention;
#   see docs/swarm.md and the swarm-coordination skill's "Budget & Waves"
#   section) it emits a non-blocking warning via the PreToolUse
#   permissionDecisionReason field.
#
# WHAT IT IS NOT
#   A token/spend tracker. The "Budget & Waves" convention this script
#   illustrates is a COST circuit-breaker — a token/wave ceiling declared
#   by the orchestrator at dispatch time. This script only approximates
#   one input to that judgment call (how many workers are simultaneously
#   in flight). It does not read token usage, and it does not detect
#   step-repetition or looping.
#
# HOW THE TWO INVOCATIONS ARE TOLD APART
#   Every hook payload carries a `hook_event_name` field (see
#   .claude/templates/hook.template.sh). PreToolUse payloads additionally
#   carry `tool_name`; SubagentStop payloads do not.
#
# WHY THIS IS OPT-IN
#   The repo's fail-soft hook doctrine ships every recipe here disabled by
#   default (see docs/examples/README.md). Wiring this in is a per-project
#   choice.
#
# HOW TO ENABLE (opt-in — not wired by default)
#   Add both entries to your .claude/settings.json:
#
#   {
#     "hooks": {
#       "PreToolUse": [
#         {
#           "matcher": "Task",
#           "hooks": [{"type": "command", "command": "$CLAUDE_PROJECT_DIR/docs/examples/worker-budget-hook.sh", "timeout": 5}]
#         }
#       ],
#       "SubagentStop": [
#         {
#           "hooks": [{"type": "command", "command": "$CLAUDE_PROJECT_DIR/docs/examples/worker-budget-hook.sh", "timeout": 5}]
#         }
#       ]
#     }
#   }
#
# DEPENDENCIES
#   None beyond coreutils. Uses jq to read hook JSON fields when present;
#   otherwise falls back to sed-based field extraction.
#
# FAIL-SOFT CONTRACT
#   Any unexpected condition (missing input, malformed JSON, unwritable
#   state directory, unrecognized event) results in a silent `exit 0`.
#   This hook never blocks a tool call — the over-threshold case only
#   ever warns via `permissionDecisionReason` on an explicit `allow`
#   decision. Known limitation: the counter file read-modify-write below
#   is not atomic across truly concurrent invocations — acceptable for an
#   illustrative example; harden with flock or similar before relying on
#   exact counts under heavy parallelism.

set -u

project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
state_dir="$project_dir/.claude/hooks/.state"
counter_file="$state_dir/worker-budget-count"
max_concurrent=8

mkdir -p "$state_dir" 2>/dev/null || exit 0

input="$(cat 2>/dev/null)" || exit 0
[ -n "$input" ] || exit 0

extract_field() {
    local field="$1"
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$input" | jq -r --arg f "$field" '.[$f] // empty' 2>/dev/null
    else
        printf '%s' "$input" | sed -n "s/.*\"${field}\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n 1
    fi
}

event="$(extract_field hook_event_name)"

# --- Read the current count (default 0 on missing/corrupt file) ----------
count=0
if [ -f "$counter_file" ]; then
    read -r count < "$counter_file" 2>/dev/null || count=0
fi
case "$count" in ''|*[!0-9]*) count=0 ;; esac

case "$event" in
  PreToolUse)
    tool="$(extract_field tool_name)"
    [ "$tool" = "Task" ] || exit 0
    count=$((count + 1))
    printf '%s\n' "$count" > "$counter_file" 2>/dev/null
    if [ "$count" -gt "$max_concurrent" ]; then
        cat <<EOF
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "worker-budget-hook: $count Task dispatches in flight, past the documented max of $max_concurrent — consider stopping to report spend and remaining work before dispatching more (see swarm-coordination's Budget & Waves section)"}}
EOF
    fi
    ;;
  SubagentStop)
    [ "$count" -gt 0 ] && count=$((count - 1))
    printf '%s\n' "$count" > "$counter_file" 2>/dev/null
    ;;
  *)
    exit 0
    ;;
esac

exit 0
