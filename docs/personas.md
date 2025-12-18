# Personas

Personas are expert modes. Use a slash command to switch.

## Quick Reference

| Command | Role | Creates |
|---------|------|---------|
| `/architect` | System design | ADRs, system design docs |
| `/builder` | Implementation | Code, tests |
| `/product-manager` | Requirements | PR-FAQs, PRDs |
| `/qa-engineer` | Testing | Test plans, test suites |
| `/reviewer` | Code review | Review feedback |
| `/refactoring-engineer` | Code cleanup | Refactored code |
| `/sre` | Infrastructure | Runbooks, monitoring |
| `/security-auditor` | Security | Audits, threat models |
| `/ui-ux-designer` | Interface design | Design specs, wireframes |

## Usage

Just use the command with your task:

```
/builder fix the caching bug
/architect design the payment system
/product-manager mobile app notifications
```

Or use without arguments to continue from the previous persona's work:

```
/product-manager user auth     # writes PRD
/architect                     # reads PRD, writes design
/builder                       # reads design, implements
```

## How Handoffs Work

```
/product-manager  →  artifacts/pr_faq_*.md, prd_*.md
       ↓
/architect        →  artifacts/adr_*.md, system_design_*.md
       ↓
/builder          →  Code + tests
       ↓
/reviewer         →  Feedback
```

Each persona reads the previous artifacts and builds on them.

## Creating Your Own

See [customization.md](customization.md#adding-a-persona).

---

[← Back to README](../README.md)
