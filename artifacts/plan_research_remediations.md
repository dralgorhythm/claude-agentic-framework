# Plan: Research Remediations (Single PR)

> Planning artifact — swarm-plan orchestrator | 2026-07-09
> Requirements source: `artifacts/research_token_management_and_skill_design.md` (12 recommendations)
> Exploration: 5 parallel worker-explorer passes (cross-references, enforcement surface, duplication map, docs surface, skill overlap/descriptions)
> Decision class: **Two-Way Door** (config/docs/content in a versioned template; reversible). No ADR required.
> Delivery shape: **one PR, eight atomic commits (C1–C8)** — user directive. The PR will exceed the 200-400 LOC review guidance the research itself recommends; mitigation is commit-level reviewability: each commit is self-contained, independently green, and maps 1:1 to a task below.

## Grounding facts from exploration

- **Enforcement baseline is strong**: 10 runtime hooks (secret detection, main-push block, auto-format, file locks), 14 CI invariants, 186 allow/22 deny permission rules. Real gaps: no CI-side secret scan (hooks are fail-open by design), no diff-size advisory, no description *style* linting, no `maxTurns` check.
- **Cross-reference map**: gating role skills touches MIGRATION.md:150-156 ("remain model-invocable" claim), docs/skills.md:49, README.md:86, CLAUDE.md:82-87, docs/commands.md, check-invariants.sh gating list (currently exactly 6). Slash names never change (directory names untouched).
- **worker-researcher has exactly 6 tracked references** (verified by git grep): plugin.json:24, the agent file, swarm-execute/SKILL.md:49, swarm-plan/SKILL.md:61, README.md:105, docs/swarm.md:28. `worker-explorer` already has WebFetch/WebSearch — absorption is clean.
- **Overlap/preserve map** (role skill → keep): architect 35% dup → keep standards-definition + Sequential-Thinking framing; security-auditor 40% → keep GitHub-MCP findings tracking + audit checklist; ui-ux-designer 50% → keep Chrome DevTools breakpoint/Lighthouse gates; builder 45% → keep plan-governance ("NO deviations") + dependency/CI checking; code-check 25% → keep swarm audit pattern + smells catalog (drop verbatim SOLID enumeration); qa-engineer 90% → keep test-types tool table + QA gates only.
- **Descriptions**: all 14 library skills pass the official spec; all 10 role/swarm skills fail ≥1 criterion. Post-gating, descriptions split two-tier: ungated = machine-triggering text (needs what + "Use when" + triggers); gated = human menu text (needs clean third-person; `argument-hint`/`$ARGUMENTS` are legitimate there).
- **Duplication map**: 15 offenders located; worst are git-push-required (4 places), regression-test (5), quality-gates (4), artifact-directories (4). Calibration: CLAUDE.md Core Principles are an *intentional* summary layer — dedup targets same-detail-level restatements only. AGENTS.md is a deliberate cross-tool surface: keep, sync, don't dedup away.
- **Docs**: claims are accurate; one stale model comment (swarm-execute/SKILL.md:40). CHANGELOG [Unreleased] empty. No CONTRIBUTING.md (eval-first policy lands there).

## Commits / Tasks

### C1 — Worker hardening + researcher consolidation (R1, R12) — 0.5d
Files: `.claude/agents/*.md`, `.claude-plugin/plugin.json`, `README.md:105`, `docs/swarm.md:28`, `.claude/skills/swarm-{plan,execute}/SKILL.md` worker tables, `scripts/check-invariants.sh`.
- Add `maxTurns` to every agent — proposed: explorer 30, builder 60, reviewer 40, research 80, architect 40 (sized from observed 16-50 tool-use runs this week; tunable, documented in-file via one-line comment in frontmatter? No — YAML frontmatter stays clean; rationale goes in docs/swarm.md).
- Add `isolation: worktree` to worker-builder.
- Delete `worker-researcher.md`; fold mandate into worker-explorer's description ("quick web research, API docs, library comparison"); update the 6 references; plugin-agents-sync CI check must pass.
- New CI checks: every agent has integer `maxTurns`; builder has `isolation: worktree`.
**AC**: `check-invariants.sh` green including 2 new checks; `git grep worker-researcher` hits only CHANGELOG/MIGRATION/artifacts; plugin.json lists exactly the 5 remaining agents.

### C2 — Role-skill restructure to gated entry points (R2) — 1d
Files: `.claude/skills/{architect,qa-engineer,security-auditor,ui-ux-designer}/SKILL.md` (+ `builder`, `code-check` trim), `MIGRATION.md:150-156`, `docs/skills.md:49`, `README.md:86`, `docs/commands.md`, `docs/getting-started.md`, `scripts/check-invariants.sh` gating list 6→10.
- Add `disable-model-invocation: true` to the four advisory role skills; rewrite each as a thin entry point: role framing + preserved-unique content (per overlap map above) + explicit delegation ("Follow the `testing` and `accessibility` skills for methodology" style).
- Trim builder/code-check duplicated content per overlap map; code-check references code-quality.md instead of restating SOLID.
- **Hard constraint**: never gate `designing-systems`, `writing-adrs`, `designing-apis`, `application-security` (preloaded via agent `skills:` — gating blocks preload). Add CI check: every skill named in any agent's `skills:` field must NOT have `disable-model-invocation`.
**AC**: 10 gated skills (CI-enforced); each role SKILL.md ≤60 lines; signature-phrase spot-greps show no verbatim duplicated paragraphs vs library skills; slash names unchanged; MIGRATION/docs claims updated.

### C3 — Description + command-era cleanup (R3) — 0.5d [blocked by C2]
Files: role/swarm SKILL.md frontmatter + Handoff sections, `scripts/check-invariants.sh`.
- Two-tier CI description linter: all skills — non-empty, third-person verb-first (heuristic verb allowlist), ≤500 chars; ungated skills additionally must contain "Use when".
- Rewrite gated descriptions (architect, builder, qa-engineer, security-auditor, ui-ux-designer, code-check; swarm-* if needed) as verb-first third-person.
- Modernize Handoff sections: `/command` framing → skill-name references; drop dangling `$ARGUMENTS` where the skill takes no meaningful argument (keep `argument-hint`/`$ARGUMENTS` on argument-taking gated workflows).
**AC**: new linter green over all 24 skills; E5 compliance table all-pass under the tiered rule.

### C4 — Enforcement-gap additions (R4) — 1d [independent]
Files: `.github/workflows/framework-invariants.yml` (+ new jobs), `docs/hooks.md`, `.claude/rules/security.md`, `.claude/rules/core-directives.md` (ladder reference).
- CI secret-scan job (Trivy `fs --scanners secret` — tech-strategy names Trivy), blocking.
- CI diff-size advisory job: PR > 400 changed LOC → non-blocking warning annotation citing the review-effectiveness evidence.
- Document the enforcement ladder (prose < skill < hook < deny/CI) in security.md + docs/hooks.md; correct any "rules guarantee X" phrasing — hooks are fail-open guardrails, deny+CI are boundaries.
- Add opt-in hook recipes to docs/hooks.md: `TaskCompleted` quality gate; forced-eval skill-activation hook (labeled MEDIUM evidence, single N=50 test).
**AC**: 2 new CI jobs run on PR (scan blocking, size advisory non-blocking); ladder table present in both files; recipes carry evidence labels; no doc claims prose rules as enforcement.

### C5 — Always-loaded dedup (R5) — 1d [blocked by C2, C3]
Files: `.claude/rules/*` (esp. core-directives, agent-constraints, debugging-protocol, code-quality), `CLAUDE.md`, `.claude/skills/swarm-*/SKILL.md`, `architect` skill, `AGENTS.md` (sync only).
- Apply the 15-item duplication map with the hierarchy rule: keep CLAUDE.md principle summaries + one canonical detail location; same-level restatements become one-line pointers. Canonical homes: git-push → core-directives §6; Two-Hats → code-quality; quality-gates → code-quality; model-tiering → agent-constraints; artifacts/scratchpad detail → core-directives §4-5; tech-strategy-authoritative → tech-strategy preamble (core-directives §1 becomes a pointer); regression-test detail → testing skill (principle stays in CLAUDE.md).
- Fix stale model comment swarm-execute/SKILL.md:40 → pointer to agent frontmatter.
**AC**: CLAUDE.md ≤200 lines (CI check added), rules total lines strictly decrease from 403, swarm skill line counts decrease; each top-10 duplicated fact greps to exactly one detail-level location; AGENTS.md remains consistent.

### C6 — Docs & positioning (R7-R11) — 0.5d [blocked by C5]
Files: `README.md`, `docs/swarm.md`, `docs/skills.md`, `.claude/rules/core-directives.md` (Rule 6), `CLAUDE.md` (workflow line), `.claude/skills/swarm-{plan,execute}/SKILL.md`.
- README: evidence anchor (speed↔stability correlate — Accelerate; AI-as-amplifier — DORA 2025; named anti-pattern: big-batch under-reviewed AI changesets) + scope-discipline statement (defended catalog; cumulative listing budget is shared across everything a user installs) + budget math with both denominators and `/doctor`+`/context` monitoring pointer.
- docs/swarm.md: dated (2026-07) model-tier table — top tier = Opus explicitly; Fable/Mythos = 2× Opus, reserve; +30% tokenizer note; task-sizing guidance (200-400 LOC / 15-45 min) here and in swarm-plan/execute bodies.
- core-directives Rule 6 + CLAUDE.md: risk calibration — planning flow scales with scope; skip ceremony when the diff is describable in one sentence (cites swarm-plan's existing size-scaled artifact table).
**AC**: sections present with dated citations; zero unmeasured round-number improvement claims (grep for `%` in changed docs); Rule 6 contains the calibration clause.

### C7 — Eval-first bootstrap (R6) — 0.5d [independent]
Files: `CONTRIBUTING.md` (new), `.claude/skills/core-engineering/testing/evals/` (new exemplar), `docs/skills.md`, `scripts/check-invariants.sh`.
- CONTRIBUTING.md: template-repo contribution model; eval-first policy (new/changed skills ship ≥3 eval scenarios + fresh-session baseline comparison; ungated skills also ship trigger tests with near-miss negatives); evidence policy (no improvement claims without disclosed methodology); scope-discipline reference.
- Exemplar: `evals/evals.json` for the `testing` skill (skill-creator format) + short run instructions referencing `/plugin install skill-creator@claude-plugins-official`.
- CI: exemplar evals.json parses as valid JSON.
**AC**: CONTRIBUTING exists with the three policies; exemplar validates in CI; docs/skills.md links the workflow.

### C8 — Changelog, version, PR assembly — 0.25d [blocked by all]
Files: `CHANGELOG.md` [Unreleased], `MIGRATION.md` (append), PR description.
- CHANGELOG entries: Added (CI jobs, CONTRIBUTING, evals, maxTurns/isolation), Changed (role skills gated + thinned, descriptions, dedup, docs), Removed (worker-researcher, with migration note: use worker-explorer for quick lookups, worker-research for deep dives).
- Version recommendation: **3.1.0** (pragmatic — v3.0.0 is one day old, adopter base minimal; strict SemVer would argue 4.0.0 for the agent removal; maintainer decides at release time via `scripts/release.sh`).
- Full `check-invariants.sh` green; PR description maps commits→tasks→research recommendations and states the deliberate single-PR choice with commit-level review guidance.
**AC**: [Unreleased] populated across categories; MIGRATION appended; all CI checks green; PR body drafted.

## Dependency graph

```
C1 ──────────────┐
C4 ──────────────┤
C7 ──────────────┼──► C8
C2 ─► C3 ─► C5 ─► C6 ─┘
```
Parallel lanes: {C1, C4, C7} and the C2→C3→C5→C6 chain. Total ≈ 5.25 worker-days; wall-clock ≈ 2-3 days with parallel workers.

## Explicitly out of scope (follow-ups, not this PR)

- Running full skill-creator evals across all 14 library skills (C7 ships the policy + one exemplar; the sweep is its own effort).
- `worker-researcher` hard-delete fallout beyond this repo (adopters pinned to 3.0.0 are unaffected until they upgrade; MIGRATION covers it).
- LSP plugin coverage check vs tech-strategy golden paths; hooks event-count verification; task-list persistence semantics (research gaps — revisit when docs land).
- Any always-on new hooks (recipes are documented opt-in only, per the repo's fail-soft hook doctrine).

## Risks & mitigations

- **PR size vs review evidence**: deliberate user choice; mitigated by atomic commits, per-commit green CI, and this plan as the review map.
- **Gating regression** (a preloaded skill accidentally gated): prevented by the new CI check in C2, not convention.
- **maxTurns too tight**: values sized from observed runs with ~2× headroom; documented as tunable in docs/swarm.md.
- **Explorer misattributions**: two path anomalies already caught and corrected via git grep; execute-phase workers must verify file:line targets before editing (standard practice).

## Handoff to /swarm-execute

Tasks #10-#17 in the native task list (epic #9), acceptance criteria above, dependencies wired via blockedBy. Suggested worker assignment: C1/C3/C5/C6/C8 → worker-builder (mechanical/content edits); C2 → worker-builder with this plan's preserve-map as prompt context; C4 → worker-builder (CI/docs) with worker-reviewer verification pass; C7 → worker-builder. Final gate: swarm-review over the assembled branch before PR.
