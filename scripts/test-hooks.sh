#!/usr/bin/env bash
# scripts/test-hooks.sh — table-driven behavior runner for .claude/hooks/*.sh.
#
# Every behavioral claim about a hook (deny / ask / silent-allow / advisory
# text / fail-open when jq is absent) gets a case here instead of living only
# in a comment or a plan doc. Extend this harness by adding a new
# scripts/hook-tests.d/NN-name.sh file that calls run_case (below) — never by
# editing this file's flow (open/closed). Mirrors check-invariants.sh's own
# report()/PASS-FAIL idiom so both harnesses read the same way.
#
# Usage:  ./scripts/test-hooks.sh                          # run every case
#         SKIP="<exact case name>" ./scripts/test-hooks.sh  # skip one case
#
# Exits non-zero if any non-skipped case fails.

# shellcheck disable=SC2329  # report/skipped/run_case/path_without_jq are a library
# for scripts/hook-tests.d/*.sh, called only after being source'd at runtime — invisible
# to shellcheck's static reachability analysis of this file in isolation.
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 1
FAIL=0
SKIP="${SKIP:-}"
CASES_DIR="scripts/hook-tests.d"

# Resolved once, via the harness's own unmodified PATH — a case's env_override
# (below) must only change what the *hook* sees (e.g. no jq reachable), never
# whether this harness can still find bash to run it.
BASH_BIN=$(command -v bash)

skipped() { case " $SKIP " in *" $1 "*) return 0;; *) return 1;; esac; }
report() { # $1=case $2=status(0 pass) $3=detail
  if skipped "$1"; then echo "SKIP  $1"; return; fi
  if [ "$2" -eq 0 ]; then echo "PASS  $1"; else echo "FAIL  $1 — ${3:-}"; FAIL=1; fi
}

# path_without_jq: symlinks every executable on PATH into a fresh temp dir,
# skipping jq itself. Pass the result as a case's env_override
# ("PATH=$(path_without_jq)") to prove a hook's fail-open path when jq is
# genuinely unreachable — not just "we didn't call it". First match wins (no
# -f on the symlink) so ordinary PATH precedence is preserved across dupes.
path_without_jq() {
  local shim dir base name
  shim=$(mktemp -d "${TMPDIR:-/tmp}/hook-test-nojq.XXXXXX")
  local -a dirs
  IFS=':' read -ra dirs <<< "$PATH"
  for dir in "${dirs[@]}"; do
    [ -d "$dir" ] || continue
    for base in "$dir"/*; do
      [ -x "$base" ] || continue
      name=$(basename "$base")
      [ "$name" = "jq" ] && continue
      ln -s "$base" "$shim/$name" 2>/dev/null
    done
  done
  printf '%s' "$shim"
}

# run_case: the harness's one extension point.
#   $1 name          human-readable case name (also the SKIP key)
#   $2 hook          hook path, repo-root-relative (e.g. .claude/hooks/x.sh)
#   $3 stdin_json    JSON payload piped to the hook's stdin (build via heredoc)
#   $4 env_override  optional "KEY=VAL KEY2=VAL2" pairs (env(1) syntax), or ""
#                    to inherit the harness's own environment unchanged
#   $5 expectation   one of:
#                      deny-json            permissionDecision:"deny" present
#                      ask-json             permissionDecision:"ask" present
#                      exit0-silent         exit 0 AND empty stdout
#                      stdout-empty         empty stdout (exit code ignored)
#                      stdout-contains:SUB  stdout contains literal SUB
run_case() {
  local name="$1" hook="$2" stdin_json="$3" env_override="$4" expectation="$5"
  local out rc ok=1 reason=""
  # shellcheck disable=SC2086  # deliberate word-split: "KEY=VAL ..." pairs for env(1), or empty
  out=$(printf '%s' "$stdin_json" | env $env_override "$BASH_BIN" "$hook" 2>/dev/null)
  rc=$?
  case "$expectation" in
    deny-json)
      printf '%s' "$out" | grep -qE '"permissionDecision"[[:space:]]*:[[:space:]]*"deny"' && ok=0 ;;
    ask-json)
      printf '%s' "$out" | grep -qE '"permissionDecision"[[:space:]]*:[[:space:]]*"ask"' && ok=0 ;;
    exit0-silent)
      [ "$rc" -eq 0 ] && [ -z "$out" ] && ok=0 ;;
    stdout-empty)
      [ -z "$out" ] && ok=0 ;;
    stdout-contains:*)
      printf '%s' "$out" | grep -qF -- "${expectation#stdout-contains:}" && ok=0 ;;
    *)
      reason="unrecognized expectation '$expectation'" ;;
  esac
  reason="${reason:-exit=$rc output=$(printf '%s' "$out" | tr '\n' ' ' | cut -c1-200)}"
  report "$name" "$ok" "$reason"
}

# Auto-source every case file — adding cases never means editing this file.
if [ -d "$CASES_DIR" ]; then
  for f in "$CASES_DIR"/*.sh; do
    [ -f "$f" ] || continue
    # shellcheck source=/dev/null
    source "$f"
  done
else
  echo "FAIL  hook-tests.d missing: $CASES_DIR"
  FAIL=1
fi

echo ""
[ "$FAIL" -eq 0 ] && echo "ALL HOOK TESTS GREEN" || echo "HOOK TEST FAILURES PRESENT"
exit "$FAIL"
