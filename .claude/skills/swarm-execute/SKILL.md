---
name: swarm-execute
description: Execute an implementation plan with parallel worker swarms, quality gates, and native task tracking — a user-invoked Execution Orchestrator workflow.
argument-hint: [plan-artifact-or-task-id]
disable-model-invocation: true
---

# Execution Orchestrator

Execute plans using parallel worker swarms with quality gates and native task-list tracking.

## MCP Tools

**Context7** (documentation):
- Research implementation patterns
- Verify API usage

## CLI Tools

**gh** (GitHub CLI):
- Use `gh pr create` for creating pull requests
- Use `gh pr view` to check PR status
- Use `gh issue list` for issue tracking

## Execution Workflow

1. **Discover** — Find available work via `TaskList` (unblocked, not-yet-started tasks)
2. **Claim** — Mark the task in progress via `TaskUpdate` (status: in_progress)
3. **Analyze** — Check the task's `blockedBy` dependencies to confirm it is actually unblocked
4. **Execute** — Launch parallel workers for independent tasks
5. **Gate** — Run quality gates before marking tasks complete
6. **Close** — Mark complete via `TaskUpdate` (status: completed)
7. **Push** — Push to remote (MANDATORY)

## Context Efficiency

1. **Workers inherit session context** - CLAUDE.md and rules are loaded, but workers use focused instructions
2. **Narrow scope** - Each worker focuses on one task
3. **Guided behavior** - Agent instructions define scope, permissionMode controls access
4. **Right-sized models** - Haiku for exploration, Sonnet for implementation, Opus for architecture

## Worker Types

| Worker | Primary Use |
|--------|-------------|
| `worker-explorer` | Fast codebase search, web research, dependency mapping |
| `worker-builder` | Implementation, testing, refactoring |
| `worker-reviewer` | Code review, security audit, quality assessment |
| `worker-research` | Deep multi-source investigation, technology evaluation |
| `worker-architect` | Complex design decisions, ADRs, system architecture |

Model tiers are pinned in each agent's frontmatter (`.claude/agents/`) — that is the single source of truth.

## Worker Focus Modes

Orchestrators specialize workers by specifying a focus mode in the prompt.

**worker-builder focus modes:**
- `implementation` (default): Write code per specification
- `testing`: Write tests, cover happy path and edge cases, ensure deterministic
- `refactoring`: Extract patterns, simplify conditionals, apply SOLID/DRY. Follow Two Hats Rule (see code-quality.md)

**worker-reviewer focus modes:**
- `quality` (default): Code review checklist — naming, style, tests, patterns
- `security`: OWASP Top 10 scan, hardcoded secrets, auth/authz flows, input validation. Reference CWE IDs. See security.md
- `performance`: N+1 queries, blocking I/O, allocations, pagination, caching. See code-quality.md

## Quality Gates

Run quality gates per `code-quality.md` — all must pass:
- Test suite passes
- Linter passes
- Type checker passes (if applicable)
- Build succeeds
- Security audit passes

No exceptions.

## Coordination Protocol

1. **Orchestrator** decomposes work into tasks via `TaskCreate`, with acceptance criteria and `blockedBy` dependencies
2. **Orchestrator** claims a task on behalf of a worker: `TaskUpdate` (status: in_progress)
3. **Workers** execute their assigned task following AGENTS.md "Landing the Plane" workflow — workers do NOT touch the task list themselves
4. **Workers** report completion (and any follow-up work discovered) back to the orchestrator
5. **Orchestrator** integrates, verifies, and updates the task list based on worker reports

### Worker Completion Requirements

Workers do not have direct access to the native task list — the orchestrator owns it. When a worker completes its assigned task, it MUST follow the full completion protocol from AGENTS.md:

1. Report any remaining or follow-up work to the orchestrator (orchestrator files it via `TaskCreate`)
2. Run quality gates (if code changed)
3. Report completion status back to the orchestrator (orchestrator marks the task completed via `TaskUpdate`)
4. **PUSH TO REMOTE** (mandatory):
   ```bash
   git pull --rebase
   git push
   ```
5. Report completion to orchestrator

**Critical**: Workers must push changes to remote. Work is NOT complete until `git push` succeeds.

## Git Push Protocol

Work is NOT complete until pushed:
1. Stage and commit with descriptive message
2. Pull with rebase
3. Push to remote
4. Verify: `git status` must show "up to date with origin"

## Checkpointing

For long-running tasks, the orchestrator records progress on the task via `TaskUpdate` (metadata/comments), e.g.:

- "Completed step 1: schema migration"
- "Completed step 2: API endpoints"
- "In progress: integration tests"

## Error Handling

If a worker fails:

1. Orchestrator marks the task blocked via `TaskUpdate` (status: blocked), with a comment: "Blocked: [safe error description without secrets]"
2. Orchestrator creates a new blocker task via `TaskCreate` describing the fix needed
3. Orchestrator sets the original task's `blockedBy` to reference the new blocker task

## Rollback

If quality gates fail: stash changes, mark the task as blocked via `TaskUpdate`, add a comment with the reason.

## Performance Tips

- Launch multiple explorers for broad searches
- Use worker-architect for decisions, worker-builder for execution
- Parallelize independent tasks (max 8 concurrent workers)
- Keep worker prompts under 500 tokens for fast startup

## Constraints

- NO closing tasks without passing quality gates
- NO leaving work uncommitted locally
- NO exceeding 8 parallel workers
- NO skipping git push step
- NO exposing secrets in error messages or comments
- ALWAYS update task status in real-time via `TaskUpdate`
- ALWAYS add comments for blocked work
- ALWAYS verify `git status` shows up to date
- ALWAYS validate inputs before executing commands

## Definition of Done

- [ ] Code implemented per specification
- [ ] Tests written and passing
- [ ] Linter passes
- [ ] Types check
- [ ] Build succeeds
- [ ] Task marked completed with reason
- [ ] Changes pushed to remote
- [ ] `git status` shows up to date with origin

## Related Skills

`swarm-coordination`, `testing`

## Handoff

- To `/swarm-review`: After implementation complete, create PR
- To `/qa-engineer`: For acceptance testing
- To `/swarm-plan`: When scope changes discovered
