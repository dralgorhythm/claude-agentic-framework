# Plan: Distill Core Directives into CLAUDE.md

## Decision: Two-Way Door (Easy to Revert)

Rule files are kept as-is; only CLAUDE.md changes. Fully reversible.

## Analysis

### Current State
- CLAUDE.md uses 4 `@`-references pulling in ~2,400 words of rules
- Rules are verbose and overlap heavily (SOLID in code-quality, "no secrets" in security AND core-directives, testing in code-quality AND core-directives)
- Agents read ALL of it every session — ~3,700 tokens of mostly redundant reminders of things any competent model already knows

### Core Insight
The framework's 5 rule files, 13 commands, and 14 skills ALL reduce to **7 principles**. Every constraint, checklist, and pattern maps to one or more of these. The value isn't teaching SOLID or OWASP — it's prioritizing and enforcing behavior.

### The 7 Principles
1. **Understand First** — Read before writing. Grep before creating.
2. **Prove It Works** — Test first. Quality gates must pass.
3. **Keep It Safe** — No secrets. Validate input. Least privilege.
4. **Keep It Simple** — Small functions. No premature abstraction.
5. **Don't Repeat Yourself** — Use skills. Follow existing patterns.
6. **Ship It** — Branch, commit, push. Not done until pushed.
7. **Leave a Trail** — Artifacts, Beads, ADRs.

### What Changes
| Item | Action |
|------|--------|
| `CLAUDE.md` | Rewrite: inline 7 principles + operational rules, remove 3 `@`-references |
| `@core-directives.md` | Remove reference (content distilled into principles + workflow section) |
| `@code-quality.md` | Remove reference (captured by principles 2, 4, 5) |
| `@security.md` | Remove reference (captured by principle 3) |
| `@tech-strategy.md` | **Keep** reference (project-specific config, not universal principle) |
| Rule files themselves | **No changes** — remain as deep-dive references for specific personas |

### Token Impact
- **Before**: ~490 words in CLAUDE.md + ~2,400 words inlined via @ = ~2,890 words (~3,750 tokens)
- **After**: ~400 words in CLAUDE.md + ~780 words via @tech-strategy = ~1,180 words (~1,530 tokens)
- **Savings**: ~59% token reduction per session while retaining all behavioral guidance

## Tasks

1. Rewrite CLAUDE.md with distilled principles and inline operational rules
2. Verify no broken references to removed @ sections
