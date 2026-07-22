---
name: postmortem
description: Runs this framework's blameless postmortem workflow — reconstruct the incident timeline from evidence, drive five-whys to a mechanism-level root cause, and produce owner-and-due-date action items with a regression guard. Use when an incident just resolved, running an outage retrospective, writing a postmortem, or doing a "what went wrong" analysis.
metadata:
  category: encoded-preference
---

# Postmortem

## Timing and Framing

- Write within 48 hours of resolution — logs, dashboards, and people's memory of the incident channel all decay fast after that window closes.
- Blameless framing is non-negotiable: name mechanisms, never people. "The on-call engineer missed the alert" is not a finding; "the alert routed to a channel nobody watches after hours" is.
- Track progress with the template's own `Status` field: Draft while the timeline and action items are still being filled in, In Review once complete, Complete once signed off.

## Workflow

Work through `resources/postmortem.template.md` section by section — reference its actual headings, don't invent parallel ones.

1. **Timeline** — reconstruct from evidence: logs, deploy history, alert-firing times, dashboards. Cite the source for every row; "I remember it happening around..." is not a timeline entry.
2. **Root Cause** — five-whys down to a MECHANISM (a missing check, an untested path, an alert that never existed). Stop at a process/system cause, not a person. If a Contributing Factor looks like "Human Error," restate it as the gap that let the error through.
3. **Impact** — fill the User Impact and Business Impact tables with real numbers before writing prose. Unquantified impact under-motivates the action items that follow.
4. **Action Items** — every row needs an owner, a due date, and a tracking issue link. No row ships with any of the three blank.
5. **Prevention** — the trigger identified in Root Cause becomes a test, an alert, or a hook. Pick the strongest rung the trigger can support on the enforcement ladder (`security.md`: prose rule < skill < hook < CI) — a hook or CI check that blocks recurrence beats a prose reminder nobody re-reads.
6. **File it** — `artifacts/postmortem_[incident-id].md`, per CLAUDE.md's artifact table.

## Handoffs

- Follow-up work → a GitHub Issue (or `ISSUES.md`) per action item, plus an entry on the orchestrator's native task list — not one bundled issue for the whole postmortem.
- Systemic fixes that need design work, not just a ticket → `/swarm-plan`.
- Link each action item's Tracking Issue column to the issue, and the issue back to the postmortem artifact path — a handoff isn't done until it's verifiable in both directions.

## Resources

- [Postmortem Template](./resources/postmortem.template.md)

## Related Skills

`testing`, `swarm-coordination`
