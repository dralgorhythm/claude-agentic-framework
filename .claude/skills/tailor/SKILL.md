---
name: tailor
description: Detects the project's stack from manifests and proposes tailored framework configuration — filled tech-strategy golden paths, REVIEW.md/CLAUDE.md review steering, and a prune list of unused framework pieces — as a reviewable plan, never silent writes.
argument-hint: "[all | detect | fill | steer | prune | instantiate]"
disable-model-invocation: true
metadata:
  category: encoded-preference
---

# Tailor

The framework's environment-triggered customization engine. Once an adopter's stack is detectable — manifests and lockfiles committed — `/tailor` proposes the configuration the framework should take: filled `tech-strategy.md` golden paths, `REVIEW.md`/`CLAUDE.md` review steering, and a prune list of unused framework pieces.

**`/tailor` proposes only. It never silently writes to `.claude/rules/`, `.claude/settings.json`, `CLAUDE.md`, or any other tracked config file.** Every run ends in a reviewable plan at `scratchpad/tailor-proposal.md` — nothing lands in a tracked file until the user approves it (see Output Contract). This promise is now hook-backed at the `ask` tier: `pre-tool-use-validator.sh` asks for confirmation before any direct Write/Edit to these same paths, rather than leaving the propose-only contract as convention alone.

## Detect

Scan for stack signals per `references/detection.md`, the mechanical signal-to-golden-path-row contract. Cover:

- **Language manifests + lockfiles**: `package.json`/`pnpm-lock.yaml`/`yarn.lock`, `pyproject.toml`/`uv.lock`, `go.mod`, `Cargo.toml`, `Package.swift`/`*.xcodeproj`, `build.gradle(.kts)`
- **Tool configs**: `biome.json`, `.eslintrc*`, `[tool.ruff]` in `pyproject.toml`, `.golangci.yml`
- **CI**: `.github/workflows/*`
- **Infra**: `Dockerfile`, `*.tf`, Railway/Fly configs

Produce a stack-fingerprint table, one row per claim, with an evidence file for each:

| Signal | Evidence | Claim |
|--------|----------|-------|
| `pnpm-lock.yaml` | `pnpm-lock.yaml:1` | Package Manager: pnpm |

Precedence when signals conflict, highest wins: **committed lockfile > manifest field > dependency presence > inference**. Never assert a claim without citing the file it came from — no vibes-based stack claims.

## Assess

Read `.claude/rules/tech-strategy.md`. Classify every golden-path section as one of:

- **placeholder** — matches the shipped example verbatim (the file's own "Customization Required" banner marks this state)
- **already-customized** — differs from the shipped example, no detected conflict
- **conflicting-with-detection** — differs from the shipped example AND contradicts what Detect found

Never overwrite an already-customized row without flagging it first. A conflicting row becomes a flagged decision in the proposal, not a silent replacement.

## Propose: Fill

For each **detected** language, draft a ready-to-paste golden-path table using the project's actual choices, with versions pulled from manifests where present (e.g. `"react": "^19.2.0"` in `package.json` → `React 19.2`). For each **undetected** language section, propose deleting it — a prune candidate, not a silent removal.

## Propose: Steer

Invoke the `review-steering` skill's workflow to draft `REVIEW.md` and verify `CLAUDE.md`'s review-context section is current. Include both the drafted `REVIEW.md` content and any `CLAUDE.md` delta in the proposal — do not write either file directly.

## Propose: Instantiate

For each pack in `.claude/templates/stack-packs/` whose stack Detect actually found, adapt the exemplar to the fingerprint — substitute package manager, test runner, framework, and version strings for the detected reality, evidence-cited per substitution; flag a default when no signal exists rather than inventing one. See `references/packs.md` for the discovery and adaptation rules this phase follows.

Render `golden-path.skill.md` at its adopter-repo target path (e.g. `.claude/skills/typescript-golden-path/SKILL.md`) and `ci-gates.yml` as a ready-to-paste block for the adopter's own CI workflow — never for a stack Detect did not find.

## Propose: Prune

List framework pieces irrelevant to the detected stack: unused golden-path language sections, hook checks that can't fire for this stack, skills the adopter may want to gate. Each entry needs a one-line rationale and the exact file/line — no bulk "remove unused stuff" claims.

## Output Contract

**`/tailor` proposes only — application is a separate, user-approved step, never automatic.** A single proposal file at `scratchpad/tailor-proposal.md` contains:

1. Stack-fingerprint table (Detect)
2. Per-file proposed blocks, ready to paste (Fill, Steer, Prune)
3. Rendered pack files (Instantiate), each with its adopter-repo target path and the evidence-cited substitutions applied
4. Conflict flags (Assess)
5. An apply checklist — one checkbox per file to change

Application happens only after the user approves the plan — either by manually pasting the approved blocks, or by re-invoking `/tailor` with the approved checklist.

## Modes

- `all` (default) — Detect + Assess, then all four Propose phases; full proposal
- `detect` — Detect only; fingerprint table
- `fill` — Detect + Assess + Propose: Fill
- `steer` — Detect + Assess + Propose: Steer
- `prune` — Detect + Assess + Propose: Prune
- `instantiate` — Detect + Assess + Propose: Instantiate

## Constraints

- NO silent writes to `.claude/rules/`, `.claude/settings.json`, `CLAUDE.md`, or any other tracked config file — proposal only, always
- NO deleting or overwriting user-customized content — flag the conflict instead
- NO stack claims without cited evidence — every fingerprint row names its source file
- NO rendering a pack for a stack Detect did not find — instantiation is scoped strictly to detected stacks, never speculative
- ALWAYS re-run after major stack changes (new language, package-manager migration, framework swap) — a stale proposal is worse than none
- ALWAYS require explicit user approval before anything in the proposal is applied — the constraint most tempting to skip under time pressure

## Handoffs

- To `review-steering`: Propose: Steer delegates `REVIEW.md`/`CLAUDE.md` drafting to its workflow
- To `/swarm-plan`: when detection reveals structural work beyond a config fill (e.g. a full framework migration)
- From first install: `docs/customization.md`'s "Configure Your Tech Stack" step points here once the repo has a detectable stack

$ARGUMENTS
