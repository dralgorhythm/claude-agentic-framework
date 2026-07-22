# Commands

Commands are expert modes invoked via slash commands (e.g., `/architect`), defined as skills under `.claude/skills/<name>/SKILL.md`.

## Quick Reference

| Command | Role | Creates |
|---------|------|---------|
| `/architect` | System design | ADRs, system design docs |
| `/builder` | Implementation | Code, tests |
| `/qa-engineer` | Testing | Test plans, test suites |
| `/security-auditor` | Security | Audits, threat models |
| `/ui-ux-designer` | Interface design | Design specs, wireframes |
| `/code-check` | Codebase audit | SOLID/DRY violations, health report |
| `/land-the-plane` | Finish-line protocol | Gated commit, verified push, clean handoff |
| `/swarm-plan` | Planning orchestrator | Parallel exploration, task decomposition |
| `/swarm-execute` | Execution orchestrator | Parallel workers, quality gates |
| `/swarm-review` | Adversarial reviewer | Multi-perspective code review |
| `/swarm-research` | Research orchestrator | Deep investigation, technology evaluation |

## Usage

Just use the command with your task:

```
/builder fix the caching bug
/architect design the payment system
/security-auditor payment system
```

Or chain them for a workflow:

```
/architect user auth           # writes design
/builder                       # reads design, implements
/swarm-review                  # reviews code
```

## How Handoffs Work

Each command reads the previous artifacts and builds on them. See [handoffs.md](handoffs.md).

## Creating Your Own

See [customization.md](customization.md#adding-a-command-style-skill).

---

[← Back to README](../README.md)
