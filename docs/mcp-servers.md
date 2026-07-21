# MCP Servers

Model Context Protocol servers extend Claude's capabilities. The framework includes a curated set.

## Included Servers

### Sequential Thinking
Structured workspace for multi-step reasoning. Makes Claude's thought process visible and auditable.

**Best for:** Architecture decisions, debugging complex issues, planning

### Chrome DevTools
Browser automation with deep debugging — performance traces, network inspection, console access.

**Best for:** QA testing, frontend debugging, performance analysis

### Context7
Up-to-date documentation and code examples for any library via Context7.

**Best for:** Researching library APIs, finding code examples, validating implementation patterns

### Filesystem
File system operations beyond the workspace boundary.

**Best for:** Cross-project file access, operations outside the working directory

## Setup

The servers are configured in `.mcp.json`. Most work out of the box.

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
| GitHub | PRs, issues, code search | GitHub-heavy workflows (requires `GITHUB_PERSONAL_ACCESS_TOKEN`) |
| PostgreSQL | Database queries | Working with Postgres |
| Brave Search | Web search | Research-heavy work |
| Slack | Team messaging | Team coordination |
| Linear | Issue tracking | If you use Linear |

### GitHub Example

```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
  }
}
```

## Troubleshooting

### Server not starting

Check logs:
```bash
claude mcp list
```

### Permission denied

MCP servers run as your user. Check file permissions and API tokens.

## Resources

- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers)
- [MCP.so Directory](https://mcp.so/)

---

[← Back to README](../README.md)
