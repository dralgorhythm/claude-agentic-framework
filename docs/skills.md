# Skills

Skills are structured workflows that Claude suggests based on what you're doing.

## How It Works

You don't invoke skills directly. Just describe what you need:

```
"I need to design an API for user management"
```

Claude sees relevant skills suggested (like `designing-apis`) and uses them to give you a better response.

## Available Skills

### Architecture
- `designing-systems` — Planning systems
- `designing-apis` — REST/GraphQL/gRPC
- `domain-driven-design` — Business domain modeling
- `cloud-native-patterns` — Microservices, containers
- `capacity-planning` — Scale and performance
- `writing-adrs` — Architecture Decision Records

### Engineering
- `implementing-code` — Writing features
- `debugging` — Finding and fixing bugs
- `refactoring-code` — Improving structure
- `optimizing-code` — Performance
- `testing` — Writing tests
- `test-driven-development` — TDD workflow

### Product
- `writing-prds` — Product requirements
- `writing-pr-faqs` — Vision documents
- `decomposing-tasks` — Breaking down work
- `execution-roadmaps` — Project planning

### Security
- `application-security` — Secure coding
- `threat-modeling` — Identifying threats
- `security-review` — Audits

### Operations
- `infrastructure` — IaC, cloud setup
- `observability` — Logs, metrics, traces
- `incident-management` — Incident response

### Design
- `interface-design` — UI/UX
- `accessibility` — a11y
- `design-systems` — Component libraries

### Languages
`typescript` · `python` · `go` · `rust` · `swift` · `kotlin` · `bash` · `terraform`

## What Triggers Skills

Skills activate based on:

- **Keywords** in your prompt (`"deploy"`, `"test"`, `"security"`)
- **Patterns** like `"how do I..."` or `"set up..."`
- **Files** you're working with (`*.tf`, `*.test.ts`)

## Creating Your Own

See [customization.md](customization.md#adding-a-skill).

---

[← Back to README](../README.md)
