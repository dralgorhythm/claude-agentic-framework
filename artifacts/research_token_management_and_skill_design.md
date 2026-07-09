# Research: Token Management & Skill Design for the Agentic Framework

> Swarm research synthesis — 7 parallel worker-research tracks, cross-checked
> Orchestrator: swarm-research | Date: 2026-07-09 | Repo state: v3.0.0 (24 skills, 6 workers, 6 rules)
> Worker reports (full findings + complete source lists) live in `scratchpad/research-*.md` (gitignored):
> `official-skills-guidance`, `token-context-management`, `community-frameworks`,
> `community-token-economics`, `orchestration-economics`, `sdlc-for-agents`, `first-party-capabilities`
>
> Confidence labels: **HIGH** = multiple independent sources or primary official docs fetched 2026-07-09;
> **MEDIUM** = one credible source or unreplicated measurement; **LOW** = inferred/unverified — do not cite externally.
> Sections marked *(orchestrator analysis)* are synthesis judgment, not sourced findings.

## Key Findings

1. **Skill metadata is cheap; attention is the scarce resource.** Descriptions cost ~100 tokens/skill in an always-loaded listing capped at 1% of the context window (`skillListingBudgetFraction`), with combined `description`+`when_to_use` truncated at 1,536 chars per skill and least-used skills silently dropped on overflow (HIGH — Tracks 1+2, official docs; Track 3's issue #59921 documents the overflow failure mode). The binding constraint is not tokens but instruction adherence, which degrades with rule volume independent of window size (MEDIUM — Track 4, HumanLayer 2026-03; corroborated by official "bloated CLAUDE.md causes Claude to ignore your actual instructions" warning, HIGH — Track 2).
2. **This repo's footprint currently fits — with thin headroom on 200K sessions.** Measured: CLAUDE.md 104 lines (official target <200), rules+CLAUDE.md ≈ 5.3k tokens always loaded, 18 ungated skill listings ≈ 1.8k tokens vs a 2.0k budget at 200K (10k at 1M). Six skills are already gated (`disable-model-invocation: true` = zero listing cost until invoked — the officially endorsed pattern, HIGH — Track 1). *(orchestrator measurement, 2026-07-09)*
3. **Sonnet 5 runs a native 1M window by default** (auto-compact ~967K; gateway-routed and `CLAUDE_CODE_DISABLE_1M_CONTEXT` sessions still budget 200K), so footprint claims must state their denominator (HIGH — Track 2, two official pages).
4. **Skill auto-triggering is unreliable by design, not a bug queue item.** Platform issues document ~50% trigger failure where skills overlap trained behavior (#20986), vague-vs-overnarrow failures (#30387), and multiple reports closed "not planned" (HIGH — Tracks 3+4). The one disclosed-methodology measurement: 20% activation with a simple reminder hook vs 84% with a forced-eval hook (N=50, one model — MEDIUM, Track 4). Official counter-guidance: third-person, what+when, deliberately "pushy" descriptions, because Anthropic's stated failure mode is *under*-triggering (HIGH — Track 1, skill-creator).
5. **The enforcement ladder is settled, quadruple-sourced doctrine**: prompt prose is advisory; hooks are deterministic; deny rules and CI are boundaries. "If a rule must hold every time, make it a hook rather than a prompt instruction" (HIGH — official features-overview, best-practices, memory docs, "Steering Claude Code" blog + community consensus; Tracks 1, 3, 6, 7).
6. **Multi-agent economics are confirmed and bounded**: agents ≈ 4× chat tokens, multi-agent ≈ 15×; token spend explains ~80% of performance variance; Opus-orchestrator+Sonnet-workers beat single-Opus by 90.2% *on breadth-first research* — and Anthropic explicitly names coding a poor multi-agent fit (shared state, coordination) (HIGH — Track 5, primary engineering post). Current frontmatter supports `maxTurns`, `isolation: worktree`, `memory`, `effort`; nesting is fixed at depth 5 (HIGH — Tracks 5+7, identical enumerations).
7. **The platform absorbed the scaffolding layer.** Native since 2025-2026: skill discovery, Task tools (TodoWrite disabled by default v2.1.142), worktrees (`--worktree`, `isolation: worktree`, auto-lock/cleanup), agent memory scopes, auto-memory, sandboxing, MCP tool search (deferred schemas by default), `/doctor` diagnostics, ~30 hook events including `TaskCreated`/`TaskCompleted` (HIGH — Track 7). Agent teams are experimental/off-by-default; auto mode is gated — do not assume either in framework guidance (HIGH — Track 7).
8. **Consolidation is the winning community pattern.** Agent OS v3 deliberately shrank ("plan mode, extended thinking, and improved models now handle much of the scaffolding"); SuperClaude measured 25% of a 200K window consumed before work began and its compression-only fix undershot targets; well-regarded catalogs actively reject scope growth (HIGH — Track 3, primary issues/discussions). None of the ten surveyed frameworks ship CI enforcement — this repo's invariant checks are a real differentiator (MEDIUM — Track 3, README-level survey).
9. **The delivery-practice evidence base endorses the framework's premise**: speed and stability correlate rather than trade off (Accelerate 2018, replicated through DORA 2025); AI is an amplifier — 2024 data tied AI adoption to −1.5% throughput/−7.2% stability, with **batch size** as the named mechanism; DORA's mitigations are small batches, fast quality feedback, strong version control (HIGH — Track 6). Veracode: 45% of AI-generated code samples introduce an OWASP Top-10 vulnerability, flat across two years of model generations — security scanning is a mandatory gate, not an option (HIGH — Track 6).
10. **The ecosystem's improvement claims are mostly unverifiable.** Every clean round-number claim checked (41%→11% errors, 91.9% context cut, 65% token cut) failed methodology verification; the one surviving measurement is modest and self-caveated (HIGH pattern — Track 4). Anthropic's own skill practice is eval-first: baseline-vs-skill runs, trigger tests with near-miss negatives, per-tier testing, shipped as the skill-creator plugin (HIGH — Track 1, docs + 2026-03 announcement).

## 1. Context Economics — Official Mechanics

| Consumer | Cost / cap (official unless noted) | Lever |
|---|---|---|
| System prompt + built-in tools | ~4.2k tokens (illustrative walkthrough) | Fixed overhead |
| CLAUDE.md (project+user) | Target **<200 lines/file**; "bloated CLAUDE.md causes Claude to ignore your actual instructions" | Move sometimes-relevant content to skills (officially endorsed) |
| `.claude/rules/*.md` unscoped | Loads every session, same priority as CLAUDE.md; re-injected after compaction | `paths:` frontmatter scopes a rule to matching files (drops from context after `/compact` until re-read) |
| Skill listing | 1% of window; 1,536 chars/skill (desc+when_to_use); least-used dropped first; **not** reloaded after compaction | `disable-model-invocation: true` → zero listing cost; front-load descriptions |
| Invoked skill bodies | <500 lines / <5k tokens target; post-compaction re-injection capped 5k/skill, 25k total, truncation keeps the start | Front-load critical instructions; `references/` one level deep |
| MCP tools | Deferred by default (Tool Search): names only (~120 tokens illustrative); output warn 10k / cap 25k (`MAX_MCP_OUTPUT_TOKENS`) | Keep deferral on; prefer CLI (`gh`, `aws`) over MCP where possible |
| Auto memory | MEMORY.md first 200 lines / 25KB | Index only; topic files load on demand |
| Hooks | Zero unless returning `additionalContext` | Keep hook output grep-filtered |
| Messages | Largest variable consumer | `/clear` between tasks; subagents for heavy reads; `/compact` with focus |

Cache economics (HIGH — Track 2): subscriptions auto-use the 1-hour TTL; reads cost ~0.1×. Mid-session CLAUDE.md/rules edits are cache-safe **but functionally inert** until `/clear`/`/compact`/restart — a counter-intuitive behavior contributors will hit. Bare-name tool denies and model/effort switches invalidate the cache; skill/hook toggles never do. Newer models (Sonnet 5, Opus 4.7+, Fable) tokenize ~30% more tokens for the same text — nominal price comparisons understate real cost (HIGH — Track 5, pricing page).

Inspection tools: `/context` (categorized live breakdown), `/doctor` (skill-listing cost + biggest contributors), `/memory`, `/mcp` (HIGH — Track 2).

## 2. What Makes a Great Skill

Distilled from official docs, the skill-creator, and the 2026-03 eval tooling announcement (HIGH — Track 1; full checklist in the worker report):

- **Description**: third person (mandatory — POV inconsistency breaks discovery); states *what* + *when* with trigger phrases a user would say; deliberately "pushy" ("use whenever the user mentions X, even if they don't ask for Y explicitly") because under-triggering is the documented failure mode; no overlap with sibling skills (overlap → wrong-skill loads); key info first (1,536-char truncation keeps the start).
- **Name**: gerund preferred (`processing-pdfs`), noun acceptable; never `helper`/`utils`; ≤64 chars; lowercase-hyphen.
- **Structure**: SKILL.md <500 lines / <5k tokens; `references/` exactly one level deep (deeper chains get partially `head`-read); TOC for reference files >100 lines; domain-split references so irrelevant domains never load.
- **Degrees of freedom** (the central design model): prose for judgment calls (high freedom), parameterized scripts for preferred-but-flexible patterns (medium), exact scripts for fragile operations (low). "Narrow bridge with cliffs → exact instructions; open field → general direction."
- **Voice**: explain *why*; ALL-CAPS MUST/NEVER is an official yellow flag — reasoning outperforms rigid rules.
- **Evaluation**: evals before extensive docs; baseline (no-skill) vs with-skill in *fresh sessions*; trigger tests with genuinely tricky should-NOT-trigger negatives; test at every deployed tier (Haiku: enough guidance? Opus: over-explained?). First-party tooling: `/plugin install skill-creator@claude-plugins-official`.
- **Placement** (features-overview decision matrix, HIGH): always-known → CLAUDE.md; sometimes-needed knowledge/workflow → skill; must-always-hold → hook; isolation/parallelism → subagent; external system → MCP (+ a skill teaching its use).

### SOLID applied to a skill catalog *(orchestrator analysis, grounded in Tracks 1+3)*

- **Single Responsibility**: one skill = one workflow. The repo's role skills (`qa-engineer`) duplicating library skills (`core-engineering/testing`) is the live violation — verified near-identical content, and overlapping descriptions are the documented wrong-skill-loads trigger.
- **Open/Closed**: extend via `references/` and new skills; CLAUDE.md core stays closed to growth (its budget is adherence, not disk).
- **Liskov**: every skill honors the same contract (frontmatter conventions, third-person what+when description) so any skill is substitutable in the listing without special handling — the conventions *are* the contract, and CI can check them.
- **Interface Segregation**: many small trigger-scoped skills beat monolithic role skills; progressive disclosure is ISP for context — sessions never pay for instructions they don't use.
- **Dependency Inversion**: rules state principles; skills/hooks/CI provide implementations; CLAUDE.md points rather than contains. Agents depend on skill *names* (`skills:` preload), not content.

## 3. Reliability: Descriptions → Hooks → CI

Three layers, each evidence-backed:

1. **Descriptions** get a skill considered (fix per §2) — but even good descriptions mis-fire where they overlap trained behavior (HIGH — Track 3/4 issues).
2. **Hooks** make behavior deterministic: "CLAUDE.md persuades, permissions filter, hooks enforce." Heuristic: rule violation = annoyance → prose; = incident/broken build/leaked secret → hook or deny rule (HIGH — quadruple-sourced). For load-bearing skill activation, the forced-eval hook pattern measured 84% vs 20% (MEDIUM — single N=50 test; offer as option, label the evidence). Note: only exit code 2 blocks (exit 1 proceeds); `WorktreeCreate` is the exception (any non-zero fails); Stop-hook loops are overridden after 8 consecutive blocks.
3. **CI** holds invariants no session can bypass. No surveyed community framework ships this layer (Track 3); this repo's `check-invariants.sh` is the pattern to deepen, not dilute.

## 4. Orchestration Economics

- **When to swarm** (HIGH — Track 5): breadth-first, read-heavy, independent subtopics (research/review/exploration). **When not to**: tightly coupled, sequential, write-heavy coding — Anthropic names coding a poor fit; degradation reports on sequential tasks exist but exact percentages (39-70%) trace to an untraceable aggregator citation (LOW — direction only, never cite the numbers).
- **Cost model**: ~4×/15× multipliers; output tokens are 5× input at every tier; July 2026 pricing: Haiku $1/$5, Sonnet 5 $2/$10 (→$3/$15 from Sept), Opus $5/$25, Fable/Mythos $10/$50 (2× Opus — "top tier" in docs must say which it means). Official tier guidance matches the repo's policy: Haiku simple, Sonnet production default, Opus complex reasoning (HIGH — pricing page).
- **Bounding**: `maxTurns` is supported and is the platform-correct way to bound workers (wall-clock timeouts are not a frontmatter feature); single-level orchestration is enforced by omitting `Agent` from worker tools — a deliberate policy atop a depth-5 platform (HIGH — Tracks 5+7).
- **Isolation**: subagents are context firewalls — heavy reads inside, compact summary out; results returned to the parent consume parent context, so bound them. `isolation: worktree` is the native answer to parallel-write conflicts (auto-lock, auto-cleanup); "file locks" are convention, not platform (HIGH — Track 5).
- **Watch**: v2.1.198 changed the built-in Explore default from Haiku to inherit-parent-model — custom workers with pinned `model:` are unaffected (this repo's explorer pins haiku ✓), but any reliance on built-in Explore inherits expensive tiers (HIGH — Track 5). The SDK now points "dozens-to-hundreds of agents" at the `Workflow` tool; subagent swarms are for "a few delegated tasks per turn" — exactly this repo's lane (MEDIUM — SDK docs).
- **Quota reality**: 10 parallel agents ≈ 10× quota burn; Anthropic's cost guidance moved $6→$13/dev/day in one 2026 revision; Uber exhausted its 2026 AI budget in four months at $500-$2,000/engineer/month (HIGH — Tracks 4+7). Fast mode pays only when a human is actively waiting (MEDIUM — Track 4).

## 5. First-Party Surface: Ride It, Don't Rebuild It

Obsoleted workarounds a framework must not ship (HIGH — Track 7): skill-activation hooks + registry JSON (native discovery), markdown TODO/handoff files (Task tools: `TaskCreate`/`TaskGet`/`TaskList`/`TaskUpdate`; TodoWrite disabled by default v2.1.142), manual worktree scripts (`--worktree`, `.worktreeinclude`, `isolation: worktree`), custom learnings-file memory (auto-memory + `memory:` agent scopes — `project` scope is documented as the recommended default and is version-controllable), Docker-wrapper isolation for the common case (native sandbox, macOS/Linux/WSL2), custom MCP trimming scripts (Tool Search default-on), custom "audit my setup" tooling (`/doctor`).

Do **not** assume in guidance: agent teams (experimental, env-gated), auto mode (research preview, plan/model/provider-gated), cross-session task-list persistence (dedicated docs page 404'd; third-party claims only — LOW). Hook event count ≈ 30 — verify before publishing an exact number. Reserved MCP server names (`workspace`, `computer-use`, etc.) silently skip user configs — lint-worthy if the repo ever ships `.mcp.json` examples.

Where a framework still adds value (Track 7 + Track 3 gap analysis): opinionated domain skills, rules content, worker tiering, CI invariants, and the delivery-methodology encoding itself — none provided by the platform.

## 6. Delivery Evidence → Encoding Map

Condensed from Track 6 (full table + citations in the worker report):

| Practice | Evidence | Encode as |
|---|---|---|
| Small batches / small PRs (200-400 LOC review ceiling; 15-45 min task units) | HIGH (DORA mechanism; SmartBear/Cisco; Google <10 files at P90) | Task-decomposition guidance in swarm-plan/execute + PR-size warning gate |
| CI + fast automated tests | HIGH (DORA core capability) | CI (canonical) + hooks |
| Speed↔stability correlate | HIGH (Accelerate, replicated) | Framing principle: gates are throughput enablers |
| TDD | HIGH on quality direction; genuinely mixed on productivity; small-steps discipline may be the active ingredient (Fucci 2017) | "Verification-loop-first" framing (Anthropic's own): give the agent a check it can run; literal red-green-refactor as strong default for new logic — already this repo's testing-skill posture |
| Regression test per bugfix | MEDIUM-HIGH (consensus) | Rule + CI check |
| Fresh-context adversarial review | HIGH as documented Anthropic pattern | swarm-review ✓ — instruct reviewers to flag correctness gaps only (over-triggering is the documented failure) |
| Shift-left security | Directionally solid; **"100x cost" figure is unverifiable folklore — never cite it** | SAST/secret-scan gates; Veracode 45% justifies mandatory scanning |
| Plan-review-implement | HIGH (official Explore→Plan→Implement→Commit) | Planning flow ✓ + risk calibration: "if you could describe the diff in one sentence, skip the plan" |
| DORA metrics for agents | MEDIUM — evolving; Rework Rate added 2025, benchmarks thin | Watch; don't over-promise measurement |

The named primary anti-pattern to design against: **big-batch, under-reviewed AI changesets** — the one mechanism DORA, GitClear, Faros, and the agent-PR literature all converge on (HIGH direction; several vendor magnitudes unreconciled — see Contradictions).

## 7. Community Landscape & Positioning

Bimodal ecosystem (Track 3): mega-collections (anthropics/skills ~158k★, superpowers ~250k★) vs curated opinionated frameworks (20-50k★). Praise concentrates on scope discipline and native-platform deference; criticism on over-engineering ("kept maybe 30%" — superpowers HN thread, ~60/40 favorable). Distribution has consolidated on the plugin marketplace; raw `.claude/` remains correct for a drop-in template per official guidance (both can coexist — this repo already does). Sustainability signals: cadence matched to the platform's near-daily releases, bus-factor, and *defended* scope (VoltAgent's rejected expansions; awesome-list rotating curation). No surveyed framework: ships CI enforcement, or documented an explicit commands→skills migration — this repo appears ahead on both (MEDIUM — survey-level).

## Cross-Cutting Themes

1. **The scarce resource moved from window to attention.** 1M contexts don't buy adherence; every always-loaded sentence competes with the task. Curate by observed failure, not upfront exhaustiveness (official context-engineering guidance).
2. **Progressive disclosure is the platform's load-bearing architecture** — skills (metadata→body→references), MCP (names→schemas), memory (index→topics). Framework content should mirror it at every layer.
3. **A determinism gradient runs through everything**: prose < skill < hook < deny/CI. Placing each rule at the right rung is the single highest-leverage design act.
4. **Convergent evolution**: official guidance, surviving community frameworks, and forty years of delivery research independently arrive at the same shape — small, focused, curated units; verification loops; fresh-context review; deterministic gates for what must hold.
5. **Platform velocity is a standing maintenance tax**: near-daily releases invalidated multiple baseline facts within 9 days (Explore default, task tools, Sonnet 5 window). Dated claims + CI invariants + periodic re-verification are survival features.
6. **Epistemic discipline is a differentiator**: the ecosystem is saturated with unverifiable round-number claims; measured-or-labeled is both rarer and cheaper to maintain.

## Contradictions & Unresolved Questions

- **MCP Tool Search savings**: 85-95% vs 46.9% figures use different baselines; unreconciled. Say "substantial, mechanism-verified" — no single number (Tracks 2+4).
- **Hook event count**: converges on ~30; not pinned. Verify before publishing (Track 7).
- **Task-list persistence across sessions/agents (non-team)**: undocumented; third-party only (LOW). Don't build on it (Track 7).
- **Sequential-task degradation percentages** (39-70%) and the 4-220× token study: secondary aggregator, primaries untraced. Direction corroborated; numbers uncitable (Track 5).
- **Faros telemetry magnitudes** (review time +91% vs +441%): snapshot inconsistency; direction only (Track 6).
- **No matched AI-vs-human PR baseline exists anywhere** — a genuine field gap, not a search failure (Track 6).
- **"Microcompact"**: not an officially named mechanism; the baseline's term should be retired (Track 2).
- **`license` skill-frontmatter field**: not found in any official source; treat as nonexistent pending a spec read (Track 1).

## Recommendations for This Repository

Priority 1 — correctness and adherence:

1. **Close the worker-bounding gap**: `agent-constraints.md` mandates `maxTurns`; no worker sets it. Add `maxTurns` to all six `.claude/agents/worker-*.md` (platform-verified field). Add `isolation: worktree` to `worker-builder` (the write-capable worker). *(Tracks 5+7 + orchestrator frontmatter audit)*
2. **Resolve role↔library skill duplication (SRP)**: `qa-engineer`↔`testing` (verified near-identical), `architect`↔`architecture/*`, `security-auditor`↔`security/*`, `ui-ux-designer`↔`design/*`. Preferred shape: role skills become thin, **gated** (`disable-model-invocation: true`) user-invoked entry points that delegate to library skills — removing four overlapping descriptions from the listing (~400 tokens of headroom on 200K sessions) and eliminating the wrong-skill-loads overlap. Constraint: never gate skills preloaded via agent `skills:` fields (`designing-systems`, `writing-adrs`, `designing-apis`, `application-security`) — gating blocks subagent preload. *(Tracks 1+3 + orchestrator audit)*
3. **Rewrite descriptions to official spec** — third person, what + "Use when…" triggers, pushy phrasing, key info first. The four ungated role skills currently fail every element (e.g., "Test strategy, automation, and quality verification" has no trigger clause). Purge command-era leftovers (`$ARGUMENTS` body text where not meaningful). Extend `scripts/check-invariants.sh`: description present, third-person verb-first, contains "Use when", ≤1,536 chars, no sibling-overlap keywords. *(Track 1)*
4. **Run the enforcement-ladder audit over the six rules files**: keep prose for judgment; move must-hold items to hooks/deny/CI. Candidates: secret-scan `PreToolUse`/pre-commit hook (security.md checklist), PR/diff-size warning gate (200-400 LOC evidence), optional `TaskCompleted` quality-gate hook. Docs must stop implying prose rules are guarantees. *(Tracks 1+3+6+7)*

Priority 2 — efficiency and evidence:

5. **Dedupe the always-loaded layer for adherence, not tokens**: 5.3k tokens is affordable; the duplication is not (agent-constraints repeated in swarm skills; Two-Hats in code-quality + testing skill; security checklist echoed in security skills). One fact, one layer: rules state the principle, skills carry the workflow, CLAUDE.md points. *(Tracks 2+4)*
6. **Adopt eval-first skill development**: run skill-creator evals (fresh-session baseline-vs-skill; trigger tests incl. near-miss negatives; per-tier checks) over the 14 library skills; record results in `artifacts/`; add a repo policy — no improvement claims without disclosed methodology. *(Tracks 1+4)*
7. **Document the budget math and monitoring**: current listing ≈ 1.8k/2.0k tokens on 200K sessions — each new ungated skill (~100 tokens) spends 5% of that budget; `/doctor` is the check; state both denominators (200K/1M) in README claims. *(Tracks 1+2 + measurement)*

Priority 3 — strategy and positioning:

8. **Anchor the README on the evidence**: safe-and-fast is one property, not a trade-off (Accelerate); AI amplifies existing discipline (DORA 2025); the framework exists to prevent big-batch unreviewed AI changesets. Add task-sizing guidance (200-400 LOC / 15-45 min) to swarm-plan/swarm-execute. *(Track 6)*
9. **Add risk calibration to the planning flow**: document when to skip ceremony ("diff describable in one sentence → skip the plan") — the over-engineering critique is the top complaint against heavyweight frameworks. *(Tracks 3+6)*
10. **Publish a scope-discipline statement**: catalog size is a defended design decision (budget ceiling #59921 makes small catalogs a community good, since the listing budget is shared across everything a user installs). *(Track 3)*
11. **Make model-tier docs explicit and dated**: "top tier" = Opus ($5/$25); Fable/Mythos = 2× Opus, reserve for stakes that justify it; note the ~30% tokenizer effect; date all cost figures (Anthropic revised its own within months). Keep the haiku pin on worker-explorer. *(Track 5)*
12. **Delete/avoid re-implementation and don't assume experimental features** (per §5); consider consolidating `worker-researcher` into `worker-explorer` (overlapping mandates — ISP at the agent layer) *(orchestrator analysis)*; frame swarm skills as the documented "few workers per turn" sweet spot and watch the `Workflow` tool's overlap with swarm-execute. *(Tracks 5+7)*

## Confidence Summary

- Official mechanics (listing budget, caps, compaction, caching, frontmatter surfaces, pricing): **HIGH** — primary pages fetched 2026-07-09, cross-worker consistent.
- Community anti-patterns with named issues (bloat, trigger failures, budget ceiling): **HIGH**; survey star-counts and README-level claims: **MEDIUM**.
- Delivery-practice evidence (DORA/Accelerate, review size, Veracode): **HIGH**; vendor telemetry magnitudes (GitClear causality, Faros): **MEDIUM/HEDGED**.
- Forced-eval activation numbers (84%/20%): **MEDIUM** — single disclosed-methodology test.
- All flagged LOW items (§Contradictions) are excluded from citable framework claims.

## Gaps & Follow-Up

- Re-verify exact hook event count and task-list persistence semantics before writing either into docs (Track 7 gaps).
- Trace the Google/UIUC multi-agent studies to primaries if degradation numbers are ever needed (Track 5 gap).
- No controlled evidence exists on rules-file count vs adherence — candidate for this repo's own eval-first program (Track 4 gap).
- LSP plugin coverage vs tech-strategy golden-path languages unchecked (Track 7 gap).

## Source Index (primary anchors; full per-track lists in worker reports)

Official (fetched 2026-07-09): code.claude.com/docs — skills, sub-agents, agent-sdk/subagents, mcp, memory, context-window, prompt-caching, model-config, best-practices, features-overview, worktrees, plugins, permission-modes, sandboxing, tools-reference, hooks, agent-teams, costs · platform.claude.com/docs — agent-skills overview + best-practices, context-windows, pricing · anthropic.com/engineering — multi-agent-research-system (2025-06), equipping-agents-for-the-real-world-with-agent-skills (2025-10), effective-context-engineering-for-ai-agents (2025-09) · claude.com/blog — steering-claude-code (2026), improving-skill-creator (2026-03), how-anthropic-teams-use-claude-code (2025) · github.com/anthropics/skills (skill-creator).
Community/issues: anthropics/claude-code #59921, #29971, #20986, #30387, #15136, #35053, #13343 · SuperClaude #286 · agent-os discussion #310 · HN 47418177, 46256606 · scottspence.com (2025-11) · HumanLayer (2026-03) · Piebald-AI/claude-code-system-prompts.
Delivery research: Forsgren/Humble/Kim *Accelerate* (2018) · DORA 2024 + 2025 reports + AI Capabilities Model (dora.dev) · SmartBear/Cisco review study · google.github.io/eng-practices · Fagan (1976) · Rafique & Mišić (2013), Bissi (2016), Fucci (2017) · Petrović ICSE 2021 · GitClear 2025/2026 · Veracode GenAI Code Security 2025/Spring-2026 · arXiv 2601.20109 · Thoughtworks SDD (2025) · Fortune (Uber, 2026-05).
