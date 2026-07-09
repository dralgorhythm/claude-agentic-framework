# Handoffs

How work flows between commands and agents.

## Command Handoff Chain

```
/architect        →  artifacts/adr_*.md, system_design_*.md
       ↓
/builder          →  Code + tests
       ↓
/swarm-review     →  Feedback → back to /builder if needed
```

Each command reads the previous artifacts and builds on them.

## Swarm Orchestration Handoffs

```
/swarm-plan       →  artifacts/plan_*.md + native task list entries
       ↓
/swarm-execute    →  Parallel workers implement tasks
       ↓
/swarm-review     →  Multi-perspective review (2-3x loop)
       ↓
PR creation       →  gh pr create
```

## Worker Completion

Every worker or session MUST follow the "Landing the Plane" protocol in `AGENTS.md`. The critical requirement: work is NOT complete until `git push` succeeds.

## Session Handoffs

Leave context for the next session:

```bash
# Write handoff message
echo '{"message": "Completed API endpoints. Remaining: tests for /users route."}' > .claude/hooks/.state/handoff.json
```

The next session's `session-start-loader.sh` will display this message on startup.

## Task-Based Handoffs

Two-tier task tracking coordinates handoffs between agents:

1. **Durable record**: GitHub Issues (or a committed `ISSUES.md` for repos without a tracker) — the permanent record of what needs doing.
2. **In-flight work**: Claude Code's native task list (`TaskCreate`/`TaskUpdate`/`TaskList`), owned by the orchestrator. Workers receive focused prompts and return results; they do not share mutable state with each other.
3. **Handoffs**: Reference the relevant artifact under `./artifacts/` so the next agent can pick up where the previous one left off — for example:

```
Continue: implement pagination for /users
See artifacts/plan_users_api.md for the remaining task breakdown.
```

The orchestrator tracks dependencies between tasks directly in the native task list; workers discover available work from the orchestrator's assignment, not by polling shared state.

---

[← Back to README](../README.md)
