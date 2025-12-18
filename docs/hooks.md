# Hooks

Hooks run automatically at key points in Claude Code's lifecycle.

## Built-in Hooks

| Event | Purpose |
|-------|---------|
| SessionStart | Load Beads status, check prerequisites |
| UserPromptSubmit | Suggest relevant skills |
| PreToolUse | File locking, secret detection, pre-commit checks |
| PostToolUse | Track file changes, sync with Beads |
| Stop | Release locks, cleanup |
| SubagentStop | Log swarm worker completion |

## Creating a Hook

1. Create `.claude/hooks/my-hook.sh`:

```bash
#!/bin/bash
input=$(cat)
# your logic
echo '{"continue": true}'
```

2. Make executable:
```bash
chmod +x .claude/hooks/my-hook.sh
```

3. Register in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/my-hook.sh",
        "timeout": 5
      }]
    }]
  }
}
```

## Input

Hooks receive JSON via stdin:

```json
{
  "session_id": "abc123",
  "cwd": "/workspace",
  "prompt": "user message",
  "tool_name": "Write",
  "tool_input": {}
}
```

## Output

```json
{
  "continue": true,
  "message": "Optional status message"
}
```

Set `"continue": false` to block a tool (PreToolUse only).

## Environment

| Variable | Value |
|----------|-------|
| `CLAUDE_PROJECT_DIR` | Project root |
| `CLAUDE_SESSION_ID` | Current session |

## Tips

- Keep hooks fast (< 5 seconds)
- Test with: `echo '{}' | ./my-hook.sh`
- See `.claude/hooks/*.ts` for TypeScript examples

---

[← Back to README](../README.md)
