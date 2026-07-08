---
description: Create implementation plans using parallel specialist workers
argument-hint: [feature-or-task-description]
---

# Planning Orchestrator

Decompose features into actionable plans using parallel exploration swarms.

## MCP Tools

**Sequential Thinking** (structured analysis):
- Complex requirement decomposition
- Trade-off evaluation for approach selection
- Risk assessment for implementation choices

**Context7** (library research):
- Research existing patterns in libraries
- Validate technology choices from Tech Strategy

## Planning Workflow

1. **Explore** — Launch 3-6 worker-explorer agents to research existing patterns, dependencies, constraints, and prior art
2. **Classify** — Determine decision reversibility (Two-Way Door vs One-Way Door)
3. **Document** — Create appropriate artifacts based on scope
4. **Decompose** — Break into right-sized tasks (1-2 days each)
5. **Track** — Create Beads for implementation tracking

## Decision Framework

| Decision Type | Reversibility | Required Artifacts |
|---------------|---------------|-------------------|
| Two-Way Door | Easy to reverse | PR description only |
| One-Way Door (Medium) | Moderate effort | RFC + Design excerpt |
| One-Way Door (High) | Expensive/impossible | Full ADR + Stakeholder review |

## Artifact Requirements

**Small Feature (1-3 days)**
- `plan_[feature].md` — Implementation steps only

**Medium Feature (1-2 weeks)**
- `prd_[feature].md` — Requirements
- `plan_[feature].md` — Implementation steps

**Large Feature (2+ weeks)**
- `pr_faq_[feature].md` — Vision and customer value
- `prd_[feature].md` — Detailed requirements
- `adr_[key-decision].md` — Architectural decisions (use ADR template from `skills/architecture/writing-adrs`)
- `plan_[feature].md` — Implementation steps

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
worker-reviewer (focus: security) scans all components in parallel
Findings aggregated and prioritized
worker-builder fixes critical/high issues
```

## Parallel Exploration Pattern

```bash
# Launch exploration workers in parallel via Task tool
# Each worker focuses on one aspect:
# - Existing patterns in codebase
# - External dependencies and APIs
# - Security and performance constraints
# - Related ADRs and design specs
```

## Beads Creation

```bash
# Create epic
bd create --title="Implement [feature]" --type=feature --priority=2

# Create implementation tasks
bd create --title="[Task 1: Foundation]" --type=task
bd create --title="[Task 2: Core Logic]" --type=task

# Link dependencies (Task 2 depends on Task 1)
bd dep add <task2-id> <task1-id>
```

## Performance Tips

- Launch multiple explorers for broad searches
- Use worker-architect for decisions, worker-builder for execution
- Parallelize independent tasks (max 8 concurrent workers)
- Keep worker prompts under 500 tokens for fast startup

## Constraints

- NO skipping artifact creation for features > 3 days
- NO creating tasks without clear acceptance criteria
- NO assuming context — explore codebase first
- ALWAYS use parallel workers for research phase
- ALWAYS store artifacts in `./artifacts/`
- ALWAYS create Beads before declaring planning complete
- ALWAYS validate arguments before using in commands

## Output

Every planning session MUST produce:
1. Artifact(s) in `./artifacts/` following naming conventions
2. Beads for all implementation tasks
3. Dependency graph showing task order
4. Handoff summary for /execute command

## Product Planning

### PR-FAQ
Use `writing-pr-faqs` skill for structure and template.

### PRD
Use `writing-prds` skill for structure and template.

### Architecture Design Process
1. **Understand** — Map existing system with Grep and Glob
2. **Reason** — Enumerate constraints and evaluate options
3. **Design** — Create ADR with trade-off matrix
4. **Validate** — Verify design fits existing patterns

### Output
- `scratchpad/` for planning exploration and working notes
- `artifacts/` for final documents (PR-FAQ, PRD, ADR, plan)

## Related Skills

`decomposing-tasks`, `beads-workflow`, `swarm-coordination`, `writing-adrs`, `designing-systems`, `designing-apis`, `writing-pr-faqs`, `writing-prds`, `requirements-analysis`

## Handoff

- To `/swarm-execute`: Plan artifact + Beads ready for `bd ready`
- To `/architect`: Complex decisions requiring ADR review

$ARGUMENTS
