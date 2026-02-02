# Claude Agentic Framework

Specialized personas and reusable workflows for Claude Code.

## Install

```bash
cd your-project
curl -sSL https://raw.githubusercontent.com/dralgorhythm/claude-agentic-framework/main/scripts/init-framework.sh | bash -s .
```

Then start Claude Code: `claude`

## Try It

```
/builder fix the login bug
```

That's it. Claude adopts the Builder persona and works on your task.

## Example: Feature from Idea to Code

```
/architect user notifications
```
Claude designs the system and writes an ADR in `artifacts/`.

```
/builder
```
Claude implements it with tests.

```
/swarm-review
```
Claude reviews for bugs, security, and performance issues.

Each step builds on the previous. Artifacts pass between personas automatically.

## What You Get

**9 Personas** — Switch expertise with slash commands
```
/architect       /builder          /qa-engineer
/security-auditor /ui-ux-designer  /code-check
/swarm-plan      /swarm-execute    /swarm-review
```

**65+ Skills** — Auto-suggested based on what you ask
```
designing-systems, debugging, react-patterns, data-to-ui, ...
```

**Swarm Workers** — Parallel agents for big jobs

**MCP Servers** — Browser debugging, GitHub integration, structured reasoning, library docs

## After Install

1. Open `CLAUDE.md` and add your build/test commands
2. Check `artifacts/` after using personas — that's where docs land
3. **Required**: Edit `.claude/rules/tech-strategy.md` to match your tech stack

## Docs

- [Installation details](docs/getting-started.md)
- [MCP servers](docs/mcp-servers.md)
- [All personas](docs/personas.md)
- [Skills reference](docs/skills.md)
- [Multi-agent swarms](docs/swarm.md)
- [Customization](docs/customization.md)
- [Hooks](docs/hooks.md)
- [Handoffs](docs/handoffs.md)
- [Beads issue tracking](docs/beads.md)