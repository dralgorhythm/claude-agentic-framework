#!/usr/bin/env bash
#
# branch-pr-discipline.sh
#
# Purpose:
#   Warn (never block) about two common git/gh workflow pitfalls before a
#   Bash tool call runs:
#     (a) creating a new branch while already on a non-main/master feature
#         branch (branch stacking)
#     (b) running `gh pr create` on a branch that already has an open PR
#         (duplicate PR)
#
# Event: PreToolUse, matcher: Bash
#
# Wiring snippet (settings.json):
#   {
#     "hooks": {
#       "PreToolUse": [
#         {
#           "matcher": "Bash",
#           "hooks": [
#             { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/branch-pr-discipline.sh" }
#           ]
#         }
#       ]
#     }
#   }
#
# Contract:
#   - Reads the PreToolUse hook JSON payload from stdin.
#   - Extracts .tool_input.command (jq if available, sed fallback).
#   - WARN-ONLY: always exits 0. Never blocks the tool call.
#   - No dependency assumed beyond coreutils/git. jq and gh are optional,
#     guarded by `command -v`.

set -u

trap 'exit 0' EXIT

payload="$(cat 2>/dev/null || true)"
[ -z "$payload" ] && exit 0

# --- extract .tool_input.command --------------------------------------------
cmd=""
if command -v jq >/dev/null 2>&1; then
    cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
    cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -n1)"
fi

[ -z "${cmd:-}" ] && exit 0

# Only makes sense inside a git repo.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
[ -z "$current_branch" ] && exit 0

# --- (a) branch stacking warning --------------------------------------------
# Matches: git checkout -b <name>  /  git switch -c <name>
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+checkout[[:space:]]+.*-b([[:space:]]|$)' \
    || printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+switch[[:space:]]+.*-c([[:space:]]|$)'; then
    case "$current_branch" in
        main|master) ;;
        *)
            echo "WARNING: creating a new branch from '$current_branch' (not main/master) stacks work on an unmerged branch."
            ;;
    esac
fi

# --- (b) duplicate PR warning ------------------------------------------------
if printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+create'; then
    if command -v gh >/dev/null 2>&1; then
        if gh pr view --json number >/dev/null 2>&1; then
            echo "WARNING: an open PR already exists for branch '$current_branch' — 'gh pr create' may create a duplicate."
        fi
    fi
fi

exit 0
