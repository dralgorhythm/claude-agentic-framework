# Code Quality Standards

Deep-dive reference for SOLID principles and type safety. See Core Principles in CLAUDE.md for the essentials.

## SOLID Principles

1. **Single Responsibility**: Each module/class should have one reason to change
2. **Open/Closed**: Open for extension, closed for modification
3. **Liskov Substitution**: Subtypes must be substitutable for base types
4. **Interface Segregation**: Prefer small, specific interfaces over large general ones
5. **Dependency Inversion**: Depend on abstractions, not concretions

## DRY (Don't Repeat Yourself)

- **Knowledge duplication** (must fix): Same business logic in multiple places
- **Incidental duplication** (evaluate carefully): Similar code that may evolve differently
- Maintain a single source of truth for business logic

## Type Safety

- Use strict typing where available
- Avoid `any` types in TypeScript (if applicable)
- Use type narrowing and discriminated unions
- Leverage compile-time type checking

## Performance Checklist

- N+1 query patterns (loops with DB calls)
- Blocking I/O in async paths (readFileSync, execSync)
- Excessive memory allocations
- Missing pagination
- Inefficient algorithms (O(n²) when O(n) possible)
- Cache opportunities missed

## Quality Gates

All of these must pass before committing:

- Tests pass
- Linter passes
- Type checker passes (if applicable)
- Build succeeds
- Security audit passes

## Refactoring Discipline

**Two Hats Rule**: Never mix refactoring and optimization in the same session.

- **Hat 1: Refactoring** - Change structure, NOT behavior. Tests must pass unchanged.
- **Hat 2: Optimization** - Improve performance, NOT behavior. Benchmarks required.

When switching hats, commit first, then switch context.
