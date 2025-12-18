# Dev Container

A sandboxed, consistent development environment with all tools pre-installed.

## Why Use It

**Safety** — Network firewall blocks all traffic except approved domains (GitHub, npm, PyPI, etc.). Claude can't accidentally reach unknown servers.

**Consistency** — Every team member gets identical tooling. No "works on my machine" issues.

**Zero Setup** — All languages, linters, and tools pre-installed. Start coding immediately.

## Quick Start

### VS Code

1. Install [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open your project
3. Click "Reopen in Container" when prompted (or Cmd/Ctrl+Shift+P → "Reopen in Container")

### GitHub Codespaces

1. Go to your repo on GitHub
2. Click Code → Codespaces → New codespace

## What's Included

### Languages & Runtimes
| Language | Version | Tools |
|----------|---------|-------|
| Node.js | 20 LTS | pnpm, Bun |
| Python | 3.13 | uv, Ruff |
| Go | 1.23 | golangci-lint |
| Rust | stable | mold linker |
| Terraform | 1.9 | — |

### Pre-installed Tools
- **Claude Code** — Latest version
- **Beads** — Issue tracking (auto-initialized)
- **MCP Servers** — Serena, Sequential Thinking, Chrome DevTools, GitHub
- **Trivy** — Security scanner
- **git-delta** — Better git diffs
- **GitHub CLI** — `gh` commands
- **fzf** — Fuzzy finder

### VS Code Extensions
- Claude Code, GitLens, Biome
- Python (with Ruff), Go, Rust Analyzer
- Terraform, TOML

## Network Firewall

The container runs a firewall that only allows connections to:

| Category | Domains |
|----------|---------|
| Code hosting | GitHub (all IPs) |
| Packages | npm, PyPI, crates.io, proxy.golang.org |
| AI | api.anthropic.com |
| Infrastructure | Terraform registry, HashiCorp releases |
| VS Code | Marketplace, updates |

Everything else is blocked. This prevents:
- Accidental data exfiltration
- Connections to unknown APIs
- Supply chain attacks from malicious packages phoning home

## Customizing

### Add Allowed Domains

Edit `.devcontainer/init-firewall.sh`:

```bash
for domain in \
    "registry.npmjs.org" \
    "your-internal-api.company.com" \  # add your domain
    ...
```

Rebuild the container after changes.

### Add Tools

Edit `.devcontainer/Dockerfile`:

```dockerfile
# Add your tool
RUN apt-get install -y your-tool
```

### Change VS Code Settings

Edit `.devcontainer/devcontainer.json`:

```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "your.setting": "value"
      }
    }
  }
}
```

## Persistent Data

These survive container rebuilds:
- **Command history** — Stored in a Docker volume
- **Claude config** — `~/.claude` persisted

## Troubleshooting

### Can't reach a domain

Check if it's in the firewall allowlist:
```bash
cat /usr/local/bin/init-firewall.sh | grep -A 50 "for domain"
```

Add it and rebuild.

### Container won't start

```bash
docker logs <container-id>
```

Usually a firewall script issue — check DNS resolution.

### Slow on Mac/Windows

Add to `.devcontainer/devcontainer.json`:
```json
{
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached"
}
```

---

[← Back to README](../README.md)
