# Plan: Stack Packs & Tailor v2

> Executes `adr_stack_packs.md`. Trunk-based: each unit is an independently mergeable PR to `main`;
> U2/U3 branch from `main` after U1 lands. 2026-07-23.

## U1 — Engine + convention + TypeScript pack (one PR)

The convention, the engine, and the first pack land together — an engine without a pack is untestable, a pack
without an engine is inert. Scope:

1. `.claude/templates/stack-packs/README.md` (≤40 lines): the three-file convention, exemplar-not-template
   principle, DRY lines (link tech-strategy/code-quality/hook — never restate), dated-header convention,
   adopter-listing-budget note, how `/tailor` discovers packs (directory scan).
2. `typescript/` pack per ADR Decision 2 — concrete golden-path values (pnpm · Vite · Biome · Vitest ·
   React 19 · Node LTS), README with the one-paragraph why + adapt notes, golden-path skill exemplar,
   ci-gates snippet.
3. Tailor v2: `Propose: Instantiate` phase + `instantiate` mode + `references/packs.md` (≤30 lines: scan,
   adapt-with-evidence, default-flagging, undetected-stack refusal); +1 eval case
   (`mixed-repo-instantiates-only-detected-packs`).
4. docs/customization.md: short "Stack packs" note under Artifact Templates; CHANGELOG entry.

**AC**: all invariant checks green; smoke test per PR #25 convention — adapt the TS pack against
`scratchpad/tailor-fixture` by hand, stage the rendered skill at a throwaway path, prove desc-style +
spec-portability + name-eq-dir pass, revert, evidence in the PR body; elegance test — every pack file legible
raw on GitHub, zero placeholder tokens; grep proves the pack reproduces no tech-strategy table rows.

## U2 — Python pack · U3 — Go pack (one PR each, after U1)

Pure additions under `stack-packs/`: same three files, golden-path values from tech-strategy (Python 3.13 · uv ·
Ruff · Litestar · msgspec · pytest/mypy; Go 1.25 · golangci-lint · sqlc/pgx per table). No engine changes —
that's the ADR's open/closed test. Same ACs (smoke test uses the fixture for Python; Go gets a 3-file fixture
added to scratchpad in-branch). Sequence U2 → U3 by merge order (shared CHANGELOG anchor).

## Out of scope (Rule of Three / YAGNI)

Rust/Swift/Kotlin packs (add on demand); pack versioning beyond the dated line; any placeholder machinery;
plugin packaging; pack content beyond the three files.

## Risks

LLM adaptation fidelity → bounded by evidence-citation constraint + instantiate eval (ADR Consequences).
Golden-path drift (tooling moves) → the dated line + normal doc maintenance; no sync machinery by design.
