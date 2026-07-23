---
name: review-steering
description: Compiles REVIEW.md and keeps CLAUDE.md accurate as the two sanctioned surfaces for steering Anthropic's managed Code Review service, translating this repo's rules into terse reviewer imperatives. Use when creating or updating REVIEW.md, configuring or steering automated code review, or reconciling review instructions after rules change.
metadata:
  category: capability-uplift
---

# Review Steering

## Two Surfaces, Not One

Anthropic's managed Code Review service and the local `/code-review` command are customized through exactly two files — nothing else steers them.

| File | Content | Read by |
|------|---------|---------|
| `CLAUDE.md` | Project context — stack, conventions, architecture | Local `/code-review` command AND the managed Code Review service |
| `REVIEW.md` | Review-only instructions, injected into every managed review agent run at highest priority | Managed Code Review service ONLY — never read by local `/code-review` |

Do not duplicate CLAUDE.md content into REVIEW.md. REVIEW.md carries only what a reviewer needs that project context doesn't already say — everything else is noise diluting a high-priority injection.

## Generation Workflow

1. Read `.claude/rules/code-quality.md` — quality gates, SOLID/DRY musts, performance checklist.
2. Read `.claude/rules/security.md` — security checklist, severity classification (block on Critical/High), CWE-reference convention.
3. Compile both into REVIEW.md as terse reviewer imperatives — "flag X", "block on Y", "ignore Z" — never prose restatements of the rules.
4. Keep it short: reviewers get REVIEW.md injected on every run, and every extra line dilutes the priority of the lines that matter.
5. Add repo-specific invariants a generic reviewer cannot infer from a diff alone — artifact-naming conventions, enforcement-ladder placement, framework-specific patterns.
6. Confirm CLAUDE.md still states project context accurately; both surfaces depend on it being current.
7. Scaffold from the bundled template and replace every placeholder before committing — see Resources below.

## Imperative Style, Not Prose

Compile rules into commands, not descriptions — every line should read like an instruction a reviewer executes, not a fact they learn.

- Rule (`code-quality.md`): "SQL queries use parameterized statements" → REVIEW.md: "Block on unparameterized SQL — require parameterized queries (`CWE-89`)."
- Rule (`security.md`): "Critical/High severity MUST fix before merge" → REVIEW.md: "Block merge on any Critical or High finding. Flag Medium; Low is optional."
- Rule (`security.md`): "No hardcoded secrets or credentials" → REVIEW.md: "Flag any hardcoded secret, credential, or token in any format (`CWE-798`)."

## Refresh Discipline

- Rules changed → regenerate REVIEW.md in the same PR. Do not defer it to a follow-up.
- REVIEW.md is a build artifact of `.claude/rules/`, not an independently maintained document — it must never contradict the rules it was compiled from.
- Drift means reviewers enforce stale policy against current code. Treat a contradiction as a bug, not a style disagreement.

## What NOT to Put in REVIEW.md

- Style nits a formatter already enforces (Biome, Ruff, golangci-lint, etc.) — reviewer attention is not a substitute for pre-commit hooks.
- Anything a CI check already blocks. Check the Enforcement Ladder in `.claude/rules/security.md` first — a deterministic gate beats a reviewer instruction, so cite the check instead of duplicating it as a review imperative.
- Secrets, credentials, or internal paths — REVIEW.md is a tracked, committed file, not a scratch note.

## Resources

- [REVIEW.md Template](./resources/review.template.md)
