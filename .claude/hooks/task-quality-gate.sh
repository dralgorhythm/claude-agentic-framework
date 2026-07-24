#!/usr/bin/env bash
# .claude/hooks/task-quality-gate.sh — TaskCompleted quality gate. Ships
# registered by default in settings.json (unit U5c, artifacts/
# plan_framework_hardening.md; decision record: artifacts/
# adr_default_quality_gate.md) — the framework's only true completion-time
# gate no longer ships disabled. Runs the same gate-lib.sh-detected gates
# pre-commit-verification.sh (U5b) runs at commit time, but at
# task-completion time instead — a second, independent checkpoint, not a
# replacement. Blocks via exit code 2, the documented TaskCompleted blocking
# mechanism (docs/hooks.md: "Only exit code 2 blocks an action").
#
# Read and discard stdin: TaskCompleted's JSON payload carries nothing this
# hook's own logic needs (CLAUDE_SKIP_GATE_HOOK and gate_lib_detect below are
# the only two things that decide behavior) — the jq guard still applies for
# consistency with every other hook's opening idiom in this repo.
cat >/dev/null

# jq is required elsewhere in this repo's hooks to parse tool input; fail
# open if unavailable (hooks are guardrails, not a security boundary — see
# docs/hooks.md).
command -v jq >/dev/null 2>&1 || exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/hooks/.state"
mkdir -p "$STATE_DIR"

# Escape hatch: unconditional, checked before any gate ever runs, and always
# disclosed on stderr — shared verbatim with pre-commit-verification.sh's
# CLAUDE_SKIP_GATE_HOOK (parity: one env var disables both gate hooks, not
# two to remember).
if [ "${CLAUDE_SKIP_GATE_HOOK:-}" = "1" ]; then
    echo "[TASK GATE SKIPPED] CLAUDE_SKIP_GATE_HOOK=1 is set — quality gates were NOT run for this task completion. Unset it to restore enforcement." >&2
    exit 0
fi

# Detection lives once in gate-lib.sh (U5a); this hook only decides what to
# DO with a detected gate (open/closed — plan's Design Principles).
# shellcheck source=gate-lib.sh
# shellcheck disable=SC1091  # dynamic path (BASH_SOURCE-relative)
source "$(dirname "${BASH_SOURCE[0]}")/gate-lib.sh"
gate_lib_detect "$PROJECT_DIR"

# No gates detected: nothing to run, nothing to say. Unlike the commit gate,
# a TaskCompleted event has no advisory-text channel worth using for the
# no-stack case, so this stays fully silent.
if [ "${#GATE_LABELS[@]}" -eq 0 ]; then
    exit 0
fi

# Run each detected gate under the shared portable-timeout resolution
# (gate_lib_timeout_bin, unit U5c — DRY with pre-commit-verification.sh's own
# use of it). Default budget is 90s per gate: tighter than the commit gate's
# 120s default, since this hook's own settings.json registration is 120s
# total (vs. the commit gate's 300s) and must leave return headroom.
GATE_TIMEOUT="${CLAUDE_GATE_TIMEOUT_SECS:-90}"
TIMEOUT_BIN=$(gate_lib_timeout_bin)
FAILED_LABEL=""
FAILED_LOG=""
TIMED_OUT_LABEL=""

for _gate_i in "${!GATE_LABELS[@]}"; do
    _gate_label="${GATE_LABELS[$_gate_i]}"
    _gate_cmd="${GATE_COMMANDS[$_gate_i]}"
    _gate_log="$STATE_DIR/taskgate-${_gate_label//\//_}.log"
    if [ -n "$TIMEOUT_BIN" ]; then
        ( cd "$PROJECT_DIR" && "$TIMEOUT_BIN" "$GATE_TIMEOUT" bash -c "$_gate_cmd" </dev/null ) >"$_gate_log" 2>&1
    else
        ( cd "$PROJECT_DIR" && bash -c "$_gate_cmd" </dev/null ) >"$_gate_log" 2>&1
    fi
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

# Timeout: non-blocking by design. A task completion should not hard-fail on
# slowness alone — mirrors U5b's ask-not-deny philosophy, in TaskCompleted's
# simpler exit-code vocabulary: allow, but say so honestly on stderr.
if [ -n "$TIMED_OUT_LABEL" ]; then
    echo "[TASK GATE TIMEOUT] '$TIMED_OUT_LABEL' exceeded its ${GATE_TIMEOUT}s budget — treated as non-blocking, task completion allowed. Run it manually to confirm; nothing was verified either way." >&2
    exit 0
fi

# Red gate: block. Exit 2 is TaskCompleted's documented blocking mechanism.
if [ -n "$FAILED_LABEL" ]; then
    echo "Quality gate '$FAILED_LABEL' failed. See $FAILED_LOG for details. Do not delete or weaken tests to force a pass — fix the issue or ask the user." >&2
    exit 2
fi

# All gates green: silent allow.
exit 0
