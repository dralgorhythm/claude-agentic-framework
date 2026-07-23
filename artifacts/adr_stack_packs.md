# ADR: Stack Packs & Tailor v2 — Exemplar Packs, LLM Adaptation

**Status**: Proposed · 2026-07-23 · Evidence: `research_stack_packs.md`

## Context

The v4 strategy's T4 tier: stack-specific value is *generated into the adopter's repo*, never shipped as live
skills here. Owner direction: KISS, DRY, SOLID, education-first — packs are exemplar material, not machinery.
Constraints from research: plugins cannot carry template payloads; adopter listing budget favors one skill per
pack; tech-strategy.md / code-quality.md / the pre-commit hook are the single sources a pack must not restate.

## Decision 1 — Exemplar over template

A pack is a set of **concrete, working files for the golden-path stack** — real `pnpm test`, real
`uv lock` — with zero placeholder machinery. `/tailor` is the adaptation engine: it reads the exemplar plus its
detection fingerprint and rewrites names/versions/commands to the adopter's reality inside the proposal.

*Why*: the 2026 ecosystem converged here ("examples are concrete, not abstract"; Spec Kit; shadcn's open-code);
jinja-class templating has a documented drift-and-tooling tax (cruft) and kills GitHub legibility. An exemplar
is simultaneously the documentation, the education, and the template — DRY at the artifact level. Rule of
Three: no parameter until a real third variation demands one.

## Decision 2 — Pack anatomy (three files, no more)

```
.claude/templates/stack-packs/<stack>/
  README.md             ~30 lines: what this pack is, why these choices (one paragraph, pointing at
                        tech-strategy.md for the choice table), how /tailor adapts it, how to adapt by hand.
                        Header carries one dated line ("Exemplar current as of 2026-07").
  golden-path.skill.md  The ONE skill /tailor renders into the adopter repo: the stack's daily loop as
                        directives — canonical commands (test/lint/typecheck/build), lockfile discipline,
                        where gates run (pre-commit hook + CI). <100 lines, ungated shape, third-person
                        description with "Use when", clean six-field frontmatter. Triggers scoped to daily
                        build/test/run tasks — never upgrade (dependency-upgrade), landing (land-the-plane),
                        or review config (review-steering).
  ci-gates.yml          Thin Actions job snippet running the four gates with the stack's commands; references
                        upstream actions, vendors nothing.
```

*Why*: converged minimal set (entry doc + few fragments + zero vendored internals); one rendered skill per pack
per first-party precedent and adopter listing-budget etiquette; anything further waits for a demonstrated need.

**DRY lines (hard)**: the pack *operationalizes* — it never reproduces the tech-strategy table (it links it),
never redefines the quality gates (it runs them), never restates hook detection (it aligns with it).

## Decision 3 — Delivery: in-repo, installer-carried, free

Packs live at `.claude/templates/stack-packs/<stack>/`. The installer already copies `templates/` recursively —
zero new machinery; GitHub renders packs as browsable education; free onramp by construction. No plugin
packaging: mechanically impossible for template payloads and adds overhead for zero function.

## Decision 4 — Tailor v2: one new phase

`Propose: Instantiate`, after `Propose: Steer`: scan `stack-packs/` (open/closed — a new pack is a new
directory, zero engine change); for each **detected** stack with a pack, adapt the exemplar to the fingerprint
(every substitution evidence-cited; defaults flagged when no signal exists — the dogfooded no-vibes discipline);
rendered files join the existing proposal and apply checklist. New mode `instantiate` in the argument hint.
Never render for an undetected stack; never write outside the proposal.

## SOLID, in one breath

One pack = one stack (SRP). New packs extend without touching the engine (O/C). Every pack satisfies the same
three-file convention, so tailor treats any pack identically (LSP). Packs expose only what tailor needs — a
directory matching the convention (ISP). Tailor depends on the convention, not on any pack's contents (DIP).

## Rejected

- **Placeholder/template engine** ({{vars}}, variable tables, render rules) — drift tax, legibility tax,
  redundant beneath an LLM adapter.
- **Plugin delivery** — no template payload type exists; indirection via skill-copies-files adds steps, not value.
- **Per-domain skill fan-out** (scaffold-router pattern) — adopter listing budget; one skill + references wins.
- **Pack-owned choice tables** — tech-strategy.md is the single source of truth for choices.

## Consequences

Packs are cheap to author (write the exemplar you'd want to read), cheap to maintain (update like any doc, one
dated line), and testable via the smoke-test convention (adapt against the fixture; rendered skill must pass
desc-style/spec-portability shape). Python/Go packs are pure additions. The bet's risk — LLM adaptation fidelity
— is bounded by tailor's evidence-citation constraint and covered by an instantiate eval case.
