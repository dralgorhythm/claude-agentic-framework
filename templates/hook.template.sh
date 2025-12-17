#!/bin/bash
# Hook: [hook-name]
# Event: [PreToolUse|PostToolUse|UserPromptSubmit|Stop|SubagentStop|SessionStart|SessionEnd|Notification|PermissionRequest|PreCompact]
# Purpose: [Brief description of what this hook does]

set -e

# Read JSON input from stdin
INPUT=$(cat)

# ============================================================
# COMMON INPUT FIELDS (all events)
# ============================================================
#
# {
#   "session_id": "string",
#   "transcript_path": "string",
#   "cwd": "string",
#   "permission_mode": "default|plan|acceptEdits|bypassPermissions",
#   "hook_event_name": "string"
# }
#
# Environment variables:
#   CLAUDE_PROJECT_DIR - Root of the project
#   CLAUDE_ENV_FILE    - Path to env file (SessionStart only)
#
# ============================================================

# ============================================================
# INPUT SCHEMAS BY EVENT TYPE
# ============================================================
#
# PreToolUse:
#   { "tool_name": "Write|Edit|Bash|...", "tool_input": {...}, "tool_use_id": "..." }
#
# PostToolUse:
#   { "tool_name": "...", "tool_input": {...}, "tool_response": {...} }
#
# UserPromptSubmit:
#   { "prompt": "user message text" }
#
# Stop:
#   { "stop_hook_active": true }
#
# SubagentStop:
#   { "subagent_id": "...", "subagent_type": "..." }
#
# SessionStart:
#   { "source": "startup|resume|clear|compact" }
#
# SessionEnd:
#   { "reason": "clear|logout|prompt_input_exit|other" }
#
# Notification:
#   { "message": "...", "notification_type": "permission_prompt|idle_prompt|auth_success|elicitation_dialog" }
#
# PermissionRequest:
#   { "tool_name": "...", "tool_input": {...} }
#
# PreCompact:
#   { "trigger": "manual|auto", "custom_instructions": "..." }
#
# ============================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Parse common fields
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# ============================================================
# HOOK-SPECIFIC LOGIC EXAMPLES
# ============================================================

# For PreToolUse/PostToolUse:
# TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
# FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# For UserPromptSubmit:
# PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# For SessionStart:
# SOURCE=$(echo "$INPUT" | jq -r '.source // empty')

# ============================================================
# OUTPUT OPTIONS
# ============================================================
#
# 1. Silent success (continue normally):
#    exit 0
#
# 2. Block action (PreToolUse):
#    echo '{"hookSpecificOutput": {"permissionDecision": "deny"}}'
#
# 3. Allow action (PreToolUse):
#    echo '{"hookSpecificOutput": {"permissionDecision": "allow"}}'
#
# 4. Ask user (PreToolUse):
#    echo '{"hookSpecificOutput": {"permissionDecision": "ask", "permissionDecisionReason": "Why"}}'
#
# 5. Modify tool input (PreToolUse):
#    echo '{"hookSpecificOutput": {"updatedInput": {"file_path": "/new/path"}}}'
#
# 6. Block with reason (UserPromptSubmit/Stop/PostToolUse):
#    echo '{"hookSpecificOutput": {"decision": "block", "reason": "Why blocked"}}'
#
# 7. Add context (UserPromptSubmit/PostToolUse/SessionStart/PreCompact):
#    echo '{"hookSpecificOutput": {"additionalContext": "Extra info for Claude"}}'
#
# ============================================================

# Your logic here...

exit 0
