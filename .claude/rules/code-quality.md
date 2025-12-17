# Code Quality Standards

## SOLID Principles

1. **Single Responsibility**: Each module/class should have one reason to change
2. **Open/Closed**: Open for extension, closed for modification
3. **Liskov Substitution**: Subtypes must be substitutable for base types
4. **Interface Segregation**: Prefer small, specific interfaces over large general ones
5. **Dependency Inversion**: Depend on abstractions, not concretions

## DRY (Don't Repeat Yourself)

- Refactor repeated logic into reusable functions or components
- Extract common patterns into shared utilities
- Maintain a single source of truth for business logic

## Testing Standards

- All new code must be testable
- Write unit tests for complex logic
- Prefer integration tests with real dependencies where possible
- Maintain high test coverage for critical paths
- Tests should be deterministic and fast

## Type Safety

- Use strict typing where available
- Avoid `any` types in TypeScript
- Use type narrowing and discriminated unions
- Leverage compile-time type checking

## Code Hygiene

- Use automated linting and formatting
- Fix all warnings before committing
- Keep functions small and focused
- Use descriptive names for variables and functions
- Document complex logic with comments
