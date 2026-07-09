---
name: code-check
description: Audit a codebase holistically for SOLID, DRY, and consistency violations — a user-invoked Codebase Auditor workflow.
argument-hint: [scope: all | path/to/dir | glob]
disable-model-invocation: true
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

### SOLID and DRY
Apply the principles and duplication classes defined in `.claude/rules/code-quality.md` — do not restate them here; that file is the single source of truth. For DRY, use AST-based tools (jscpd) not just grep patterns.

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

## Handoff

- To `/builder` / `/swarm-execute`: with tasks for specific fixes and refactoring
- To `/architect`: for systemic architectural issues

$ARGUMENTS
