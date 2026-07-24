#!/usr/bin/env bash
# scripts/hook-tests.d/60-taskgate.sh — PR5 gates-default lane: unit U5c of
# artifacts/plan_framework_hardening.md (TaskCompleted quality gate, ships
# registered by default; decision record: artifacts/adr_default_quality_gate.md).
# Extends the harness per its own open/closed contract (a new numbered file,
# never edits to scripts/test-hooks.sh's flow or the other lane files).
#
# Reuses 00-baseline.sh's `_fresh_dir` (no-stack case) and 30-gates-lane.sh's
# `_gate_fixture_repo` (red/green fixtures — both already in scope, sourced
# before this file by numeric load order: 00 < 30 < 60). task-quality-gate.sh
# needs no git state at all (unlike pre-commit-verification.sh, it never
# runs `git write-tree` or intercepts `git commit`), but reusing the same
# fixture-copy helper is simpler than a near-duplicate and the extra `git
# init` it performs is harmless — gate_lib_detect only looks for manifest
# files, never git state.
#
# TaskCompleted's documented contract is an exit code plus a stderr message,
# not the PreToolUse JSON contract — hence this lane's use of run_case's
# exit2-stderr-contains:/exit0-stderr-contains: forms (added alongside this
# file; see scripts/test-hooks.sh's run_case header).

_taskgate_completed_json='{"session_id":"test-session"}'

# ============================================================================
# failing-project fixture: red gate -> blocks via exit 2, naming the gate +
# log path + the fixed anti-test-deletion sentence, all on stderr
# ============================================================================
u5c_fail_dir=$(_gate_fixture_repo scripts/fixtures/failing-project)

run_case \
  "task-quality-gate: failing-project fixture blocks with exit 2" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "CLAUDE_PROJECT_DIR=$u5c_fail_dir" \
  "exit2-stderr-contains:test(npm)"

run_case \
  "task-quality-gate: exit-2 stderr names the gate's log path (taskgate- namespace)" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "CLAUDE_PROJECT_DIR=$u5c_fail_dir" \
  "exit2-stderr-contains:$u5c_fail_dir/.claude/hooks/.state/taskgate-test(npm).log"

run_case \
  "task-quality-gate: exit-2 stderr includes the exact anti-test-deletion sentence" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "CLAUDE_PROJECT_DIR=$u5c_fail_dir" \
  "exit2-stderr-contains:Do not delete or weaken tests to force a pass — fix the issue or ask the user."

# --- escape hatch on the same (still-failing) fixture: allow, disclosed on stderr ---
run_case \
  "task-quality-gate: CLAUDE_SKIP_GATE_HOOK=1 allows even a failing gate (exit 0)" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "CLAUDE_PROJECT_DIR=$u5c_fail_dir CLAUDE_SKIP_GATE_HOOK=1" \
  "exit0-stderr-contains:TASK GATE SKIPPED"

run_case \
  "task-quality-gate: escape hatch disclosure names the env var" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "CLAUDE_PROJECT_DIR=$u5c_fail_dir CLAUDE_SKIP_GATE_HOOK=1" \
  "exit0-stderr-contains:CLAUDE_SKIP_GATE_HOOK=1"

# ============================================================================
# passing-project fixture: green gate -> silent allow (no stamp — this hook,
# unlike the commit gate, does not cache across TaskCompleted events)
# ============================================================================
u5c_pass_dir=$(_gate_fixture_repo scripts/fixtures/passing-project)

run_case \
  "task-quality-gate: passing-project fixture allows silently" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "CLAUDE_PROJECT_DIR=$u5c_pass_dir" \
  "exit0-silent"

# ============================================================================
# no-stack fixture: an empty directory with no detectable manifest -> silent
# allow, nothing run, nothing said
# ============================================================================
u5c_nostack_dir=$(_fresh_dir)

run_case \
  "task-quality-gate: no detectable stack allows silently" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "CLAUDE_PROJECT_DIR=$u5c_nostack_dir" \
  "exit0-silent"

# ============================================================================
# fail-open: jq absent -> silent allow, same convention as every other hook,
# even against a fixture that would otherwise fail its gate
# ============================================================================
u5c_nojq_path=$(path_without_jq)

run_case \
  "task-quality-gate: jq absent allows silently, even on an otherwise-failing fixture" \
  ".claude/hooks/task-quality-gate.sh" \
  "$_taskgate_completed_json" \
  "PATH=$u5c_nojq_path CLAUDE_PROJECT_DIR=$u5c_fail_dir" \
  "exit0-silent"
