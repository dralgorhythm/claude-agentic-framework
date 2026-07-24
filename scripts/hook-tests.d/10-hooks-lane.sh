#!/usr/bin/env bash
# scripts/hook-tests.d/10-hooks-lane.sh — PR1 hooks-lane cases: U1, U9, U2, U4
# of artifacts/plan_framework_hardening.md. Extends the harness per its own
# open/closed contract (a new numbered file, never edits to
# scripts/test-hooks.sh or 00-baseline.sh) so this lane stays independently
# mergeable. Reuses 00-baseline.sh's `_fresh_dir` helper (that file sources
# before this one, so the function is already in scope) and the runner's
# `run_case` / `path_without_jq`.

# ============================================================================
# U1 — push-block matcher precision + jq-free fallback + visible degradation
# ============================================================================

# --- false positives fixed: branch names merely containing "main"/"master"
# as a substring must be ALLOWED, not denied --------------------------------
run_case \
  "pre-push-main-blocker: 'git push origin feature/main-cleanup' allowed (false positive fixed)" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push origin feature/main-cleanup"}}
JSON
)" \
  "" \
  "exit0-silent"

run_case \
  "pre-push-main-blocker: 'git push origin domain-master-list' allowed (false positive fixed)" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push origin domain-master-list"}}
JSON
)" \
  "" \
  "exit0-silent"

# --- explicit push to main: denied, with jq present AND with jq absent —
# the hook no longer calls jq at all (field-scoped sed extraction instead),
# so both must behave identically ------------------------------------------
u1_nojq_path=$(path_without_jq)

run_case \
  "pre-push-main-blocker: explicit 'git push origin main' denied (jq present)" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}
JSON
)" \
  "" \
  "deny-json"

run_case \
  "pre-push-main-blocker: explicit 'git push origin main' denied (jq absent)" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}
JSON
)" \
  "PATH=$u1_nojq_path" \
  "deny-json"

run_case \
  "pre-push-main-blocker: refspec 'git push origin main:main' denied" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push origin main:main"}}
JSON
)" \
  "" \
  "deny-json"

# --- bare/implicit `git push` while on a branch actually named main: denied,
# with jq present AND with jq absent — needs a real fixture repo since the
# hook reads the *actual* current branch via `git -C ... rev-parse` --------
u1_main_repo=$(_fresh_dir)
git -C "$u1_main_repo" init -q -b main >/dev/null 2>&1
git -C "$u1_main_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m init >/dev/null 2>&1

run_case \
  "pre-push-main-blocker: bare 'git push' denied when CURRENT_BRANCH=main (jq present)" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$u1_main_repo" \
  "deny-json"

run_case \
  "pre-push-main-blocker: bare 'git push' denied when CURRENT_BRANCH=main (jq absent)" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$u1_main_repo PATH=$u1_nojq_path" \
  "deny-json"

# --- session-start-loader.sh: jq-absent now emits a visible degradation
# block instead of failing open silently. This deliberately supersedes the
# generic fail-open characterization for this one hook in 00-baseline.sh's
# jq-absent loop (that case now asserts stdout is empty, which is no longer
# true by design) — run the harness with
#   SKIP="fail-open: .claude/hooks/session-start-loader.sh exits 0 silently with jq absent"
# until 00-baseline.sh itself is updated in a follow-up (out of scope here:
# this lane does not edit 00-baseline.sh, see file header). ------------------
u1_ssl_dir=$(_fresh_dir)
run_case \
  "session-start-loader: jq absent emits [HOOK DEGRADATION] block" \
  ".claude/hooks/session-start-loader.sh" \
  '{"source":"startup","session_id":"11111111-0000-0000-0000-000000000000"}' \
  "CLAUDE_PROJECT_DIR=$u1_ssl_dir PATH=$u1_nojq_path" \
  "stdout-contains:[HOOK DEGRADATION]"
