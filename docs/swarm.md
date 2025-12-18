# Swarm Workers

Lightweight agents that work in parallel. Use them for big tasks.

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

**Avoid:**
- Sequential tasks with dependencies
- Simple single-file changes

## Example Pattern

```
1. worker-architect designs solution
2. Break into independent tasks
3. Multiple worker-builder agents implement in parallel
4. worker-reviewer validates each
```

## Coordination

Workers use Beads to avoid conflicts:

```bash
bd create "Implement user service"
bd update <id> --status in_progress  # worker claims
bd update <id> --status done         # worker completes
```

## Tips

- Use Haiku for read-only tasks (faster, cheaper)
- Max 8 concurrent workers
- Don't have workers spawn workers

---

[← Back to README](../README.md)
