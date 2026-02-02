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
/product-manager user notifications
```
Claude writes a PR-FAQ and PRD in `artifacts/`.

```
/architect
```
Claude reads the PRD, designs the system, writes an ADR.

```
/builder
```
Claude implements it with tests.

```
/reviewer
```
Claude reviews for bugs and security issues.

Each step builds on the previous. Artifacts pass between personas automatically.

## What You Get

**9 Personas** — Switch expertise with slash commands
```
/architect       /builder          /product-manager
/reviewer        /qa-engineer      /refactoring-engineer
/sre             /security-auditor /ui-ux-designer
```

**4 Swarm Commands** — Orchestrate parallel agents
```
/swarm-plan      /swarm-execute    /swarm-review    /code-check
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