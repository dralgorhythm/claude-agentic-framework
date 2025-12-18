# Beads

AI-native issue tracking. Optional but useful for swarm coordination.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
bd init
```

## Commands

```bash
bd create "Task description"          # create
bd ready                              # find work
bd update <id> --status in_progress   # claim
bd update <id> --status done          # complete
bd sync                               # sync with team
bd doctor                             # health check
```

## Workflow

```
bd ready → claim → work → complete → bd sync
```

## Team Setup

```bash
bd init --branch beads-metadata
bd config set sync.branch "beads-metadata"
```

## Why CLI?

The CLI uses 98% fewer tokens than MCP tool calls.

---

[← Back to README](../README.md)
