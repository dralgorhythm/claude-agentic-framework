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

# ============================================================================
# U9 — post-compaction re-orientation
# ============================================================================

u9_compact_dir=$(_fresh_dir)
run_case \
  "session-start-loader: source=compact emits [POST-COMPACTION RE-ORIENTATION] block" \
  ".claude/hooks/session-start-loader.sh" \
  '{"source":"compact","session_id":"22222222-0000-0000-0000-000000000000"}' \
  "CLAUDE_PROJECT_DIR=$u9_compact_dir" \
  "stdout-contains:POST-COMPACTION RE-ORIENTATION"

u9_resume_dir=$(_fresh_dir)
run_case \
  "session-start-loader: source=resume emits [POST-COMPACTION RE-ORIENTATION] block" \
  ".claude/hooks/session-start-loader.sh" \
  '{"source":"resume","session_id":"33333333-0000-0000-0000-000000000000"}' \
  "CLAUDE_PROJECT_DIR=$u9_resume_dir" \
  "stdout-contains:POST-COMPACTION RE-ORIENTATION"

u9_startup_dir=$(_fresh_dir)
run_case \
  "session-start-loader: source=startup does not emit [POST-COMPACTION RE-ORIENTATION] (silent on a fresh project)" \
  ".claude/hooks/session-start-loader.sh" \
  '{"source":"startup","session_id":"44444444-0000-0000-0000-000000000000"}' \
  "CLAUDE_PROJECT_DIR=$u9_startup_dir" \
  "exit0-silent"

# ============================================================================
# U2 — stop-validator detects unpushed work, remote-aware
# ============================================================================

# Shared throwaway bare "remote" for the fixtures below — a local filesystem
# path works fine as a git remote; no network needed.
u2_remote=$(_fresh_dir)
git init -q --bare "$u2_remote" >/dev/null 2>&1

# --- ahead of a configured upstream: warns with count + push command ------
u2_ahead_repo=$(_fresh_dir)
git -C "$u2_ahead_repo" init -q >/dev/null 2>&1
git -C "$u2_ahead_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m init >/dev/null 2>&1
git -C "$u2_ahead_repo" remote add origin "$u2_remote" >/dev/null 2>&1
git -C "$u2_ahead_repo" push -q -u origin HEAD >/dev/null 2>&1
git -C "$u2_ahead_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m second >/dev/null 2>&1

run_case \
  "stop-validator: ahead-of-upstream reminder includes the commit count" \
  ".claude/hooks/stop-validator.sh" \
  '{"session_id":"u2-ahead","stop_hook_active":false}' \
  "CLAUDE_PROJECT_DIR=$u2_ahead_repo" \
  "stdout-contains:1 commit(s) ahead"

run_case \
  "stop-validator: ahead-of-upstream reminder includes the push command" \
  ".claude/hooks/stop-validator.sh" \
  '{"session_id":"u2-ahead","stop_hook_active":false}' \
  "CLAUDE_PROJECT_DIR=$u2_ahead_repo" \
  "stdout-contains:git push"

# --- clean and pushed: silent (has a real upstream, ahead=0) ---------------
u2_clean_repo=$(_fresh_dir)
git -C "$u2_clean_repo" init -q >/dev/null 2>&1
git -C "$u2_clean_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m init >/dev/null 2>&1
git -C "$u2_clean_repo" remote add origin "$u2_remote" >/dev/null 2>&1
git -C "$u2_clean_repo" push -q -u origin HEAD >/dev/null 2>&1

run_case \
  "stop-validator: silent when pushed and up to date with a configured remote" \
  ".claude/hooks/stop-validator.sh" \
  '{"session_id":"u2-clean","stop_hook_active":false}' \
  "CLAUDE_PROJECT_DIR=$u2_clean_repo" \
  "exit0-silent"

# --- remote configured but no upstream tracking branch: git push -u guidance
u2_nostream_repo=$(_fresh_dir)
git -C "$u2_nostream_repo" init -q >/dev/null 2>&1
git -C "$u2_nostream_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m init >/dev/null 2>&1
git -C "$u2_nostream_repo" remote add origin "$u2_remote" >/dev/null 2>&1

run_case \
  "stop-validator: git push -u guidance when a remote exists but no upstream is configured" \
  ".claude/hooks/stop-validator.sh" \
  '{"session_id":"u2-nostream","stop_hook_active":false}' \
  "CLAUDE_PROJECT_DIR=$u2_nostream_repo" \
  "stdout-contains:git push -u"

# --- zero-remote repo: no unpushed warning at all --------------------------
u2_noremote_repo=$(_fresh_dir)
git -C "$u2_noremote_repo" init -q >/dev/null 2>&1
git -C "$u2_noremote_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m init >/dev/null 2>&1

run_case \
  "stop-validator: silent — no unpushed warning in a zero-remote repo" \
  ".claude/hooks/stop-validator.sh" \
  '{"session_id":"u2-noremote","stop_hook_active":false}' \
  "CLAUDE_PROJECT_DIR=$u2_noremote_repo" \
  "exit0-silent"

# ============================================================================
# U4 — config-write ask-gate + Bash secret-write scan
# ============================================================================

u4_ptu_dir=$(_fresh_dir)

run_case \
  "pre-tool-use-validator: Write to .claude/rules/x.md asks (tailor propose-only contract)" \
  ".claude/hooks/pre-tool-use-validator.sh" \
  "$(cat <<'JSON'
{"tool_name":"Write","tool_input":{"file_path":".claude/rules/x.md","content":"some rule content"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$u4_ptu_dir" \
  "ask-json"

run_case \
  "pre-tool-use-validator: Write to .claude/settings.json asks" \
  ".claude/hooks/pre-tool-use-validator.sh" \
  "$(cat <<'JSON'
{"tool_name":"Write","tool_input":{"file_path":".claude/settings.json","content":"{}"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$u4_ptu_dir" \
  "ask-json"

run_case \
  "pre-tool-use-validator: Write to root CLAUDE.md asks" \
  ".claude/hooks/pre-tool-use-validator.sh" \
  "$(cat <<'JSON'
{"tool_name":"Write","tool_input":{"file_path":"CLAUDE.md","content":"# hi"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$u4_ptu_dir" \
  "ask-json"

# Split across two vars so this fixture file's own text never contains a
# contiguous AWS-key-shaped string (would false-positive this repo's own
# Trivy secret-scan CI job) — same precaution as 00-baseline.sh.
_u4_akid_prefix="AKIA"
_u4_akid_suffix="TESTTESTTESTTEST"
run_case \
  "pre-tool-use-validator: Bash heredoc writing an AWS-key-shaped string asks" \
  ".claude/hooks/pre-tool-use-validator.sh" \
  "$(cat <<JSON
{"tool_name":"Bash","tool_input":{"command":"cat > .env <<'EOF'\nAWS_KEY=${_u4_akid_prefix}${_u4_akid_suffix}\nEOF"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$u4_ptu_dir" \
  "ask-json"

run_case \
  "pre-tool-use-validator: ordinary source Write is unaffected (allowed, silent)" \
  ".claude/hooks/pre-tool-use-validator.sh" \
  "$(cat <<'JSON'
{"tool_name":"Write","tool_input":{"file_path":"src/u4-example.ts","content":"export const answer = 42;"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$u4_ptu_dir" \
  "exit0-silent"
