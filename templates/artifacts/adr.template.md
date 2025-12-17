# ADR: [Decision Title]

<!--
Architecture Decision Record
Filename: artifacts/adr_NNNN_[topic].md (e.g., adr_0001_database_choice.md)
Owner: Architect (/architect)
Handoff to: Builder (/builder), Security Auditor (/security-auditor)
Related Skills: designing-systems, designing-apis, domain-driven-design, cloud-native-patterns, writing-adrs

Format: Based on MADR (Markdown Any Decision Records) - https://adr.github.io/madr/
Best Practices:
- Write ADRs BEFORE committing to implementation
- Keep them short, specific, and comparable across the codebase
- One decision per ADR (not groups of decisions)
- Quantify when possible (SLOs, latency budgets, cost envelopes)
-->

## Metadata

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** [YYYY-MM-DD]
**Deciders:** [List of people involved]
**Beads Issue:** [bd://issue-id or N/A]
**Related PRD:** [Link to PRD]
**Tech Strategy Alignment:**
- [ ] Decision follows Golden Path in `.claude/rules/tech-strategy.md`
- [ ] OR deviation is explicitly justified in Rationale section
**Domain Tags:** [security | data | integration | infrastructure | api | frontend | devops]
**Supersedes:** [adr_NNNN if applicable]
**Superseded By:** [adr_NNNN if applicable]

## Context

[What is the issue that we're seeing that motivates this decision or change?]

## Decision Drivers

- [Driver 1: e.g., scalability requirements]
- [Driver 2: e.g., team expertise]
- [Driver 3: e.g., time constraints]
- [Driver 4: e.g., cost considerations]

## Considered Options

### Option 1: [Name]

**Description:** [Brief description]

| Pros | Cons |
|------|------|
| [Pro 1] | [Con 1] |
| [Pro 2] | [Con 2] |

### Option 2: [Name]

**Description:** [Brief description]

| Pros | Cons |
|------|------|
| [Pro 1] | [Con 1] |
| [Pro 2] | [Con 2] |

### Option 3: [Name]

**Description:** [Brief description]

| Pros | Cons |
|------|------|
| [Pro 1] | [Con 1] |
| [Pro 2] | [Con 2] |

## Decision Outcome

**Chosen Option:** [Option N]

**Rationale:** [Why this option was selected over others]

### Quantified Impact (where applicable)

| Metric | Before | After | Notes |
|--------|--------|-------|-------|
| Latency (p99) | [X]ms | [Y]ms | [Context] |
| Cost | $[X]/mo | $[Y]/mo | [Context] |
| Throughput | [X] req/s | [Y] req/s | [Context] |
| SLO Impact | [X]% | [Y]% | [Context] |

### Consequences

**Positive:**
- [Consequence 1]
- [Consequence 2]

**Negative:**
- [Consequence 1]
- [Consequence 2]

**Risks:**
- [Risk 1 and mitigation]

## Technical Details

### Architecture

```
[ASCII diagram or description of architecture]
```

### API Contract

```
[Key interfaces, endpoints, or contracts]
```

### Data Model

```
[Key entities and relationships]
```

## Implementation Plan

1. [ ] [Step 1]
2. [ ] [Step 2]
3. [ ] [Step 3]

## Validation

- [ ] Performance benchmarks meet requirements
- [ ] Security review completed
- [ ] Cost analysis approved

## Links

- [Related ADR 1](./adr_related.md)
- [PRD](./prd_feature.md)
- [External documentation]

---

## Changelog

| Date | Author | Change |
|------|--------|--------|
| [Date] | [Name] | Initial draft |
