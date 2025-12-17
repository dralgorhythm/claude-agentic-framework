---
name: design-systems
description: Build and maintain design systems. Use when creating component libraries, design tokens, or style guides. Covers atomic design and tokens.
allowed-tools: Read, Write, Glob, Grep
---

# Design Systems

## What is a Design System?

A collection of reusable components, guided by clear standards, that can be assembled to build applications.

## Components

### Atomic Design

**Atoms**: Basic building blocks
- Buttons, inputs, labels, icons

**Molecules**: Simple combinations
- Search bar (input + button)
- Form field (label + input + error)

**Organisms**: Complex components
- Header, sidebar, card

**Templates**: Page layouts
- Dashboard, settings page

**Pages**: Specific instances
- User dashboard, admin settings

## Design Tokens

```json
{
  "color": {
    "primary": {
      "50": "#f0f9ff",
      "500": "#0ea5e9",
      "900": "#0c4a6e"
    },
    "neutral": {
      "100": "#f5f5f5",
      "900": "#171717"
    }
  },
  "spacing": {
    "1": "0.25rem",
    "2": "0.5rem",
    "4": "1rem",
    "8": "2rem"
  },
  "font": {
    "family": {
      "sans": "Inter, sans-serif",
      "mono": "JetBrains Mono, monospace"
    },
    "size": {
      "sm": "0.875rem",
      "base": "1rem",
      "lg": "1.125rem"
    }
  },
  "radius": {
    "sm": "0.25rem",
    "md": "0.375rem",
    "lg": "0.5rem"
  }
}
```

## Component API

```typescript
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'ghost';
  size: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  children: ReactNode;
  onClick?: () => void;
}
```

## Documentation

Each component should document:
- **Usage**: When to use
- **Props**: Available options
- **Examples**: Common patterns
- **Accessibility**: A11y considerations
- **Do/Don't**: Best practices

## Resources

- [Design Framework Template](./resources/design-framework.template.md)
