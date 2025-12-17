---
name: threat-modeling
description: Identify and analyze security threats. Use when designing systems, reviewing architecture, or assessing risk. Covers STRIDE methodology.
allowed-tools: Read, Write, Glob, Grep
---

# Threat Modeling

## Why Threat Model?

- Identify threats early
- Prioritize security efforts
- Document security assumptions
- Guide security testing

## STRIDE Methodology

### S - Spoofing
Pretending to be someone else.
- **Example**: Forged authentication tokens
- **Mitigation**: Strong authentication, MFA

### T - Tampering
Modifying data without authorization.
- **Example**: Changing request parameters
- **Mitigation**: Integrity checks, signatures

### R - Repudiation
Denying an action occurred.
- **Example**: User denies making transaction
- **Mitigation**: Audit logging, non-repudiation

### I - Information Disclosure
Exposing confidential data.
- **Example**: API returns sensitive fields
- **Mitigation**: Encryption, access controls

### D - Denial of Service
Making system unavailable.
- **Example**: Resource exhaustion attack
- **Mitigation**: Rate limiting, auto-scaling

### E - Elevation of Privilege
Gaining unauthorized access.
- **Example**: User becomes admin
- **Mitigation**: Least privilege, input validation

## Threat Modeling Process

### 1. Decompose System
- Identify assets
- Draw data flow diagrams
- Identify entry points
- Identify trust boundaries

### 2. Identify Threats
For each component, ask STRIDE questions.

### 3. Rate Threats
Use DREAD or CVSS scoring:
- **D**amage potential
- **R**eproducibility
- **E**xploitability
- **A**ffected users
- **D**iscoverability

### 4. Mitigate
- Avoid: Remove the feature
- Transfer: Use third-party
- Mitigate: Add controls
- Accept: Document risk

## Data Flow Diagram

```
[User] --HTTPS--> [API Gateway] --Internal--> [Service]
                        |                         |
                        v                         v
                   [Auth DB]                 [Data DB]
```

## Threat Model Document

```markdown
## Asset: User Database

### Threats
| Threat | Type | Likelihood | Impact | Risk |
|--------|------|------------|--------|------|
| SQL Injection | Tampering | Medium | High | High |
| Data Breach | Info Disclosure | Low | Critical | High |

### Mitigations
1. Parameterized queries
2. Encryption at rest
3. Access logging
```
