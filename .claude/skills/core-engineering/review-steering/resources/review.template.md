<!--
  REVIEW.md skeleton — scaffolded by .claude/skills/core-engineering/review-steering.

  This file is read ONLY by Anthropic's managed Code Review service, injected into
  every review agent run at highest priority. It is NOT read by the local
  /code-review command — that one reads CLAUDE.md instead. Do not copy CLAUDE.md
  content here; keep only what a reviewer needs that project context doesn't
  already say.

  Compile each section below from .claude/rules/code-quality.md and
  .claude/rules/security.md as TERSE reviewer imperatives (flag X / block on Y /
  ignore Z), not prose. Regenerate in the same PR whenever those rules change —
  this file must never contradict the rules it was compiled from.

  Before committing: replace every [bracketed] placeholder, delete any section
  that doesn't apply, and delete this top comment block.
-->

# Review Instructions

<!-- Source: .claude/rules/security.md — Severity Classification table -->
## Severity & Blocking Policy

- Block merge: Critical, High findings — [confirm this matches your repo's severity table]
- Flag, don't block: Medium findings — [note negotiation criteria, if any]
- Optional: Low findings — style/best-practice, does not gate merge
- Cite a CWE ID on every Critical/High finding (e.g. `CWE-89` SQL Injection, `CWE-798` hardcoded credentials)

<!-- Source: .claude/rules/security.md — Security Checklist + OWASP Top 10 -->
## Always Flag

- Unparameterized or string-built SQL queries — require parameterized statements
- Unvalidated or unsanitized user input at a trust boundary
- Hardcoded secrets, credentials, or tokens, in any format — not just known key patterns
- Missing authorization check on a state-changing endpoint
- Error responses that leak internal details (stack traces, file paths, query text)
- [Add always-flag items specific to your rules that a generic reviewer wouldn't know]

<!--
  Source: CLAUDE.md + .claude/rules/core-directives.md — conventions a generic
  reviewer cannot infer from the diff alone, because they live in this repo's
  own rules rather than in general engineering practice.
-->
## Repo Invariants

- [Artifact naming pattern, e.g. `artifacts/adr_[topic].md` — flag docs saved elsewhere]
- [Enforcement-ladder placement, e.g. "a finding that's already a CI-blocking check is a
  duplicate, not a new finding — cite the CI job instead of re-flagging it"]
- [Any other invariant a reviewer needs restated every run because it isn't in CLAUDE.md]

<!--
  Source: .claude/rules/security.md — Enforcement Ladder (deterministic gates beat
  reviewer instructions) + .claude/rules/code-quality.md — Automated Quality Suite.
-->
## Scope & Noise Control — Do NOT Comment On

- Formatting/style nits a formatter already enforces — [name your formatter, e.g. Biome/Ruff/gofmt]
- Anything a CI check already blocks — cite the check instead of re-flagging it (see the Enforcement Ladder)
- Naming-convention bikeshedding not tied to a correctness or security risk
- Project context already stated in CLAUDE.md — restate only what's review-specific

<!-- rules-hash: [REPLACE — run: cat .claude/rules/code-quality.md .claude/rules/security.md | shasum -a 256 | cut -d' ' -f1] -->
