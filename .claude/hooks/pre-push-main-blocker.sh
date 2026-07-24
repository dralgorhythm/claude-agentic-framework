#!/bin/bash
# Hook: pre-push-main-blocker
# Event: PreToolUse (Bash)
# Purpose: Block pushing directly to main branch
#
# Rules:
# - Commits on main: ALLOWED (may commit)
# - Push to non-main branches: ALLOWED
# - Push to main: BLOCKED
#
# No jq dependency: the two fields this hook reads (.tool_name,
# .tool_input.command) are both flat JSON strings, so the field-scoped sed
# idiom used by branch-pr-discipline.sh extracts them precisely — never by
# substring-matching the raw JSON blob. This also closes the old fail-open
# gap where an absent jq skipped the whole hook, including the implicit
# "bare `git push` while on main" case that permissions.deny cannot express
# (it has no literal branch name in a bare push to pattern-match against).

payload="$(cat 2>/dev/null || true)"
[ -z "$payload" ] && exit 0

# extract_json_field: prints the string value of a flat "field":"value" pair
# in $payload (e.g. tool_name, or tool_input's leaf key "command"), or empty
# if absent. Handles JSON-escaped characters inside the value via the
# (...|\\.) alternation — same field-scoped idea as branch-pr-discipline.sh's
# command extraction, generalized to a field name and written with `sed -E`
# (extended regex) rather than backslash-escaped BRE groups/alternation:
# BSD/macOS sed's BRE mode does not support `\|` as alternation (it free
# passes as a literal pipe), so the exact BRE form silently extracts nothing
# there — `-E` is portable across both BSD and GNU sed.
extract_json_field() { # $1=field name
    printf '%s' "$payload" | sed -nE 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' | head -n1
}

TOOL_NAME=$(extract_json_field tool_name)
COMMAND=$(extract_json_field command)

# Only process Bash tool
[ "$TOOL_NAME" != "Bash" ] && exit 0

# Only check git push commands
echo "$COMMAND" | grep -qE '\bgit\s+push\b' || exit 0

# Current branch — -C defaults to "." (a real invocation's cwd is already the
# project dir); the explicit path lets tests point this at a throwaway
# fixture repo without changing this process's own cwd.
CURRENT_BRANCH=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

IS_PUSH_TO_MAIN=false
DENY_REASON=""

# Trailing positional token after `git push` — the destination-branch
# position in ordinary `git push [opts] [remote [refspec]]` usage — compared
# for EQUALITY, never substring/word-boundary, against main/master. A
# word-boundary match (the previous approach) also matches "main" inside
# branch names like `feature/main-cleanup` or `domain-master-list`, which is
# the reproduced false positive this rewrite fixes.
push_args="${COMMAND#*git push}"
read -ra _tokens <<< "$push_args"
positional=()
for tok in "${_tokens[@]}"; do
    case "$tok" in
        -*) continue ;;
        *) positional+=("$tok") ;;
    esac
done

if [ "${#positional[@]}" -ge 2 ]; then
    # Explicit remote + ref given: the ref is the destination. A `src:dst`
    # refspec names the destination after the colon.
    dest="${positional[${#positional[@]}-1]}"
    case "$dest" in
        *:*) dest="${dest##*:}" ;;
    esac
    if [ "$dest" = "main" ] || [ "$dest" = "master" ]; then
        IS_PUSH_TO_MAIN=true
        DENY_REASON="explicit push to $dest"
    fi
elif [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    # Bare/implicit push (no explicit remote+ref pair): git pushes the
    # current branch via its configured upstream (or push.default=simple).
    IS_PUSH_TO_MAIN=true
    DENY_REASON="implicit push of current branch '$CURRENT_BRANCH'"
fi

if [ "$IS_PUSH_TO_MAIN" = true ]; then
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "BLOCKED: Cannot push directly to main branch ($DENY_REASON). Trunk-based development requires:\\n\\n1. Create a feature branch: git checkout -b feature/your-change\\n2. Commit your changes on the branch\\n3. Push the branch: git push -u origin feature/your-change\\n4. Create a PR for review\\n\\nCurrent branch: $CURRENT_BRANCH"
  }
}
EOF
    exit 0
fi

exit 0
