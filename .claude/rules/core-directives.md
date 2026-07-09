# Core Directives

Operational rules that support the Core Principles in CLAUDE.md.

## Purpose

These directives translate the Core Principles into concrete, day-to-day operating rules — when in doubt, return to the Core Principles.

## Constraints

- Always branch from `main` — never commit directly to the main branch
- Verify artifacts exist before proceeding to the next phase in the planning flow
- Consult `tech-strategy.md` for all technology choices — do not deviate without explicit instruction
- Ship It: work is not complete until pushed to remote — mechanical protocol lives in AGENTS.md "Landing the Plane" (canonical detail-level home)

## Seven Rules

### 1. Tech Strategy Is Authoritative

Golden paths are defined and enforced in `.claude/rules/tech-strategy.md` — see its preamble. Do not deviate without explicit instruction.

### 2. Check Skills First

See Core Principle 5 ("Don't Repeat Yourself") in CLAUDE.md — search `.claude/skills/` before generating ad-hoc solutions.

### 3. Write Tests

Every feature gets tests; every bug fix gets a regression test (workflow detail in the `testing` skill). Run all quality gates — see `.claude/rules/code-quality.md` — before committing. Do not skip or remove existing tests.

### 4. Durable Artifacts Go in `./artifacts/`

Plans, ADRs, PRDs, design specs, security audits, and post-mortems belong in `./artifacts/`. Follow the naming conventions defined in CLAUDE.md. Artifacts are the permanent record of decisions and must be checked in.

### 5. Ephemeral Notes Go in `./scratchpad/`

Working notes, exploration output, draft content, and in-progress thinking belong in `./scratchpad/`. This directory is for disposable content that supports the current session. Do not treat scratchpad files as authoritative artifacts.

### 6. Follow the Planning Flow — Ceremony Scales With Scope

Use the prescribed planning sequence: PR-FAQ → PRD → ADR → Design Spec → Plan → Implementation. Each phase produces an artifact that gates the next, and skipping a phase a feature actually needs creates unvalidated assumptions that surface as bugs or rework — but the flow applies in full only to features. A change describable in one sentence needs at most a plan artifact, and a trivial diff needs none. `swarm-plan`'s artifact-requirements table defines the scaling (Small/Medium/Large Feature tiers) — use it rather than defaulting to the full sequence for every change.

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

### Artifacts, Scratchpad, Handoffs

See Rules 4, 5, and 7 above.
