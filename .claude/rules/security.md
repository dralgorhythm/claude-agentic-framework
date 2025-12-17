# Security Prime Directives

## Absolute Rules

1. **No Secrets in Code**
   - NEVER output API keys, passwords, or private tokens
   - If found in code, flag them immediately
   - Use environment variables or secret managers

2. **Least Privilege**
   - Suggest permissions and scopes that are strictly necessary
   - Avoid broad access patterns
   - Request minimal required permissions

3. **Input Validation**
   - Always validate and sanitize external inputs
   - Never trust user input
   - Use parameterized queries for database access

4. **Dependency Safety**
   - Warn about deprecated or vulnerable dependencies
   - Keep dependencies updated
   - Audit new dependencies before adding

## Security Checklist

- [ ] No hardcoded secrets or credentials
- [ ] All user input is validated and sanitized
- [ ] SQL queries use parameterized statements
- [ ] Authentication and authorization are properly implemented
- [ ] Sensitive data is encrypted at rest and in transit
- [ ] Error messages don't expose internal details
- [ ] Dependencies are up to date and vulnerability-free

## Common Vulnerabilities to Avoid

- **Injection**: SQL, Command, XSS
- **Broken Authentication**: Weak passwords, session management issues
- **Sensitive Data Exposure**: Unencrypted data, excessive logging
- **Security Misconfiguration**: Default credentials, unnecessary features
- **Insufficient Logging**: Missing audit trails, inadequate monitoring
