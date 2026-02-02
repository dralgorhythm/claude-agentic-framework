---
description: Holistic codebase audit for SOLID, DRY, consistency, and code health
argument-hint: [scope: all | packages/api | packages/web | path/to/dir]
---

# Codebase Health Auditor

Regular codebase review for Clean Code, SOLID, DRY principles and consistency.

## MCP Tools

**Sequential Thinking** (analysis):
- Complex code smell evaluation
- Trade-off analysis for refactoring decisions

## Audit Workflow

1. **Swarm** — Launch parallel worker-reviewer agents for each audit dimension
2. **SOLID** — Audit for principle violations
3. **DRY** — Detect knowledge duplication
4. **Smells** — Identify code smells from Fowler's catalog
5. **Consistency** — Check pattern consistency across codebase
6. **Report** — Generate prioritized findings with remediation

## Parallel Analysis Pattern

Launch workers for different audit aspects:
- SOLID violations audit
- DRY violations and duplication detection
- Code smell detection
- Consistency audit
- Security anti-pattern detection
- Dead code and unused export detection

## Audit Dimensions

### SOLID Principles
Apply SOLID principles from `code-quality.md`:
- Single Responsibility (SRP) — One reason to change
- Open/Closed (OCP) — Open for extension, closed for modification
- Liskov Substitution (LSP) — Subtypes substitutable for base types
- Interface Segregation (ISP) — Small, specific interfaces
- Dependency Inversion (DIP) — Depend on abstractions

### DRY Violations
Detect DRY violations per `code-quality.md`:
- Knowledge duplication (MUST fix) — Same business logic in multiple places
- Incidental duplication (evaluate carefully) — Similar code that may evolve differently
- Use AST-based tools (jscpd) not just grep patterns

### Code Smells
Identify common code smells (context-dependent thresholds):
- Long methods/functions
- Large classes
- Feature envy
- Data clumps
- Primitive obsession
- Message chains
- Language-specific anti-patterns (type assertions, any propagation, promise anti-patterns)

### Consistency
Check pattern consistency:
- Error handling patterns
- Async/await usage
- Naming conventions
- Import strategies
- Type vs interface usage
- Validation approach

### Complexity
Evaluate cyclomatic complexity and function/class sizes. Use language-appropriate tools:
- TypeScript: ts-complexity-report, eslint-plugin-sonarjs
- Python: radon cc, radon mi
- Go: gocyclo, gocognit
- Rust: cargo-geiger, cargo-bloat

### Dead Code
Use language-appropriate detection tools:
- TypeScript: knip, depcheck
- Python: vulture, pip-audit
- Go: go mod tidy, staticcheck
- Rust: cargo-udeps, cargo-machete

Verify findings before deletion (false positives with dynamic imports).

## Output Format

```markdown
## Codebase Health Report

### Executive Summary
**Health Score**: [A/B/C/D/F]
**Critical Issues**: [count]
**Total Issues**: [count]

### SOLID Violations
| Principle | File:Line | Description | Remediation |
|-----------|-----------|-------------|-------------|

### DRY Violations
| Type | Files | Pattern | Remediation |
|------|-------|---------|-------------|

### Code Smells
| Smell | Location | Severity | Suggestion |
|-------|----------|----------|------------|

### Consistency Issues
| Area | Finding | Recommendation |
|------|---------|----------------|

### Complexity Hotspots
| File | Function | Cyclomatic | Action |
|------|----------|------------|--------|
```

## Constraints

- NO flagging incidental duplication as critical
- NO recommending changes that break public APIs without migration
- NO prioritizing style over substance
- NO removing "dead code" without verifying false positives
- ALWAYS provide specific file:line references
- ALWAYS suggest concrete remediation steps
- ALWAYS consider context when evaluating thresholds

## Related Skills

`refactoring-code`, `testing`, `decomposing-tasks`

## Handoff

- To Builder: With Beads for specific fixes and refactoring
- To Architect: For systemic architectural issues

$ARGUMENTS
