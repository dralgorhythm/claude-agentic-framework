# Agent Constraints

Rules that apply to all agent workflows.

## Anti-Patterns

- NO loading full context into workers — give each worker a focused, self-contained prompt
- NO sharing mutable state between workers — the orchestrator owns coordination and task tracking
- NO workers spawning workers — a deliberate cost/complexity policy, enforced by omitting `Agent` from every worker's `tools` allowlist (the platform itself allows nesting up to depth 5)
- NO unbounded workers — bound runtime with `maxTurns` in agent frontmatter rather than wall-clock limits
- NO premium models for mechanical tasks — model tiering is pinned in each agent's frontmatter, which is the single source of truth for model assignments
- NO skipping git push — work is NOT complete until pushed
