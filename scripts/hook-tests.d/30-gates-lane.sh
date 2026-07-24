#!/usr/bin/env bash
# scripts/hook-tests.d/30-gates-lane.sh — PR4 gates-enforce lane: unit U5b of
# artifacts/plan_framework_hardening.md (commit-gate enforcement, content-bound
# evidence stamp, per-gate timeout, escape hatch). Extends the harness per its
# own open/closed contract (a new numbered file, never edits to
# scripts/test-hooks.sh or the other lane files), so this lane stays
# independently mergeable. Reuses 00-baseline.sh's `_fresh_dir` helper (sourced
# before this file, so already in scope) and the runner's `run_case`/`report`.
#
# Hermeticity: every case below gets its OWN fresh directory and never
# operates on the checked-in scripts/fixtures/* trees directly — see
# 10-hooks-lane.sh's u2_clean_remote comment for why sharing mutable git
# state across cases makes results order-dependent.
#
# Fixture note: scripts/fixtures/failing-project/, .../slow-gate/, and the new
# .../passing-project/ (added here, sibling of failing-project) each ship an
# EMPTY package-lock.json alongside their package.json. Verified directly via
# gate_lib_detect: without a lockfile it picks pnpm ("test(pnpm)" / "pnpm
# test"); GitHub-hosted ubuntu-latest runners ship node+npm but not pnpm, so
# an npm-selecting lockfile keeps every case below deterministic in CI instead
# of only on a dev machine that happens to have pnpm installed.

# --- shared setup: a git repo from a fixture's files, staged, no commit yet
# (the hook intercepts `git commit` BEFORE it runs, so a staged-but-uncommitted
# index is the realistic state to test against) ------------------------------
_gate_fixture_repo() { # $1=fixture dir (repo-root-relative) -> prints fresh repo path
    local src="$1" dir
    dir=$(_fresh_dir)
    cp "$src"/* "$dir/" 2>/dev/null
    git -C "$dir" init -q >/dev/null 2>&1
    git -C "$dir" add -A >/dev/null 2>&1
    printf '%s' "$dir"
}

_gate_commit_json='{"tool_name":"Bash","tool_input":{"command":"git commit -m wip"}}'

# ============================================================================
# failing-project fixture: red gate -> deny, naming the gate + log + the
# fixed anti-test-deletion sentence
# ============================================================================
u5b_fail_dir=$(_gate_fixture_repo scripts/fixtures/failing-project)

run_case \
  "pre-commit-verification: failing-project fixture denies the commit" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_fail_dir" \
  "deny-json"

run_case \
  "pre-commit-verification: deny reason names the failing gate label" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_fail_dir" \
  "stdout-contains:test(npm)"

run_case \
  "pre-commit-verification: deny reason names the gate's log path" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_fail_dir" \
  "stdout-contains:$u5b_fail_dir/.claude/hooks/.state/gate-test(npm).log"

run_case \
  "pre-commit-verification: deny reason includes the exact anti-test-deletion sentence" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_fail_dir" \
  "stdout-contains:Do not delete or weaken tests to force a pass — fix the issue or ask the user."

# --- escape hatch on the same (still-failing) fixture: allow, disclosed ----
run_case \
  "pre-commit-verification: CLAUDE_SKIP_GATE_HOOK=1 allows even a failing gate" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_fail_dir CLAUDE_SKIP_GATE_HOOK=1" \
  "stdout-contains:GATE HOOK SKIPPED"

run_case \
  "pre-commit-verification: escape hatch disclosure names the env var" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_fail_dir CLAUDE_SKIP_GATE_HOOK=1" \
  "stdout-contains:CLAUDE_SKIP_GATE_HOOK=1"

# ============================================================================
# passing-project fixture: green gate -> silent allow, hook-authored stamp
# content-bound to the current index; a later staged change forces a re-run
# even though the stamp is still well within the 5-minute freshness window
# ============================================================================
u5b_pass_dir=$(_gate_fixture_repo scripts/fixtures/passing-project)
u5b_pass_stamp="$u5b_pass_dir/.claude/hooks/.state/commit-verified"
u5b_tree_1=$(git -C "$u5b_pass_dir" write-tree 2>/dev/null)

run_case \
  "pre-commit-verification: passing-project fixture allows silently" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_pass_dir" \
  "exit0-silent"

u5b_stamp_epoch_1="" u5b_stamp_tree_1=""
if [ -f "$u5b_pass_stamp" ]; then
    read -r u5b_stamp_epoch_1 u5b_stamp_tree_1 < "$u5b_pass_stamp" 2>/dev/null || true
fi
report \
  "pre-commit-verification: passing-project writes a hook-authored stamp bound to the current write-tree hash" \
  "$([ -n "$u5b_stamp_tree_1" ] && [ "$u5b_stamp_tree_1" = "$u5b_tree_1" ]; echo $?)" \
  "stamp epoch=${u5b_stamp_epoch_1:-missing} tree=${u5b_stamp_tree_1:-missing} expected=${u5b_tree_1:-empty}"

# --- unmodified re-run within the freshness window: cache hit, stamp mtime
# (and content) must NOT change — proves the fast path is actually taken,
# not just coincidentally also green -----------------------------------------
u5b_stamp_mtime_before=$(stat -f '%m' "$u5b_pass_stamp" 2>/dev/null || stat -c '%Y' "$u5b_pass_stamp" 2>/dev/null)

run_case \
  "pre-commit-verification: unmodified re-run within 5 min allows silently (cache hit)" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_pass_dir" \
  "exit0-silent"

u5b_stamp_mtime_after=$(stat -f '%m' "$u5b_pass_stamp" 2>/dev/null || stat -c '%Y' "$u5b_pass_stamp" 2>/dev/null)
report \
  "pre-commit-verification: unmodified re-run does not rewrite the stamp (true cache hit, not a coincidental re-pass)" \
  "$([ "$u5b_stamp_mtime_before" = "$u5b_stamp_mtime_after" ]; echo $?)" \
  "mtime before=$u5b_stamp_mtime_before after=$u5b_stamp_mtime_after"

# --- modify + re-stage a TRACKED file: tree-hash changes even though the
# stamp is still fresh by time alone -> must force a real re-run, not ride
# the stale-but-recent timestamp ---------------------------------------------
printf '{}' > "$u5b_pass_dir/package-lock.json"
git -C "$u5b_pass_dir" add -A >/dev/null 2>&1
u5b_tree_2=$(git -C "$u5b_pass_dir" write-tree 2>/dev/null)

run_case \
  "pre-commit-verification: re-run after staging a change still allows (gate re-ran and passed again)" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_pass_dir" \
  "exit0-silent"

u5b_stamp_epoch_2="" u5b_stamp_tree_2=""
if [ -f "$u5b_pass_stamp" ]; then
    read -r u5b_stamp_epoch_2 u5b_stamp_tree_2 < "$u5b_pass_stamp" 2>/dev/null || true
fi
report \
  "pre-commit-verification: a staged tree-hash change forces a fresh re-run despite an otherwise-fresh stamp (tree mismatch, not cached-allow)" \
  "$([ "$u5b_stamp_tree_2" = "$u5b_tree_2" ] && [ "$u5b_stamp_tree_2" != "$u5b_tree_1" ]; echo $?)" \
  "stamp epoch=${u5b_stamp_epoch_2:-missing} tree after re-run=${u5b_stamp_tree_2:-missing}, new tree=${u5b_tree_2:-empty}, old tree=${u5b_tree_1:-empty}"

# ============================================================================
# slow-gate fixture: a gate that outlives its budget -> an honest ask, never
# a silent kill or an indefinite hang, and no stamp is written
# ============================================================================
u5b_slow_dir=$(_gate_fixture_repo scripts/fixtures/slow-gate)
u5b_slow_stamp="$u5b_slow_dir/.claude/hooks/.state/commit-verified"

run_case \
  "pre-commit-verification: slow-gate fixture asks rather than silently killing or hanging" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$_gate_commit_json" \
  "CLAUDE_PROJECT_DIR=$u5b_slow_dir CLAUDE_GATE_TIMEOUT_SECS=2" \
  "ask-json"

report \
  "pre-commit-verification: a timed-out gate does not write an evidence stamp" \
  "$([ ! -f "$u5b_slow_stamp" ]; echo $?)" \
  "stamp unexpectedly present at $u5b_slow_stamp"
