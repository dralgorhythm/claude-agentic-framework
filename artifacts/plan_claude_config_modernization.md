# Plan: Claude Config Modernization (Public Framework) — v2

- **Date:** 2026-06-30 · **Revision:** v2 (post-adversarial-review; supersedes v1)
- **Owner:** repo owner
- **Inputs:** `artifacts/adr_claude_config_modernization.md` (decisions D1–D4); internal research + review notes (local `scratchpad/`, gitignored — not shipped).
- **Goal:** Improve **consistency + token usage** of the neutral public `claude-agentic-framework`, grounded in proven patterns from a mature private reference config + 2025–2026 Claude Code best practices, with a **quantified** token target and **CI-enforced** invariants.
- **Decisions locked:** D1 remove Beads · D2 native discovery (primary) + opt-in bash fallback · D3 full command→skill migration · D4 raw + optional plugin.
- **v2 changes vs v1 (from review):** added **PR4 skill-catalog rationalization** (the count/budget gap) and **PR8 CI invariants**; scoped the global grep AC; enumerated all Beads docs; fixed command-body model drift; added `.env` deny rules; resolved AGENTS.md/frontend-design/rules TBDs; added versioning + measurement; kept a dependency-free opt-in discovery hook.

## Why v2 exists (headline review finding)

The token goal is defeated if the **skill *count*** is ignored: 67 skills ≈ 3k–6.7k tokens of always-on descriptions vs the default ~2,000-token (1% of 200K) skill-listing budget → native discovery **silently drops least-used descriptions on a fresh clone**. The fix is to treat the framework as **a library to draw from, not 67 options in front of the model at once**: prune training-data-duplicating skills (the reference config pruned `languages/` ~20→1), set niche skills to `name-only`, and/or raise `skillListingBudgetFraction`, verified by `/doctor` reporting **0 dropped/truncated**.

---

## Scope & sequencing

```
PR1 ─┐ (agents; independent; ship first)
PR2 ─┼─ Beads removal ─┐
PR3 ─┤ native discovery ┤
PR4 ─┤ catalog prune   ├─→ PR5 commands→skills ─→ PR9 plugin (optional)
PR6 ─┤ hooks+deny      ┘        │
PR7 ─┘ settings/skills ─────────┘
PR8 ── CI invariants: build early, must be GREEN as the gate for every other PR
```

Order: **PR1 → PR2 → PR3 → PR4 → PR5 → PR6 → PR7 → (PR9 optional)**, with **PR8 introduced early** and each subsequent PR required to keep it green. Do **not** parallelize PRs that both edit `docs/skills.md` or `docs/hooks.md` (review F5).

| PR | Scope | Risk |
|----|-------|------|
| 1 | Agent model-tiering + least-privilege tools + fix command-body model drift | Low |
| 2 | Remove Beads (all 34 files) + AGENTS.md rewrite + CHANGELOG/MIGRATION/VERSION | Med |
| 3 | Native skill discovery (delete TS hook+node deps+skill-rules.json) + opt-in bash fallback | Med |
| 4 | **Skill-catalog rationalization (count/budget)** — NEW | Med-High |
| 5 | Commands → skills migration + gating | Med-High |
| 6 | Hooks hardening + `.env`/secret deny rules + security note | Med |
| 7 | Settings cleanup + large-skill disclosure + link/decisiveness fixes | Med |
| 8 | **CI / framework-invariants** — NEW | Low |
| 9 | Plugin packaging (optional) | Low |

---

## PR1 — Agent model-tiering + least-privilege tools

1. `worker-research` opus→**sonnet**, `worker-reviewer` opus→**sonnet** (keep architect=opus, explorer=haiku, builder/researcher=sonnet). **AC:** `grep "^model:" .claude/agents/*.md` → only architect opus; aliases only.
2. Least-privilege `tools` per worker (readers: `Read,Grep,Glob,WebFetch,WebSearch`; reviewer: `+Bash`, no Write/Edit; builder: `Read,Write,Edit,Bash,Glob,Grep`; architect: `Read,Grep,Glob,Write`). No worker lists `Agent` (single-level by omission). **AC:** every agent has explicit `tools:`; no `Agent` in worker tools.
3. **Fix command-body model drift (review H2):** update the hard-coded worker model tables in `swarm-execute.md:46,48`, `swarm-plan.md:58,60`, `swarm-research.md:30,32` to match agent frontmatter (sonnet), or replace with a pointer to frontmatter. **AC:** `git grep -nE 'worker-(reviewer|research)\b.*opus'` → 0.
4. Reword `agent-constraints.md`: nesting = deliberate policy (not platform limit); 5-min → `maxTurns`; remove "use Beads" line (coordinate w/ PR2). **AC:** no platform-limit claim; no Beads line.

## PR2 — Remove Beads entirely (Critical)

**Complete file set (34; review H1 — all enumerated):**
- **Delete:** `.claude/skills/operations/beads-workflow/`, `docs/beads.md`.
- **Rewrite (de-couple):** `.claude/skills/operations/swarm-coordination/SKILL.md` (Beads→native tasks).
- **Core:** `CLAUDE.md`, `README.md`, **`AGENTS.md` → keep + rewrite** as a generic cross-tool agent-onboarding file (it's the `agents.md` standard; do NOT delete — review H7).
- **Scripts/config:** `scripts/init-framework.sh` (remove `bd init`), `settings.json` (`Bash(bd:*)`), `.gitattributes`, `.gitignore`.
- **Hooks:** `session-start-loader.sh`, `post-tool-use-tracker.sh`, `stop-validator.sh`, `pre-tool-use-validator.sh`.
- **Docs (review F1/H1 — previously omitted):** `docs/getting-started.md`, `docs/handoffs.md`, `docs/swarm.md`, `docs/skills.md`, `docs/hooks.md`. **Fix dangling links** to the deleted `beads.md` (`README.md`, `docs/getting-started.md:64`).
- **Commands:** `swarm-execute.md`, `swarm-plan.md`, `swarm-research.md`, `code-check.md` (de-bead now; migrated in PR5).
- **Templates:** `postmortem`, `security_audit`, `prd`, `pr_faq`, `system_design`, `roadmap`, `plan`, `design_spec`, `adr`.
- **Rules:** `agent-constraints.md` (with PR1).
- **Replacement:** add a two-tier task-tracking convention — durable record via **GitHub Issues or a committed `ISSUES.md`** + in-flight native `TaskCreate` (review D1 nuance: native Tasks persist locally but are NOT git-synced/team-durable). Add `CHANGELOG.md` + `MIGRATION.md` note (see PR2 versioning).
- **Versioning (review H6):** add `CHANGELOG.md`, `MIGRATION.md`, and a `VERSION`/semver marker; call the beads removal a breaking change.

**AC (scoped — review C1/F2):** `git grep -iw -e beads -e bd -- ':!artifacts/' ':!CHANGELOG*' ':!MIGRATION*'` → **0**; `init-framework.sh` runs with no `bd` dependency; no dangling `beads.md` links.

## PR3 — Native skill discovery + opt-in fallback

1. **Delete:** `.claude/hooks/skill-activation-prompt.ts`, `.sh`, `package.json`, `package-lock.json`, `tsconfig.json`; `.claude/skills/skill-rules.json`. Remove `.claude/hooks/node_modules/` gitignore line.
2. **Unwire** `UserPromptSubmit` in `settings.json`. Remove the npm-install step from `init-framework.sh`.
3. **Update ALL skill-rules.json references (review H3):** `CLAUDE.md:109`, `docs/customization.md:30`, `docs/skills.md:81` (and any others) → describe native discovery. **AC:** `git grep -n skill-rules` → 0.
4. **Opt-in fallback (review M1):** ship a **dependency-free bash** activation hook as a documented, disabled-by-default example under `docs/` (it reads SKILL.md frontmatter directly — no duplicate `skill-rules.json`, preserving single-source-of-truth) for teams that re-expand the catalog or need deterministic injection.
5. Update `docs/skills.md`/`hooks.md`/`README` to native discovery + budget tooling (`/doctor`, `/context`, `skillListingBudgetFraction`); warn large-context adopters re the fixed-200K budget baseline (bug #57941).
6. **Discovery smoke test (review M1):** confirm ≥N representative skills trigger without the hook. **AC:** no node deps under `.claude/`; `/doctor` clean (post-PR4); documented smoke test passes.

## PR4 — Skill-catalog rationalization (NEW — the token/consistency core)

**Why:** 67 skills overflow the listing budget → native discovery drops descriptions (review C2/F2/BP-studies). Target: descriptions fit the budget with **0 truncations**.
1. **Prune training-data-duplicating skills** (reference-config model: `languages/` ~20→~1). Candidate cuts: pure-language skills that duplicate Claude's training data (`go`, `rust`, `swift`, `kotlin`, `python`, `typescript`, `react-patterns`, etc.) — **owner confirms final cut list**; keep opinionated/project-specific/composable ones.
2. For niche-but-keep skills, set **`skillOverrides: name-only`** (reclaims budget, stays available) and/or raise `skillListingBudgetFraction` to ~0.02–0.03 (documented tradeoff).
3. Establish **quantified token target (review M/H4):** measure base-context + skill-listing via `/context` before and after; target a specific reduction (e.g., ≤ default 1% budget, 0 dropped descriptions).
**AC:** `/doctor` reports **0 dropped/truncated** skill descriptions at default budget (or documented raised budget); recorded before/after `/context` numbers meet target; every remaining skill is single-responsibility, non-duplicative.

## PR5 — Commands → skills migration + gating

1. Move each `.claude/commands/<name>.md` → `.claude/skills/<name>/SKILL.md` (**dir name == old `/name`**; verified correct). Standardize frontmatter; add missing `argument-hint` to `swarm-research`.
2. Gate side-effecting/orchestration skills with `disable-model-invocation: true` (`builder`, `swarm-execute`, `swarm-plan`, `swarm-review`, `swarm-research`, `code-check`); keep advisory role skills model-invocable. **Version-fragile (review M2):** pin/document a min CC version and add an **empirical AC** (verify the gated skill is not auto-invoked AND still user-invocable on the target version — open bugs exist).
3. Remove legacy `.claude/commands/` after migration (no dup names). Split any body >500 lines into `resources/`.
4. **AC:** every `/name` resolves; gated ones don't auto-fire but remain user-invocable; **`git grep -iw beads .claude/skills` → 0** (review M4 — no beads re-import); no body >500 lines.

## PR6 — Hooks hardening + `.env`/secret deny + security

1. Remaining hooks: bash-first, `jq`-optional (detect+degrade), exec-form, fail-soft, explicit tight `timeout`s. **AC:** no Node dep; every hook entry has a `timeout`.
2. **Hard secret rules in `permissions.deny` (review H5 — fixes ADR self-violation):** `Read(**/.env)`, `Read(**/.env.*)`, `Read(**/secrets/**)`, `Read(~/.ssh/**)`, `Read(~/.aws/**)`, `Read(**/*.pem)`, `Read(**/credentials)`; destructive `Bash` denies. **AC:** README's `.env`-protection claim (README:101) is backed by a deny rule, not just a fail-open hook.
3. Blocking hooks opt-in; `Stop` checks `stop_hook_active`. Add supply-chain **security note** (committed hooks run on adopters' machines; cite 2026 RCE) in `docs/hooks.md` + README.
4. Port generalized `post-edit-lint` (auto-fix-then-surface, no-op if no formatter) + warn-only `branch-pr-discipline`.

## PR7 — Settings cleanup + large-skill disclosure + decisiveness/link fixes

1. `settings.json`: **remove `enabledPlugins: frontend-design@claude-plugins-official`** (review H7 — not neutral); remove dangling `mcp__ide__*`; confirm `Bash(bd:*)` gone; keep `$schema`.
2. Split large language skills **if kept after PR4** (`framer-motion` 514 / `kotlin` 478 / `swift` 405 / `hono` 343) → SKILL.md <500 lines + one-level `references/` (TOC if >100 lines).
3. **Decisiveness (review H7):** **add a generic `debugging-protocol.md`** rule (useful, stack-agnostic); **skip a stack-specific `frontend.md`** rule (document the decision).
4. Link hygiene: rename `docs/personas.md` → `docs/commands.md` + fix `README.md:135`. **Drop the phantom `docs.claude.com` migration clause** (review M5 — 0 such links exist); if any appear, update to `code.claude.com`.
5. **AC:** no `frontend-design`/`mcp__ide`/`bd` allows; kept skills <500 lines; no `personas.md`.

## PR8 — CI / framework-invariants (NEW — enforcement)

**Why:** no CI exists (review H4) → ACs are advisory. Add `.github/workflows/framework-invariants.yml` (+ optional pre-commit) that fails on any violation. Introduce **early**; every PR must keep it green.
Checks:
- `git grep -iw -e beads -e bd -- ':!artifacts/' ':!CHANGELOG*' ':!MIGRATION*'` → 0
- **no private-reference identifiers** in tracked files: the private reference-repo name, internal service names, ticket prefixes (`ENG-\d+`), employer/org names, and personal absolute paths (`/Users/...`) → 0. (The public template must read as clean, original, generic work — no trace of any private source repo.)
- no `node_modules`/`package*.json`/`tsconfig.json` under `.claude/`; no `skill-rules.json`
- every `SKILL.md` body < 500 lines
- **every skill: frontmatter `name` == parent dir name** (fixes review M3: `languages/reanimated` currently `react-native-reanimated` — rename to comply)
- `settings.json` validates against its `$schema`
- only `worker-architect` uses opus; all models are aliases; `git grep -nE 'worker-(reviewer|research)\b.*opus'` → 0
- side-effecting skills carry `disable-model-invocation`
- description-listing size heuristic under budget (warn if total > ~1,500 tokens as a proxy for `/doctor`)
**AC:** workflow present and green on `main`.

## PR9 — (Optional) Plugin packaging

Add `.claude-plugin/plugin.json` + root `marketplace.json`; hooks → `hooks/hooks.json` for the plugin path; keep raw `.claude/` working. **AC:** `claude plugin validate --strict` passes; raw clone unchanged; `/plugin install` + `/framework:*` resolve; no secrets/machine paths.

---

## Final-state invariants (enforced by PR8)

Beads-free (outside CHANGELOG/artifacts) · no node deps or `skill-rules.json` under `.claude/` · skill descriptions fit the listing budget (**/doctor 0 dropped**) · every SKILL.md <500 lines with `name`==dir · only architect on opus, aliases only, no model drift in bodies · side-effecting skills gated · secrets enforced by `permissions.deny` (not just hooks) · `settings.json` schema-valid, no stale/force-enabled entries · CHANGELOG+MIGRATION+VERSION present · **fresh `git clone` works with zero install step** · recorded before/after `/context` token reduction meets target · **no private-reference-repo identifiers in any committed file** (clean, original, generic public work).

## Risks & mitigations
- **Broad Beads sweep / drift regressions** → PR8 CI is the durable gate (not manual grep).
- **Catalog prune removes a wanted skill** → owner confirms cut list; `name-only` keeps niche skills available rather than deleting.
- **Native discovery non-determinism** → PR4 makes the catalog fit budget; opt-in bash hook documented as fallback; smoke test.
- **`disable-model-invocation` version bugs** → pin CC version + empirical AC.
- **Self-modification** (editing swarm-* while using them) → do PR2/PR5 swarm-* edits in one validated pass before relying on them.

## Handoff to `/swarm-execute`
Execute in dependency order; PR8 green is the definition-of-done gate for all others. No Beads (D1) — track via the native task list seeded from these PRs + a committed `ISSUES.md`/GitHub Issues for durable records.
