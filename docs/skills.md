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
- `defense-in-depth` — Layered security architecture

### Engineering
- `implementing-code` — Writing features
- `debugging` — Finding and fixing bugs
- `refactoring-code` — Improving structure
- `optimizing-code` — Performance
- `testing` — Writing tests
- `test-driven-development` — TDD workflow
- `dependency-management` — Package management
- `data-management` — Database design
- `data-to-ui` — JSON to React pipelines

### Product
- `writing-prds` — Product requirements
- `writing-pr-faqs` — Vision documents
- `decomposing-tasks` — Breaking down work
- `execution-roadmaps` — Project planning
- `requirements-analysis` — Clarifying scope
- `documentation` — Technical docs
- `estimating-work` — Effort sizing
- `brainstorming` — Ideation
- `agile-methodology` — Scrum/Kanban
- `context-management` — Onboarding/handoffs
- `reaching-consensus` — Decision facilitation

### Security
- `application-security` — Secure coding
- `threat-modeling` — Identifying threats
- `security-review` — Audits
- `compliance` — Regulatory requirements
- `identity-access` — Auth patterns

### Operations
- `infrastructure` — IaC, cloud setup
- `observability` — Logs, metrics, traces
- `incident-management` — Incident response
- `swarm-coordination` — Multi-agent workflows
- `deploy-railway` — Railway deployments
- `deploy-aws-ecs` — ECS/Fargate deployments
- `deploy-cloudflare` — Cloudflare Pages/Workers
- `chaos-engineering` — Resilience testing

### Design
- `interface-design` — UI/UX
- `accessibility` — a11y
- `design-systems` — Component libraries
- `visual-assets` — Icons, images, graphics
- `component-recipes` — Tailwind component patterns
- `demo-design-tokens` — Default design tokens

### Languages & Frameworks
`typescript` · `python` · `go` · `rust` · `swift` · `kotlin` · `bash` · `terraform` · `react-patterns` · `biome` · `hono` · `tailwind-css` · `framer-motion` · `radix-ui` · `vite` · `expo-router` · `expo-sdk` · `react-native-patterns` · `nativewind` · `reanimated`

## What Triggers Skills

Skills activate based on **keywords** in your prompt (`"deploy"`, `"test"`, `"security"`). The skill-activation hook matches keywords defined in `.claude/skills/skill-rules.json`.

## Creating Your Own

See [customization.md](customization.md#adding-a-skill).

---

[← Back to README](../README.md)
