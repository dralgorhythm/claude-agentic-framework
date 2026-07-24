#!/usr/bin/env bash
# scripts/hook-tests.d/40-self-improvement.sh — correction-capture reminder
# (O14/U16): stop-validator.sh's scratchpad/corrections.log nudge. Hermetic:
# each case gets its own throwaway CLAUDE_PROJECT_DIR; no git repo is needed
# since the reminder is independent of the hook's separate uncommitted-
# changes check (see 00-baseline.sh's "silent on a clean tree" case for that).

_fresh_corrections_dir() { mktemp -d "${TMPDIR:-/tmp}/hook-test-corrections.XXXXXX"; }

# --- corrections.log with 2 lines: reminder names the count and the surface
two_line_dir=$(_fresh_corrections_dir)
mkdir -p "$two_line_dir/scratchpad"
printf '2026-07-24 | example correction one | none-yet\n2026-07-24 | example correction two | none-yet\n' \
  > "$two_line_dir/scratchpad/corrections.log"
run_case \
  "stop-validator: corrections.log with 2 lines names the count" \
  ".claude/hooks/stop-validator.sh" \
  "$(cat <<'JSON'
{"session_id":"test-session","stop_hook_active":false}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$two_line_dir" \
  "stdout-contains:2"
run_case \
  "stop-validator: corrections.log reminder names 'corrections' for promotion" \
  ".claude/hooks/stop-validator.sh" \
  "$(cat <<'JSON'
{"session_id":"test-session","stop_hook_active":false}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$two_line_dir" \
  "stdout-contains:corrections"

# --- absent corrections.log: silent ------------------------------------------
absent_dir=$(_fresh_corrections_dir)
run_case \
  "stop-validator: silent (exit 0, no output) when corrections.log is absent" \
  ".claude/hooks/stop-validator.sh" \
  "$(cat <<'JSON'
{"session_id":"test-session","stop_hook_active":false}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$absent_dir" \
  "exit0-silent"

# --- empty (zero-byte) corrections.log: silent -------------------------------
empty_dir=$(_fresh_corrections_dir)
mkdir -p "$empty_dir/scratchpad"
: > "$empty_dir/scratchpad/corrections.log"
run_case \
  "stop-validator: silent (exit 0, no output) when corrections.log is zero-byte" \
  ".claude/hooks/stop-validator.sh" \
  "$(cat <<'JSON'
{"session_id":"test-session","stop_hook_active":false}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$empty_dir" \
  "exit0-silent"
