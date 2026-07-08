# Claude Agentic Framework

A drop-in template for Claude Code projects. Adds coordinated multi-agent swarms, specialized workflow skills, 14 reusable knowledge skills, and safety hooks — all configured through a single install command.

## Two ways to adopt

### (a) Raw drop-in — recommended, full-featured

Clone or copy the repo's files directly into your project. This is the only path that gives you everything: skills, agents, hooks, `.claude/settings.json` permission rules (including the `permissions.deny` secret-file guards), and `.claude/rules/` (tech strategy, security standards, core directives).

```bash
git clone https://github.com/dralgorhythm/claude-agentic-framework.git
cd your-project
../claude-agentic-framework/scripts/init-framework.sh .
```

(Clone-then-run, deliberately — this framework's own permission rules deny pipe-to-shell installs, and its docs tell you to review scripts before executing them. Practice what we ship.)

The script will:
- Copy `.claude/` (skills, rules, hooks, agents, templates)
- Copy `.mcp.json` (MCP server configuration)
- Copy `CLAUDE.md` and `AGENTS.md` (project instructions)
- Create an `artifacts/` directory for planning documents
- Set up `.gitignore` entries

The script prompts before overwriting any existing files. Re-run it to pull in framework updates. The framework is zero-install — no dependencies to fetch.

**After install:**

1. **Edit `CLAUDE.md`** — Add your build/test commands and project context
2. **Edit `.claude/rules/tech-strategy.md`** — Configure your tech stack (this is required — the framework enforces whatever you put here)
3. Start Claude Code and try: `/architect hello`

### (b) Plugin install — skills, agents, and hooks only

Install directly inside a Claude Code session, no cloning required:

```
/plugin marketplace add dralgorhythm/claude-agentic-framework
/plugin install agentic-framework@agentic-framework
```

This gets you the skills, the six worker agents, and the guardrail hooks, wired up automatically. It does **not** replace cloning the repo — it's a lighter-weight path with real gaps:

- **Skills are namespaced.** Invoke them as `/agentic-framework:architect`, `/agentic-framework:builder`, etc., not the bare `/architect` names used in the raw drop-in.
- **No `.claude/settings.json` permission rules ship with the plugin.** The `permissions.deny` guards for secrets, `.env*`, and other sensitive paths are repo-level configuration — a plugin install will not add them to your project. You get the hooks that warn/guard, but not the deny-layer enforcement described above.
- **No `.claude/rules/` ship with the plugin.** `tech-strategy.md`, `security.md`, `core-directives.md`, `agent-constraints.md`, and `code-quality.md` are repo-level files, not plugin content — they won't appear in your project via plugin install.
- **Plugin agents ignore `permissionMode` frontmatter.** Any per-agent permission mode set in an agent's frontmatter is not honored when the agent is loaded as a plugin agent.

If you need the full guardrail set (deny rules, rules directory, settings.json), use the raw drop-in instead — the plugin path trades completeness for a faster, in-session install.

For maintainers: validate packaging with `claude plugin validate --strict .` (marketplace) and `claude plugin validate .claude-plugin/plugin.json` (plugin — reports one expected warning that the repo-level `CLAUDE.md` is not loaded as plugin context; that is by design, per the caveats above).

This repo currently ships with no `LICENSE` file; nothing here should be read as a license grant.

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
