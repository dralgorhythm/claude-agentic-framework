# Evals: Catalog Rationalization — Base-Model Redundancy (C0 gate)

> Gates Wave C of `artifacts/plan_skills_portfolio_execution.md`. Applies the official redundancy test from
> `artifacts/research_skills_portfolio_strategy.md` (finding 1): if the base model passes a skill's scenarios
> without the skill loaded, the skill's content adds no lift and it retires.
> Run: 2026-07-21, orchestrator-executed.

## Methodology (disclosed per CONTRIBUTING evidence policy)

- **Subjects**: the 6 skills slated for retirement/conversion — designing-apis, application-security,
  observability, interface-design, accessibility, debugging.
- **Design**: 3 scenarios per skill, derived from each skill's central content before the run; 4–6 predefined
  assertions per skill = the skill's key practices. A run passes an assertion if its answer covers the practice.
- **Execution**: 12 fresh subagent sessions (6 skills × claude-haiku-4-5 + claude-sonnet-5), instructed to answer
  from own knowledge only, no tools (0 tool uses confirmed in all 12), ≤200 words/task. N=1 per skill×tier;
  single-graded by the orchestrator against the predefined assertions.
- **Known confounds** (disclosed): (1) subagent sessions inherit this repo's always-loaded rules —
  `debugging-protocol.md` overlaps the debugging skill (the haiku run cited it), `security.md` carries an OWASP
  table, `tech-strategy.md` names OTel. For those skills the demonstrated redundancy is against
  *always-loaded-rules ∪ training* — which is the operative question for an ungated skill in this framework,
  since every session already has the rules. designing-apis, interface-design, and accessibility have **no rule
  overlap**; their results are clean training-knowledge baselines. (2) This is an agent-run approximation of
  CONTRIBUTING's fresh-interactive-session protocol, not a live-session trigger test. (3) N=1 per cell; treat
  percentages as demonstrative, not statistical.

## Results

| Skill | Assertions | haiku | sonnet | Notes |
|---|---|---|---|---|
| designing-apis | 5 (resource/method/status design; pagination trade-off; versioning+deprecation; non-breaking evolution; error envelope) | 5/5 | 5/5 | sonnet: expand-contract by name, Sunset headers, telemetry-gated removal — exceeds skill body |
| application-security | 6 (SQLi+parameterized fix; authz; input validation; data exposure; ≥7 OWASP classes; secrets rules) | 6/6 | 6/6 | both found MORE than the skill teaches (unhandled rejection, rate limiting); sonnet adds CWE ids, IDOR, CSRF |
| observability | 5 (three pillars+correlation; OTel; RED; USE; percentile alert quality) | 5/5 | 5/5 | sonnet names method authors (Wilkie/Gregg), Golden Signals, symptom-vs-cause alerting, error budgets |
| interface-design | 6 (hierarchy; consistency/spacing system; progressive disclosure; wireframe flow; states; spec contents) | 6/6 | 6/6 | sonnet grounds in Gestalt + HIG/Material + design tokens |
| accessibility | 5 (contrast ratios; keyboard/focus; label/aria-describedby/aria-live wiring; color-not-sole-indicator; tools+manual split) | 5/5 | 5/5 | sonnet cites WCAG success criteria by number, adds 2.2 deltas, CI integration (jest-axe/Pa11y) |
| debugging | 5 (reproduce/isolate; hypotheses before edits; root-cause+regression test; prod rollback discipline; anti-thrash escalation) | 5/5* | 5/5 | *haiku explicitly drew on the always-loaded debugging-protocol rule; sonnet reproduced the full discipline in independent phrasing |

**Aggregate: 32/32 assertions at both tiers.** Several answers exceeded the skill bodies in currency and depth
(WCAG 2.2, CWE mapping, methodology attribution) — consistent with the strategy's depreciation finding: this
content has been absorbed into (or superseded by) default model behavior.

## Decisions

- **Retire** designing-apis, application-security, observability, interface-design: content redundant with
  training (apis, ui) or training∪rules (appsec, obs). Unique procedural slivers move per plan C1 (Grep
  data-flow tracing → security-auditor; template relocation for interface-design).
- **Convert** accessibility: knowledge body retires (redundant with training); the DevTools/Lighthouse
  *procedure* folds into qa-engineer + ui-ux-designer.
- **Retire** debugging skill; `rules/debugging-protocol.md` remains the canonical (always-loaded) home of the
  discipline — demonstrated sufficient at both tiers.
- No skill met the "fails baseline → downgrade to trim" branch; Wave C proceeds at planned scope.

## Rerun protocol

Re-run this suite at each model-generation bump (depreciation clock, docs/skills.md doctrine). Scenario prompts
are reproducible from this file; keep assertions fixed for comparability.
