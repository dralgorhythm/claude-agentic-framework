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

## Worker Types

| Task Type | Worker | Model | Parallelism |
|-----------|--------|-------|-------------|
| Implementation | worker-builder | sonnet | Up to 4 |
| Test Writing | worker-tester | sonnet | Up to 4 |
| Research/Spike | worker-explorer | haiku | Up to 8 |
| Security Check | worker-security | sonnet | 1-2 |
| Refactoring | worker-refactor | sonnet | Up to 4 |

## Quality Gates

**Before closing ANY task:**

```bash
# Run project test suite (npm test, pytest, cargo test, go test, etc.)
# Run linter (biome, ruff, clippy, golangci-lint, etc.)
# Run type checker if applicable (tsc, mypy, etc.)
# Verify build succeeds
# Run security audit (npm audit, trivy, cargo audit, etc.)
```

All gates MUST pass. No exceptions.

## Git Push Protocol (MANDATORY)

Work is NOT complete until pushed to remote:

```bash
# Stage and commit
git add -A
git commit -m "feat(scope): description

- Change 1
- Change 2

Closes: beads-xxx"

# Pull, sync beads, and push
git pull --rebase
bd sync
git push

# Verify
git status  # MUST show "up to date with origin"
```

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

## Rollback Protocol

```bash
# Revert changes if quality gates fail
git stash
git checkout -- .

# Mark task as blocked
bd update <id> --status blocked
bd comments add <id> "Rolled back: [reason]"
```

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

- To Reviewer: After implementation complete, create PR
- To QA Engineer: For acceptance testing
- To Planner: When scope changes discovered

$ARGUMENTS
