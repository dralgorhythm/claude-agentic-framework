# Design Framework: [Project Name]

## Core Principles

1. **[Principle 1]**: [Description]
2. **[Principle 2]**: [Description]
3. **[Principle 3]**: [Description]

---

## Design Tokens

### Colors

#### Primary
| Token | Value | Usage |
|-------|-------|-------|
| `primary-50` | #f0f9ff | Backgrounds |
| `primary-500` | #0ea5e9 | Interactive elements |
| `primary-900` | #0c4a6e | Text on light |

#### Neutral
| Token | Value | Usage |
|-------|-------|-------|
| `neutral-100` | #f5f5f5 | Backgrounds |
| `neutral-500` | #737373 | Secondary text |
| `neutral-900` | #171717 | Primary text |

#### Semantic
| Token | Value | Usage |
|-------|-------|-------|
| `success` | #22c55e | Success states |
| `warning` | #f59e0b | Warning states |
| `error` | #ef4444 | Error states |

### Typography

| Token | Font | Size | Weight | Line Height |
|-------|------|------|--------|-------------|
| `heading-1` | Inter | 2.25rem | 700 | 1.2 |
| `heading-2` | Inter | 1.875rem | 600 | 1.25 |
| `body` | Inter | 1rem | 400 | 1.5 |
| `caption` | Inter | 0.875rem | 400 | 1.4 |

### Spacing

| Token | Value |
|-------|-------|
| `space-1` | 0.25rem (4px) |
| `space-2` | 0.5rem (8px) |
| `space-4` | 1rem (16px) |
| `space-8` | 2rem (32px) |

---

## Components

### Atoms

#### Button
```
Variants: primary, secondary, ghost
Sizes: sm, md, lg
States: default, hover, active, disabled, loading
```

#### Input
```
Types: text, email, password, search
States: default, focus, error, disabled
```

### Molecules

#### Form Field
- Label + Input + Helper Text + Error Message

#### Search Bar
- Input + Button + Clear action

### Organisms

#### Header
- Logo + Navigation + User menu

---

## Accessibility

- All interactive elements keyboard accessible
- Color contrast minimum 4.5:1
- Focus states visible
- Error messages announced to screen readers

---

## Responsive Breakpoints

| Name | Min Width |
|------|-----------|
| `sm` | 640px |
| `md` | 768px |
| `lg` | 1024px |
| `xl` | 1280px |
