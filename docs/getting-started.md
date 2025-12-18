# Getting Started

## Quick Install

```bash
cd your-project
curl -sSL https://raw.githubusercontent.com/anthropics/claude-agentic-framework/main/scripts/init-framework.sh | bash -s .
```

The script prompts before overwriting existing files.

## Manual Install

```bash
git clone https://github.com/anthropics/claude-agentic-framework.git
cp -r claude-agentic-framework/.claude your-project/
cp -r claude-agentic-framework/templates your-project/
cp claude-agentic-framework/CLAUDE.md your-project/
mkdir -p your-project/artifacts
cd your-project/.claude/hooks && npm install
```

## What Gets Installed

```
.claude/         Commands, skills, rules, hooks
templates/       Templates for extending
artifacts/       Where generated docs go (empty at first)
CLAUDE.md        Project context — customize this
```

## Verify It Works

```bash
claude
```

Then try:
```
/architect hello
```

You should see Claude adopt the Architect persona.

## Next Steps

1. **Edit CLAUDE.md** — Add your build commands (`npm test`, etc.)
2. **Try the workflow** — `/product-manager my-feature` then `/architect` then `/builder`
3. **Check artifacts/** — Your PRDs and ADRs appear here

## Optional: Beads Issue Tracking

```bash
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
bd init
```

See [beads.md](beads.md).

## Recommended: Dev Container

For a sandboxed environment with all tools pre-installed:

**VS Code:**
1. Install [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open project → "Reopen in Container"

**GitHub Codespaces:**
Click Code → Codespaces → New codespace

The container includes a network firewall that only allows approved domains (GitHub, npm, PyPI, etc.).

See [devcontainer.md](devcontainer.md) for full details.

---

[← Back to README](../README.md)
