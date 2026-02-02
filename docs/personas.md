# Personas

Personas are expert modes. Use a slash command to switch.

## Quick Reference

| Command | Role | Creates |
|---------|------|---------|
| `/architect` | System design | ADRs, system design docs |
| `/builder` | Implementation | Code, tests |
| `/qa-engineer` | Testing | Test plans, test suites |
| `/security-auditor` | Security | Audits, threat models |
| `/ui-ux-designer` | Interface design | Design specs, wireframes |
| `/code-check` | Codebase audit | SOLID/DRY violations, health report |
| `/swarm-plan` | Planning orchestrator | Parallel exploration, task decomposition |
| `/swarm-execute` | Execution orchestrator | Parallel workers, quality gates |
| `/swarm-review` | Adversarial reviewer | Multi-perspective code review |

## Usage

Just use the command with your task:

```
/builder fix the caching bug
/architect design the payment system
/security-auditor payment system
```

Or use without arguments to continue from the previous persona's work:

```
/architect user auth           # writes design
/builder                       # reads design, implements
/swarm-review                  # reviews code
```

## How Handoffs Work

```
/architect        →  artifacts/adr_*.md, system_design_*.md
       ↓
/builder          →  Code + tests
       ↓
/swarm-review     →  Feedback
```

Each persona reads the previous artifacts and builds on them.

## Creating Your Own

See [customization.md](customization.md#adding-a-persona).

---

[← Back to README](../README.md)
