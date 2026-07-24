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

## Agent-Specific Threats

Beyond STRIDE, include this class whenever the design under review has a tool/model boundary:

- **Indirect prompt injection**: a directive embedded in tool output (fetched web page, file contents, API response) that the model executes as if the user had typed it
- **Tool poisoning**: a compromised or malicious MCP server/tool that returns crafted output designed to manipulate the calling agent
- **Instruction-hierarchy violation**: content from a lower-trust source (tool output, retrieved document) overriding system- or developer-level instructions
- **Over-scoped tokens**: credentials or API keys granted broader access than the task requires, widening the blast radius of a successful injection
- **Config-as-code execution paths**: hooks, settings, and MCP definitions that execute automatically on checkout — see `.claude/rules/security.md`'s "Untrusted Content & Prompt Injection" section

## Threat Model Document

```markdown
## Asset: User Database

### Threats
| Threat | Type | Severity | Remediation |
|--------|------|----------|--------------|
| SQL Injection | Tampering | High | Parameterized queries |
| Data Breach | Info Disclosure | Critical | Encryption at rest, access logging |
```
