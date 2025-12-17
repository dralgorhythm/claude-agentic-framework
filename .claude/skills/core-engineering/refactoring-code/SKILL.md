---
name: refactoring-code
description: Improve code structure without changing behavior. Use when code is hard to read, modify, or test. Covers Extract Method, Rename, and other safe refactorings.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Refactoring Code

## The Refactoring Hat

When refactoring, you change **structure** without changing **behavior**. Always have tests passing before and after.

## Workflows

- [ ] **Tests Green**: Ensure all tests pass before starting
- [ ] **Small Steps**: Make one small change at a time
- [ ] **Commit Often**: Commit after each successful refactoring
- [ ] **Tests Green**: Verify tests still pass after each change

## Common Refactorings

### Extract Method
When a code block does one thing, extract it to a named method.

```typescript
// Before
function processOrder(order: Order) {
  // Calculate total
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }
  // ... more code
}

// After
function processOrder(order: Order) {
  const total = calculateTotal(order.items);
  // ... more code
}

function calculateTotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
```

### Rename for Clarity
Names should reveal intent.

```typescript
// Before
const d = new Date();
const x = user.fn + ' ' + user.ln;

// After
const currentDate = new Date();
const fullName = user.firstName + ' ' + user.lastName;
```

### Replace Conditional with Polymorphism
When you have repeated switch/if statements on type.

### Introduce Parameter Object
When multiple parameters travel together.

## Code Smells to Address

- **Long Method**: Extract smaller methods
- **Long Parameter List**: Introduce parameter object
- **Duplicate Code**: Extract to shared function
- **Feature Envy**: Move method to the class it uses most
- **Data Clumps**: Group related data into objects
- **Primitive Obsession**: Replace primitives with value objects

## Safety Rules

1. Never refactor and add features simultaneously
2. Run tests after every change
3. Use IDE refactoring tools when available
4. Commit working states frequently
