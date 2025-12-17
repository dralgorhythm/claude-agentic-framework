---
name: domain-driven-design
description: Apply Domain-Driven Design patterns. Use when modeling complex business domains, defining bounded contexts, or designing aggregates. Covers entities, value objects, and repositories.
allowed-tools: Read, Write, Glob, Grep
---

# Domain-Driven Design

## Core Concepts

### Ubiquitous Language
Use the same terminology as domain experts. Code should read like business documentation.

### Bounded Context
A boundary within which a particular domain model is defined and applicable.

### Context Map
Shows how bounded contexts relate to each other.

## Building Blocks

### Entity
Has identity that persists over time. Equality based on ID.

```typescript
class User {
  constructor(
    public readonly id: UserId,
    public email: Email,
    public name: string
  ) {}
}
```

### Value Object
Immutable, equality based on attributes.

```typescript
class Email {
  private constructor(public readonly value: string) {}

  static create(value: string): Email {
    if (!value.includes('@')) {
      throw new Error('Invalid email');
    }
    return new Email(value);
  }

  equals(other: Email): boolean {
    return this.value === other.value;
  }
}
```

### Aggregate
Cluster of entities and value objects with a root entity.

```typescript
class Order { // Aggregate Root
  private items: OrderItem[] = [];

  addItem(product: ProductId, quantity: number): void {
    // Business rules enforced here
    this.items.push(new OrderItem(product, quantity));
  }

  get total(): Money {
    return this.items.reduce((sum, item) => sum.add(item.subtotal), Money.zero());
  }
}
```

### Repository
Abstracts data access for aggregates.

```typescript
interface OrderRepository {
  findById(id: OrderId): Promise<Order | null>;
  save(order: Order): Promise<void>;
}
```

### Domain Event
Something that happened in the domain.

```typescript
class OrderPlaced {
  constructor(
    public readonly orderId: OrderId,
    public readonly userId: UserId,
    public readonly occurredAt: Date
  ) {}
}
```

## Strategic Patterns

### Anti-Corruption Layer
Translate between your model and external systems.

### Shared Kernel
Shared subset of domain model between contexts.

### Customer-Supplier
Upstream provides what downstream needs.
