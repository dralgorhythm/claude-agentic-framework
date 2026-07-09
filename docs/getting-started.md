# Getting Started

## Install

```bash
git clone https://github.com/dralgorhythm/claude-agentic-framework.git
cd your-project
../claude-agentic-framework/scripts/init-framework.sh .
```

To pin to a known-good release: `git checkout vX.Y.Z` before running the script.

The script copies the framework files and prompts before overwriting anything. The framework is zero-install — no dependencies to fetch.

## Manual Install

```bash
git clone https://github.com/dralgorhythm/claude-agentic-framework.git
cp -r claude-agentic-framework/.claude your-project/
cp claude-agentic-framework/.mcp.json your-project/
cp claude-agentic-framework/CLAUDE.md your-project/
cp claude-agentic-framework/AGENTS.md your-project/
mkdir -p your-project/artifacts
```

## Install as a plugin

For a lighter-weight, in-session install (skills, agents, and hooks only — no cloning):

```
/plugin marketplace add dralgorhythm/claude-agentic-framework
/plugin install agentic-framework@agentic-framework
```

Skills are namespaced (`/agentic-framework:architect`, not `/architect`). The plugin does **not** ship `.claude/settings.json` permission rules or `.claude/rules/` — those are repo-level and only come from the raw drop-in above. See [README.md — Two ways to adopt](../README.md#two-ways-to-adopt) for the full comparison.

Plugin content updates at each tagged release — run `/plugin update` to pull the latest; after updating, check `MIGRATION.md` for breaking changes.

## What Gets Installed

```
.claude/         Commands, skills, rules, hooks, agents, templates
.mcp.json        MCP server configuration
artifacts/       Where generated docs go (empty at first)
CLAUDE.md        Project context — customize this
AGENTS.md        Agent instructions for session completion
```

## Verify It Works

```bash
claude
```

Then try:
```
/architect hello
```

You should see Claude adopt the Architect command.

## Next Steps

1. **Edit CLAUDE.md** — Add your build commands (`npm test`, etc.)
2. **Edit `.claude/rules/tech-strategy.md`** — Configure your tech stack
3. **Try the workflow** — `/architect my-feature` then `/builder` then `/swarm-review`
4. **Check artifacts/** — Your ADRs and design docs appear here

Upgrading? Check CHANGELOG.md and MIGRATION.md.

See [handoffs.md](handoffs.md) for how in-flight work is tracked and handed off between sessions.

---

[← Back to README](../README.md)
