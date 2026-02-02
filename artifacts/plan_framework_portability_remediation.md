# Plan: Framework Portability & Doc Alignment Remediation

## Decision Classification

**Two-Way Door** — All changes are documentation and config text edits, easily reversible.

## Scope

Small-Medium (1-3 days) — ~20 files, all text/config edits.

## Task Breakdown

All 7 tasks are independent and can execute in parallel.

### Task A: Fix Repository URL Inconsistency (Critical)

Canonical URL: `github.com/dralgorhythm/claude-agentic-framework`

| File | Line | Change |
|------|------|--------|
| `docs/getting-started.md` | 7, 15 | `anthropics` → `dralgorhythm` |

README.md and init-framework.sh already use the correct URL.

### Task B: Document Context7 MCP Server (Critical)

| File | Change |
|------|--------|
| `docs/mcp-servers.md` | Add Context7 section after GitHub section |
| `README.md:67` | Update MCP description to include context7 |

Context7 section content:
```markdown
### Context7
Up-to-date documentation and code examples for any library via context7.

**Best for:** Researching library APIs, finding code examples, validating patterns
```

README MCP line: "Browser debugging, GitHub integration, structured reasoning, library docs"

### Task C: Make Commands Language-Agnostic (Critical)

| File | Lines | Change |
|------|-------|--------|
| `.claude/commands/swarm-execute.md` | 46-54 | Replace `pnpm` quality gates with generic + examples |
| `.claude/commands/code-check.md` | 134 | Qualify `npx ts-complexity-report` as JS-specific |
| `.claude/commands/code-check.md` | 138-141 | Qualify `npx knip`/`npx depcheck` as JS-specific |
| `.claude/commands/qa-engineer.md` | 32-37 | Change "Vitest/pytest" to "Project test runner (e.g., Vitest, pytest, JUnit)" |

### Task D: Add Customization Directive to Tech Strategy (Critical)

| File | Change |
|------|--------|
| `.claude/rules/tech-strategy.md` | Add "CUSTOMIZE FOR YOUR PROJECT" header; soften "OVERRIDES" to "recommended defaults" |
| `README.md:73` | Strengthen: "Edit .claude/rules/tech-strategy.md if you use different tech" → "**Required**: Edit .claude/rules/tech-strategy.md to match your tech stack" |
| `docs/customization.md` | Update "Changing Tech Choices" section framing |

### Task E: Fix Doc Consistency (High)

| File | Change |
|------|--------|
| `README.md:60` | "55+ Skills" → "65+ Skills" |
| `docs/swarm.md` | Add `/code-check` to swarm command listing |
| `CLAUDE.md` or `docs/beads.md` | Standardize bd close syntax |

### Task F: Agent/Skill/Rule Portability Fixes (Medium-Low)

| File | Change |
|------|--------|
| `.claude/agents/worker-tester.md:18` | "Vitest/pytest" → "Project test framework" |
| `.claude/rules/code-quality.md:28` | "Avoid `any` types in TypeScript" → add "(if applicable)" |
| `.claude/skills/core-engineering/debugging/SKILL.md:54-66` | Add "Examples for common languages:" header |
| `.claude/skills/core-engineering/testing/SKILL.md:47` | Add "Example (TypeScript):" header |
| `.claude/skills/core-engineering/testing/SKILL.md:76-86` | Add "Use your project's test runner. Examples:" header |

### Task G: Settings Cleanup (Medium)

| File | Change |
|------|--------|
| `.claude/settings.local.json` | Note: This file is gitignored and won't ship to users. No action needed — it's local development config. |

## Dependency Graph

```
Task A (URL fix)          ──┐
Task B (MCP docs)         ──┤
Task C (Agnostic cmds)    ──┤── All independent, parallel execution
Task D (Tech strategy)    ──┤
Task E (Doc consistency)  ──┤
Task F (Portability)      ──┤
Task G (Settings) ──────────┘  (no-op, documented)
```

## Risk Assessment

- **Low risk** — All text/documentation edits
- **Reversible** — Git history preserves everything
- **No behavioral changes** — Only prose and config
