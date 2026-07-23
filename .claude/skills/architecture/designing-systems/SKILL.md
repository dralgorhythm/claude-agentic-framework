---
name: designing-systems
description: Produces this framework's ADR and system-design artifacts from bundled templates with trade-off analysis. Use when designing a system or component, choosing between architectures, or recording an architecture decision in the planning flow.
---

# Designing Systems

## Artifact Selection

- **ADR** (`./artifacts/adr_[topic].md`, [template](./resources/adr.template.md)): one decision — a choice among alternatives with rationale and consequences.
- **System Design Doc** (`./artifacts/system_design_[component].md`, [template](./resources/system-design.template.md)): a whole system or component — architecture, data model, API, NFRs, phased plan.

A new system usually needs both: the system design doc for the overall shape, plus an ADR for each decision worth justifying independently (e.g., "why Postgres over DynamoDB").

## Workflow

- [ ] **Requirements**: Gather functional and non-functional requirements
- [ ] **Diagram**: Draft a Mermaid diagram showing components and their boundaries
- [ ] **Data & API**: Define the data model, storage strategy, and interface contracts
- [ ] **Trade-offs**: For each major decision, table Option A vs Option B — pros, cons, when to choose
- [ ] **Risks**: Identify single points of failure
- [ ] **Tech Strategy**: Confirm every technology choice matches `.claude/rules/tech-strategy.md` — no deviation without explicit instruction
- [ ] **Document**: Fill in the matching template and save under `./artifacts/`

## Design-Validation Loop

1. Draft the artifact from the template
2. Review with stakeholders
3. Build a POC for the riskiest component
4. Refine the design from POC findings
5. Finalize the artifact

## Resources

- [System Design Template](./resources/system-design.template.md)
- [ADR Template](./resources/adr.template.md)
