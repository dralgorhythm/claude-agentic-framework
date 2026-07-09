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

To pin to a known-good release: `git checkout vX.Y.Z` before running the script.

(Clone-then-run, deliberately — this framework's own permission rules deny pipe-to-shell installs, and its docs tell you to review scripts before executing them. Practice what we ship.)

The script will:
- Copy `.claude/` (skills, rules, hooks, agents, templates)
- Copy `.mcp.json` (MCP server configuration)
- Copy `CLAUDE.md` and `AGENTS.md` (project instructions)
- Create an `artifacts/` directory for planning documents
- Set up `.gitignore` entries

The script prompts before overwriting any existing files. To pull in framework updates, cd into your clone, git pull, then re-run the script. The framework is zero-install — no dependencies to fetch. New versions are announced on the GitHub Releases page.

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

This gets you the skills, the five worker agents, and the guardrail hooks, wired up automatically. It does **not** replace cloning the repo — it's a lighter-weight path with real gaps:

- **Skills are namespaced.** Invoke them as `/agentic-framework:architect`, `/agentic-framework:builder`, etc., not the bare `/architect` names used in the raw drop-in.
- **No `.claude/settings.json` permission rules ship with the plugin.** The `permissions.deny` guards for secrets, `.env*`, and other sensitive paths are repo-level configuration — a plugin install will not add them to your project. You get the hooks that warn/guard, but not the deny-layer enforcement described above.
- **No `.claude/rules/` ship with the plugin.** `tech-strategy.md`, `security.md`, `core-directives.md`, `agent-constraints.md`, and `code-quality.md` are repo-level files, not plugin content — they won't appear in your project via plugin install.
- **Plugin agents ignore `permissionMode` frontmatter.** Any per-agent permission mode set in an agent's frontmatter is not honored when the agent is loaded as a plugin agent.

If you need the full guardrail set (deny rules, rules directory, settings.json), use the raw drop-in instead — the plugin path trades completeness for a faster, in-session install.

Plugin content updates at each tagged release — run `/plugin update` to pull the latest; after updating, check `MIGRATION.md` for breaking changes.

For maintainers: validate packaging with `claude plugin validate --strict .` (marketplace) and `claude plugin validate .claude-plugin/plugin.json` (plugin — reports one expected warning that the repo-level `CLAUDE.md` is not loaded as plugin context; that is by design, per the caveats above).

This repo currently ships with no `LICENSE` file; nothing here should be read as a license grant.

## Why This Shape

Three findings anchor the design, dated because the evidence base moves:

- **Speed and stability correlate — they don't trade off.** Forsgren, Humble & Kim's *Accelerate* (2018) found this, and DORA's 2025 State of DevOps Report replicated it: teams that ship fast are also the teams whose systems stay stable. Under that model, quality gates (tests, linting, type checks, review) are throughput enablers, not a tax on speed — which is why this framework treats them as non-negotiable rather than optional.
- **AI amplifies whatever engineering discipline already exists.** DORA's 2025 report found AI adoption alone doesn't predict outcomes; it magnifies the discipline — or its absence — that was already there. This framework's rules, skills, and quality gates exist to give that amplification something good to amplify.
- **The anti-pattern this framework designs against**: big-batch, under-reviewed AI changesets. It's the mechanism DORA, GitClear, and the emerging agent-generated-PR research all converge on independently — large, unreviewed diffs are where speed and stability actually start trading off. Swarm orchestration's small-task decomposition and mandatory multi-perspective review exist specifically to keep AI-authored changes out of that failure mode.

## What You Get

### Commands

Single-agent expert modes, invoked via slash commands, backed by skills in `.claude/skills/`:

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

All 10 workflow skills — `/architect`, `/builder`, `/qa-engineer`, `/security-auditor`, `/ui-ux-designer`, `/code-check`, `/swarm-plan`, `/swarm-execute`, `/swarm-review`, and `/swarm-research` — carry `disable-model-invocation: true`: only a user typing the slash name can invoke them. The four role skills (`/architect`, `/qa-engineer`, `/security-auditor`, `/ui-ux-designer`) are thin entry points that delegate methodology to always-on library skills (e.g. `designing-systems`, `accessibility`) — Claude still reaches those on its own, so the underlying knowledge stays discoverable even though the role wrapper is gated.

### The Full Cycle

```
/architect <feature>  →  /swarm-plan  →  /swarm-execute  →  /swarm-review (2-3x)  →  PR
```

One agent thinks. Many agents build. Many agents review.

### Workers

Five specialized agent types tuned for cost and capability:

| Worker | Use |
|--------|-----|
| `worker-explorer` | Fast codebase search, web research, dependency mapping |
| `worker-builder` | Implementation, testing, refactoring |
| `worker-reviewer` | Code review, security analysis |
| `worker-research` | Deep multi-source investigation |
| `worker-architect` | Complex design decisions, ADRs |

Model tiers are pinned in each agent's frontmatter (`.claude/agents/`) — that is the single source of truth.

### Skills

14 skills across 6 categories — discovered natively from each skill's description, no hook or registry required:

**Architecture** · **Core Engineering** · **Design** · **Operations** · **Product** · **Security**

A deliberately lean catalog: high-value, single-responsibility skills that don't duplicate what the model already knows, from `designing-systems` and `debugging` to `swarm-coordination` and `application-security`. See [docs/skills.md](docs/skills.md) for the full list.

Catalog size is a defended design decision, not an oversight. Every skill's name and description loads into every session's context regardless of relevance, and the skill-listing context budget is shared across *everything* an adopter has installed — this framework's skills plus their own. Growing the catalog without discipline degrades discovery for every skill sharing that budget, including ones this repo didn't add. New skill proposals go through CONTRIBUTING.md's eval-first bar, not "this seems useful."

Measured 2026-07: after gating the 10 workflow skills (`disable-model-invocation: true`), only the 14 library skills are ungated and auto-discoverable, at roughly ~1.4k tokens of always-loaded listing — against a ~2k-token listing budget on 200K-context sessions (~10k on 1M-context sessions). Separately, CLAUDE.md (104 lines) plus `.claude/rules/` (409 lines) run roughly ~5k tokens of always-loaded instructions — a different budget line item from the skill listing. Both numbers move as the platform and catalog change; run `/doctor` to check for dropped or truncated skill descriptions and `/context` to see live context-window consumption on your own setup rather than trusting a static figure.

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
- [Changelog](CHANGELOG.md)
- [Migration guide](MIGRATION.md)
- [Releasing](docs/releasing.md)
