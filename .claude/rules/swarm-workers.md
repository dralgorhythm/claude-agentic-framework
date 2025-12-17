# Swarm Worker Guidelines

Rules for efficient multi-agent swarm execution.

## Context Efficiency

1. **Workers start clean** - No CLAUDE.md or rules loaded
2. **Narrow scope** - Each worker focuses on one task
3. **Minimal tools** - Only tools needed for the task
4. **Right-sized models** - Haiku for exploration, Sonnet for implementation, Opus for architecture

## Worker Types

| Worker | Model | Tools | Use |
|--------|-------|-------|-----|
| `worker-explorer` | haiku | Read, Glob, Grep | Fast codebase search |
| `worker-builder` | sonnet | Read, Write, Edit, Bash, Glob, Grep | Implementation |
| `worker-reviewer` | sonnet | Read, Glob, Grep, Bash | Code review |
| `worker-tester` | sonnet | Read, Write, Edit, Bash, Glob, Grep | Test writing |
| `worker-researcher` | sonnet | Read, Glob, Grep, WebFetch, WebSearch | External research |
| `worker-architect` | opus | Read, Write, Edit, Glob, Grep | Complex design decisions |
| `worker-security` | sonnet | Read, Glob, Grep, Bash | Security analysis |
| `worker-refactor` | sonnet | Read, Write, Edit, Bash, Glob, Grep | Code cleanup |

## Swarm Patterns

### Parallel Exploration
```
Orchestrator spawns 4-8 worker-explorer agents simultaneously
Each searches different parts of codebase
Results aggregated for next phase
```

### Divide and Conquer
```
1. worker-architect designs solution
2. Orchestrator decomposes into N tasks
3. N worker-builder agents execute in parallel
4. worker-reviewer validates each output
5. Orchestrator integrates
```

### Security Sweep
```
worker-security scans all components in parallel
Findings aggregated and prioritized
worker-builder fixes critical/high issues
```

## Coordination Protocol

1. **Orchestrator** decomposes task via Beads
2. **Workers** claim issues: `bd update <id> --status in_progress`
3. **Workers** report completion to orchestrator
4. **Orchestrator** integrates and verifies

## Performance Tips

- Launch multiple explorers for broad searches
- Use worker-architect for decisions, worker-builder for execution
- Parallelize independent tasks (max 8 concurrent workers)
- Keep worker prompts under 500 tokens for fast startup

## Anti-Patterns

- NO loading full context into workers
- NO sharing state between workers (use Beads)
- NO workers spawning workers (single-level only)
- NO long-running workers (timeout at 5 min)
- NO opus for simple tasks (cost optimization)
