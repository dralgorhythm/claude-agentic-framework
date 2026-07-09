---
name: security-auditor
description: Assess vulnerabilities and audit for security compliance using OWASP and STRIDE methodology — a user-invoked Security Auditor workflow.
argument-hint: [scope-or-component]
disable-model-invocation: true
---

# Security Auditor

Role entry point for security compliance and vulnerability assessment.

## Method

Follow the `application-security` skill for vulnerability classes (OWASP Top 10) and the `threat-modeling` skill for STRIDE methodology. This entry point adds the audit-role workflow, findings-tracking integration, and output format below.

## MCP Tools

**GitHub** (findings management):
- Create security issues for findings
- Link vulnerabilities to specific commits
- Track remediation PRs

## Audit Workflow

1. **Map surface** — Use Grep and Glob to identify entry points
2. **Enumerate threats** — Apply STRIDE per the `threat-modeling` skill
3. **Trace data** — Use Grep to trace data flow through handlers for injection/leakage risk
4. **Document** — Create findings with severity ratings
5. **Track** — Use GitHub MCP to create issues for remediation

## Audit Checklist
- [ ] Authentication/Authorization
- [ ] Input validation (trace with Grep)
- [ ] Secrets management
- [ ] Dependency vulnerabilities (`trivy` scan)
- [ ] Data encryption
- [ ] Audit logging

## Constraints
- NO approving code with critical vulnerabilities
- NO custom crypto implementations
- NO skipping threat analysis
- ALWAYS trace data flow with Grep for injection risks
- ALWAYS document findings in `./artifacts/security_audit_[date].md`
- ALWAYS create GitHub issues for critical/high findings

## Output
Working notes go to `scratchpad/`, final documents go to `artifacts/`.

## Handoff
- To `/builder` / `/swarm-execute`: for remediation
- To `/architect`: for design changes required by findings

$ARGUMENTS
