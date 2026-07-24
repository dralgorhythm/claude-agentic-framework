# ADR: TaskCompleted Quality Gate Ships Default-On

**Status**: Accepted · 2026-07-24 · Evidence: `plan_framework_hardening.md` (U5c, Decision D1)

## Context

`docs/hooks.md`'s "Opt-in recipes" section stated a blanket doctrine: hooks documented there "ship
disabled unless a project deliberately opts in... a per-project choice, not something this framework
turns on for you." One of those recipes was `task-quality-gate.sh` — a `TaskCompleted` hook that
blocks task completion (via the platform's documented exit-code-2 mechanism) until the project's
detected quality gates pass. `artifacts/research_ai_coding_frustrations.md`'s option O1 names this
framework's own gap directly: "enable the documented `TaskCompleted` quality-gate recipe by default
rather than opt-in," cited against the research's strongest-evidenced failure category —
verification failures at 23.5% of coded multi-agent failures (MAST), Sonar's 2026 finding that fewer
than half of developers review AI-written code before committing, and the typia port's own agent
deleting roughly 70% of its test suite while reporting "all tests pass."

The audit's highest-stakes finding, in short: the framework's only true *completion-time* gate — as
opposed to `pre-commit-verification.sh`'s commit-time gate, hardened separately in unit U5b — shipped
present, documented, and switched off. A hardening release that leaves its own flagship finding
unaddressed fails its own purpose. Opt-in guardrails demonstrably don't get adopted: the recipe
existed in this repo's own docs, with copy-paste install instructions, and nothing suggests any
project actually wired it in — present, disabled, invisible, the opt-in framing itself the reason
nobody used it.

## Decision — the `TaskCompleted` quality gate ships registered by default

`task-quality-gate.sh` moves from `docs/hooks.md`'s opt-in recipes into `.claude/settings.json`'s
`hooks.TaskCompleted` array, registered for every adopter who pulls this config, with a 120s hook
timeout. It runs the same `gate-lib.sh`-detected gates (unit U5a) that `pre-commit-verification.sh`
already runs at commit time (unit U5b), but at task-completion time — a second, independent
checkpoint, not a replacement for the commit gate. A failing gate blocks (exit 2); a gate that
exceeds its budget does not (non-blocking, disclosed on stderr — completion should not hard-fail on
slowness alone); `CLAUDE_SKIP_GATE_HOOK=1` remains a universal escape hatch.

This is this plan's one deliberate **doctrine** change. Every other unit in
`plan_framework_hardening.md` is a Two-Way Door — reversible without a recorded decision. Flipping a
repo-wide "ships disabled" default to "ships enabled" for one specific hook is a
**One-Way-Door-Medium**: cheap to reverse mechanically (see Reversal Path below), but adopters who
re-pull this config get new blocking behavior they did not explicitly opt into — exactly the kind of
change that warrants a recorded decision rather than a quiet settings.json edit.

## Alternative Considered — keep opt-in, but make it more prominent

Rejected. The recipe was already documented, with copy-paste install instructions, in the same file
under review here — prominence within the opt-in framing was not the gap. The audit's finding is
that opt-in guardrails demonstrably don't get adopted regardless of how visible the documentation
is: a recipe a project must remember to wire in competes with every other task on that project's
list, and loses by default. Making an already-documented recipe easier to find fixes a
discoverability problem this repo didn't have; it does not fix the adoption problem the audit
actually found. Only a default-on change closes the gap the evidence points at.

## Reversal Path

Two-Way-Door mechanics, despite the One-Way-Door-Medium classification above — that classification
is about the *default* changing under adopters, not about this repo's own ability to undo it:

- **Repo-wide**: delete the `TaskCompleted` entry from `.claude/settings.json`'s `hooks` block — one
  JSON array entry; no other file depends on it existing.
- **Per-commit / per-environment**: `CLAUDE_SKIP_GATE_HOOK=1`, the exact same escape hatch
  `pre-commit-verification.sh` (U5b) already honors — one env var disables both gate hooks, not two
  to remember.
- **Per-machine**: `"disableAllHooks": true` in `settings.local.json` — the existing hook-suite-wide
  mechanism, not specific to this decision.

## Consequences

- Adopters who re-pull this config after this change inherit a newly blocking `TaskCompleted` gate
  the moment their project has a detectable stack (`package.json` with a `test`/`lint`/`typecheck`/
  `biome` script, `pyproject.toml` with `pytest`/`ruff`/`mypy`, `go.mod`, or `Cargo.toml`). A
  `MIGRATION.md` entry under the v4.0.x section names this explicitly, alongside the one-line disable
  and the shared escape hatch.
- `docs/hooks.md`'s general opt-in preamble ("hooks in this repo ship disabled unless a project
  deliberately opts in") no longer holds universally now that one recipe ships by default; the
  preamble is rewritten so it accurately scopes to the recipes that remain genuinely opt-in (the
  forced-eval skill-activation hook, and `docs/examples/worker-budget-hook.sh`) instead of silently
  contradicting the shipped default.
- Any later addition to the opt-in recipes list inherits the same question this ADR answers for
  `task-quality-gate.sh`: opt-in is the default framing, and flipping it again requires the same
  scrutiny this decision applied — evidence that the guardrail's value is high enough, and its
  false-positive/adoption-friction cost low enough, to justify a doctrine change instead of a
  documentation improvement.
