# Claude Agentic Framework

Drop-in framework for optimized Claude Code workflows with specialized personas and reusable skills.

## Quick Reference

```bash
# Add repository-specific key commands here.
# E.g. npm run build, npm run test
```

## Critical Directives

@.claude/rules/core-directives.md

## Code Quality

@.claude/rules/code-quality.md

## Security

@.claude/rules/security.md

## Tech Stack

@.claude/rules/tech-strategy.md

## Personas

| Command | Role | Use |
|---------|------|-----|
| `/architect` | Principal Architect | System design, ADRs |
| `/builder` | Software Engineer | Implementation, debugging |
| `/product-manager` | Product Manager | PR-FAQs, PRDs, requirements |
| `/qa-engineer` | QA Engineer | Test strategy |
| `/reviewer` | Code Reviewer | Code review, security |
| `/refactoring-engineer` | Refactoring Engineer | Code cleanup, optimization |
| `/sre` | SRE | Infrastructure, DevOps |
| `/security-auditor` | Security Auditor | Threat modeling, audits |
| `/ui-ux-designer` | UI/UX Designer | Interface design, a11y |
| `/code-check` | Codebase Auditor | SOLID, DRY, consistency audits |
| `/swarm-plan` | Planning Orchestrator | Parallel exploration, decomposition |
| `/swarm-execute` | Execution Orchestrator | Parallel workers, quality gates |
| `/swarm-review` | Adversarial Reviewer | Multi-perspective code review |

## Planning Flow

```
PR-FAQ → PRD → ADR → Design Spec → Plan → Implementation Beads
```

## Artifacts

All planning docs in `./artifacts/` and all templates from `templates/`.

For naming conventions, see the **Artifact Naming Convention** section in `.claude/rules/core-directives.md`.

## Skills

Check `.claude/skills/` before ad-hoc generation. Skills are auto-suggested based on context via `.claude/skills/skill-rules.json`.

## Issue Tracking (Beads)

Use **CLI commands** for Beads - saves 98% tokens vs MCP.

```bash
bd create "Task"           # Create issue
bd ready                   # Find unblocked work
bd show <id>               # View issue details
bd update <id> --status in_progress  # Claim
bd close <id> --reason "Done"        # Complete
bd sync                    # Sync with git
```

See `beads-workflow` skill for complete command reference.
