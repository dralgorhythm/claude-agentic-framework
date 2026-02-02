# Post-Mortem: [Incident Title]

<!--
Incident Post-Mortem Report
Filename: artifacts/postmortem_[incident-id].md
Owner: Architect (/architect)
Handoff to: Architect (/architect) for design changes, Builder (/builder) for fixes
Related Skills: incident-management, observability, infrastructure

Blameless culture: Focus on systems and processes, not individuals.
-->

## Summary

**Incident ID:** [INC-XXXX]
**Date:** [YYYY-MM-DD]
**Duration:** [X hours Y minutes]
**Severity:** SEV1 | SEV2 | SEV3 | SEV4
**Status:** Draft | In Review | Complete
**Beads Issue:** [bd://issue-id or N/A]

**Author:** [Name]
**Incident Commander:** [Name]
**Reviewers:** [Names]

### One-Line Summary

[Brief description of what happened and impact]

---

## Impact

### User Impact

| Metric | Value |
|--------|-------|
| Users Affected | [Number or %] |
| Duration of Impact | [Time] |
| Error Rate Peak | [%] |
| Support Tickets | [Number] |

### Business Impact

| Metric | Value |
|--------|-------|
| Revenue Impact | [$X or N/A] |
| SLA Breach | [Yes/No] |
| Customer Notifications | [Number] |

### Systems Affected

- [System/Service 1]
- [System/Service 2]

---

## Timeline

All times in UTC.

| Time | Event |
|------|-------|
| HH:MM | [First alert/detection] |
| HH:MM | [Incident declared, severity assigned] |
| HH:MM | [Investigation started] |
| HH:MM | [Root cause identified] |
| HH:MM | [Mitigation applied] |
| HH:MM | [Service restored] |
| HH:MM | [Incident closed] |

---

## Root Cause

### What Happened

[Detailed technical explanation of the failure chain]

### Why It Happened

[Analysis of underlying causes - use 5 Whys if helpful]

1. **Why?** [First level cause]
2. **Why?** [Second level cause]
3. **Why?** [Third level cause]
4. **Why?** [Fourth level cause]
5. **Why?** [Root cause]

### Trigger

[What specific event or change triggered the incident?]

---

## Contributing Factors

Factors that made the incident possible or worse:

- [ ] **Detection Gap**: [Monitoring didn't catch it]
- [ ] **Process Gap**: [Missing runbook/procedure]
- [ ] **Testing Gap**: [Untested scenario]
- [ ] **Documentation Gap**: [Missing/outdated docs]
- [ ] **Capacity Issue**: [Resource constraints]
- [ ] **Dependency Failure**: [External service]
- [ ] **Configuration Error**: [Misconfiguration]
- [ ] **Code Defect**: [Bug in code]
- [ ] **Human Error**: [Manual mistake]

Details:
- [Factor 1]: [Explanation]
- [Factor 2]: [Explanation]

---

## Detection

### How Was It Detected?

- [ ] Automated monitoring/alerting
- [ ] Customer report
- [ ] Internal user report
- [ ] Scheduled check
- [ ] Other: [specify]

### Detection Delay

<!--
Key Incident Metrics:
- TTD: When did we first know something was wrong?
- TTA: When did someone acknowledge and start investigating?
- TTM: When was the bleeding stopped (even if not fully fixed)?
- TTR: When was the incident fully resolved?
- MTTR (Mean Time to Recovery) = TTR, used for aggregate reporting
-->

| Metric | Value | Notes |
|--------|-------|-------|
| Time to Detection (TTD) | [X minutes] | First alert or report |
| Time to Acknowledgment (TTA) | [X minutes] | Investigation started |
| Time to Mitigation (TTM) | [X minutes] | Bleeding stopped |
| Time to Resolution (TTR/MTTR) | [X minutes] | Fully resolved |

### Detection Gaps

[What should have alerted us but didn't?]

---

## Response

### What Went Well

- [Positive 1: e.g., "Quick escalation to on-call"]
- [Positive 2: e.g., "Clear communication in incident channel"]
- [Positive 3: e.g., "Runbook was helpful"]

### What Didn't Go Well

- [Issue 1: e.g., "Took too long to identify root cause"]
- [Issue 2: e.g., "Missing access to logs"]
- [Issue 3: e.g., "Unclear ownership"]

### Where We Got Lucky

- [Lucky break 1: e.g., "Engineer happened to be online"]
- [Lucky break 2: e.g., "Impact was during low-traffic period"]

---

## Resolution

### Immediate Fix

[What was done to stop the bleeding?]

```
[Commands/steps taken]
```

### Verification

[How did we confirm the fix worked?]

---

## Action Items

### Immediate (Within 1 Week)

| Action | Owner | Due Date | Status | Beads Issue |
|--------|-------|----------|--------|-------------|
| [Action 1] | [Name] | [Date] | Open | [bd://xxx] |
| [Action 2] | [Name] | [Date] | Open | [bd://xxx] |

### Short-Term (Within 1 Month)

| Action | Owner | Due Date | Status | Beads Issue |
|--------|-------|----------|--------|-------------|
| [Action 1] | [Name] | [Date] | Open | [bd://xxx] |

### Long-Term (Within 1 Quarter)

| Action | Owner | Due Date | Status | Beads Issue |
|--------|-------|----------|--------|-------------|
| [Action 1] | [Name] | [Date] | Open | [bd://xxx] |

---

## Prevention

### How Do We Prevent Recurrence?

[Specific technical and process changes]

### How Do We Detect Faster?

[New alerts, dashboards, or checks to add]

### How Do We Recover Faster?

[Runbook updates, automation, or process improvements]

---

## Lessons Learned

### Key Takeaways

1. [Lesson 1]
2. [Lesson 2]
3. [Lesson 3]

### Process Improvements

- [Improvement 1]
- [Improvement 2]

---

## Appendix

### Related Incidents

- [Link to similar past incidents]

### Relevant Logs/Dashboards

- [Link to logs]
- [Link to dashboard]
- [Link to traces]

### External References

- [Vendor post-mortem if applicable]
- [Related documentation]

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Author | | |
| Incident Commander | | |
| Engineering Lead | | |
| Product Owner | | |
