# PRD: [Feature Name]

<!--
Product Requirements Document
Filename: artifacts/prd_[feature].md
Owner: Architect (/architect)
Handoff to: Architect (/architect), UI/UX Designer (/ui-ux-designer)
Related Skills: writing-prds, decomposing-tasks, requirements-analysis
-->

## Overview

**Status:** Draft | In Review | Approved
**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Version:** [1.0]
**Beads Issue:** [bd://issue-id or N/A]
**PR-FAQ:** [Link to approved PR-FAQ - required for new initiatives]
**Stakeholders:** [List]

## Problem Statement

[What problem are we solving? Who has this problem? Why does it matter?]

### Evidence

Great PRDs prove problems exist with evidence. Include both types:

**Quantitative Evidence** (numbers that demonstrate impact):
- [Financial metric: e.g., "$X lost per month due to..."]
- [Behavioral data: e.g., "Y% of users abandon at step Z"]
- [Volume indicator: e.g., "N support tickets/week about..."]

**Qualitative Evidence** (insights that explain the human side):
- [User quote: "Direct feedback from user research..."]
- [Support insight: "Common complaint pattern..."]
- [Observation: "During usability testing, we saw..."]

## Goals & Success Metrics

| Goal | Metric | Target |
|------|--------|--------|
| [Goal 1] | [Metric] | [Target value] |
| [Goal 2] | [Metric] | [Target value] |

## User Stories

<!--
Use INVEST criteria for all stories:
- Independent: Self-contained
- Negotiable: Not a contract
- Valuable: Delivers value
- Estimable: Can be sized
- Small: Fits in a sprint
- Testable: Clear acceptance criteria
-->

### [Persona 1]

- As a [persona], I want [capability] so that [benefit]
  - Acceptance: [Testable criteria]
- As a [persona], I want [capability] so that [benefit]
  - Acceptance: [Testable criteria]

### [Persona 2]

- As a [persona], I want [capability] so that [benefit]
  - Acceptance: [Testable criteria]

## Requirements

### Functional Requirements

| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| FR-1 | [Requirement] | Must Have | |
| FR-2 | [Requirement] | Should Have | |
| FR-3 | [Requirement] | Nice to Have | |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | Performance | [e.g., < 200ms response time] |
| NFR-2 | Availability | [e.g., 99.9% uptime] |
| NFR-3 | Security | [e.g., SOC 2 compliant] |

## Scope

### In Scope

- [Feature/capability 1]
- [Feature/capability 2]

### Out of Scope

- [Explicitly excluded item 1]
- [Explicitly excluded item 2]

## Dependencies

| Dependency | Owner | Status | Risk |
|------------|-------|--------|------|
| [Dependency 1] | [Team/Person] | [Status] | [Low/Med/High] |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | [L/M/H] | [L/M/H] | [Strategy] |

## Open Questions

- [ ] [Question 1]
- [ ] [Question 2]

## Appendix

### Mockups/Wireframes

[Link or embed]

### Research

[Link to user research, competitive analysis, etc.]

---

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Product | | | Pending |
| Engineering | | | Pending |
| Design | | | Pending |

---

## Next Steps & Handoffs

After PRD approval:

1. [ ] **Architect Review**: Technical feasibility assessment
   - Trigger: `/architect`
   - Output: ADR (`artifacts/adr_[topic].md`)

2. [ ] **UI/UX Designer**: Visual design and wireframes
   - Trigger: `/ui-ux-designer`
   - Output: Design Spec (`artifacts/design_spec_[component].md`)

3. [ ] **Engineering Estimate**: Effort estimation and decomposition
   - Trigger: `/builder` or `/architect`
   - Output: Implementation Plan (`artifacts/plan_[task].md`)

4. [ ] **Create Beads Issues**: Decompose into trackable work items
   - Command: `bd create "Title" -t feature`

**Related Artifacts**:
- ADR: [Link after architect review]
- Design Spec: [Link after designer review]
- Implementation Plan: [Link after decomposition]

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Name] | Initial draft |
| | | | |

<!--
Track major requirement changes here. This helps stakeholders understand
how requirements have evolved and provides context for future reference.
-->
