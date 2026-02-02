# Claude Agentic Framework

Parallel agent swarms for Claude Code. Ship features faster with coordinated multi-agent workflows.

## Install

```bash
cd your-project
curl -sSL https://raw.githubusercontent.com/dralgorhythm/claude-agentic-framework/main/scripts/init-framework.sh | bash -s .
```

Then start Claude Code: `claude`

## The Swarm Workflow

The fastest way to go from idea to shipped code. One agent thinks, then many agents build.

### 1. Research — Single agent, deep thinking

Use a persona to explore the problem space and draft your planning prompt:

```
/product-manager user notifications
/architect redesign the auth system
```

This produces artifacts (PR-FAQs, PRDs, ADRs) that feed the next step.

### 2. Plan — Parallel exploration

```
/architect user notifications
```
Claude designs the system and writes an ADR in `artifacts/`.
/swarm-plan implement user notifications per the PRD
```

Launches 3-6 explorer agents in parallel. They research existing patterns, dependencies, and constraints simultaneously, then produce a decomposed plan tracked as Beads.

### 3. Execute — Parallel implementation

```
/swarm-execute
```

Picks up the planned work and fans out across multiple builder agents. Each worker claims a task, implements it, runs quality gates (tests, lint, types, build), and pushes to remote. Up to 8 workers in parallel.

### 4. Review — Adversarial, multi-pass

```
/swarm-review    # run 2-3 times
```

Each pass launches 5 parallel reviewers covering different perspectives: security (OWASP Top 10), performance, architecture, test coverage, and code quality. Repeat until clean. Then ship the PR.

### Full cycle

```
/swarm-review
```
Claude reviews for bugs, security, and performance issues.
/product-manager <feature>  →  /swarm-plan  →  /swarm-execute  →  /swarm-review (2-3x)  →  PR
```

## Swarm Workers

Eight specialized agent types, each tuned for cost and capability:

| Worker | Model | Use |
|--------|-------|-----|
| `worker-explorer` | Haiku | Fast codebase search |
| `worker-builder` | Sonnet | Implementation |
| `worker-reviewer` | Sonnet | Code review |
| `worker-tester` | Sonnet | Test writing |
| `worker-researcher` | Sonnet | Web research |
| `worker-architect` | Opus | Complex design decisions |
| `worker-security` | Sonnet | Security analysis |
| `worker-refactor` | Sonnet | Code cleanup |

Haiku for read-only exploration. Sonnet for most work. Opus only for hard architectural calls.

## Personas

For single-agent work, ideation, and research:

```
/architect       /builder          /qa-engineer
/security-auditor /ui-ux-designer  /code-check
/swarm-plan      /swarm-execute    /swarm-review
```

**65+ Skills** — Auto-suggested based on what you ask
```
designing-systems, debugging, react-patterns, data-to-ui, ...
```
/architect       /builder          /product-manager
/reviewer        /qa-engineer      /refactoring-engineer
/sre             /security-auditor /ui-ux-designer
```

Personas produce artifacts in `artifacts/` that chain naturally into swarm workflows.

## Also Included

- **65+ Skills** — Auto-suggested based on context (designing-systems, debugging, react-patterns, ...)
- **Beads** — Lightweight issue tracking that coordinates swarm workers via git
- **MCP Servers** — Browser debugging, GitHub integration, structured reasoning, library docs
- **`/code-check`** — Holistic codebase audit for SOLID, DRY, consistency

## After Install

1. Open `CLAUDE.md` and add your build/test commands
2. **Required**: Edit `.claude/rules/tech-strategy.md` to match your tech stack
3. Try the swarm workflow on your next feature

## Docs

- [Installation details](docs/getting-started.md)
- [Multi-agent swarms](docs/swarm.md)
- [All personas](docs/personas.md)
- [Skills reference](docs/skills.md)
- [Beads issue tracking](docs/beads.md)
- [MCP servers](docs/mcp-servers.md)
- [Customization](docs/customization.md)
- [Hooks](docs/hooks.md)
- [Handoffs](docs/handoffs.md)