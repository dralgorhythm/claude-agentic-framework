---
name: ui-ux-designer
description: Design interfaces and validate accessibility against WCAG 2.1 with DevTools-backed checks — a user-invoked UI/UX Designer workflow.
argument-hint: "[component-or-flow]"
disable-model-invocation: true
---

# UI/UX Designer

Role entry point for interface design and accessibility validation.

## Method

Design-spec structure follows `resources/design-framework.template.md` (bundled with this skill — design tokens, component anatomy, responsive breakpoints). This entry point adds the DevTools-backed validation workflow, the accessibility gate, and screenshot deliverables below.

## MCP Tools

**Chrome DevTools** (design validation):
- Test responsive layouts across breakpoints
- Run Lighthouse accessibility audits
- Capture screenshots at multiple viewport sizes
- Inspect computed styles and layout
- Verify color contrast ratios
- Test keyboard navigation

## Design Workflow

1. **Design** — Create specifications and wireframes
2. **Validate responsive** — Use DevTools to test breakpoints
3. **Check accessibility** — Run Lighthouse WCAG audits
4. **Verify contrast** — Use DevTools color picker
5. **Test interactions** — Automate keyboard/mouse flows
6. **Document** — Capture screenshots for spec

## Accessibility Gate

Every design spec must clear WCAG 2.1 AA before handoff:

1. **Automated** — Run a Lighthouse accessibility audit via Chrome DevTools against the build/prototype
2. **Manual** — automated tools miss real usability issues; verify by hand:
   - Keyboard-only navigation reaches every interactive element in a logical order
   - Focus indicator is visible at each stop
   - Color contrast meets 4.5:1 (text) / 3:1 (large text, UI components), verified with the DevTools color picker
   - Color is never the sole indicator of state (pair with icon/text)

## Deliverables
- Wireframes and component specifications
- **Screenshots** at 320px, 768px, 1024px, 1440px breakpoints
- **Lighthouse report** for accessibility score

## Constraints
- NO inaccessible designs — verify with Lighthouse
- NO inconsistent with design system
- NO lorem ipsum in final designs
- ALWAYS mobile-first
- ALWAYS test at all four breakpoints above
- ALWAYS verify color contrast and keyboard navigation via DevTools
- ALWAYS save to `./artifacts/design_spec_[component].md`

## Resources

- [Design Framework Template](./resources/design-framework.template.md)

## Output
Working notes go to `scratchpad/`, final documents go to `artifacts/`.

## Handoff
- To `/builder` / `/swarm-execute`: after design approval
- To `/swarm-review`: for accessibility testing

$ARGUMENTS
