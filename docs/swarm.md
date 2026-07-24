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

| Worker | Best For |
|--------|----------|
| `worker-explorer` | Fast codebase search, web research, dependency mapping |
| `worker-builder` | Implementation, testing, refactoring |
| `worker-reviewer` | Code review, security analysis |
| `worker-research` | Deep multi-source investigation |
| `worker-architect` | Complex design decisions, ADRs |

Model tiers are pinned in each agent's frontmatter (`.claude/agents/`) — that is the single source of truth. `maxTurns` values below are the frontmatter defaults, sized from observed runs with headroom; tune them per-agent if your workload runs longer or shorter.

### Model tier assignments (dated 2026-07)

| Tier | Worker(s) | Rationale |
|------|-----------|-----------|
| Haiku | `worker-explorer` (`maxTurns: 30`) | Mechanical, read-heavy work — codebase search, dependency mapping, quick web lookups. Cheapest tier for high tool-call volume with low judgment. |
| Sonnet | `worker-builder` (`maxTurns: 90`, `isolation: worktree`), `worker-reviewer` (`maxTurns: 60`), `worker-research` (`maxTurns: 80`) | Production default — the tier for implementation, review, and multi-source investigation where judgment matters but the reasoning load doesn't require the top tier. |
| Opus | `worker-architect` (`maxTurns: 40`) | Top mainline tier, reserved for architecture judgment — system design, ADRs, trade-off evaluation across competing constraints. |

Fable/Mythos exists as a premium tier at roughly 2× Opus pricing (Opus: $5/$25 per MTok in/out, 2026-07) — deliberately **not** a default for any worker in this framework; reserve it only for stakes that justify the cost. Separately, newer-generation models tokenize noticeably more tokens (roughly +30%) for equivalent text versus older tokenizers, which affects cost comparisons across model generations even at flat per-token pricing — factor that in before assuming a price-per-token figure translates directly to cost-per-task. No in-session tool surfaces pricing — re-check the official pricing page when these figures matter.

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

Workers MUST follow the "Landing the Plane" protocol from AGENTS.md — which is two modes now, not one. `worker-builder` runs isolated (`isolation: worktree` in its frontmatter) and follows Mode A: commit on the assigned worktree branch, then report the commit SHA back to the orchestrator, which merges, re-runs gates, pushes, and cleans up the worktree. Every other worker (and any non-isolated agent or session) follows Mode B and pushes directly. Work is NOT complete until the responsible party's `git push` succeeds.

Research output delivery layers a framework protocol on top of the platform default: the platform always returns a Task-tool worker's final message to the orchestrator; this repo's `swarm-research` protocol additionally directs `worker-research`/`worker-architect` to persist that output to their assigned file (the deliverable of record), while `worker-explorer` (no `Write` tool) always returns inline and the orchestrator persists it — see `swarm-research`'s Worker Dispatch rules.

## Tips

- Use Haiku for read-only tasks (faster, cheaper)
- Max 8 concurrent workers
- Don't have workers spawn workers (single-level only)
- Keep worker prompts under 500 tokens for fast startup
- Right-size tasks to roughly 200-400 changed LOC or 15-45 minutes of focused work — review effectiveness collapses beyond ~400 LOC (SmartBear/Cisco)

---

[← Back to README](../README.md)
