# ADR: Rules Layering & Parent-Config Drift

**Status**: Accepted · 2026-07-24 · Evidence: `plan_framework_hardening.md` (U13)

## Context

A parent rules layer at `~/src/.claude/rules/` — one directory above this repo's own working
tree — loads alongside this repo's `.claude/rules/` whenever a session starts from that ancestor
directory or below it, this repo included. Both layers use the same filenames
(`agent-constraints.md`, `core-directives.md`, `security.md`) and both declare the identical
Decision Hierarchy, so nothing about the layering itself signals that the two disagree. Direct
comparison of the parent files against this repo's own copies surfaces four concrete
contradictions:

**(a) Beads.** Parent `agent-constraints.md` line 8 mandates "NO sharing state between workers
(use Beads)." This repo's `agent-constraints.md` line 8 instead reads "NO sharing mutable state
between workers — the orchestrator owns coordination and task tracking," and
`scripts/check-invariants.sh` check 1 (`no-beads`) mechanically fails the build on any tracked
`beads`/`bd` reference outside `artifacts/`, `CHANGELOG*`, and `MIGRATION*`. A session that loaded
only the parent copy would recommend the one dependency this repo's own CI is built to reject.

**(b) Worker timeout mechanism.** Parent `agent-constraints.md` line 10 mandates a wall-clock
bound: "NO long-running workers (timeout at 5 min)." This repo's line 10 names the opposite
mechanism outright: "NO unbounded workers — bound runtime with `maxTurns` in agent frontmatter
rather than wall-clock limits."

**(c) Enforcement Ladder.** Parent `security.md` has no Enforcement Ladder section — its Security
Checklist reads as if every line carried equal force. This repo's `security.md` opens with an
Enforcement Ladder stating hooks "are fail-open by design: if `jq` is missing or input can't be
parsed, the check is skipped and the tool call proceeds" and are "deterministic guardrails, not a
security boundary." An agent reasoning from the parent copy alone has no way to know a silent hook
means "skipped," not "verified."

**(d) Planning-flow ceremony.** Parent `core-directives.md` Rule 6 states the sequence
unconditionally: "Use the prescribed planning sequence: PR-FAQ → PRD → ADR → Design Spec → Plan →
Implementation. Do not skip phases." This repo's Rule 6 — retitled "Follow the Planning Flow —
Ceremony Scales With Scope" — scales instead: "the flow applies in full only to features. A change
describable in one sentence needs at most a plan artifact, and a trivial diff needs none."

This is not a new failure mode. `artifacts/adr_claude_config_modernization.md:5` already admits its
own comparison work was "kept in local `scratchpad/`, not shipped" — a prior instance of exactly
the Rule-4 violation (durable findings stranded outside `artifacts/`) that Decision 3 below closes.

## Decision 1 — This repo's own `.claude/rules/` win, in this repo

Within any session operating inside this repo, its own `.claude/rules/*` are authoritative over
the parent layer wherever the two conflict, per the Decision Hierarchy both copies already declare
(`Security > Tech Strategy > Core Directives > Skill Conventions > Local Judgment`). The hierarchy
ranks rule *categories*; for a given category, only one file's wording can be "the" Core Directives
or Agent Constraints for work done in this repo, and this repo's own CI, hooks, and doctrine are
built against its own text — the `no-beads` check, the `maxTurns`-frontmatter convention, and the
Enforcement Ladder all assume the in-repo wording, not the parent's. The parent layer is a
machine-local overlay outside this repo's git history; it is not part of the portable template
this repo ships to adopters, so it cannot be the source of truth for work done inside it.

*Why*: any other resolution makes this repo's own mechanically-enforced invariants (`no-beads`)
inconsistent with the rules an agent is told to follow, and silently reintroduces doctrine this
repo deliberately moved past (wall-clock timeouts, unconditional planning ceremony).

## Decision 2 — Recommend the owner align or retire the parent copies (owner action, outside this repo)

This repo cannot edit `~/src/.claude/rules/` — it sits outside this repo's working tree and git
history, so the contradiction stays live until the owner acts on it directly. Actionable checklist,
one line per file:

- `agent-constraints.md` line 8 — align: drop "(use Beads)" and adopt the orchestrator-owned
  wording; or retire: delete the parenthetical, leaving "no sharing state" mechanism-agnostic.
- `agent-constraints.md` line 10 — align: replace the 5-minute wall-clock figure with the
  `maxTurns`-in-frontmatter convention; or retire: drop the parenthetical, keep only "no
  long-running workers."
- `security.md` — align: add an Enforcement Ladder section (or a pointer to this repo's) so a
  session loading the parent alone still learns hooks are fail-open guardrails, not a boundary.
- `core-directives.md` Rule 6 — align: adopt the ceremony-scales-with-scope wording; or retire:
  keep the unconditional sequence only with an explicit, documented reason it differs here.

Until each line above is actioned, this ADR is the live tie-breaker for any session starting
inside this repo — the contradiction itself does not go away.

## Decision 3 — Layer-comparison findings ship as artifacts, never scratchpad-only

This closes the violation class Context cites in `adr_claude_config_modernization.md:5`: any future
comparison between this repo's rules and an ancestor, parent, or sibling overlay must land as a
committed artifact under `artifacts/` — this document is that norm applied to itself. Scratchpad
remains the right place for the exploratory diffing that produces a comparison, but its conclusions
— the contradiction list and the recommended resolution — must be checked in before the work counts
as done, per core-directives Rules 4 and 5.

## Consequences

This repo's rules become the single, checkable source of truth for anyone contributing here,
regardless of which ancestor directory a session started from — closing the ambiguity a naive
layered read would otherwise leave open, and the four contradictions above no longer need
re-discovery by the next agent that happens to run from `~/src/`. The owner-facing checklist in
Decision 2 is actionable but not self-executing: this ADR does not edit the parent files, and per
`plan_framework_hardening.md`'s Out-of-scope note, the contradiction — and this document's currency
— stays live until the owner acts outside this repo. Any adopter who clones this template into a
directory tree with its own conflicting parent rules inherits the same ambiguity Decision 1
resolves only for sessions inside this repo; the pattern, not the specific fixes, is worth
restating in `docs/customization.md` if it recurs elsewhere. Future edits to this repo's own
`.claude/rules/` should keep the Decision Hierarchy language and this contradiction list in sync,
or file a follow-up ADR when they diverge again.
