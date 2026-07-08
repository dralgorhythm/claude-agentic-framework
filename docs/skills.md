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

## How Skills Activate

Skill discovery is **native and model-driven** — there is no hook and no registry file. At startup, Claude Code loads every skill's `name` and `description` from its `SKILL.md` frontmatter into context. When your prompt matches what a skill's description says it does, Claude reads that skill's full `SKILL.md` body and uses it to shape its response.

This means the `description` field is the entire activation mechanism. Write it well:

- **Third person**, stating both **what the skill does** and **when to use it**.
- Put **trigger phrases first** — the words a user would actually type — so the match happens early in the description.
- Example: `"Guides REST/GraphQL/gRPC API design. Use when designing a new API, choosing between API styles, or reviewing an existing API's contract."`

Every skill's name + description is **always loaded**, regardless of whether it's relevant to the current prompt — budget roughly **~100 tokens per skill**. The full set of listings is capped at a **listing budget of ~1% of the context window**. If you add enough skills to exceed that budget, Claude Code drops or truncates descriptions to fit.

- Run `/doctor` to see which skill descriptions were dropped or truncated.
- Run `/context` to see how much of the context window the skill listing is currently consuming.
- Raise the cap with the `skillListingBudgetFraction` setting if you have many skills and need more headroom.

Caveat: on large-context models, the ~1% budget is currently computed against a ~200K-token baseline rather than the model's true context window (an upstream tracking issue) — so budget math is conservative and the effective allowance may be smaller than 1% of the real window.

### Deterministic activation (optional)

Native discovery is probabilistic — it depends on the model matching your prompt to a description. If you need guaranteed, keyword-based activation instead, see [docs/examples/skill-activation-hook.sh](examples/skill-activation-hook.sh) for an opt-in example hook (disabled by default).

## Creating Your Own

See [customization.md](customization.md#adding-a-skill).

---

[← Back to README](../README.md)
