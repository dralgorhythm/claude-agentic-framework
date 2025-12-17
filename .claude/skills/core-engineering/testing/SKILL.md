---
name: testing
description: Write effective tests for code quality and reliability. Use when implementing features, fixing bugs, or improving coverage. Covers unit, integration, and E2E testing.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Testing Software

## Testing Pyramid

1. **Unit Tests** (Many): Fast, isolated, test single units
2. **Integration Tests** (Some): Test component interactions
3. **E2E Tests** (Few): Test complete user flows

## Workflows

- [ ] **Unit Tests**: Cover all public functions
- [ ] **Edge Cases**: Test boundaries and error conditions
- [ ] **Integration**: Test external dependencies
- [ ] **Regression**: Add test for each bug fix

## Test Quality Standards

### Deterministic
Tests must produce the same result every time.

```typescript
// BAD: Depends on current time
expect(getGreeting()).toBe("Good morning");

// GOOD: Inject time dependency
expect(getGreeting(new Date("2024-01-01T09:00:00"))).toBe("Good morning");
```

### Isolated
Tests should not depend on each other or shared state.

```typescript
// BAD: Shared state
let counter = 0;
test("increment", () => { counter++; expect(counter).toBe(1); });
test("increment again", () => { counter++; expect(counter).toBe(2); });

// GOOD: Fresh state per test
test("increment", () => {
  const counter = new Counter();
  counter.increment();
  expect(counter.value).toBe(1);
});
```

### Clear
Test names should describe the behavior being tested.

```typescript
// BAD
test("test1", () => { ... });

// GOOD
test("returns empty array when no users match filter", () => { ... });
```

## Test Patterns

### Arrange-Act-Assert (AAA)

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

### Given-When-Then (BDD)

```typescript
describe("Shopping Cart", () => {
  describe("given an empty cart", () => {
    describe("when adding a product", () => {
      it("then cart contains one item", () => {
        const cart = new Cart();
        cart.add(product);
        expect(cart.items).toHaveLength(1);
      });
    });
  });
});
```

## Commands

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
