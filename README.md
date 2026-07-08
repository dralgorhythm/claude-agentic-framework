# Claude Agentic Framework

A drop-in template for Claude Code projects. Adds coordinated multi-agent swarms, specialized workflow skills, 14 reusable knowledge skills, and safety hooks — all configured through a single install command.

## Install

Run this inside your project directory:

```bash
cd your-project
curl -sSL https://raw.githubusercontent.com/dralgorhythm/claude-agentic-framework/main/scripts/init-framework.sh | bash -s .
```

The script will:
- Copy `.claude/` (skills, rules, hooks, agents, templates)
- Copy `.mcp.json` (MCP server configuration)
- Copy `CLAUDE.md` and `AGENTS.md` (project instructions)
- Create an `artifacts/` directory for planning documents
- Set up `.gitignore` entries

The script prompts before overwriting any existing files. Re-run it to pull in framework updates. The framework is zero-install — no dependencies to fetch.

## After Install

1. **Edit `CLAUDE.md`** — Add your build/test commands and project context
2. **Edit `.claude/rules/tech-strategy.md`** — Configure your tech stack (this is required — the framework enforces whatever you put here)
3. Start Claude Code and try: `/architect hello`

## What You Get

### Commands

Single-agent expert modes, invoked via slash commands, backed by model-invocable skills in `.claude/skills/`:

| Command | Role |
|---------|------|
| `/architect` | System design, ADRs |
| `/builder` | Implementation, debugging, testing |
| `/qa-engineer` | Test strategy, E2E, accessibility |
| `/security-auditor` | Threat modeling, security audits |
| `/ui-ux-designer` | Interface design, visual assets |
| `/code-check` | SOLID, DRY, consistency audit |

### Swarm Orchestrators

Multi-agent commands that fan work out across parallel workers:

| Command | What It Does |
|---------|-------------|
| `/swarm-plan` | Launches 3-6 explorer agents to research patterns, dependencies, and constraints — produces a decomposed plan |
| `/swarm-execute` | Picks up planned work, fans out across builder agents (up to 8 parallel), each running quality gates |
| `/swarm-review` | Launches 5 parallel reviewers (security, performance, architecture, tests, quality) — run 2-3 times |
| `/swarm-research` | Deep multi-source investigation with verification tiers |

`/builder`, `/swarm-execute`, `/swarm-plan`, `/swarm-review`, `/swarm-research`, and `/code-check` are side-effecting and carry `disable-model-invocation: true` — only a user typing the slash name can invoke them. `/architect`, `/qa-engineer`, `/security-auditor`, and `/ui-ux-designer` are advisory and stay model-invocable, so Claude can also reach for them on its own.

### The Full Cycle

```
/architect <feature>  →  /swarm-plan  →  /swarm-execute  →  /swarm-review (2-3x)  →  PR
```

One agent thinks. Many agents build. Many agents review.

### Workers

Six specialized agent types tuned for cost and capability:

| Worker | Model | Use |
|--------|-------|-----|
| `worker-explorer` | Haiku | Fast codebase search, dependency mapping |
| `worker-builder` | Sonnet | Implementation, testing, refactoring |
| `worker-reviewer` | Opus | Code review, security analysis |
| `worker-researcher` | Sonnet | Quick web research, API docs |
| `worker-research` | Opus | Deep multi-source investigation |
| `worker-architect` | Opus | Complex design decisions, ADRs |

### Skills

14 skills across 6 categories — discovered natively from each skill's description, no hook or registry required:

**Architecture** · **Core Engineering** · **Design** · **Operations** · **Product** · **Security**

A deliberately lean catalog: high-value, single-responsibility skills that don't duplicate what the model already knows, from `designing-systems` and `debugging` to `swarm-coordination` and `application-security`. See [docs/skills.md](docs/skills.md) for the full list.

### Safety Hooks

Pre-configured hooks that run automatically:

- **Secret detection** — blocks commits containing API keys, tokens, private keys
- **Protected files** — prevents accidental modification of `.env`, `.mcp.json`
- **Push blocking** — stops direct pushes to `main`/`master`
- **Dangerous command guard** — warns on `rm -rf`, force push, `terraform destroy`
- **File locking** — prevents concurrent edits in multi-agent swarms

What ships enabled: format, warn, and guard hooks, all fail-soft (a missing `jq` or unparseable input skips the check rather than blocking). Secret-bearing paths and destructive commands are denied at the permission layer (`permissions.deny`), not just warned about by a hook. See [docs/hooks.md#security-model](docs/hooks.md#security-model) for what hooks can and cannot guarantee.

### MCP Servers

Four servers pre-configured in `.mcp.json`:

| Server | Purpose |
|--------|---------|
| Sequential Thinking | Structured multi-step reasoning |
| Chrome DevTools | Browser testing, performance profiling |
| Context7 | Up-to-date library documentation |
| Filesystem | File operations beyond workspace |

## Customization

Everything is designed to be extended:

- Add command-style skills → `.claude/skills/your-skill/SKILL.md` (add `disable-model-invocation: true` for side-effecting workflows)
- Add skills → `.claude/skills/category/your-skill/SKILL.md`
- Add rules → `.claude/rules/your-rule.md`
- Add hooks → `.claude/hooks/your-hook.sh`
- Add workers → `.claude/agents/worker-yourtype.md`

Templates for each are in `.claude/templates/`.

See [docs/customization.md](docs/customization.md) for details.

## Docs

- [Getting started](docs/getting-started.md)
- [Multi-agent swarms](docs/swarm.md)
- [Commands](docs/commands.md)
- [Skills reference](docs/skills.md)
- [MCP servers](docs/mcp-servers.md)
- [Hooks](docs/hooks.md)
- [Handoffs](docs/handoffs.md)
- [Task tracking](CLAUDE.md#task-tracking)
- [Customization](docs/customization.md)
