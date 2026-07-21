# Research: Skills Portfolio Strategy for the 2026 Agent Skills Ecosystem

> Swarm research synthesis — 3 parallel tracks (catalog inventory · first-party platform coverage · deep-research
> harness with 3-vote adversarial claim verification, 107 agents) cross-read against
> `artifacts/research_token_management_and_skill_design.md` (2026-07-09).
> Orchestrator: swarm-research pattern | Date: 2026-07-21 | Repo state: v3.1.0, 24 skills (10 gated / 14 ungated)
> Worker reports live in gitignored `scratchpad/`: `research-platform-coverage-2026-07-21.md`,
> `research-catalog-inventory-2026-07-21.md`, `strategy-hypotheses-skills-portfolio.md`.
>
> Confidence labels: **HIGH** = verbatim-verified on live primary sources 2026-07-21 (deep-research verify pass)
> or direct repo/live-session observation; **MEDIUM** = single credible source, official-but-inferential, or
> survey-level; **LOW** = judgment/unverified — not citable externally. *(strategy)* marks orchestrator synthesis.

## The Question

The repo's historical value was "a source of a variety of skills" — but the variety was language-specific
knowledge, which the 2026 modernization deliberately cut (67→14 ungated). How do we restore variety-value the
right way for the current meta: useful, novel, **standard** (spec-portable) skills that are not restatements of
model training — plus active tech- and policy-specific customization once an adopter establishes their environment?

## Key Findings

1. **Anthropic's official skill taxonomy is the inclusion bar we were looking for.** Two valuable categories
   only: **capability uplift** (things the base model can't do consistently) and **encoded preference** (sequencing
   capabilities the model has, according to *your* process). Restating model knowledge is the named anti-pattern
   ("Default assumption: Claude is already very smart"; "Only add context Claude doesn't already have"), with an
   official redundancy test: if base-model evals pass without the skill loaded, retire it (HIGH — best-practices
   doc + 2026-03 skill-creator blog, verbatim). Durability asymmetry: capability uplift **depreciates** as models
   improve; encoded preference endures, but only to the fidelity of the actual workflow (MEDIUM — official, the
   third-party application is inference).
2. **Agent Skills is now a real 44-client open standard, and `.claude/skills/` is read in place by non-Claude
   tools.** The whole GitHub Copilot family (cloud agent, code review, CLI, app, VS Code/JetBrains agent mode)
   discovers repo skills from `.claude/skills/` directly; VS Code also reads `~/.claude/skills/`. Cursor, Codex,
   Gemini CLI, Junie, Goose, Kiro, Databricks, Snowflake et al. support the format (HIGH — agentskills.io clients
   page, GitHub/VS Code docs, verbatim). Portability is zero-relocation but not zero-modification: this repo's own
   PR #24 (Copilot CLI ≥1.0.65 rejecting unquoted `argument-hint`) is the canonical example; VS Code silently
   drops skills whose `name` ≠ parent directory (HIGH).
3. **The portable contract is exactly six frontmatter fields** — `name` (≤64, must match dir) and `description`
   (≤1024) required; `license`, `compatibility`, `metadata`, `allowed-tools` (explicitly experimental) optional —
   with `metadata` as the *only* sanctioned extension point. Claude Code's `model`, `argument-hint`, `context`,
   `disable-model-invocation` sit outside the spec and are ignored (not fatal) elsewhere (HIGH — spec, verbatim).
4. **Generic engineering-workflow skills are commoditized first-party.** Claude Code bundles debug / code-review /
   verify / simplify (+ batch, loop, claude-api; exact set varies by version/surface — check `/skills`). The
   official marketplace carries **38 Anthropic-maintained plugins** including code-review, code-simplifier,
   security-guidance, pr-review-toolkit, feature-dev, commit-commands, code-modernization, claude-md-management,
   hookify, skill-creator, and **12 language-server integrations**; `anthropics/skills` (163k★) covers document
   and builder skills. Notably it contains *no* code-review / security-review / testing-strategy /
   language-best-practices skills — those are handled by built-ins and plugins (HIGH — GitHub API + docs, verbatim).
   The 2026-02 cowork plugin suites commoditize departmental role skills (Engineering/Design/Operations/…)
   (MEDIUM — press + live-session observation; official manifest unverified).
5. **For code review, the sanctioned third-party leverage point is repo configuration, not rival skills.** The
   managed Code Review service's entire customization surface is two files: CLAUDE.md (project context) and
   **REVIEW.md** (injected into every review agent as highest-priority instructions); local `/code-review` follows
   CLAUDE.md. A framework adds review value by *shipping and tailoring those files* (HIGH — code-review docs, verbatim).
6. **This repo's stated policy already matches the official bar — the shipped catalog doesn't.** docs/skills.md
   declares "No Generic Coverage by Design," yet 5 of 14 ungated skills are knowledge restatements
   (designing-apis, accessibility, interface-design, observability, application-security — spot-verified: OWASP
   list, OTel/RED/USE textbook content), and two descriptions collide with first-party surface
   (`application-security` "use when reviewing code for security" vs bundled security-review; `debugging` vs
   bundled `/debug`; `designing-systems` name-collides with a first-party cowork skill) (HIGH — inventory + file reads).
7. **Environment-triggered tailoring is a genuine open lane.** Native `/init` generates CLAUDE.md from codebase
   analysis and `/doctor` audits installed config, but nothing native detects a stack and suggests skills, rules,
   hooks, or policy wiring ("cannot recommend beyond what's already installed") (HIGH — docs). The deep-research
   verify pass additionally killed *every* candidate claim about established community solutions on this axis —
   no verified prior art surfaced (MEDIUM signal: absence of surviving claims ≠ absence of practice; the 07-09
   ten-framework survey also found none). Watch item: `/init` is evolving (interactive mode behind
   `CLAUDE_CODE_NEW_INIT=1`, v2.1.216+) — generic stack detection may go native; policy-aware tailoring against
   this framework's own rules/enforcement-ladder would remain differentiated (*strategy*).
8. **An official gated distribution channel exists**: `anthropics/claude-plugins-official` maintains an
   `/external_plugins` tier with a submission form and a quality/security approval bar; a community mirror runs
   the same pipeline with automated scanning (HIGH — README + docs, verbatim).
9. **Community-saturation claims did not survive adversarial verification** (all killed or unverifiable
   2026-07-21). The 07-09 survey's shape stands at MEDIUM: bimodal ecosystem (mega-collections vs curated
   frameworks), consolidation as the winning pattern, no surveyed framework shipping CI enforcement. Treat
   "where the community is" as directional, not factual.
10. **Listing-budget mechanics have drifted across readings and must be treated as version-dependent**: 2026-07-09
    verification found 1% of window / 1,536 chars per skill; 2026-07-21 reading found 2% (16k-char fallback) /
    250-char listing cap / `SLASH_COMMAND_TOOL_CHAR_BUDGET` override (CONTRADICTION — carry both, dated). The
    strategic invariant holds either way: the listing is finite, shared with everything the adopter installs,
    silently drops least-used entries, and every ungated skill spends it (HIGH on the invariant).

## The Inclusion Bar: Useful × Novel × Standard *(strategy)*

Adopt as the repo's published skill-acceptance test, replacing intuition:

| Axis | Test | Enforced by |
|---|---|---|
| **Useful** | Eval-backed lift on an observed failure mode (≥3 scenarios, fresh-session baseline) | CONTRIBUTING eval-first policy (exists) |
| **Novel** | Passes the official redundancy test (base model fails without the skill) AND no first-party built-in/plugin covers the trigger AND no description collision | New: base-model eval + first-party collision checklist in CONTRIBUTING |
| **Standard** | Spec-portable: six-field-clean frontmatter (extensions inventoried or `metadata`-nested), name==dir, desc ≤1024, body <500 lines, core value in prose/scripts rather than Claude-only machinery | New: spec-lint in `check-invariants.sh` |

Encoded preference is the durable default; capability-uplift content ships only with an explicit depreciation
expectation (finding 1) and a scheduled re-eval.

## Portfolio Architecture: Four Delivery Tiers *(strategy)*

Variety returns — but never again as an undifferentiated pile of always-listed skills. Each tier has a different
cost model:

| Tier | What lives here | Listing cost | Examples |
|---|---|---|---|
| **T1 Core (ungated)** | Encoded-preference skills that must auto-trigger; capped at roughly today's count (~8–14 after cleanup) | Paid by every adopter — defended budget | testing (trimmed), swarm-coordination, threat-modeling, planning-artifacts, new starters below |
| **T2 Workflows (gated)** | Slash-invoked orchestration + role entry points; side-effecting flows | Zero | swarm suite, architect, builder, code-check, `/tailor` (new) |
| **T3 Opt-in packs (plugin marketplace)** | Breadth: domain packs an adopter chooses; submit to `/external_plugins` | Paid only by installers | future: ops pack, compliance pack |
| **T4 Generated (tailoring engine)** | Stack- and policy-specific config *manufactured into the adopter's repo* from templates — never listed here | Adopter's own | golden-path skills, REVIEW.md, hooks/deny/CI stanzas |

T4 is where language/stack specificity returns *correctly*: "this project uses uv/Ruff/Litestar — here is the
scaffold command, migration workflow, deploy pipeline" is encoded preference bound to the adopter's
tech-strategy.md; "how to write good Python" (the old 67-skill mistake) stays dead.

## Catalog Verdicts (current 24) *(strategy — each retirement/addition gated by the CONTRIBUTING eval workflow)*

**Gated 10 — keep.** Zero listing cost; the swarm suite + role entry points are the framework's differentiated
pipeline (wired to worker agents, artifact conventions, quality gates — none of which first-party surfaces provide).
Reposition role skills explicitly as *pipeline entry points*, not generic personas (cowork suites own those).

**Ungated 14 → ~8:**

| Skill | Verdict | Why |
|---|---|---|
| designing-apis | **Retire** (base-model eval first) | Training-data restatement; agent-preload reference must be updated |
| application-security | **Retire listing** | OWASP restatement (verified); checklist already canonical in rules/security.md; kills the security-review collision; move Grep-tracing bits into security-auditor |
| observability | **Retire** | Textbook content (verified); OTel choice already lives in tech-strategy.md; procedures → T4 stack packs |
| interface-design | **Retire** | Generic principles; first-party design suite territory |
| accessibility | **Convert** | Retire the WCAG restatement; fold the DevTools/Lighthouse *procedure* into qa-engineer / ui-ux-designer |
| debugging | **Merge into rule** | Protocol already canonical in rules/debugging-protocol.md; description collides with bundled `/debug`; keep only if evals beat baseline+built-in |
| testing | **Keep, trim** | Strip pyramid/TDD knowledge; keep verification-loop-first workflow, regression-per-bugfix, evals exemplar |
| designing-systems | **Keep, trim + de-collide** | Templates/artifact wiring are encoded preference; trim C4 exposition; description must differentiate from first-party designing-systems |
| writing-adrs | **Keep** | Encoded preference (artifact conventions); agent-preloaded |
| writing-prds / writing-pr-faqs / execution-roadmaps | **Consolidate → 1 `planning-artifacts`** | One trigger surface for the planning flow's templates; frees ~200 listing tokens; templates all retained as resources |
| swarm-coordination | **Keep** | Framework-specific |
| threat-modeling | **Keep, trim** | Design-time STRIDE procedure with Grep tracing; no first-party collision (security-review is diff-time) |

Net effect: ~5–6 listing slots and ~500–700 tokens freed *before* anything is added — the additions below are
budget-neutral or better.

**New T1/T2 starters (priority order, each an encoded-preference workflow, each eval-gated before ship):**

1. **postmortem** (T1) — incident → postmortem artifact workflow; template exists ownerless in
   `.claude/templates/artifacts/`; no bundled/first-party equivalent on the Claude Code surface.
2. **dependency-upgrade** (T1) — safe-upgrade protocol: changelog read, pin verification (`git ls-remote` — the
   PR #20 lesson, including transitive-pin inspection), staged rollout, regression gate. Novel: encodes hard-won
   operational verification nothing first-party ships.
3. **land-the-plane** (T2, gated) — quality gates → commit → push → PR discipline; generalizes AGENTS.md's
   landing protocol into an invocable finish-line workflow.
4. **review-steering** (T1, small) — generates/maintains REVIEW.md + CLAUDE.md review sections compiled from
   `.claude/rules/` (finding 5: the sanctioned way to influence first-party review, managed and local).
5. Deferred pending eval capacity: legacy-archaeology (characterization-tests-first), performance-investigation
   (measure-first protocol), release-management (generalized from release.sh).

## The Tailoring Engine (`/tailor`, T2) *(strategy — the flagship net-new capability)*

The user-visible promise: *"Once you tell the framework what your environment is, it configures itself — and
suggests what you no longer need."* Nothing native or (verifiably) community-shipped does this today (finding 7).

Phased scope:

- **v1 — Detect & fill**: read stack signals (lockfiles, manifests, CI configs, IaC) + tech-strategy.md
  customization state → propose filled golden-path tables; generate REVIEW.md + CLAUDE.md review-steering from
  the repo's rules; emit a prune list (framework pieces irrelevant to this stack). Output = a diff the adopter
  reviews, never silent writes.
- **v2 — Stack packs (T4)**: instantiate golden-path skill/hook/CI templates (start with the three
  tech-strategy.md exemplar stacks: TypeScript, Python, Go) with the adopter's values, into *their* repo.
- **v3 — Policy packs (T4)**: compile stated policies ("no secrets", "dependency scanning", "no silent external
  data routing") down the enforcement ladder into hooks + `permissions.deny` + CI stanzas — the ladder is already
  quadruple-sourced doctrine; this makes it executable.

Constraint honored: plugins cannot deliver rules/settings/permissions (inventory finding) — the engine therefore
*writes files into the adopter repo* under review, rather than relying on plugin delivery.

## Portability Program *(strategy)*

1. Spec-lint in CI: name==dir, description ≤1024 chars, body <500 lines, YAML values quoted, non-spec frontmatter
   fields inventoried (decide per-field: keep top-level for Claude Code function vs nest under `metadata`).
2. Body discipline: portable core (prose + scripts) first; Claude-Code-specific machinery (MCP tools, worker
   dispatch, hooks) in a clearly-marked section so 43 other clients degrade gracefully. The swarm suite is
   exempt — it is Claude-Code-native by design.
3. Positioning: README states the cross-tool fact — installing this framework equips Copilot/VS Code/Cursor/Codex
   sessions from the same `.claude/skills/` directory (finding 2). Retire the "14 reusable knowledge skills"
   README line (finding 6's vocabulary is the old era's).
4. Submit the plugin to `/external_plugins` (finding 8); raw drop-in stays primary.

## Lifecycle: the Depreciation Clock *(strategy)*

Institutionalize finding 1's retirement mechanic — this is what structurally prevents the next 67-skill accretion:

- Every skill records its category (uplift vs preference) in `metadata`.
- Scheduled re-eval (each model-generation bump or quarterly): run the skill's evals against the bare base model;
  base model passes → open a retirement PR citing the run.
- Contradiction ledger stays live (listing-budget figures, bundled-skill set per version) with dated claims only.

## Migration Plan (phased, stacked-PR convention) *(strategy)*

| PR | Scope | Gate |
|---|---|---|
| A | Doctrine + positioning: this artifact's bar into CONTRIBUTING/docs/skills.md; README cross-tool + vocabulary fix | docs-only |
| B | Spec-lint CI (six-field contract, name==dir, quoted YAML, extension inventory) | check-invariants green on current catalog |
| C | Retirements/conversions/consolidation (verdict table) + agent `skills:` preload updates + description de-collisions | base-model evals recorded per skill |
| D | Starters: postmortem, dependency-upgrade, land-the-plane, review-steering | CONTRIBUTING eval-first per skill |
| E | `/tailor` v1 (detect, fill, REVIEW.md/CLAUDE.md generation, prune list) | eval + dogfood on this repo |
| F | Stack-pack templates ×3 (TS/Python/Go golden paths) + tailor v2 instantiation | smoke-test convention from PR #25 |
| G | Marketplace `/external_plugins` submission; policy-pack v3 scoping | external review bar |

## Contradictions & Unresolved

- **Listing-budget mechanics** (1% + 1,536 chars vs 2% + 250-char cap): version drift; both readings dated above;
  re-verify at PR B when writing the lint thresholds.
- **Bundled-skill set varies by surface**: /debug and /batch documented as bundled 2026-07-21 but absent from at
  least one live session listing the same day; per-version check via `/skills` is the only reliable source.
- **Community saturation and tailoring prior art**: zero claims survived adversarial verification on either axis;
  directional MEDIUM survey data (07-09) only. Do not cite specific competitor claims externally.
- **Cowork plugin manifest**: category names verified via press + live session; official manifest/names unverified.
- **Native tailoring risk**: `/init`'s interactive evolution could absorb generic stack detection; the framework's
  moat is policy-aware compilation of its own rules system — revisit at each minor CLI release.

## Confidence Summary

Official taxonomy, spec contract, first-party plugin/skill inventories, REVIEW.md surface, `.claude/skills/`
cross-tool discovery: **HIGH** (verbatim-verified live 2026-07-21, 3-vote adversarial pass, zero refuted claims
in final set). Catalog classifications: **HIGH** (inventory + orchestrator spot-verification). Cowork suite
scope, durability-asymmetry application to third parties, community landscape: **MEDIUM**. All portfolio verdicts
and the tailoring design: *(strategy)* — orchestrator synthesis to be validated by the eval gates in the plan.

## Source Index (primary anchors)

agentskills.io — specification + clients (44) · docs.github.com/copilot — about-agent-skills ·
code.visualstudio.com — agent-skills · github.blog changelog 2025-12-18 · github.com/anthropics/skills (spec,
17 skills, README) · github.com/anthropics/claude-plugins-official (38 plugins, /external_plugins, submission
form) · code.claude.com/docs — skills (bundled set), commands, code-review (REVIEW.md/CLAUDE.md), memory (/init),
discover-plugins, plugin-marketplaces · docs.claude.com — agent-skills best-practices ("already very smart",
redundancy test) · claude.com/blog — improving-skill-creator 2026-03 (uplift/preference taxonomy, durability) ·
TechCrunch 2026-02-24 (cowork suites) · repo evidence: PR #24 (Copilot YAML), PR #20/#25 lessons,
docs/skills.md, CONTRIBUTING.md, live-session skill listing 2026-07-21 · prior:
artifacts/research_token_management_and_skill_design.md (2026-07-09).
