# Review: Agent & Command Matrix Consolidation

**Date**: 2026-02-02
**Scope**: `.claude/agents/` (8 files), `.claude/commands/` (13 files), `.claude/rules/` (5 files)
**Method**: 8 parallel review workers (overlap, token cost, duality, DRY, consolidation, SOLID, necessity, consistency)

---

## Executive Summary

The framework has **21 agent/command files** with approximately **40% redundancy**. The primary issues are:

1. **Tool-set duplication**: 5 of 8 agents share identical Sonnet + Read/Write/Edit/Bash/Glob/Grep configurations
2. **Agent/command duality**: 6 paired duplicates where agents are stripped-down command copies
3. **Content repetition**: Security checklists appear 4x, SOLID definitions 3x, git push protocol 3x
4. **Personas vs prompts**: Several commands are "good prompts in a file" with no unique tools or workflows

**Recommendation**: Consolidate from 21 to 12 files (~43% reduction), using rules to specialize generic actors.

---

## Finding 1: Tool-Set Overlap (Critical)

Three agent groups share **100% identical tool sets**:

| Group | Agents | Tools | Model |
|-------|--------|-------|-------|
| **Implementation** | worker-builder, worker-refactor, worker-tester | Read, Write, Edit, Bash, Glob, Grep | sonnet |
| **Analysis** | worker-reviewer, worker-security | Read, Glob, Grep, Bash | sonnet |
| **Unique** | worker-explorer (haiku), worker-researcher (web tools), worker-architect (opus) | varied | varied |

**Verdict**: The 3 "unique" agents justify separate files (different model tiers or tools). The 5 duplicative agents should consolidate to 2.

---

## Finding 2: Agent/Command Duality (High)

6 paired duplicates exist where the agent is a condensed copy of the command:

| Agent | Command | Redundancy | Agent Unique Value |
|-------|---------|------------|-------------------|
| worker-builder | /builder | 85% | Tool restriction (no Task/MCP) |
| worker-reviewer | /reviewer | 90% | Read-only enforcement |
| worker-architect | /architect | 75% | Model tier (Opus) |
| worker-security | /security-auditor | 80% | Focused scope |
| worker-refactor | /refactoring-engineer | 85% | None (identical tools to builder) |
| worker-tester | /qa-engineer | 95% | None (identical tools to builder) |

**Verdict**: Agents only justify separate existence when they have a different **model tier** or **tool restriction**. worker-refactor and worker-tester add zero value over worker-builder.

---

## Finding 3: DRY Violations (High)

### Centralize Immediately

| Content | Files Containing It | Recommendation |
|---------|---------------------|----------------|
| **Security/OWASP checklist** | security.md, security-auditor.md, swarm-review.md, worker-security.md | Single source in `rules/security.md` |
| **SOLID definitions** | code-quality.md, code-check.md, worker-refactor.md | Single source in `rules/code-quality.md` |
| **Performance checklist** | reviewer.md, swarm-review.md, worker-reviewer.md | Add to `rules/code-quality.md` |
| **Git push protocol** | CLAUDE.md, swarm-workers.md, swarm-execute.md | Single source in `rules/swarm-workers.md` |
| **Quality gates** | CLAUDE.md, swarm-execute.md | Add to `rules/code-quality.md` |
| **Worker types table** | swarm-workers.md, swarm-execute.md | Single source in `rules/swarm-workers.md` |

### Keep Inline (Context-Specific)

- "NO placeholders/TODOs" constraint (reinforces at point of use)
- "ALWAYS use Grep before..." (context-specific emphasis)
- Beads CLI commands (shown in different workflow contexts)
- Output format templates (each role has genuinely different output)
- Handoff sections (persona-specific routing)

---

## Finding 4: Necessity Analysis (High)

### ESSENTIAL (unique tools, model, or workflow) — Keep

| Item | Type | Why Essential |
|------|------|---------------|
| worker-explorer | Agent | Haiku model = 90% cost savings |
| worker-researcher | Agent | WebFetch/WebSearch tools unavailable elsewhere |
| worker-architect | Agent | Opus model for deep reasoning |
| /swarm-plan | Command | Orchestration: parallel workers, Beads, artifact creation |
| /swarm-execute | Command | Orchestration: quality gates, git push, worker delegation |
| /swarm-review | Command | Orchestration: parallel adversarial review, Five Whys |

### VALUABLE (meaningful structure beyond prompting) — Keep

| Item | Type | Why Valuable |
|------|------|--------------|
| worker-builder | Agent | Tool restriction prevents sub-worker spawning |
| worker-reviewer | Agent | Read-only enforcement (no Write/Edit) |
| /architect | Command | Sequential Thinking MCP + ADR workflow |
| /code-check | Command | 207-line audit methodology too complex for ad-hoc prompts |
| /qa-engineer | Command | Chrome DevTools MCP for E2E/a11y |
| /security-auditor | Command | STRIDE via Sequential Thinking + GitHub issues |
| /ui-ux-designer | Command | Chrome DevTools for responsive/a11y testing |

### REDUNDANT (achievable with rules + good prompts) — Consolidate

| Item | Type | Why Redundant | Absorb Into |
|------|------|---------------|-------------|
| worker-tester | Agent | Identical tools to worker-builder | worker-builder |
| worker-refactor | Agent | Identical tools to worker-builder | worker-builder |
| worker-security | Agent | Identical tools to worker-reviewer | worker-reviewer |
| /builder | Command | Just adds GitHub MCP; 90% from base + rules | Rules + prompting |
| /reviewer | Command | Checklist-only; no unique workflow | /swarm-review for formal reviews |
| /refactoring-engineer | Command | "Two Hats Rule" should be a rule, not a persona | Rules |
| /product-manager | Command | PR-FAQ/PRD templates should be skills, not persona | Skills |
| /sre | Command | Just reminds to use Terraform/GH Actions; tech-strategy covers it | Rules |

---

## Finding 5: SOLID Scorecard

| Principle | Grade | Key Issue |
|-----------|-------|-----------|
| **SRP** | C- | code-check.md has 6+ responsibilities; reviewer vs swarm-review unclear |
| **OCP** | B | Skills provide extension, but swarm-review hardcodes review perspectives |
| **LSP** | D | Workers with identical tool sets aren't interchangeable (different output contracts) |
| **ISP** | B+ | Agent tool sets are well-scoped; some commands have unnecessary tools |
| **DIP** | D- | Handoffs hardcode concrete persona names; no abstract role contracts |

**Biggest architectural weakness**: Lack of abstraction. Commands reference each other by name, creating tight coupling. Renaming a command requires cascading edits.

---

## Finding 6: Consistency Issues

### Structural

| Issue | Detail |
|-------|--------|
| Section headers vary | Agents use "Focus" / "Capabilities" / "Directives" / "Checklist" interchangeably |
| code-check.md missing `allowed-tools:` frontmatter | Only command with this omission |
| swarm-execute.md missing "Related Skills" and "Handoff" | Only command missing both |
| Output formats inconsistent | 6/8 agents have them, only 2/13 commands do |

### Naming Misalignment

| Agent | Command | Match |
|-------|---------|-------|
| worker-refactor | refactoring-engineer | Mismatch |
| worker-security | security-auditor | Mismatch |
| worker-tester | qa-engineer | Mismatch |

---

## Finding 7: Token Cost

| Category | Files | Lines | Est. Tokens | % of Total |
|----------|-------|-------|-------------|------------|
| Agents | 8 | 242 | ~2,000 | 17% |
| Commands | 13 | 1,117 | ~9,500 | 83% |
| **Total** | **21** | **1,359** | **~11,500** | 100% |

### Most Bloated Files

| File | Lines | Signal/Noise | Issue |
|------|-------|-------------|-------|
| code-check.md | 207 | 3/10 | SOLID catalog, code smells, metrics — all duplicated from rules |
| swarm-review.md | 165 | 3.5/10 | OWASP table, perf checklist, Five Whys — largely from rules |
| swarm-execute.md | 147 | 4/10 | Git protocol, worker table, quality gates — duplicated |
| swarm-plan.md | 127 | 4.5/10 | ADR template, decision framework — could be skills |

**Estimated savings from deduplication alone**: ~4,800 tokens (42%)

---

## Recommended Consolidation Plan

### Phase 1: Delete Redundant Agents (3 files)

```
DELETE: .claude/agents/worker-tester.md
DELETE: .claude/agents/worker-refactor.md
DELETE: .claude/agents/worker-security.md

UPDATE: .claude/agents/worker-builder.md
  - Add: testing, refactoring capabilities from deleted files
  - Add: "Two Hats Rule" from refactoring-engineer

UPDATE: .claude/agents/worker-reviewer.md
  - Add: OWASP severity levels from worker-security
  - Add: CWE reference guidance
```

**Result**: 8 agents → 5 agents

### Phase 2: Delete Redundant Commands (5 files)

```
DELETE: .claude/commands/builder.md
DELETE: .claude/commands/reviewer.md
DELETE: .claude/commands/refactoring-engineer.md
DELETE: .claude/commands/product-manager.md
DELETE: .claude/commands/sre.md

KEEP (with updates):
  /architect        — absorb design validation from ui-ux-designer
  /qa-engineer      — primary testing/validation command
  /security-auditor — STRIDE + formal audits
  /ui-ux-designer   — Chrome DevTools design focus
  /code-check       — SLIM DOWN to orchestrator only
  /swarm-plan       — SLIM DOWN, reference rules
  /swarm-execute    — SLIM DOWN, reference rules
  /swarm-review     — SLIM DOWN, reference rules
```

**Result**: 13 commands → 8 commands

### Phase 3: Centralize Shared Content into Rules

```
UPDATE: .claude/rules/security.md
  - Add: Full OWASP Top 10 2021 table
  - Add: Severity classification (Critical/High/Medium/Low)
  - Add: CWE reference patterns

UPDATE: .claude/rules/code-quality.md
  - Add: Performance checklist (N+1, blocking I/O, etc.)
  - Add: Quality gates definition
  - Keep: Existing SOLID + DRY content (single source of truth)

UPDATE: .claude/rules/swarm-workers.md
  - Add: Worker focus modes (review, security, test, refactor)
  - Remove: Redundant worker table from swarm-execute
  - Add: Git push protocol (single source)

CREATE: .claude/skills/pr-faq-template/ (from product-manager)
CREATE: .claude/skills/prd-template/ (from product-manager)
```

### Phase 4: Slim Down Remaining Commands

Target: Each command under 80 lines. Move reference content to rules.

| Command | Current Lines | Target Lines | Cut |
|---------|---------------|--------------|-----|
| code-check | 207 | ~60 | Remove SOLID/DRY/smell catalogs (→ rules) |
| swarm-review | 165 | ~70 | Remove OWASP table, perf checklist (→ rules) |
| swarm-execute | 147 | ~60 | Remove git protocol, worker table (→ rules) |
| swarm-plan | 127 | ~60 | Remove ADR template (→ skill), decision framework inline |

---

## Final State

### Files After Consolidation

```
.claude/
├── agents/ (5 files, was 8)
│   ├── worker-architect.md     # Opus, design decisions
│   ├── worker-builder.md       # Sonnet, impl + test + refactor
│   ├── worker-explorer.md      # Haiku, read-only search
│   ├── worker-researcher.md    # Sonnet, web research
│   └── worker-reviewer.md      # Sonnet, review + security analysis
├── commands/ (8 files, was 13)
│   ├── architect.md            # System design, ADRs
│   ├── code-check.md           # Codebase audit orchestrator
│   ├── qa-engineer.md          # Testing + Chrome DevTools
│   ├── security-auditor.md     # STRIDE + threat modeling
│   ├── swarm-execute.md        # Execution orchestrator
│   ├── swarm-plan.md           # Planning orchestrator
│   ├── swarm-review.md         # Adversarial review orchestrator
│   └── ui-ux-designer.md       # Interface design + a11y
└── rules/ (5 files, updated)
    ├── code-quality.md         # + performance checklist, quality gates
    ├── core-directives.md      # unchanged
    ├── security.md             # + OWASP Top 10, severity levels
    ├── swarm-workers.md        # + focus modes, git push protocol
    └── tech-strategy.md        # unchanged
```

**Total: 18 files (was 26) — 31% reduction**
**Estimated token savings: ~4,800 tokens (42%)**

---

## Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Agent files | 8 | 5 | -37% |
| Command files | 13 | 8 | -38% |
| Total files | 21 | 13 | -38% |
| Est. tokens | ~11,500 | ~6,700 | -42% |
| Security checklist copies | 4 | 1 | -75% |
| SOLID definition copies | 3 | 1 | -67% |
| Git protocol copies | 3 | 1 | -67% |

---

## What's Preserved

- All 3 model tiers (Haiku/Sonnet/Opus) with clear cost justification
- All MCP tool integrations (Sequential Thinking, Chrome DevTools, Context7)
- All orchestration workflows (plan/execute/review)
- All unique workflow content ("Two Hats Rule", STRIDE, Five Whys, adversarial questions)
- Beads integration throughout

## What's Lost (Acceptable)

- Dedicated `/builder` command — base Claude Code + rules handles this
- Dedicated `/reviewer` command — `/swarm-review` covers formal reviews
- Dedicated `/refactoring-engineer` — rules carry the "Two Hats" guidance
- Dedicated `/product-manager` — templates move to skills
- Dedicated `/sre` — tech-strategy.md covers infrastructure choices
- 3 redundant worker agents — absorbed into worker-builder and worker-reviewer

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Losing specialized focus in merged workers | Focus modes in swarm-workers.md rule; orchestrators specify focus in prompts |
| Users miss deleted commands | CLAUDE.md documents that base Claude Code handles implementation/review/refactoring |
| Rules become bloated | Keep rules factual and concise; catalogs go in skills, not rules |
| Breaking existing Beads referencing old agents | Update swarm-workers.md; Beads track work items, not agent types |

---

## Next Steps

1. Create planning bead for this consolidation work
2. Branch from main
3. Execute Phase 1-4 sequentially
4. Update CLAUDE.md personas table
5. Test with sample swarm-plan → swarm-execute → swarm-review cycle
6. PR for review
