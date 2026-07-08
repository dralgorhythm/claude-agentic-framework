---
name: testing
description: Write effective tests for code quality and reliability. Use when implementing features, fixing bugs, improving coverage, or practicing TDD/test-driven development. Covers unit, integration, and E2E testing.
---

# Testing Software

## MCP Tools

**Chrome DevTools** (E2E testing):
- Automate user flows in real browser
- Capture screenshots for visual regression
- Run Lighthouse for accessibility testing
- Profile performance during test runs

## Testing Pyramid

1. **Unit Tests** (Many): Fast, isolated, test single units
2. **Integration Tests** (Some): Test component interactions
3. **E2E Tests** (Few): Test complete user flows — use Chrome DevTools

## Workflows

- [ ] **Analyze**: Use Glob and Grep to identify untested code
- [ ] **Unit Tests**: Cover all public functions
- [ ] **Edge Cases**: Test boundaries and error conditions
- [ ] **Integration**: Test external dependencies
- [ ] **E2E**: Use Chrome DevTools for browser automation
- [ ] **Regression**: Add test for each bug fix

## Test-Driven Development

When writing new logic, default to red-green-refactor:

1. **Red**: Write a failing test for one behavior before writing the implementation.
2. **Green**: Write the minimum code needed to make that test pass.
3. **Refactor**: Clean up structure only while the suite is green — no new behavior in this step.

- One behavior per test — if a test needs "and" to describe it, split it.
- Never write production code without a failing test driving it, except for spikes/throwaway exploration (delete or backfill tests before merging).
- Don't refactor and add behavior in the same commit; commit on green before switching hats (see `code-quality.md` Two Hats Rule).

**When TDD is the right default**: new business logic, bug fixes (write the regression test first, watch it fail, then fix), and any code with clear input/output contracts.

**When it isn't**: exploratory spikes, throwaway scripts, UI layout/styling tweaks, and generated boilerplate — write tests after the shape stabilizes instead.

## Test Quality Standards

### Deterministic
Tests must produce the same result every time.

### Isolated
Tests should not depend on each other or shared state.

### Clear
Test names should describe the behavior being tested.

## Test Patterns

### Arrange-Act-Assert (AAA) (TypeScript Example)

```typescript
test("user registration sends welcome email", async () => {
  // Arrange
  const emailService = new MockEmailService();
  const userService = new UserService(emailService);

  // Act
  await userService.register("test@example.com");

  // Assert
  expect(emailService.sentEmails).toContainEqual({
    to: "test@example.com",
    subject: "Welcome!"
  });
});
```

## E2E Testing with Chrome DevTools

```javascript
// Use Chrome DevTools MCP for browser automation
// - Navigate to pages
// - Fill forms and click buttons
// - Capture screenshots for visual regression
// - Run Lighthouse accessibility audits
// - Check console for errors
```

## Commands (Examples by Language)

```bash
# Run tests
npm test
pytest
go test ./...

# With coverage
npm test -- --coverage
pytest --cov=src
go test -cover ./...
```

## Finding Untested Code

Use Glob and Grep to identify gaps:
1. Use Glob to find all source files and test files
2. Check which source files have corresponding test files
3. Use Grep to see if functions are referenced in tests
