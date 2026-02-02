# Handoffs

How work flows between personas and agents.

## Persona Handoff Chain

```
/architect        →  artifacts/adr_*.md, system_design_*.md
       ↓
/builder          →  Code + tests
       ↓
/swarm-review     →  Feedback → back to /builder if needed
```

Each persona reads the previous artifacts and builds on them.

## Swarm Orchestration Handoffs

```
/swarm-plan       →  artifacts/plan_*.md + Beads tasks
       ↓
/swarm-execute    →  Parallel workers implement tasks
       ↓
/swarm-review     →  Multi-perspective review (2-3x loop)
       ↓
PR creation       →  gh pr create
```

## Worker Completion (Landing the Plane)

Every worker or session MUST complete these steps before handoff:

1. **File issues** for remaining work (`bd create`)
2. **Run quality gates** if code changed (lint, typecheck, test, build)
3. **Update issue status** (`bd close <id>`)
4. **Push to remote** — work is NOT complete until `git push` succeeds
5. **Cleanup** — release locks, sync Beads
6. **Report** — summarize what was done and what remains

See `AGENTS.md` for the full protocol.

## Session Handoffs

Leave context for the next session:

```bash
# Write handoff message
echo '{"message": "Completed API endpoints. Remaining: tests for /users route."}' > .claude/hooks/.state/handoff.json
```

The next session's `session-start-loader.sh` will display this message on startup.

## Beads-Based Handoffs

Use Beads for structured handoffs between agents:

```bash
bd create "Continue: implement pagination for /users" --type=task
bd dep add <new-id> <completed-id>  # link dependency
```

Workers discover available work via `bd ready`.

---

[← Back to README](../README.md)
