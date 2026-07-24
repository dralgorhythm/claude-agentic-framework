#!/usr/bin/env bash
# scripts/hook-tests.d/00-baseline.sh — characterization cases pinning the
# CURRENT behavior of the five hooks this framework-hardening plan touches
# next (artifacts/plan_framework_hardening.md, unit U15). These must pass
# against the *unmodified* hooks; a later unit changing one of these
# behaviors does so deliberately, by editing the case here, not by accident.
# Add new behavior in a new NN-name.sh file alongside this one.

# A throwaway CLAUDE_PROJECT_DIR isolates state-file/lock-file hooks
# (pre-commit-verification, stop-validator, pre-tool-use-validator all read
# or write .claude/hooks/.state or .locks under it) from this repo's own,
# genuinely-dirty-during-development working tree.
_fresh_dir() { mktemp -d "${TMPDIR:-/tmp}/hook-test-fixture.XXXXXX"; }

# --- pre-commit-verification.sh: advisory on git commit --------------------
commit_dir=$(_fresh_dir)
run_case \
  "pre-commit-verification: git commit emits advisory additionalContext" \
  ".claude/hooks/pre-commit-verification.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git commit -m \"wip\""}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$commit_dir" \
  "stdout-contains:PRE-COMMIT VERIFICATION REQUIRED"

# --- pre-push-main-blocker.sh: explicit push to main is denied -------------
run_case \
  "pre-push-main-blocker: explicit 'git push origin main' denied" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  "$(cat <<'JSON'
{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}
JSON
)" \
  "" \
  "deny-json"

# --- stop-validator.sh: silent on a clean tree ------------------------------
clean_repo=$(_fresh_dir)
git -C "$clean_repo" init -q >/dev/null 2>&1
git -C "$clean_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m init >/dev/null 2>&1
run_case \
  "stop-validator: silent (exit 0, no output) on a clean tree" \
  ".claude/hooks/stop-validator.sh" \
  "$(cat <<'JSON'
{"session_id":"test-session","stop_hook_active":false}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$clean_repo" \
  "exit0-silent"

# --- pre-tool-use-validator.sh: secret-shaped content asks; plain content allows
ptu_dir=$(_fresh_dir)
# Split across two vars so this fixture file's own text never contains a
# contiguous AWS-key-shaped string (would false-positive this repo's own
# Trivy secret-scan CI job).
_akid_prefix="AKIA"
_akid_suffix="TESTTESTTESTTEST"
run_case \
  "pre-tool-use-validator: Write with AWS-key-shaped content asks" \
  ".claude/hooks/pre-tool-use-validator.sh" \
  "$(cat <<JSON
{"tool_name":"Write","tool_input":{"file_path":"src/config.ts","content":"const key = \\"${_akid_prefix}${_akid_suffix}\\";"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$ptu_dir" \
  "ask-json"

run_case \
  "pre-tool-use-validator: ordinary Write is allowed (silent)" \
  ".claude/hooks/pre-tool-use-validator.sh" \
  "$(cat <<'JSON'
{"tool_name":"Write","tool_input":{"file_path":"src/example.ts","content":"export const answer = 42;"}}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$ptu_dir" \
  "exit0-silent"

# --- session-start-loader.sh: multi-agent count survives the ls->find fix --
ssl_dir=$(_fresh_dir)
mkdir -p "$ssl_dir/.claude/hooks/.state"
echo '{}' > "$ssl_dir/.claude/hooks/.state/session_aaaaaaaa.json"
run_case \
  "session-start-loader: counts multiple active-agent session files (SWARM STATUS)" \
  ".claude/hooks/session-start-loader.sh" \
  "$(cat <<'JSON'
{"source":"startup","session_id":"bbbbbbbb-0000-0000-0000-000000000000"}
JSON
)" \
  "CLAUDE_PROJECT_DIR=$ssl_dir" \
  "stdout-contains:Active agents in project: 2"

# --- fail-open: with jq absent, hooks exit 0 without blocking. Most stay
# silent; session-start-loader is the designated exception since U1 — it
# announces the degraded guardrail set (that IS its jq-absent behavior now).
nojq_path=$(path_without_jq)
for hook in \
  ".claude/hooks/pre-commit-verification.sh" \
  ".claude/hooks/pre-push-main-blocker.sh" \
  ".claude/hooks/stop-validator.sh" \
  ".claude/hooks/pre-tool-use-validator.sh"
do
  run_case \
    "fail-open: $hook exits 0 silently with jq absent" \
    "$hook" \
    '{}' \
    "PATH=$nojq_path" \
    "exit0-silent"
done

run_case \
  "fail-open: session-start-loader announces [HOOK DEGRADATION] with jq absent (U1)" \
  ".claude/hooks/session-start-loader.sh" \
  '{}' \
  "PATH=$nojq_path" \
  "stdout-contains:[HOOK DEGRADATION]"
