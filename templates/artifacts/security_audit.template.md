# Security Audit: [Scope/Component]

<!--
Security Audit Report
Filename: artifacts/security_audit_[date].md
Owner: Security Auditor (/security-auditor)
Handoff to: Builder (/builder) for remediation, Architect (/architect) for design changes
Related Skills: application-security, threat-modeling, security-review, compliance, identity-access

Methodology:
- STRIDE threat modeling (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation)
- OWASP Top 10 (2021) - https://owasp.org/Top10/
- MITRE ATT&CK framework for advanced threat mapping - https://attack.mitre.org/
- CWE (Common Weakness Enumeration) for vulnerability classification
- Dependency scanning (Trivy, Snyk, or equivalent)

For cloud-native systems, also consider:
- Shared responsibility model (what's provider-managed vs customer-managed)
- IAM policies, roles, and service accounts
- Network segmentation (VPCs, security groups)
- Managed service configurations
-->

## Executive Summary

**Audit Date:** [YYYY-MM-DD]
**Auditor:** [Name]
**Beads Issue:** [bd://issue-id or N/A]
**Scope:** [What was audited]
**Overall Risk Level:** Critical | High | Medium | Low

### Summary of Findings

| Severity | Count | Remediated |
|----------|-------|------------|
| Critical | 0 | 0 |
| High | 0 | 0 |
| Medium | 0 | 0 |
| Low | 0 | 0 |
| Informational | 0 | N/A |

## Scope

### In Scope

- [Component/System 1]
- [Component/System 2]
- [API endpoints]
- [Data flows]

### Out of Scope

- [Explicitly excluded items]

### Methodology

- [ ] Static code analysis
- [ ] Dynamic testing
- [ ] Dependency scanning
- [ ] Configuration review
- [ ] Threat modeling (STRIDE)

### Pre-Audit Checklist

From `/security-auditor` persona requirements:

- [ ] Authentication/Authorization reviewed
- [ ] Input validation verified
- [ ] Secrets management audited
- [ ] Dependency vulnerabilities scanned
- [ ] Data encryption confirmed
- [ ] Audit logging verified

## STRIDE Threat Analysis

| Threat | Description | Mitigated | Notes |
|--------|-------------|-----------|-------|
| **S**poofing | Identity impersonation | Yes/No/Partial | |
| **T**ampering | Data modification | Yes/No/Partial | |
| **R**epudiation | Deny actions | Yes/No/Partial | |
| **I**nformation Disclosure | Data exposure | Yes/No/Partial | |
| **D**enial of Service | Availability attacks | Yes/No/Partial | |
| **E**levation of Privilege | Unauthorized access | Yes/No/Partial | |

## Findings

### Critical Findings

#### [FINDING-001] [Title]

**Severity:** Critical
**Status:** Open | Remediated | Accepted Risk
**CWE:** [CWE-XXX]
**CVSS:** [Score]

**Description:**
[Detailed description of the vulnerability]

**Location:**
- File: `path/to/file.ts:123`
- Endpoint: `POST /api/vulnerable`

**Impact:**
[What could happen if exploited]

**Proof of Concept:**
```
[Code or steps to reproduce]
```

**Remediation:**
```
[Code fix or mitigation steps]
```

**References:**
- [OWASP Reference](link)
- [CVE if applicable](link)

---

### High Findings

#### [FINDING-002] [Title]

**Severity:** High
**Status:** Open | Remediated | Accepted Risk
**CWE:** [CWE-XXX]

[Same structure as above]

---

### Medium Findings

#### [FINDING-003] [Title]

**Severity:** Medium
**Status:** Open | Remediated | Accepted Risk
**CWE:** [CWE-XXX]

[Same structure as above]

---

### Low Findings

#### [FINDING-004] [Title]

**Severity:** Low
**Status:** Open | Remediated | Accepted Risk

[Same structure as above]

---

### Informational

#### [INFO-001] [Title]

[Observations, best practices, recommendations]

---

## OWASP Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| A01: Broken Access Control | Pass/Fail | [Notes] |
| A02: Cryptographic Failures | Pass/Fail | [Notes] |
| A03: Injection | Pass/Fail | [Notes] |
| A04: Insecure Design | Pass/Fail | [Notes] |
| A05: Security Misconfiguration | Pass/Fail | [Notes] |
| A06: Vulnerable Components | Pass/Fail | [Notes] |
| A07: Auth Failures | Pass/Fail | [Notes] |
| A08: Data Integrity Failures | Pass/Fail | [Notes] |
| A09: Logging Failures | Pass/Fail | [Notes] |
| A10: SSRF | Pass/Fail | [Notes] |

## Cloud-Native Security Assessment

*Skip this section if not applicable to your architecture.*

### Shared Responsibility Model

| Security Control | Provider Managed | Customer Managed | Status |
|-----------------|------------------|------------------|--------|
| Physical security | ✅ | | N/A |
| Network infrastructure | ✅ | | N/A |
| Hypervisor | ✅ | | N/A |
| OS patching | [Varies] | [Varies] | [Status] |
| Application security | | ✅ | [Status] |
| Data encryption | [Varies] | ✅ | [Status] |
| IAM configuration | | ✅ | [Status] |
| Network configuration | | ✅ | [Status] |

### IAM Review

| Resource | Permissions | Least Privilege | Notes |
|----------|-------------|-----------------|-------|
| [Service Role] | [Permissions] | Yes/No | [Notes] |
| [User Role] | [Permissions] | Yes/No | [Notes] |

### Network Security

- [ ] VPC/Network isolation configured
- [ ] Security groups follow least privilege
- [ ] Private subnets used for sensitive workloads
- [ ] No public IPs on internal services
- [ ] VPC flow logs enabled

### Managed Services Configuration

| Service | Configuration Review | Status |
|---------|---------------------|--------|
| [RDS/Database] | Encryption, backups, public access | [Status] |
| [S3/Storage] | Bucket policies, encryption, versioning | [Status] |
| [Lambda/Compute] | IAM roles, VPC config, secrets | [Status] |

## Dependency Analysis

### Vulnerable Dependencies

| Package | Version | Vulnerability | Severity | Fix Version |
|---------|---------|---------------|----------|-------------|
| [pkg] | [ver] | [CVE-XXXX] | [Sev] | [ver] |

### Outdated Dependencies

| Package | Current | Latest | Risk |
|---------|---------|--------|------|
| [pkg] | [ver] | [ver] | [L/M/H] |

## Configuration Review

### Secrets Management

- [ ] No hardcoded secrets in code
- [ ] Environment variables properly configured
- [ ] Secrets rotation policy in place

### Authentication

- [ ] Strong password policy enforced
- [ ] MFA available/required
- [ ] Session management secure

### Authorization

- [ ] Principle of least privilege applied
- [ ] Role-based access control implemented
- [ ] API authorization consistent

### Data Protection

- [ ] Data encrypted at rest
- [ ] Data encrypted in transit (TLS 1.2+)
- [ ] PII handling compliant

## Recommendations

### Immediate Actions (Critical/High)

1. [Action 1]
2. [Action 2]

### Short-term (Medium)

1. [Action 1]
2. [Action 2]

### Long-term (Low/Best Practices)

1. [Action 1]
2. [Action 2]

## Remediation Tracking

| Finding | Owner | Due Date | Beads Issue | Status |
|---------|-------|----------|-------------|--------|
| FINDING-001 | [Name] | [Date] | [bd://issue-xxx] | Open |
| FINDING-002 | [Name] | [Date] | [bd://issue-yyy] | In Progress |

## MITRE ATT&CK Mapping

*For advanced persistent threat (APT) analysis. Skip for basic audits.*

| Tactic | Technique ID | Technique Name | Mitigated | Notes |
|--------|--------------|----------------|-----------|-------|
| Initial Access | T1190 | Exploit Public-Facing App | Yes/No | [Details] |
| Persistence | T1078 | Valid Accounts | Yes/No | [Details] |
| Privilege Escalation | T1068 | Exploitation for Priv Esc | Yes/No | [Details] |
| Defense Evasion | T1562 | Impair Defenses | Yes/No | [Details] |
| Credential Access | T1110 | Brute Force | Yes/No | [Details] |
| Lateral Movement | T1021 | Remote Services | Yes/No | [Details] |
| Exfiltration | T1048 | Exfil Over Alt Protocol | Yes/No | [Details] |

*Reference: https://attack.mitre.org/matrices/enterprise/*

## Appendix

### Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| [Tool 1] | [Ver] | [Purpose] |
| [Tool 2] | [Ver] | [Purpose] |

### Test Cases

[Detailed test cases if applicable]

---

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Security Lead | | | |
| Engineering Lead | | | |
| Product Owner | | | |
