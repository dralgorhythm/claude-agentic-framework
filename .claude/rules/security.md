# Security Standards

Deep-dive reference for security reviews. See Core Principle 3 ("Keep It Safe") in CLAUDE.md for the essentials.

## Enforcement Ladder

This file states requirements. It does not, by itself, enforce them. Enforcement strength increases down this ladder:

1. **Prose rules** (this file, CLAUDE.md, `.claude/rules/*`) — advisory. Read by agents as instructions; nothing mechanically checks compliance.
2. **Skills** (`.claude/skills/*`) — on-demand advisory. Surfaced when a task matches, but an agent can still proceed without invoking one.
3. **Hooks** (`.claude/hooks/*`) — deterministic guardrails, not a security boundary. This repo's hooks are **fail-open by design**: if `jq` is missing or input can't be parsed, the check is skipped and the tool call proceeds. See `docs/hooks.md` for the full security model.
4. **`permissions.deny` + CI** — boundaries. `permissions.deny` in `settings.json` cannot be overridden by any allow rule at any scope. CI checks (`.github/workflows/`) run outside the agent's control and block merges on failure.

Only the mechanically checkable items on this page have enforcement below step 1. The checklist states what must be true; it is the hooks, `permissions.deny` entries, and CI jobs cited in each line's parenthetical that actually verify it.

## Security Checklist

- [ ] No hardcoded secrets or credentials (enforced via `pre-tool-use-validator.sh` hook secret detection + CI secret-scan job, Trivy `fs --scanners secret`, blocking)
- [ ] All user input is validated and sanitized (enforce via input validation middleware)
- [ ] SQL queries use parameterized statements
- [ ] Authentication and authorization are properly implemented
- [ ] Sensitive data is encrypted at rest and in transit
- [ ] Error messages don't expose internal details
- [ ] Dependencies are up to date and vulnerability-free (enforce via automated dependency scanning)

## Data Routing

**No Silent External Data Routing**: Data must not leave the system boundary without explicit authorization and documentation.

- All external API calls, webhooks, and data exports must be explicitly documented in the architecture and code
- No data should leave the system boundary without clear authorization from an appropriate owner
- Log all outbound data transfers for audit purposes
- This applies to third-party integrations, analytics pipelines, and monitoring agents — any component that transmits data externally must be inventoried and reviewed

## OWASP Top 10 2021

| Category | Check For |
|----------|-----------|
| Broken Access Control | Missing authorization checks |
| Cryptographic Failures | Unencrypted sensitive data |
| Injection | SQL, Command, XSS vulnerabilities |
| Insecure Design | Missing threat modeling |
| Security Misconfiguration | Default credentials, debug enabled |
| Vulnerable Components | Outdated/CVE-affected packages |
| Auth Failures | Weak passwords, session issues |
| Integrity Failures | Unsigned updates, untrusted deserialization |
| Logging Failures | Missing audit trails |
| SSRF | Unvalidated URLs in server requests |

## Severity Classification

| Severity | Definition | Action |
|----------|------------|--------|
| Critical | Exploitable vulnerability, data loss risk, high impact | MUST fix before merge |
| High | Exploitable vulnerability, breaking change, moderate impact, major bug | MUST fix before merge |
| Medium | Requires conditions to exploit, performance issue, code smell | SHOULD fix, can negotiate |
| Low | Best practice violation, style, minor improvement | COULD fix, optional |

## CWE References

When reporting findings, reference CWE (Common Weakness Enumeration) IDs for standardized vulnerability classification. Example: `CWE-89` for SQL Injection, `CWE-798` for hardcoded credentials.

## Dependency Safety

- Warn about deprecated or vulnerable dependencies
- Audit new dependencies before adding
- Keep dependencies updated
- Use automated scanning (Trivy, Snyk, Dependabot)

## Output Guidelines

- Never expose actual secrets in analysis output
- Provide specific file locations and line numbers
- Include concrete remediation steps
- Check both code AND configuration files
