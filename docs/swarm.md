# Swarm Workers

Lightweight agents that work in parallel. Use them for big tasks.

## Orchestration Commands

| Command | Role | Use |
|---------|------|-----|
| `/swarm-plan` | Planning Orchestrator | Parallel exploration, task decomposition, artifact creation |
| `/swarm-execute` | Execution Orchestrator | Parallel workers, quality gates, git push protocol |
| `/swarm-review` | Adversarial Reviewer | Multi-perspective code review, root cause analysis |
| `/code-check` | Codebase Auditor | Holistic codebase audit for SOLID, DRY, consistency, and code health |

### Full Cycle

```
/swarm-plan <feature>  →  /swarm-execute <plan>  →  /swarm-review <branch> (2-3x)  →  PR
```

## Available Workers

| Worker | Model | Best For |
|--------|-------|----------|
| `worker-explorer` | Haiku | Fast codebase search |
| `worker-builder` | Sonnet | Implementation |
| `worker-reviewer` | Sonnet | Code review |
| `worker-tester` | Sonnet | Test writing |
| `worker-researcher` | Sonnet | Web research |
| `worker-architect` | Opus | Complex design |
| `worker-security` | Sonnet | Security analysis |
| `worker-refactor` | Sonnet | Code cleanup |

## When to Use

**Good:**
- Searching a large codebase
- Implementing independent features in parallel
- Security scanning all components
- Reviewing multiple files
- Planning complex features with parallel exploration

**Avoid:**
- Sequential tasks with dependencies
- Simple single-file changes

## Swarm Patterns

### Parallel Exploration (via /swarm-plan)
```
Orchestrator spawns 3-6 worker-explorer agents
Each researches different aspects (patterns, deps, constraints, prior art)
Results aggregated into plan artifact
```

### Divide and Conquer (via /swarm-execute)
```
1. worker-architect designs solution
2. Break into independent tasks via Beads
3. Multiple worker-builder agents implement in parallel
4. worker-reviewer validates each
5. Orchestrator integrates
```

### Adversarial Review (via /swarm-review)
```
Parallel reviewers from different perspectives:
- Security (OWASP Top 10)
- Performance (N+1, blocking I/O, algorithms)
- Architecture (SOLID, coupling, cohesion)
- Test coverage
- Code quality
Findings consolidated with severity classification
```

## Coordination

Workers use Beads to avoid conflicts:

```bash
bd create "Implement user service"
bd update <id> --status in_progress  # worker claims
bd close <id> --reason "Done"        # worker completes
bd sync                              # sync with git
```

## Worker Completion Protocol

Workers MUST follow the "Landing the Plane" protocol from AGENTS.md:

1. File issues for remaining work
2. Run quality gates (if code changed)
3. Update issue status
4. **Push to remote** (mandatory — work is NOT complete until `git push` succeeds)
5. Report completion to orchestrator

## Tips

- Use Haiku for read-only tasks (faster, cheaper)
- Max 8 concurrent workers
- Don't have workers spawn workers (single-level only)
- Keep worker prompts under 500 tokens for fast startup

---

[← Back to README](../README.md)
