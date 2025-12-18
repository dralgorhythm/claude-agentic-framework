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

## Planning Flow

```
PR-FAQ → PRD → ADR → Design Spec → Plan → Implementation
```

## Artifacts

All planning docs in `./artifacts/`:

| Type | Pattern |
|------|---------|
| Vision | `pr_faq_[feature].md` |
| Requirements | `prd_[feature].md` |
| Architecture | `adr_[topic].md` |
| System Design | `system_design_[component].md` |
| Design Specs | `design_spec_[component].md` |
| Roadmaps | `roadmap_[project].md` |
| Plans | `plan_[task].md` |
| Security | `security_audit_[date].md` |
| Post-mortems | `postmortem_[incident-id].md` |

## Skills

Check `.claude/skills/` before ad-hoc generation. Skills are auto-suggested based on context.

## Issue Tracking (Beads)

Use **CLI commands** for Beads - saves 98% tokens vs MCP.

```bash
bd create "Task"     # Create
bd ready             # Find work
bd update <id> --status in_progress  # Claim
bd update <id> --status done         # Complete
bd sync              # Sync
bd doctor            # Health check
```
