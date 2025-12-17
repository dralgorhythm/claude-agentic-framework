# Design Spec: [Component Name]

<!--
Visual/UI Design Specification
Filename: artifacts/design_spec_[component].md
Owner: UI/UX Designer (/ui-ux-designer)
Handoff to: Builder (/builder), QA Engineer (/qa-engineer) for accessibility testing
Related Skills: interface-design, accessibility, design-systems, visual-assets

Design Principles:
- Mobile-first responsive design
- WCAG 2.1 AA compliance required
- Design system consistency
-->

## Overview

**Status:** Draft | In Review | Approved
**Designer:** [Name]
**Date:** [YYYY-MM-DD]
**Beads Issue:** [bd://issue-id or N/A]
**Related PRD:** [Link to PRD]
**Approach:** Mobile-first

## Design Goals

- [Goal 1: e.g., Improve task completion rate]
- [Goal 2: e.g., Reduce cognitive load]
- [Goal 3: e.g., Maintain brand consistency]

## User Flow

```
[Start] → [Step 1] → [Step 2] → [Decision Point]
                                    ↓         ↓
                              [Path A]    [Path B]
                                    ↓         ↓
                                [End]     [End]
```

## Component Specifications

### [Component 1]

**Purpose:** [What this component does]

**States:**
| State | Description | Visual |
|-------|-------------|--------|
| Default | [Description] | [Link/Reference] |
| Hover | [Description] | [Link/Reference] |
| Active | [Description] | [Link/Reference] |
| Disabled | [Description] | [Link/Reference] |
| Error | [Description] | [Link/Reference] |

**Properties:**
| Property | Value | Notes |
|----------|-------|-------|
| Width | [Value] | |
| Height | [Value] | |
| Padding | [Value] | |
| Border Radius | [Value] | |

### [Component 2]

[Repeat structure above]

## Layout

### Desktop (1440px+)

```
┌─────────────────────────────────────┐
│  Header                             │
├─────────┬───────────────────────────┤
│         │                           │
│  Side   │     Main Content          │
│  Nav    │                           │
│         │                           │
├─────────┴───────────────────────────┤
│  Footer                             │
└─────────────────────────────────────┘
```

### Tablet (768px - 1439px)

[Layout description]

### Mobile (< 768px)

[Layout description]

## Typography

| Element | Font | Size | Weight | Line Height |
|---------|------|------|--------|-------------|
| H1 | [Font] | [Size] | [Weight] | [Height] |
| H2 | [Font] | [Size] | [Weight] | [Height] |
| Body | [Font] | [Size] | [Weight] | [Height] |
| Caption | [Font] | [Size] | [Weight] | [Height] |

## Colors

| Usage | Token | Light Mode | Dark Mode |
|-------|-------|------------|-----------|
| Primary | --color-primary | #XXXXXX | #XXXXXX |
| Secondary | --color-secondary | #XXXXXX | #XXXXXX |
| Background | --color-bg | #XXXXXX | #XXXXXX |
| Text | --color-text | #XXXXXX | #XXXXXX |
| Error | --color-error | #XXXXXX | #XXXXXX |

## Spacing

Using 8px grid system:
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px

## Animations

<!--
Keep animations subtle and purposeful. Respect prefers-reduced-motion.
Duration: 150-300ms for micro-interactions, 300-500ms for transitions.
-->

| Element | Trigger | Duration | Easing | Properties |
|---------|---------|----------|--------|------------|
| Button | Hover | 150ms | ease-in-out | background-color, transform |
| Modal | Open | 300ms | ease-out | opacity, transform |
| Dropdown | Expand | 200ms | ease-in-out | max-height, opacity |
| [Element] | [Trigger] | [Duration] | [Easing] | [Properties] |

## Accessibility

### Requirements

- [ ] Color contrast ratio ≥ 4.5:1 (AA)
- [ ] Focus indicators visible
- [ ] Keyboard navigation supported
- [ ] Screen reader compatible
- [ ] Touch targets ≥ 44px

### ARIA Labels

| Element | aria-label | aria-describedby |
|---------|------------|------------------|
| [Element] | [Label] | [Description ID] |

## Assets

| Asset | Format | Sizes | Location |
|-------|--------|-------|----------|
| [Icon 1] | SVG | 16, 24, 32 | /assets/icons/ |
| [Image 1] | WebP | 1x, 2x | /assets/images/ |

## Figma/Design Links

- [Main Design File](link)
- [Component Library](link)
- [Prototype](link)

---

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Design Lead | | | Pending |
| Product | | | Pending |
| Engineering | | | Pending |
