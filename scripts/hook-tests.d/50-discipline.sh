#!/usr/bin/env bash
# Cases for branch-pr-discipline.sh — specifically its no-jq sed fallback.
# Regression coverage for the BSD/macOS sed -E fix: with the old BRE \|
# alternation the fallback extracted nothing on macOS, silently disabling
# every warning this hook exists to give. GIT_DIR/GIT_WORK_TREE pin the
# hook's bare `git rev-parse` calls to a fixture repo regardless of the
# harness's own checkout (hermetic on any runner/branch).

bpd_repo=$(_fresh_dir)
git -C "$bpd_repo" init -q >/dev/null 2>&1
git -C "$bpd_repo" -c user.email=test@example.com -c user.name=test \
  commit -q --allow-empty -m init >/dev/null 2>&1
git -C "$bpd_repo" checkout -q -b feature/one >/dev/null 2>&1

bpd_nojq=$(path_without_jq)

run_case \
  "branch-pr-discipline: no-jq sed fallback extracts the command (stacking warning fires)" \
  ".claude/hooks/branch-pr-discipline.sh" \
  '{"tool_name":"Bash","tool_input":{"command":"git checkout -b feature/two"}}' \
  "PATH=$bpd_nojq GIT_DIR=$bpd_repo/.git GIT_WORK_TREE=$bpd_repo" \
  "stdout-contains:stacks work on an unmerged branch"

run_case \
  "branch-pr-discipline: non-branching command stays silent (no-jq path)" \
  ".claude/hooks/branch-pr-discipline.sh" \
  '{"tool_name":"Bash","tool_input":{"command":"git status"}}' \
  "PATH=$bpd_nojq GIT_DIR=$bpd_repo/.git GIT_WORK_TREE=$bpd_repo" \
  "exit0-silent"
