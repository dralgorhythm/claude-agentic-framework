#!/usr/bin/env bash
#
# skill-activation-hook.sh — deterministic skill-suggestion hook (UserPromptSubmit)
#
# WHAT IT DOES
#   Reads the UserPromptSubmit hook JSON payload from stdin, extracts the
#   user's prompt text, and scans every .claude/skills/*/SKILL.md (and one
#   level deeper: .claude/skills/*/*/SKILL.md) for its YAML frontmatter
#   `name:` and `description:` fields. It scores each skill by counting
#   whole-word, case-insensitive matches between prompt words (4+ chars)
#   and the skill's name + description, ranks skills by match count, and
#   prints at most the top 3 as a compact <skill-suggestions> block on
#   stdout — naming each skill's SKILL.md path so Claude can go read the
#   full file for details. There is NO separate registry file: the
#   frontmatter in each SKILL.md is the single source of truth.
#
# WHY THIS IS OPT-IN
#   Claude Code's native skill discovery (description-based matching baked
#   into the harness) is the default and requires no configuration. This
#   hook adds a second, deterministic layer of skill injection on top of
#   that — useful for teams that want guaranteed, reproducible suggestions
#   independent of model judgment. The cost is per-turn latency: this
#   script runs as a subprocess on every single prompt submission. Only
#   enable it if that tradeoff is worth it for your team.
#
# HOW TO ENABLE (opt-in — not wired by default)
#   Add the following to your .claude/settings.json:
#
#   {
#     "hooks": {
#       "UserPromptSubmit": [
#         {
#           "hooks": [
#             {
#               "type": "command",
#               "command": "$CLAUDE_PROJECT_DIR/docs/examples/skill-activation-hook.sh",
#               "timeout": 5
#             }
#           ]
#         }
#       ]
#     }
#   }
#
# DEPENDENCIES
#   None beyond coreutils (awk, sed, grep, tr, find). Uses jq to parse the
#   hook JSON if jq is present on PATH; otherwise falls back to a POSIX
#   sed-based extraction of the "prompt" field.
#
# FAIL-SOFT CONTRACT
#   Any unexpected condition (missing input, malformed JSON, no skills
#   directory, extraction failure, etc.) results in a silent `exit 0`
#   with no stdout output. This hook must never block or fail a prompt.

set -u

# --- Read stdin (the hook JSON payload) --------------------------------
input="$(cat 2>/dev/null)" || exit 0
[ -n "$input" ] || exit 0

# --- Extract the prompt text --------------------------------------------
prompt=""
if command -v jq >/dev/null 2>&1; then
    prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)"
fi

if [ -z "$prompt" ]; then
    # POSIX sed fallback: pull the value of the top-level "prompt" key.
    # Handles simple JSON strings; does not attempt full JSON parsing.
    prompt="$(printf '%s' "$input" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' 2>/dev/null | head -n 1)"
    # Unescape common JSON escapes.
    prompt="$(printf '%s' "$prompt" | sed 's/\\"/"/g; s/\\n/ /g; s/\\t/ /g' 2>/dev/null)"
fi

[ -n "$prompt" ] || exit 0

# --- Skip slash commands -------------------------------------------------
case "$prompt" in
    /*) exit 0 ;;
esac

# --- Locate the project root / skills directories ------------------------
project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
skills_dir="$project_dir/.claude/skills"
[ -d "$skills_dir" ] || exit 0

# --- Collect candidate SKILL.md files -------------------------------------
skill_files="$(find "$skills_dir" \
    -mindepth 2 -maxdepth 3 -type f -name 'SKILL.md' \
    2>/dev/null)"
[ -n "$skill_files" ] || exit 0

# --- Build the set of significant prompt words (4+ chars, lowercased) ----
prompt_words="$(printf '%s' "$prompt" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -c 'a-z0-9' ' ' \
    | tr -s ' ' '\n' \
    | awk 'length($0) >= 4' \
    | sort -u)"
[ -n "$prompt_words" ] || exit 0

# --- Score each skill ------------------------------------------------------
# For each SKILL.md: extract name/description from the frontmatter block
# (between the first pair of '---' lines), then count whole-word matches
# against the prompt words.
results_file="$(mktemp 2>/dev/null)" || exit 0
trap 'rm -f "$results_file"' EXIT

while IFS= read -r skill_file; do
    [ -n "$skill_file" ] || continue
    [ -r "$skill_file" ] || continue

    frontmatter="$(awk '
        /^---[[:space:]]*$/ { c++; if (c == 2) exit; next }
        c == 1 { print }
    ' "$skill_file" 2>/dev/null)"
    [ -n "$frontmatter" ] || continue

    name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)"
    description="$(printf '%s\n' "$frontmatter" | sed -n 's/^description:[[:space:]]*//p' | head -n 1)"
    [ -n "$name" ] || continue

    haystack="$(printf '%s %s' "$name" "$description" | tr '[:upper:]' '[:lower:]')"

    count=0
    while IFS= read -r word; do
        [ -n "$word" ] || continue
        case " $(printf '%s' "$haystack" | tr -c 'a-z0-9' ' ') " in
            *" $word "*) count=$((count + 1)) ;;
        esac
    done <<EOF
$prompt_words
EOF

    if [ "$count" -gt 0 ]; then
        printf '%s\t%s\t%s\n' "$count" "$name" "$skill_file" >> "$results_file"
    fi
done <<EOF
$skill_files
EOF

[ -s "$results_file" ] || exit 0

# --- Rank by match count desc, take top 3 ---------------------------------
top="$(sort -t "$(printf '\t')" -k1,1nr "$results_file" 2>/dev/null | head -n 3)"
[ -n "$top" ] || exit 0

# --- Emit the compact suggestion block -------------------------------------
{
    printf '<skill-suggestions>\n'
    while IFS="$(printf '\t')" read -r count name path; do
        [ -n "$name" ] || continue
        printf -- '- %s (matches: %s) — %s\n' "$name" "$count" "$path"
    done <<EOF2
$top
EOF2
    printf '</skill-suggestions>\n'
} 2>/dev/null

exit 0
