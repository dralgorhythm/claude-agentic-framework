# Plan: [Task Name]

<!--
Implementation Plan
Filename: artifacts/plan_[task].md
Owner: Builder (/builder) or Architect (/architect)
Handoff to: Builder (/builder), QA Engineer (/qa-engineer)
Related Skills: implementing-code, debugging, testing, test-driven-development
-->

## Overview

**Status:** Draft | Approved | In Progress | Complete
**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Beads Issue:** [bd://issue-id or N/A]
**Related PRD:** [Link to PRD]
**Related ADR:** [Link to ADR]

## Objective

[Clear, concise statement of what this plan will accomplish]

## Scope

### In Scope

- [Item 1]
- [Item 2]

### Out of Scope

- [Item 1]
- [Item 2]

## Technical Approach

### Architecture Changes

```
[Diagram or description of architectural changes]
```

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| [Decision 1] | [Why] |
| [Decision 2] | [Why] |

## Implementation Steps

### Phase 1: [Setup/Preparation]

- [ ] **Step 1.1:** [Description]
  - Files: `path/to/file.ts`
  - Details: [Additional context]

- [ ] **Step 1.2:** [Description]
  - Files: `path/to/file.ts`
  - Details: [Additional context]

### Phase 2: [Core Implementation]

- [ ] **Step 2.1:** [Description]
  - Files: `path/to/file.ts`
  - Details: [Additional context]

- [ ] **Step 2.2:** [Description]
  - Files: `path/to/file.ts`
  - Details: [Additional context]

### Phase 3: [Testing & Cleanup]

- [ ] **Step 3.1:** Write unit tests
  - Files: `path/to/file.test.ts`
  - Coverage: [Target %]

- [ ] **Step 3.2:** Integration testing
  - Scenarios: [List]

- [ ] **Step 3.3:** Documentation
  - Update: [Files/sections]

## Files to Modify

| File | Action | Description |
|------|--------|-------------|
| `path/to/file.ts` | Create | [Purpose] |
| `path/to/existing.ts` | Modify | [Changes] |
| `path/to/old.ts` | Delete | [Reason] |

## Dependencies

### Code Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [package] | [version] | [why needed] |

### Service Dependencies

| Service | Status | Notes |
|---------|--------|-------|
| [Service] | [Available/Needed] | [Notes] |

## Testing Strategy

### Unit Tests

| Component | Test Cases | Status |
|-----------|------------|--------|
| [Component 1] | [Cases] | Pending |
| [Component 2] | [Cases] | Pending |

### Integration Tests

| Scenario | Expected Outcome | Status |
|----------|------------------|--------|
| [Scenario 1] | [Outcome] | Pending |
| [Scenario 2] | [Outcome] | Pending |

### Manual Testing

- [ ] [Test case 1]
- [ ] [Test case 2]

## Rollback Plan

1. [Step to revert if issues arise]
2. [Step to restore previous state]
3. [Verification steps]

## Risks

| Risk | Mitigation |
|------|------------|
| [Risk 1] | [How to handle] |
| [Risk 2] | [How to handle] |

## Checklist

### Before Starting

- [ ] PRD/ADR approved
- [ ] Dependencies available
- [ ] Branch created from main

### Before PR

- [ ] All tests passing
- [ ] No linting errors
- [ ] Documentation updated
- [ ] Self-review complete

### Before Merge

- [ ] Code review approved
- [ ] QA sign-off
- [ ] No merge conflicts

## Notes

[Any additional context, considerations, or comments]

---

## Progress Log

| Date | Update |
|------|--------|
| [Date] | [What was done] |
