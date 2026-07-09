# Core Directives

Operational rules that support the Core Principles in CLAUDE.md.

## Purpose

These directives translate the Core Principles into concrete, day-to-day operating rules. When in doubt, return to the Core Principles. When the Core Principles are clear, these directives specify how to act on them.

## Constraints

- Always branch from `main` — never commit directly to the main branch
- Verify artifacts exist before proceeding to the next phase in the planning flow
- Consult `tech-strategy.md` for all technology choices — do not deviate without explicit instruction

## Seven Rules

### 1. Tech Strategy Is Authoritative

Follow the golden paths defined in `.claude/rules/tech-strategy.md` for every technology choice — language, runtime, framework, database, infrastructure, and tooling. Do not suggest alternatives unless explicitly instructed. Use the latest stable version unless a version is pinned.

### 2. Check Skills First

Before generating an ad-hoc solution, search `.claude/skills/` for an existing workflow or pattern. Use established patterns before inventing new ones. Skills encode accumulated best practices and save time for both agents and reviewers.

### 3. Write Tests

Every feature gets tests. Every bug fix gets a regression test. Tests must be deterministic and isolated. Run all quality gates — tests, linter, type checker, build — before committing. Do not skip or remove existing tests.

### 4. Durable Artifacts Go in `./artifacts/`

Plans, ADRs, PRDs, design specs, security audits, and post-mortems belong in `./artifacts/`. Follow the naming conventions defined in CLAUDE.md. Artifacts are the permanent record of decisions and must be checked in.

### 5. Ephemeral Notes Go in `./scratchpad/`

Working notes, exploration output, draft content, and in-progress thinking belong in `./scratchpad/`. This directory is for disposable content that supports the current session. Do not treat scratchpad files as authoritative artifacts.

### 6. Follow the Planning Flow

Use the prescribed planning sequence: PR-FAQ → PRD → ADR → Design Spec → Plan → Implementation. Do not skip phases. Each phase produces an artifact that gates the next. Skipping phases creates unvalidated assumptions that surface as bugs or rework.

### 7. Follow Command Protocols

Respect the handoff requirements between commands. Every handoff must include an artifact reference. Follow the protocols defined in the command definitions. Never hand off work without a concrete artifact that the receiving command can verify.

## Decision Hierarchy

Note: precedence between rule *sources* is decided below. For how strongly any single rule is *enforced* (prose < skill < hook < deny/CI), see the Enforcement Ladder in `.claude/rules/security.md`.

When rules conflict, resolve using this order of precedence:

```
Security > Tech Strategy > Core Directives > Skill Conventions > Local Judgment
```

- **Security**: No tradeoff overrides a security requirement
- **Tech Strategy**: Golden paths override convenience preferences
- **Core Directives**: These rules override skill-level conventions
- **Skill Conventions**: Patterns in `.claude/skills/` override ad-hoc choices
- **Local Judgment**: Use judgment only when no higher rule applies

## Output Standards

### Commits

Write atomic, descriptive commit messages. Each commit should represent one complete, working change. Do not bundle unrelated changes. Do not commit broken states.

### Artifacts

Store all durable planning output in `./artifacts/` using the naming conventions from CLAUDE.md. Every architectural decision, requirement, and plan must have a corresponding artifact before implementation begins.

### Scratchpad

Store all ephemeral working content in `./scratchpad/`. This includes exploration notes, draft outlines, and intermediate analysis. Do not reference scratchpad files in handoffs or final deliverables.

### Handoffs

Every handoff between commands or agents must include explicit artifact references — file path and a one-line description of what the artifact contains. The receiving agent must be able to verify the artifact exists before proceeding.
