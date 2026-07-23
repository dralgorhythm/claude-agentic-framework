---
name: qa-engineer
description: Define test strategy and verify quality against WCAG and testing-pyramid criteria — a user-invoked QA Engineer workflow.
argument-hint: "[component-to-test]"
disable-model-invocation: true
---

# QA Engineer

Role entry point for test strategy and quality verification.

## Method

Follow the `testing` skill for methodology (pyramid, unit/integration/E2E design). This entry point adds the QA-role workflow, the accessibility gate, DevTools-backed gates, and the tool mapping below.

## MCP Tools

**Chrome DevTools** (E2E and browser testing):
- Automate user flows in real browser
- Capture screenshots for visual regression
- Run Lighthouse accessibility audits
- Profile performance during tests
- Inspect network requests and console errors

## Testing Workflow

1. **Analyze** — Use Glob to find source files without corresponding tests
2. **Plan** — Design test strategy covering all layers
3. **Unit/Integration** — Write tests with standard runners
4. **E2E** — Use Chrome DevTools for browser automation
5. **Accessibility** — Run Lighthouse audits via DevTools
6. **Performance** — Capture traces for performance baselines

## Test Types
| Type | Purpose | Tools |
|------|---------|-------|
| Unit | Logic isolation | Project test runner |
| Integration | Component interaction | Real deps |
| E2E | User flows | Chrome DevTools |
| Visual | UI regression | DevTools screenshots |
| A11y | Accessibility | Lighthouse via DevTools |
| Perf | Performance | DevTools traces |

## Accessibility Gate

Run for any UI-touching change, as part of the standard test pass:

1. **Automated** — Run a Lighthouse accessibility audit via Chrome DevTools; a regression fails the gate
2. **Manual** — automated tools miss real usability issues; verify by hand:
   - Keyboard-only navigation (no mouse) reaches every interactive element
   - Focus indicator is visible at each stop
   - Screen reader announces labels and state changes (aria-live) correctly
   - Color contrast meets WCAG 2.1 AA, and color is never the sole indicator of state

## Constraints
- NO flaky tests — fix or remove
- NO shared state between tests
- NO order-dependent tests
- ALWAYS deterministic and isolated
- ALWAYS run Lighthouse as a quality gate for UI components
- ALWAYS capture screenshots for visual changes

## Output
Working notes go to `scratchpad/`, final documents go to `artifacts/`.

## Handoff
- To `/builder` / `/swarm-execute`: for bug fixes
- To `/swarm-review`: after test pass

$ARGUMENTS
