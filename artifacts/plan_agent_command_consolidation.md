# Plan: Agent & Command Matrix Consolidation

**Date**: 2026-02-02
**Decision Type**: Two-Way Door (reversible from git history)
**Based on**: `artifacts/review_agent_command_consolidation.md`

---

## Objective

Consolidate the agent/command matrix from 21 to 14 files (~33% reduction) while preserving all essential capabilities. Centralize duplicated content into rules. Reduce token overhead by ~40%.

---

## Scope

### Agents: 8 → 5

| Action | File | Rationale |
|--------|------|-----------|
| **DELETE** | worker-tester.md | Identical tools to worker-builder; testing focus via prompt |
| **DELETE** | worker-refactor.md | Identical tools to worker-builder; refactor focus via prompt |
| **DELETE** | worker-security.md | Identical tools to worker-reviewer; security focus via prompt |
| **UPDATE** | worker-builder.md | Absorb testing + refactoring capabilities |
| **UPDATE** | worker-reviewer.md | Absorb security analysis capabilities |
| KEEP | worker-explorer.md | Unique: Haiku model (cost optimization) |
| KEEP | worker-researcher.md | Unique: WebFetch/WebSearch tools |
| KEEP | worker-architect.md | Unique: Opus model (deep reasoning) |

### Commands: 13 → 9

| Action | File | Rationale |
|--------|------|-----------|
| **DELETE** | reviewer.md | /swarm-review covers formal reviews; lightweight review is base behavior |
| **DELETE** | refactoring-engineer.md | "Two Hats Rule" moves to rules; base Claude handles refactoring |
| **DELETE** | sre.md | tech-strategy.md covers infra; 0 inbound handoff refs from surviving commands |
| **DELETE** | product-manager.md | PR-FAQ/PRD templates exist in skills; 1 inbound ref (swarm-plan) |
| **SLIM** | code-check.md | 207→~80 lines; extract SOLID/DRY/smell catalogs to rules |
| **SLIM** | swarm-review.md | 165→~80 lines; extract OWASP table, perf checklist to rules |
| **SLIM** | swarm-execute.md | 147→~70 lines; extract git protocol, worker table to rules |
| **SLIM** | swarm-plan.md | 127→~70 lines; extract ADR template (already in skills) |
| **UPDATE** | builder.md | Slim down; absorb "review handoff" since /reviewer deleted |
| KEEP | architect.md | Unique: Sequential Thinking MCP + ADR workflow |
| KEEP | qa-engineer.md | Unique: Chrome DevTools MCP |
| KEEP | security-auditor.md | Unique: STRIDE + threat modeling |
| KEEP | ui-ux-designer.md | Unique: Chrome DevTools + a11y |

### Rules: Update 3

| Action | File | Changes |
|--------|------|---------|
| **UPDATE** | security.md | Add OWASP Top 10 2021 table, severity classification |
| **UPDATE** | code-quality.md | Add performance checklist, quality gates, "Two Hats Rule" |
| **UPDATE** | swarm-workers.md | Add worker focus modes, update worker table, consolidate git push protocol |
| KEEP | core-directives.md | No changes |
| KEEP | tech-strategy.md | No changes |

### Cross-References: Update ~12 files

| File | Update Needed |
|------|---------------|
| CLAUDE.md | Remove 4 deleted commands from personas table |
| architect.md | Update handoff (remove "To Builder" if still valid, update refs) |
| builder.md | Remove handoff to deleted commands |
| qa-engineer.md | Update handoff refs |
| security-auditor.md | Update handoff refs |
| ui-ux-designer.md | Update handoff refs |
| code-check.md | Update handoff refs |
| swarm-plan.md | Update handoff refs |
| swarm-execute.md | Update worker table, handoff refs |
| swarm-review.md | Update handoff refs |
| docs/personas.md | Remove deleted personas |
| docs/swarm.md | Update worker table |
| docs/handoffs.md | Update handoff chains |
| docs/getting-started.md | Update examples |
| README.md | Update feature list |

---

## Task Breakdown

### Task 1: Centralize security content in rules/security.md
**Acceptance Criteria**:
- OWASP Top 10 2021 table (from swarm-review.md lines 42-55)
- Severity classification table (Critical/High/Medium/Low with definitions)
- CWE reference guidance (from worker-security.md)
- Existing checklist preserved and enhanced

### Task 2: Centralize quality content in rules/code-quality.md
**Acceptance Criteria**:
- Performance checklist added (N+1, blocking I/O, allocations, pagination, caching)
- Quality gates definition added (tests, linter, types, build, security audit)
- "Two Hats Rule" added (from refactoring-engineer.md lines 20-21)
- Existing SOLID/DRY content preserved (single source of truth)

### Task 3: Update rules/swarm-workers.md with focus modes
**Acceptance Criteria**:
- Worker focus modes section added (review, security, test, refactor)
- Worker types table updated to show 5 agents
- Git push protocol consolidated here as single source
- Swarm patterns updated to reference only surviving workers
- Worker Completion Requirements preserved

### Task 4: Consolidate agents (delete 3, update 2)
**Depends on**: Tasks 1-3
**Acceptance Criteria**:
- worker-tester.md deleted
- worker-refactor.md deleted
- worker-security.md deleted
- worker-builder.md updated: adds testing + refactoring capabilities, "Two Hats" reference
- worker-reviewer.md updated: adds OWASP severity, CWE references, security focus mode

### Task 5: Delete 4 commands
**Depends on**: Tasks 1-3
**Acceptance Criteria**:
- reviewer.md deleted
- refactoring-engineer.md deleted
- sre.md deleted
- product-manager.md deleted
- No unique content lost (all absorbed into rules or already in skills)

### Task 6: Slim down 4 bloated commands
**Depends on**: Tasks 1-3
**Acceptance Criteria**:
- code-check.md: Remove inline SOLID/DRY definitions (reference rules/code-quality.md). Remove code smell catalog and complexity metrics (reference skills). Keep audit workflow and orchestrator logic. Target ~80 lines.
- swarm-review.md: Remove inline OWASP table (reference rules/security.md). Remove inline performance checklist (reference rules/code-quality.md). Keep adversarial questions, Five Whys, verdict framework. Target ~80 lines.
- swarm-execute.md: Remove inline worker table (reference rules/swarm-workers.md). Remove inline git push protocol (reference rules/swarm-workers.md). Remove inline quality gates (reference rules/code-quality.md). Keep execution workflow, checkpointing, error handling. Target ~70 lines.
- swarm-plan.md: Remove inline ADR template (already in skills/architecture/writing-adrs). Keep decision framework, parallel exploration pattern, Beads creation. Target ~70 lines.

### Task 7: Update all cross-references (commands + CLAUDE.md + templates)
**Depends on**: Tasks 4-6
**Acceptance Criteria**:
- CLAUDE.md personas table: 9 entries (was 13)
- All surviving command handoff sections updated:
  - Remove references to deleted commands (/reviewer, /refactoring-engineer, /sre, /product-manager)
  - Replace with surviving equivalents or remove if no equivalent needed
- Artifact templates: Update owner/handoff references in templates/artifacts/
- No broken references anywhere in .claude/ directory

### Task 8: Update documentation (docs/ + README.md)
**Depends on**: Task 7
**Acceptance Criteria**:
- README.md: Updated persona list (9 commands), updated examples
- docs/personas.md: Updated table, remove 4 deleted entries
- docs/swarm.md: Updated worker table (5 workers), updated patterns
- docs/handoffs.md: Updated handoff chains
- docs/getting-started.md: Updated examples if they reference deleted commands

---

## Dependency Graph

```
Task 1 (security.md)  ──┐
Task 2 (code-quality.md)─┼──→ Task 4 (agents)  ──┐
Task 3 (swarm-workers.md)┤                        │
                          ├──→ Task 5 (commands) ──┼──→ Task 7 (cross-refs) ──→ Task 8 (docs)
                          │                        │
                          └──→ Task 6 (slim)    ──┘
```

**Parallelism**:
- Tasks 1, 2, 3 run in parallel (independent rule updates)
- Tasks 4, 5, 6 run in parallel (all depend on 1-3, independent of each other)
- Task 7 runs after 4-6 complete
- Task 8 runs after 7 completes

---

## Expected Outcome

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Agent files | 8 | 5 | -37% |
| Command files | 13 | 9 | -31% |
| Total agent+command files | 21 | 14 | -33% |
| Est. tokens (agents+commands) | ~11,500 | ~6,900 | -40% |
| Security checklist copies | 4 | 1 | -75% |
| SOLID definition copies | 3 | 1 | -67% |
| Git protocol copies | 3 | 1 | -67% |

---

## What's Preserved

- All 3 model tiers (Haiku/Sonnet/Opus) with cost justification
- All MCP integrations (Sequential Thinking, Chrome DevTools, Context7)
- All orchestration workflows (plan/execute/review)
- All unique content: "Two Hats Rule", STRIDE, Five Whys, adversarial questions
- 57 skills untouched
- Beads integration untouched
- Hook system untouched
- Settings/permissions untouched

## What's Lost (Acceptable)

- Dedicated `/reviewer` command → `/swarm-review` for formal reviews, base behavior for quick reviews
- Dedicated `/refactoring-engineer` → "Two Hats Rule" in code-quality.md rule, base behavior for refactoring
- Dedicated `/sre` → tech-strategy.md covers infra choices
- Dedicated `/product-manager` → PR-FAQ/PRD skills already exist in skills library
- 3 redundant worker agents → absorbed into worker-builder and worker-reviewer with focus modes

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Focus modes less effective than dedicated workers | Rules provide explicit checklists; orchestrators specify focus in prompts |
| Users miss deleted commands | CLAUDE.md documents base Claude handles impl/review/refactoring |
| Cross-reference edits miss something | Task 7 includes grep verification pass |
| Need to reverse a deletion | Git history preserves all files; Two-Way Door |

---

## Handoff

Execute with `/swarm-execute` using the 8 Beads created for this plan.
- Tasks 1-3: worker-builder agents (rule file updates)
- Tasks 4-5: worker-builder agents (delete + update)
- Task 6: worker-builder agents (slim down)
- Task 7-8: worker-builder agents (cross-reference updates)
