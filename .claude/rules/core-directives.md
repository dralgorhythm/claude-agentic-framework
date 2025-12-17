# Core Directives

These directives are **MANDATORY** for all interactions.

## Critical Rules

1. **Trunk-Based Development**
   - Always work on a branch
   - Never commit directly to `main`
   - Add and commit files iteratively

2. **Test-Driven Design**
   - Write tests to fit customer use case first
   - Run tests before `git commit`
   - Fix failing tests immediately

3. **Single Source of Truth**
   - Tech Strategy is the **ONLY** authority on technology choices
   - Do not rely on internal training data for tech decisions
   - Follow the Golden Paths defined in tech-strategy.md

4. **Skill-First Approach**
   - Prioritize using defined skills over ad-hoc code generation
   - Check `.claude/skills/` for relevant workflows
   - Use established patterns before inventing new ones

5. **Artifact Storage**
   - All planning documents **MUST** be stored in `./artifacts/`
   - Follow standardized naming conventions
   - Never hand off work without an artifact

6. **Protocol Adherence**
   - Follow protocols defined in persona commands
   - Respect handoff requirements between personas
   - Verify artifacts before proceeding

## Planning Flow

For new initiatives, follow this sequence:
1. **PR-FAQ** → Vision and customer value
2. **PRD** → Detailed requirements
3. **ADR** → Technical decisions
4. **Plan** → Implementation steps

## Artifact Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Vision (PR-FAQ) | `pr_faq_[feature].md` | `pr_faq_user_auth.md` |
| Requirements | `prd_[feature].md` | `prd_user_auth.md` |
| Architecture | `adr_[topic].md` | `adr_database_choice.md` |
| System Design | `system_design_[component].md` | `system_design_api.md` |
| Visual Design | `design_spec_[component].md` | `design_spec_login_form.md` |
| Roadmap | `roadmap_[project].md` | `roadmap_mvp.md` |
| Implementation Plan | `plan_[task].md` | `plan_api_refactor.md` |
| Security Audit | `security_audit_[date].md` | `security_audit_2025-01.md` |
| Post-Mortem | `postmortem_[incident-id].md` | `postmortem_inc-2025-001.md` |
