# Claude Agentic Framework

Drop-in framework for optimized Claude Code workflows with specialized personas and reusable skills.

## Quick Reference

```bash
# Add your project's key commands here
# npm run build | pytest | cargo test | go test ./...
```

## Core Principles

These seven principles distill every rule, skill, and standard in this framework. Follow them and everything else follows.

### 1. Understand First

Read before writing. Grep before creating. Never modify code you haven't read. Check what exists before building something new.

### 2. Prove It Works

Write tests for the customer use case first. Run them before committing. Every bug fix gets a regression test. All quality gates must pass — tests, linter, types, build.

### 3. Keep It Safe

No secrets in code — use env vars or secret managers. Validate all external input. Parameterized queries only. Least privilege everywhere. Flag vulnerabilities immediately.

### 4. Keep It Simple

Small functions, single responsibility. No premature abstraction — three similar lines beat a bad helper. Delete dead code. Avoid `any` types. Fix warnings before committing.

### 5. Don't Repeat Yourself

Check `.claude/skills/` before ad-hoc generation. Follow existing patterns in the codebase. Single source of truth for business logic. Extract only when duplication is real, not incidental.

### 6. Ship It

Work on a branch, never main. Commit iteratively. Push to remote — work isn't done until `git push` succeeds. Never leave changes stranded locally.

### 7. Leave a Trail

Planning artifacts go in `./artifacts/`. Track work with Beads (`bd` CLI). Document architectural decisions in ADRs. Name things so the next person understands.

## Tech Stack

@.claude/rules/tech-strategy.md

## Workflow

**Branching**: Always branch from `main`. Never commit directly to `main`.

**Planning flow**: PR-FAQ → PRD → ADR → Design Spec → Plan → Implementation Beads

**Artifacts**: All planning docs stored in `./artifacts/`:

| Type | Pattern | Example |
|------|---------|---------|
| Vision | `pr_faq_[feature].md` | `pr_faq_user_auth.md` |
| Requirements | `prd_[feature].md` | `prd_user_auth.md` |
| Architecture | `adr_[topic].md` | `adr_database_choice.md` |
| System Design | `system_design_[component].md` | `system_design_api.md` |
| Design | `design_spec_[component].md` | `design_spec_login_form.md` |
| Roadmap | `roadmap_[project].md` | `roadmap_mvp.md` |
| Plan | `plan_[task].md` | `plan_api_refactor.md` |
| Security Audit | `security_audit_[date].md` | `security_audit_2025-01.md` |
| Post-Mortem | `postmortem_[incident-id].md` | `postmortem_inc-2025-001.md` |

**Beads** (issue tracking — CLI saves 98% tokens vs MCP):

```bash
bd create "Task"                        # Create
bd ready                                # Find unblocked work
bd show <id>                            # View details
bd update <id> --status in_progress     # Claim
bd close <id>                           # Complete
bd sync                                 # Sync with git
```

See `beads-workflow` skill for complete command reference.

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

## Skills

Check `.claude/skills/` before ad-hoc generation. Skills are auto-suggested based on context via `.claude/skills/skill-rules.json`.
