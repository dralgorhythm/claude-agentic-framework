# Swarm Workers

Lightweight agents that work in parallel. Use them for big tasks.

## Orchestration Commands

| Command | Role | Use |
|---------|------|-----|
| `/swarm-plan` | Planning Orchestrator | Parallel exploration, task decomposition, artifact creation |
| `/swarm-execute` | Execution Orchestrator | Parallel workers, quality gates, git push protocol |
| `/swarm-review` | Adversarial Reviewer | Multi-perspective code review, root cause analysis |
| `/swarm-research` | Research Orchestrator | Deep multi-source investigation, technology evaluation |
| `/code-check` | Codebase Auditor | Holistic codebase audit for SOLID, DRY, consistency, and code health |

### Full Cycle

```
/swarm-plan <feature>  →  /swarm-execute <plan>  →  /swarm-review <branch> (2-3x)  →  PR
```

## Available Workers

| Worker | Model | Best For |
|--------|-------|----------|
| `worker-explorer` | Haiku | Fast codebase search, dependency mapping |
| `worker-builder` | Sonnet | Implementation, testing, refactoring |
| `worker-reviewer` | Opus | Code review, security analysis |
| `worker-researcher` | Sonnet | Quick web research, API docs |
| `worker-research` | Opus | Deep multi-source investigation |
| `worker-architect` | Opus | Complex design decisions, ADRs |

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
2. Break into independent tasks in the orchestrator's native task list
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

The orchestrator uses its native task list to avoid conflicts between workers:

```
TaskCreate  "Implement user service"
TaskUpdate  <id> --status in_progress   # worker claims (reported back to orchestrator)
TaskUpdate  <id> --status completed     # worker completes
```

Workers do not share mutable state directly — they receive a focused prompt from the orchestrator and return results. The orchestrator records durable follow-up work as GitHub Issues (or `ISSUES.md`) and references relevant artifacts under `./artifacts/` in each handoff.

## Worker Completion

Workers MUST follow the "Landing the Plane" protocol from AGENTS.md. Work is NOT complete until `git push` succeeds.

## Tips

- Use Haiku for read-only tasks (faster, cheaper)
- Max 8 concurrent workers
- Don't have workers spawn workers (single-level only)
- Keep worker prompts under 500 tokens for fast startup

---

[← Back to README](../README.md)
