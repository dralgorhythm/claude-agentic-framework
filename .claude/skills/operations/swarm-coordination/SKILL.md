---
name: swarm-coordination
description: Coordinate multi-agent swarm workflows. Use when working in parallel with other agents, managing shared resources, or orchestrating distributed tasks. Covers conflict prevention, handoffs, and two-tier task tracking (native task list + artifacts).
---

# Swarm Coordination

Protocols and patterns for consistent, conflict-free multi-agent development. Follow these guidelines when working alongside other Claude Code agents in the same codebase.

## Core Principles

1. **Two-Tier Task Tracking**: Durable work items live in GitHub Issues (or a committed `ISSUES.md`); in-flight work lives in the orchestrator's native task list (TaskCreate/TaskUpdate/TaskList)
2. **File Locking**: Hooks automatically manage file locks - respect them
3. **Session Isolation**: Each agent has a unique session ID for tracking
4. **Clean Handoffs**: Always leave state — and an artifact reference — that another agent can continue from

## Two-Tier Task Tracking

- **Tier 1 — Durable record**: GitHub Issues (or `ISSUES.md` for repos without a tracker) hold the permanent history of work items: what was requested, why, and its final disposition.
- **Tier 2 — In-flight work**: The orchestrator owns a native task list (TaskCreate/TaskUpdate/TaskList). One task per work item, each with explicit acceptance criteria. Workers do not maintain their own task lists (see `.claude/rules/agent-constraints.md` for the no-shared-state rule).
- **Handoffs**: see Core Directives §7 "Follow Command Protocols" — every handoff needs a verifiable artifact reference.

## File-Based Output

Workers write results to `scratchpad/<task-id>.md`, not direct context. Only durable artifacts (ADRs, plans, PRDs) go to `artifacts/`. Orchestrator creates output targets before launching workers; workers write to assigned files; orchestrator reads and synthesizes.

## Workflows

### Starting Work

- [ ] **Check the Task List**: Orchestrator reviews TaskList for unblocked, unclaimed items
- [ ] **Create Tasks**: One task per work item, each with explicit acceptance criteria
- [ ] **Check Conflicts**: Review `.claude/hooks/.file-tracker.log` for recent edits
- [ ] **Dispatch**: Send workers a focused, self-contained prompt (see `agent-constraints.md`)

### During Work

- [ ] **Atomic Changes**: Make small, complete changes that don't leave broken state
- [ ] **Frequent Commits**: Commit often to reduce merge conflicts
- [ ] **Update Task Status**: Orchestrator updates TaskUpdate as workers report back
- [ ] **Respect Locks**: If a file is locked, wait or work on something else

### Completing Work

- [ ] **Run Tests**: Verify changes don't break existing functionality
- [ ] **Mark Task Done**: Orchestrator closes the task in the native task list with the result
- [ ] **Update Durable Record**: Reflect completion in the GitHub Issue / `ISSUES.md`
- [ ] **Clean State**: Commit all changes, leave no uncommitted work

## Conflict Prevention

### File Lock Protocol

Hooks automatically acquire/release locks. If you encounter a lock:

```bash
# Check who holds the lock
cat .claude/hooks/.locks/<filename>.lock

# Lock automatically expires after 60 seconds
# If urgent, wait or pick a different task from the task list
```

### Merge Conflict Strategy

1. Pull frequently: Keep your branch up to date
2. Small PRs: Easier to merge than large changes
3. Coordinate: Claim a task (and its files) in the orchestrator's task list before editing
4. Resolve quickly: Address conflicts immediately when detected

## Communication Patterns

### Handoff Message

When ending a session with incomplete work, leave a handoff pointing at a concrete artifact:

```bash
echo '{"message": "Continue implementing auth middleware. Tests passing but needs error handling in src/auth.ts:45", "artifact": "artifacts/plan_auth_middleware.md"}' > .claude/hooks/.state/handoff.json
```

## Multi-Agent Patterns

### Orchestrator-Worker Pattern

For complex tasks, one agent orchestrates while others execute:

1. **Orchestrator**: Plans, decomposes work into tasks on the native task list, dispatches workers
2. **Workers**: Receive a focused prompt, implement, return results (no worker-to-worker state sharing — see `agent-constraints.md`)
3. **Sync Point**: Orchestrator collects all worker results and reconciles before final integration

### Parallel Streams

For independent features:

1. Create a separate task (with acceptance criteria) for each stream
2. Each worker claims one stream via its assigned task
3. Avoid editing same files across streams
4. Merge streams at defined integration points

## State Files

| File | Purpose |
|------|---------|
| `.claude/hooks/.state/session_*.json` | Active agent sessions |
| `.claude/hooks/.state/handoff.json` | Handoff messages between sessions |
| `.claude/hooks/.locks/*.lock` | File edit locks |
| `.claude/hooks/.file-tracker.log` | Recent file modifications |

## Best Practices

1. **Check Before Edit**: Always verify no active locks on target files
2. **Complete Units**: Finish logical units of work before switching
3. **Document Intent**: Use the task list to declare what you're working on and its acceptance criteria
4. **Test Locally**: Run tests before pushing to catch issues early
5. **Sync Often**: Keep the task list, durable issues, and git in sync with other agents

## Emergency Procedures

### Deadlock Detection

If agents are waiting on each other:

```bash
# Check active sessions
ls -la .claude/hooks/.state/session_*.json

# Check active locks
ls -la .claude/hooks/.locks/

# Force release stale locks (use with caution)
find .claude/hooks/.locks -mmin +5 -delete
```

### Recovery from Conflict

1. Save current work to a new branch
2. Sync with main: `git fetch && git rebase origin/main`
3. Resolve conflicts file by file
4. Update the native task list and durable issue record to reflect current state
5. Continue work
