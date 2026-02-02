# MCP Servers

Model Context Protocol servers extend Claude's capabilities. The framework includes a curated set.

## Included Servers

### Sequential Thinking
Structured workspace for multi-step reasoning. Makes Claude's thought process visible and auditable.

**Best for:** Architecture decisions, debugging complex issues, planning

### Chrome DevTools
Browser automation with deep debugging — performance traces, network inspection, console access.

**Best for:** QA testing, frontend debugging, performance analysis

### GitHub
Direct integration with repositories — PRs, issues, commits, code search.

**Best for:** Code review workflows, issue management

**Requires:** `GITHUB_TOKEN` environment variable

### Context7
Up-to-date documentation and code examples for any library via Context7.

**Best for:** Researching library APIs, finding code examples, validating implementation patterns

## Setup

The servers are configured in `.mcp.json`. Most work out of the box.

### GitHub Token

Set your token for GitHub integration:

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

Or add to your shell profile (`~/.zshrc`, `~/.bashrc`).

## Adding More Servers

Edit `.mcp.json`:

```json
{
  "mcpServers": {
    "new-server": {
      "command": "npx",
      "args": ["@example/mcp-server"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

## Recommended Additions

| Server | Purpose | When to Add |
|--------|---------|-------------|
| PostgreSQL | Database queries | Working with Postgres |
| Brave Search | Web search | Research-heavy work |
| Slack | Team messaging | Team coordination |
| Linear | Issue tracking | If you use Linear |

### PostgreSQL Example

```json
"postgres": {
  "command": "npx",
  "args": ["@anthropic-ai/mcp-server-postgres"],
  "env": {
    "DATABASE_URL": "${DATABASE_URL}"
  }
}
```

## Not Included (and Why)

| Server | Reason |
|--------|--------|
| Memory | Redundant with claude-mem plugin |
| Puppeteer | Chrome DevTools is superior |
| Filesystem | Claude Code has built-in file tools |

## Troubleshooting

### Server not starting

Check logs:
```bash
claude mcp list
```

### GitHub auth failing

Verify token:
```bash
echo $GITHUB_TOKEN
gh auth status
```

### Permission denied

MCP servers run as your user. Check file permissions and API tokens.

## Resources

- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers)
- [MCP.so Directory](https://mcp.so/)

---

[← Back to README](../README.md)
