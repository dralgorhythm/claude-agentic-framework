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
