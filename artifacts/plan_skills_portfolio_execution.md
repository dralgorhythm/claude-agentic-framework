# Plan: Skills Portfolio Execution (PRs A–E, F/G prepared)

> Executes `artifacts/research_skills_portfolio_strategy.md` (2026-07-21). Planning inputs: 4-explorer coupling
> maps (gitignored `scratchpad/` + session records). Decision classification: A/B/D/E two-way doors; C medium
> one-way door gated on recorded base-model evals; G owner-action only.
> Branch strategy: stacked chain from `claude/skills-repo-strategy-6dab3c` (PR #26) — merge bottom-up, delete
> each base branch on merge (PR #18 lesson). Workers: `worker-builder` (isolated worktrees — commit + report SHA,
> orchestrator merges per AGENTS.md Mode A); evals run by the orchestrator (workers cannot spawn workers).

## Catalog delta (net effect C+D)

24 skills (14 ungated) → **20 skills (9 ungated)**: retire 6 dirs (designing-apis, application-security,
observability, interface-design, accessibility, debugging), consolidate 3 product skills → `planning-artifacts`,
add ungated postmortem, dependency-upgrade, review-steering + gated land-the-plane, `/tailor`.
Listing shrinks ~35% before additions; desc-budget check guards the ceiling.

## Wave A — doctrine + positioning (branch `claude/portfolio-a-doctrine`, docs-only)

**A1 (builder):**
- docs/skills.md: add "Portfolio Doctrine" section — Useful × Novel × Standard bar, uplift/preference taxonomy
  with base-model-eval retirement test, four delivery tiers, first-party-collision rule. Do NOT change counts yet.
- CONTRIBUTING.md: under Scope discipline add first-party-collision checklist (check bundled `/skills` set +
  claude-plugins-official + anthropics/skills before proposing); new "Spec portability" subsection (six-field
  contract, non-spec allowlist, quoted YAML — cite PR #24); new "Retirement policy" subsection (depreciation clock).
- README.md: reword "reusable knowledge skills" vocabulary → library/workflow skills (keep count 14 for now);
  add cross-tool paragraph (`.claude/skills/` read in place by Copilot family/VS Code/44-client standard, cite
  agentskills.io) near the plugin section.
- CHANGELOG [Unreleased]: Added/Changed entries.
**AC:** check-invariants green; no count claims changed; no skill files touched.

## Wave B — spec-lint CI (branch `claude/portfolio-b-spec-lint`)

**B1 (builder):** new `spec-portability` check in scripts/check-invariants.sh (style-match existing checks):
1. SKILL.md frontmatter keys ⊆ spec six {name, description, license, compatibility, metadata, allowed-tools} ∪
   Claude-functional allowlist {argument-hint, disable-model-invocation} — anything else fails with guidance
   ("nest under metadata or add to allowlist deliberately").
2. description ≤1024 chars (spec cap; desc-style's <500 stays stricter for style — both run).
3. Frontmatter values beginning with `[` or containing `: ` must be quoted (Copilot CLI regression guard, PR #24).
docs/hooks.md or docs/skills.md enforcement table mention + CHANGELOG line.
**AC:** new check green on current catalog; deliberately-broken fixture fails it locally (demonstrated in PR body);
existing 20 checks untouched.

## Wave C — catalog rationalization (branch `claude/portfolio-c-catalog`, gated on C0)

**C0 (orchestrator, parallel with A/B):** base-model evals for the 6 retiring/converting skills. Method: per skill
3 scenarios from its central content; fresh subagent sessions, no skill text, haiku + sonnet tiers; assertions =
skill's key practices appear unaided. Pass bar for retirement: sonnet covers ≥80% assertions, haiku substantially.
Record methodology + raw results in `artifacts/evals_catalog_rationalization.md` (evidence-policy compliant).
**AC:** artifact committed with per-skill scenario/assertion/result tables; any skill FAILING baseline is flagged
and its retirement re-scoped to trim (decision recorded) before C1 executes it.

**C1 (builder — retirements + conversions; owns swarm-execute, swarm-review, role skills, agents, templates):**
- Delete 6 skill dirs listed above. Move `interface-design/resources/design-framework.template.md` →
  `ui-ux-designer/resources/`.
- worker-architect skills: drop designing-apis → `designing-systems, writing-adrs`; worker-reviewer: drop
  application-security (remove `skills:` line).
- Method rewrites: architect (drop designing-apis), security-auditor (rules/security.md canonical + absorb Grep
  data-flow tracing bullets), qa-engineer + ui-ux-designer (absorb DevTools/Lighthouse a11y procedure, ~10 lines
  each; ui-ux-designer additionally absorbs interface-design's template pointer), builder (debugging skill →
  `.claude/rules/debugging-protocol.md`).
- Related-Skills cleanups: swarm-execute:148 (drop debugging), swarm-review:127 (drop application-security).
- Templates Related-Skills lines: design_spec (→ ui-ux-designer), security_audit (→ threat-modeling),
  plan (→ testing), postmortem (drop observability/debugging).
- Do NOT touch swarm-plan, docs/, README, CHANGELOG, CLAUDE.md.
**AC:** grep zero dangling references to 6 retired names outside CHANGELOG/artifacts history; check-invariants
green (incl. preload-ungated with edited agent lists).

**C2 (builder — consolidation; owns product/ + swarm-plan):**
- Create `product/planning-artifacts/` SKILL.md (ungated; description with distinct trigger clauses for PR-FAQ /
  PRD / roadmap; body = when-which-artifact decision table + per-artifact essentials, <150 lines) with
  resources/{pr-faq,prd,execution-roadmap}.template.md moved in; delete 3 old dirs.
- swarm-plan: lines 140/143 → planning-artifacts; line 153 Related Skills → drop retired names, add
  planning-artifacts.
**AC:** templates byte-identical after move; desc passes desc-style; zero dangling references to 3 old names in
.claude/; check-invariants green.

**C3 (builder — trims; owns 3 files + testing evals):**
- designing-systems: strip C4-notation exposition → decision framework + templates + validation loop; description
  de-collided (frame as this framework's artifact flow, "Use when…" for the repo's ADR/system-design pipeline).
- testing: strip pyramid/TDD textbook sections; keep verification-loop-first, regression-per-bugfix workflow,
  evals exemplar + DevTools E2E pointers; update evals.json assertions if they cite stripped text.
- threat-modeling: trim STRIDE definitions table to a pointer; keep the Grep-tracing STRIDE procedure.
**AC:** each file shrinks ≥25%; evals-json check green; descriptions pass desc-style.

**C4 (builder, after C1–C3 merge — docs/counts):**
- docs/skills.md: regenerate catalog (16 skills: 6 ungated + 10 gated), update counts/categories, recompute budget
  figures (state both 200K/1M denominators + note version drift per strategy artifact).
- README: lines 3/120/124 counts + examples (use surviving skills), line 94 role-skill phrasing (roles absorb
  procedures, delegate where library skills remain); CLAUDE.md:82-83 skill examples if retired names appear.
- CHANGELOG [Unreleased]: Removed/Changed/Deprecated entries incl. migration hints (retired skill → replacement).
**AC:** grep zero references to retired/old names across README/docs/CLAUDE.md; desc-budget + claudemd-lines green.

## Wave D — starter skills (branch `claude/portfolio-d-starters`)

Four builders, disjoint new dirs, each: SKILL.md + evals/evals.json (existing schema; ≥3 cases; trigger cases incl.
near-miss negatives for ungated) + resources as noted. No docs/ edits (D5 integrates).
- **D1 postmortem** (ungated, `operations/postmortem/`): incident → postmortem artifact workflow (blameless,
  five-whys, action-item tracking, `artifacts/postmortem_[id].md` naming); MOVE `.claude/templates/artifacts/
  postmortem.template.md` → resources/ and update docs/customization.md's skill-less-types list (4→3).
- **D2 dependency-upgrade** (ungated, `core-engineering/dependency-upgrade/`): protocol — changelog/breaking-notes
  read, `git ls-remote` tag verification + composite-action internal-pin inspection (PR #20 lessons), staged
  rollout order, regression gate, lockfile hygiene.
- **D3 land-the-plane** (gated, `land-the-plane/`): finish-line workflow generalizing AGENTS.md Mode B (gates →
  commit → pull --rebase → push → verify up-to-date → handoff), argument-hint "[scope]".
- **D4 review-steering** (ungated, `core-engineering/review-steering/`): generate/refresh REVIEW.md +
  CLAUDE.md review section compiled from `.claude/rules/{code-quality,security}.md`; resources/review.template.md;
  explicitly notes REVIEW.md steers the managed pipeline, CLAUDE.md steers local /code-review.
**D5 (orchestrator):** run evals (baseline vs with-skill fresh subagents; simulated-listing trigger tests —
methodology disclosed), record `artifacts/evals_starter_skills.md`; docs/skills.md + README counts (20/9);
CHANGELOG; check-invariants.
**AC per skill:** evals recorded with raw results; description passes desc-style + spec-portability; body <500
lines; no first-party collision (checked against bundled set + official plugins).

## Wave E — /tailor v1 (branch `claude/portfolio-e-tailor`)

**E1 (builder):** `tailor/` gated skill: workflow = detect (manifest table reused from
pre-commit-verification.sh patterns: package.json/pyproject/go.mod/Cargo.toml + CI/IaC signals) → read
tech-strategy.md fill-state → PROPOSE (never silently write): filled golden-path rows, REVIEW.md via
review-steering, prune list (irrelevant framework pieces), gitignore/hook wiring; output = reviewable diff plan.
references/detection.md carries the manifest→golden-path mapping. docs/customization.md "Configure Your Tech
Stack" gains the `/tailor` path; docs/commands.md + README command table row; CHANGELOG.
**E2 (orchestrator):** dogfood — fixture project in scratchpad (TS+Python mixed), run a fresh subagent with the
skill body against it, verify the proposal fills correct rows / proposes correct prunes; record in the PR body.
**AC:** gated (zero listing cost); no silent-write language anywhere; smoke-test evidence in PR.

## Waves F/G — prepared, not executed this session

- **F stack packs**: templates for TS/Python/Go golden paths + tailor v2 instantiation (tracked follow-up).
- **G marketplace**: `/external_plugins` submission checklist doc (owner executes submission).

## Dependency graph

A → B → (C0 ∥ started earlier) → C1 ∥ C2 ∥ C3 → C4 → D1 ∥ D2 ∥ D3 ∥ D4 → D5 → E1 → E2 → (F, G follow-ups).
C0 may run parallel with A/B (no repo-state dependency). File-collision resolution: swarm-plan owned by C2;
docs/README/CHANGELOG owned by C4/D5 integration tasks only.

## Risks

- Stacked-merge discipline: merge bottom-up, delete base branches (PR #18). PR bodies state order.
- preload-ungated / plugin-agents-sync interplay when agent lists change (C1) — run gates before every commit.
- desc-budget headroom after D additions — recompute at D5; if within 10% of ceiling, gate review-steering
  (weakest auto-trigger case) instead of shipping ungated.
- Guard-hook false positives on push/main substrings — keep commands clean, --body-file for PR bodies.
- Retirement eval failure (C0) → downgrade that skill to trim, record decision; do not delete unproven-redundant content.
