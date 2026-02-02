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

## SOLID Principle Audit

### Single Responsibility (SRP)

**Signals** (evaluate in context, not absolute):
- Classes with multiple unrelated methods
- Methods doing multiple distinct operations
- Files importing from many unrelated modules
- "And" in class names (UserAndNotificationService)

### Open/Closed (OCP)

**Signals**:
- Frequent modifications to existing classes for new features
- Missing extension points (no strategy/plugin pattern)
- Hardcoded type checks (`instanceof`, `typeof` chains) without polymorphism

Note: TypeScript discriminated unions with switch statements are VALID OCP when types are co-located.

### Liskov Substitution (LSP)

**Signals**:
- Overridden methods that throw "not implemented"
- Subtypes with stricter preconditions
- Type checks before method calls

### Interface Segregation (ISP)

**Signals**:
- Interfaces with > 5 methods (evaluate context)
- Classes implementing methods as no-ops
- Optional method implementations

### Dependency Inversion (DIP)

**Signals**:
- Direct instantiation of dependencies in constructors
- Concrete class imports in business logic
- Missing dependency injection (constructor or context)

## DRY Violation Detection

### Knowledge Duplication (MUST fix)

Same business logic in multiple places:

```typescript
// ❌ Knowledge duplication
// file1.ts
const isValidEmail = (email: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

// file2.ts
const validateEmail = (e: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);
```

### Incidental Duplication (evaluate carefully)

Similar code that may evolve differently — NOT always a violation.

**Detection**: Use `jscpd` or AST-based tools, not just grep patterns.

## Code Smell Detection

| Smell | Description | Threshold |
|-------|-------------|-----------|
| Long Method | Functions too large | > 50 lines (context-dependent) |
| Large Class | Classes too large | > 500 lines (context-dependent) |
| Feature Envy | Method uses another class's data excessively | Manual review |
| Data Clumps | Same data groups passed together | 3+ parameters repeating |
| Primitive Obsession | Using primitives instead of domain types | Manual review |
| Message Chains | a.b().c().d() patterns | > 3 chained calls |

### TypeScript/React-Specific Smells

- Type Assertions Abuse (excessive `as` casts)
- Any Propagation (`any` spreading through codebase)
- Promise Anti-patterns (unhandled rejections, missing `await`)
- Barrel File Bloat (index files creating circular deps)
- Prop Drilling (passing props through many levels)

## Consistency Audit

| Area | What to Check |
|------|---------------|
| Error Handling | Same pattern across modules (Result types, try-catch) |
| Async Patterns | Consistent Promise/async-await usage |
| Naming | camelCase, PascalCase, snake_case conventions |
| Imports | Absolute vs relative, barrel files |
| Types | Type vs Interface usage |
| Validation | Zod schemas, manual validation, or mixed |

## Complexity Metrics

| Metric | Green | Yellow | Red |
|--------|-------|--------|-----|
| Cyclomatic Complexity | < 10 | 10-15 | > 15 |
| Function Length | < 30 | 30-50 | > 50 |
| Class Length | < 300 | 300-500 | > 500 |

**Tools**:
- For TypeScript: `npx ts-complexity-report`, `eslint-plugin-sonarjs` for cognitive complexity
- For Python: `radon cc`, `radon mi` for maintainability index
- For Go: `gocyclo`, `gocognit`
- For Rust: `cargo-geiger`, `cargo-bloat`

## Dead Code Detection

**For JavaScript/TypeScript projects:**
```bash
npx knip          # Find unused exports (verify before removing)
npx depcheck      # Find unused dependencies
```

**For other languages**, use appropriate unused code/dependency detectors:
- Python: `vulture` (dead code), `pip-audit` (dependencies)
- Go: `go mod tidy`, `staticcheck`
- Rust: `cargo-udeps`, `cargo-machete`

**Warning**: Verify findings before deletion — tools have false positives with dynamic imports and external consumers.

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

- To Builder: With Beads for specific fixes
- To Refactoring Engineer: For large-scale cleanups
- To Architect: For systemic architectural issues

$ARGUMENTS
