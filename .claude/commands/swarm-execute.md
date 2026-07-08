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
| `worker-researcher` | Quick web research, API docs, library comparison |
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

1. **Orchestrator** decomposes task via Beads
2. **Workers** claim issues: `bd update <id> --status in_progress`
3. **Workers** complete task following AGENTS.md "Landing the Plane" workflow
4. **Workers** report completion to orchestrator
5. **Orchestrator** integrates and verifies

### Worker Completion Requirements

When a worker completes its assigned task, it MUST follow the full completion protocol from AGENTS.md:

1. File issues for remaining work
2. Run quality gates (if code changed)
3. Update issue status: `bd close <id>`
4. **PUSH TO REMOTE** (mandatory):
   ```bash
   git pull --rebase
   bd sync
   git push
   ```
5. Report completion to orchestrator

**Critical**: Workers must push changes to remote. Work is NOT complete until `git push` succeeds.

## Git Push Protocol

Work is NOT complete until pushed:
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

- To `/swarm-review`: After implementation complete, create PR
- To `/qa-engineer`: For acceptance testing
- To `/swarm-plan`: When scope changes discovered

$ARGUMENTS
