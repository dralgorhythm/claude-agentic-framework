# Evals: Starter Skills (D-wave gate) — Lift and Trigger Results

> Gates Wave D of `artifacts/plan_skills_portfolio_execution.md` per CONTRIBUTING's eval-first policy.
> Run: 2026-07-21, orchestrator-executed. Companion to `evals_catalog_rationalization.md` (same session's C0 gate).

## Methodology (disclosed)

- **Lift tests** (4 skills): one representative scenario per skill, run twice at claude-sonnet-5 in fresh
  subagent sessions — (a) baseline: scenario only; (b) with-skill: scenario + the skill body injected in-prompt
  (simulating activation). Graded by the orchestrator against skill-specific assertions fixed in advance
  (each skill's encoded workflow steps). N=1 per arm.
- **Trigger tests** (3 ungated skills; land-the-plane is gated and exempt): the full 9-skill ungated listing
  (names + descriptions verbatim) presented to fresh subagents at sonnet AND haiku, with 3 positive prompts and
  3 near-miss negatives shuffled and unlabeled; the agent names which skill it would read first, or none.
  This simulates listing-based discovery, not a live session — disclosed limitation.
- **Confound** (same as the C0 record): subagents inherit this repo's always-loaded rules; baselines are
  therefore "rules ∪ training," which is the operative comparison for skills shipped alongside those rules.

## Trigger results: 12/12

Both tiers routed all three positives correctly (postmortem, dependency-upgrade, review-steering) and rejected
all three near-misses (runbook summarization ≠ postmortem; new-dependency install ≠ upgrade; performing a
review ≠ configuring review) — sonnet with explicit trigger-clause reasoning, haiku identically. The new
descriptions discriminate cleanly against both each other and the six pre-existing library skills.

## Lift results

| Skill | Baseline vs skill-specific assertions | With-skill | Verdict |
|---|---|---|---|
| postmortem | ~2.5/6 — strong generic writeup (blameless, timeline, action items) but no five-whys structure, no owner/due/issue completeness rule, no enforcement-ladder mapping, no template/status lifecycle, no per-item issue + bidirectional-link discipline | 6/6 — all of the above, plus NEEDS-DATA honesty over fabricated metrics | **Clear lift.** Encoded preference doing its job: the model improvises *a* postmortem; the skill produces *this framework's* postmortem |
| land-the-plane | ~5/7 — rules-rich baseline already stages explicitly, splits unrelated work, gates before commit (it cited the repo rules directly); missed proactive pull-rebase, verify-up-to-date + SHA evidence, retry-once cap, body-via-file | 7/7 + file-by-file disposition table | **Modest lift, acceptable**: gated (zero listing cost); value = making the finish-line protocol invocable as a ritual. Much of its discipline is ambient in the rules by design |
| dependency-upgrade | ~4/6 — baseline independently strong (SHA-pinning, tj-actions precedent, silent-change auditing) but missed composite-action internal-pin inspection, explicit tag-existence verification, and queue ordering | 6/6, and composed SHA-pinning (training) WITH the skill's verification steps | **Lift concentrated exactly in the hard-won-lesson content.** Action taken: the baseline's SHA-pinning practice folded into the skill body (see below) — eval-driven refinement per the doctrine |
| review-steering | 1/6 — baseline has NO knowledge of REVIEW.md; steered everything through CLAUDE.md and asserted it is "the only steering surface you control" for the managed app (stale) | 6/6 — correct two-surface semantics, compiled imperatives, CI-duplication exclusions with ladder rationale | **Strongest lift; capability-uplift class** (post-cutoff platform knowledge). Flagged `capability-uplift` in metadata; depreciation clock applies — retire when base models learn the REVIEW.md surface |

## Actions taken from these results

1. `dependency-upgrade` body amended: resolve releases to full commit SHAs and pin the SHA (tag as trailing
   comment) as the primary defense, with tag verification applying to what the SHA resolves from.
2. `review-steering` and the other three starters carry `metadata.category` (capability-uplift vs
   encoded-preference) so the depreciation clock has a machine-readable target.
3. Related-Skills references to the retired `debugging` skill removed from `postmortem` and `land-the-plane`
   (builders forked pre-Wave-C).

## Post-integration catalog measurements (2026-07-21)

20 skills total (9 ungated + 11 gated). Descriptions: 3,784 chars all-skills vs the 6,000-char CI budget;
2,301 chars ungated (≈0.9k tokens of always-loaded listing at ~100 tokens/skill). Comfortable headroom for
adopters' own skills; `desc-budget` and `spec-portability` enforce the ceiling.

## Rerun protocol

Lift scenarios and assertions are reproducible from this file. Re-run at each model-generation bump;
`review-steering` is the priority re-eval target (uplift-class). Trigger tests should graduate to live-session
checks per CONTRIBUTING when run interactively.
