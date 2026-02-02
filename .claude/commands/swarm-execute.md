---
description: Execute implementation plans with parallel worker swarm and beads tracking
argument-hint: [plan-artifact-or-bead-id]
---

# Execution Orchestrator

Execute plans using parallel worker swarms with quality gates and Beads tracking.

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

1. **Discover** — Find available work via `bd ready --sort hybrid`
2. **Claim** — Update status: `bd update <id> --status in_progress`
3. **Analyze** — Check dependency graph: `bd dep tree <id>`
4. **Execute** — Launch parallel workers for independent tasks
5. **Gate** — Run quality gates before closing tasks
6. **Close** — Mark complete: `bd close <id> --reason "..."`
7. **Push** — Push to remote (MANDATORY)

## Worker Assignment

See `swarm-workers.md` for worker types and focus modes:
- worker-builder (implementation, testing, refactoring)
- worker-reviewer (code review, security analysis, performance review)
- worker-explorer (research/spike)
- worker-researcher (external documentation/API research)
- worker-architect (complex design decisions)

## Quality Gates

Run quality gates per `code-quality.md` — all must pass:
- Test suite passes
- Linter passes
- Type checker passes (if applicable)
- Build succeeds
- Security audit passes

No exceptions.

## Git Push Protocol

Follow git push protocol in `swarm-workers.md` — work is NOT complete until pushed:
1. Stage and commit with descriptive message
2. Pull with rebase
3. Sync beads: `bd sync`
4. Push to remote
5. Verify: `git status` must show "up to date with origin"

## Checkpointing

For long-running tasks, add progress updates:

```bash
bd comments add <id> "Completed step 1: schema migration"
bd comments add <id> "Completed step 2: API endpoints"
bd comments add <id> "In progress: integration tests"
```

## Error Handling

```bash
# If worker fails, update bead
bd update <id> --status blocked
bd comments add <id> "Blocked: [safe error description without secrets]"

# Create follow-up task if needed
bd create --title="Fix: [description]" --type=bug --priority=1
bd dep add <new-id> <blocked-id>
```

## Rollback

If quality gates fail: stash changes, mark task as blocked, add comment with reason.

## Constraints

- NO closing tasks without passing quality gates
- NO leaving work uncommitted locally
- NO exceeding 8 parallel workers
- NO skipping git push step
- NO exposing secrets in error messages or comments
- ALWAYS update bead status in real-time
- ALWAYS add comments for blocked work
- ALWAYS verify `git status` shows up to date
- ALWAYS validate inputs before executing commands

## Definition of Done

- [ ] Code implemented per specification
- [ ] Tests written and passing
- [ ] Linter passes
- [ ] Types check
- [ ] Build succeeds
- [ ] Bead closed with reason
- [ ] Changes pushed to remote
- [ ] `git status` shows up to date with origin

## Related Skills

`beads-workflow`, `swarm-coordination`, `testing`

## Handoff

- To Swarm Review: After implementation complete, create PR
- To QA Engineer: For acceptance testing
- To Planner: When scope changes discovered

$ARGUMENTS
