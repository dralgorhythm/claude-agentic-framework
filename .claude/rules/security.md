# Security Standards

Deep-dive reference for security reviews. See Core Principle 3 ("Keep It Safe") in CLAUDE.md for the essentials.

## Security Checklist

- [ ] No hardcoded secrets or credentials
- [ ] All user input is validated and sanitized
- [ ] SQL queries use parameterized statements
- [ ] Authentication and authorization are properly implemented
- [ ] Sensitive data is encrypted at rest and in transit
- [ ] Error messages don't expose internal details
- [ ] Dependencies are up to date and vulnerability-free

## Common Vulnerabilities

- **Injection**: SQL, Command, XSS
- **Broken Authentication**: Weak passwords, session management issues
- **Sensitive Data Exposure**: Unencrypted data, excessive logging
- **Security Misconfiguration**: Default credentials, unnecessary features
- **Insufficient Logging**: Missing audit trails, inadequate monitoring

## Dependency Safety

- Warn about deprecated or vulnerable dependencies
- Audit new dependencies before adding
- Keep dependencies updated
