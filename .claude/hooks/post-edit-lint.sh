#!/usr/bin/env bash
#
# post-edit-lint.sh
#
# Purpose:
#   Auto-format/lint a file immediately after Claude edits or writes it,
#   using whatever formatter the project already declares (detected via
#   project marker files). Fully silent on the happy path; if a formatter
#   still reports unfixable issues after auto-fix, print a short excerpt
#   so the model can see and address them.
#
# Event: PostToolUse, matcher: Edit|MultiEdit|Write
#
# Wiring snippet (settings.json):
#   {
#     "hooks": {
#       "PostToolUse": [
#         {
#           "matcher": "Edit|MultiEdit|Write",
#           "hooks": [
#             { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-edit-lint.sh" }
#           ]
#         }
#       ]
#     }
#   }
#
# Contract:
#   - Reads the PostToolUse hook JSON payload from stdin.
#   - Extracts .tool_input.file_path (jq if available, sed fallback).
#   - Never blocks the agent: always exits 0, no matter what happens.
#   - No dependency assumed beyond coreutils. jq/npx/ruff/gofmt/rustfmt
#     are all optional; every invocation is guarded by `command -v`
#     (or --no-install for npx) so absence is a silent no-op.
#
# Formatter detection (by project marker, first match wins):
#   biome.json | biome.jsonc            -> npx --no-install @biomejs/biome check --write <file>   (js/ts/jsx/tsx/json)
#   .prettierrc* | "prettier" in package.json -> npx --no-install prettier --write <file>
#   ruff.toml | [tool.ruff] in pyproject.toml -> ruff format <file> && ruff check --fix <file>     (.py)
#   *.go                                -> gofmt -w <file>
#   *.rs                                -> rustfmt <file>

set -u

# Always succeed from the hook's perspective; never block the tool call.
trap 'exit 0' EXIT

payload="$(cat 2>/dev/null || true)"
[ -z "$payload" ] && exit 0

# --- extract .tool_input.file_path -----------------------------------------
file_path=""
if command -v jq >/dev/null 2>&1; then
    file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
else
    # Minimal fallback: pull the first "file_path":"..." value out of the JSON.
    file_path="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

[ -z "${file_path:-}" ] && exit 0
[ -f "$file_path" ] || exit 0

# --- resolve project dir ----------------------------------------------------
project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"

# Resolve to absolute paths for a reliable prefix check.
abs_file="$(cd "$(dirname "$file_path")" 2>/dev/null && pwd -P)/$(basename "$file_path")"
abs_project="$(cd "$project_dir" 2>/dev/null && pwd -P)"

[ -z "$abs_file" ] && exit 0
[ -z "$abs_project" ] && exit 0

case "$abs_file" in
    "$abs_project"/*) ;;
    *) exit 0 ;;
esac

# --- skip noisy / vendored paths --------------------------------------------
case "$abs_file" in
    */node_modules/*|*/dist/*|*/build/*|*/.git/*|*/vendor/*) exit 0 ;;
esac

# --- extension check ---------------------------------------------------------
ext="${abs_file##*.}"
case "$ext" in
    js|jsx|ts|tsx|json|py|go|rs) ;;
    *) exit 0 ;;
esac

# --- capture formatter output, print at most 8 lines on failure ------------
run_and_report() {
    # remaining args = command to run (no label argument)
    out="$("$@" 2>&1)"
    status=$?
    if [ $status -ne 0 ] && [ -n "$out" ]; then
        printf '%s\n' "$out" | head -n 8
    fi
    return 0
}

did_format=0

# 1) Biome
if [ -f "$project_dir/biome.json" ] || [ -f "$project_dir/biome.jsonc" ]; then
    case "$ext" in
        js|jsx|ts|tsx|json)
            if command -v npx >/dev/null 2>&1; then
                run_and_report npx --no-install @biomejs/biome check --write "$abs_file"
                did_format=1
            fi
            ;;
    esac
fi

# 2) Prettier
if [ "$did_format" -eq 0 ]; then
    has_prettier_marker=0
    for f in "$project_dir"/.prettierrc "$project_dir"/.prettierrc.*; do
        [ -f "$f" ] && has_prettier_marker=1
    done
    if [ -f "$project_dir/package.json" ] && grep -q '"prettier"' "$project_dir/package.json" 2>/dev/null; then
        has_prettier_marker=1
    fi
    if [ "$has_prettier_marker" -eq 1 ]; then
        case "$ext" in
            js|jsx|ts|tsx|json)
                if command -v npx >/dev/null 2>&1; then
                    run_and_report npx --no-install prettier --write "$abs_file"
                    did_format=1
                fi
                ;;
        esac
    fi
fi

# 3) Ruff
if [ "$did_format" -eq 0 ] && [ "$ext" = "py" ]; then
    has_ruff_marker=0
    [ -f "$project_dir/ruff.toml" ] && has_ruff_marker=1
    if [ -f "$project_dir/pyproject.toml" ] && grep -q '\[tool\.ruff\]' "$project_dir/pyproject.toml" 2>/dev/null; then
        has_ruff_marker=1
    fi
    if [ "$has_ruff_marker" -eq 1 ] && command -v ruff >/dev/null 2>&1; then
        run_and_report ruff format "$abs_file"
        run_and_report ruff check --fix "$abs_file"
        did_format=1
    fi
fi

# 4) gofmt
if [ "$did_format" -eq 0 ] && [ "$ext" = "go" ]; then
    if command -v gofmt >/dev/null 2>&1; then
        run_and_report gofmt -w "$abs_file"
        did_format=1
    fi
fi

# 5) rustfmt
if [ "$did_format" -eq 0 ] && [ "$ext" = "rs" ]; then
    if command -v rustfmt >/dev/null 2>&1; then
        run_and_report rustfmt "$abs_file"
        did_format=1
    fi
fi

exit 0
