# Stack Packs

`/tailor`'s source material for its `Propose: Instantiate` phase — one directory per supported stack, each a set of concrete, working files for that stack's golden path.

## Convention: Three Files, No More

```
.claude/templates/stack-packs/<stack>/
  README.md             What this pack is, why these choices, how /tailor adapts it,
                         how to adapt by hand. Opens with one dated line:
                         "Exemplar current as of YYYY-MM".
  golden-path.skill.md  The ONE skill /tailor renders into the adopter's repo: the
                         stack's daily loop as directives.
  ci-gates.yml           Thin CI job snippet running the same gates with the stack's
                         own commands.
```

## Exemplar, Not Template

A pack is concrete, working files for the golden-path stack — real commands, real values, zero double-brace placeholder machinery. `/tailor`'s LLM is the adaptation engine: it reads a pack plus the repo's detection fingerprint and substitutes into the proposal. See `artifacts/adr_stack_packs.md` (Decision 1) for the full rationale.

## DRY Lines (Hard)

A pack never reproduces `.claude/rules/tech-strategy.md`'s choice table, never redefines `.claude/rules/code-quality.md`'s gates, and never restates `.claude/hooks/pre-commit-verification.sh`'s stack detection — every pack links each of the three and operationalizes what they already define.

## Listing Budget

`golden-path.skill.md` is the only skill a pack renders into an adopter's repo — every rendered skill costs that adopter's always-loaded listing budget, so a pack ships exactly one, shaped to pass this repo's own `desc-style`/`spec-portability` invariants.

## Discovery

`/tailor` finds packs by scanning this directory — a new pack is a new subdirectory here; adding one changes zero lines of `/tailor` itself.
