---
name: testing
description: Write effective tests for code quality and reliability. Use when implementing features, fixing bugs, improving coverage, or practicing TDD/test-driven development. Covers unit, integration, and E2E testing.
---

# Testing Software

## Verification Loop First

Give every change a check it can run before calling it done: red-then-green for new logic, a failing-then-passing regression test for bug fixes, or the existing suite for anything else. No change ships without one.

**Red-green-observe, not red-green-assume**: "confirm it fails" (the Regression workflow item below, and TDD's "watch it fail" step) means actually *run* the test and *read* the failure output before touching the fix or the implementation — never reason your way to "this must fail" and skip the run.

**Falsifiable done-when**: before writing a feature's implementation, state one concrete, checkable condition that defines done — not "should work now," a condition a test or command can confirm or refute.

**Evidence over narration**: a completion claim is only as good as what it cites — a pasted test-run result, a real exit code, a pushed commit SHA. Describing what the code should now do is not evidence; re-running the check and quoting its output is.

## MCP Tools

**Chrome DevTools** (E2E testing):
- Automate user flows in real browser
- Capture screenshots for visual regression
- Run Lighthouse for accessibility testing
- Profile performance during test runs

## Workflow

- [ ] **Analyze**: Use Glob and Grep to identify untested code
- [ ] **Unit Tests**: Cover all public functions
- [ ] **Edge Cases**: Test boundaries and error conditions
- [ ] **Integration**: Test external dependencies
- [ ] **E2E**: Use Chrome DevTools for browser automation
- [ ] **Regression**: Add a test that reproduces the bug, confirm it fails against the current code, then fix — keep it passing and in the suite afterward (never delete or skip it)

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
Tests must produce the same result every time — no reliance on wall-clock time, random values, or uncontrolled external state.

### Isolated
Tests must not depend on each other or share mutable state.

### Clear
Test names describe the behavior under test, not just the function name.
