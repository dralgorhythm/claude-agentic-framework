---
name: threat-modeling
description: Identify and analyze security threats. Use when designing a feature with security implications, before implementing auth/input-handling code, or when an audit calls for a threat model. Covers STRIDE methodology.
---

# Threat Modeling

## Procedure

1. **Map Attack Surface**: Use Grep and Glob to find entry points and trust boundaries; sketch the data flow.
2. **Enumerate Threats**: Work through STRIDE per component — Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege. Use Sequential Thinking to cover each category systematically.
3. **Trace Data Flow**: Use Grep to trace user input → processing → storage, authentication token flow, and sensitive data paths, watching for injection and leakage points.
4. **Rate Severity**: Classify each threat as Critical / High / Medium / Low per the definitions in `.claude/rules/security.md` — Critical and High findings MUST be fixed before merge.
5. **Record Findings**: Document each threat with its STRIDE category, severity, and remediation.

## Threat Model Document

```markdown
## Asset: User Database

### Threats
| Threat | Type | Severity | Remediation |
|--------|------|----------|--------------|
| SQL Injection | Tampering | High | Parameterized queries |
| Data Breach | Info Disclosure | Critical | Encryption at rest, access logging |
```
