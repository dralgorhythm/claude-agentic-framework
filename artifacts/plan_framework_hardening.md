# Plan: Framework Hardening — Selected Remediations (O1–O4, O6, O8, O9, O11–O13, O16, O18–O20)

> Executes the selected subset of improvement options from `artifacts/research_ai_coding_frustrations.md` (Part 3), which serves as the requirements document (PRD-substitute — it already carries the evidence and requirements weight; per core-directives Rule 6 this is a Medium-tier feature claiming plan-only ceremony on that basis). Option IDs refer to it.
> **Rev 2, 2026-07-24** — amended after a 4-worker adversarial `/swarm-review` (correctness, completeness, process/packaging, platform verification). Material changes from Rev 1: new U15 hook-test harness (was the review's Critical finding); U5 split into 5a/5b/5c along its refactor/behavior/feature seams; U1 upgraded from "add fallback" to "fix matcher + fallback" (a live false-positive was reproduced empirically); evidence stamp now content-bound via `git write-tree`; hook-timeout budget corrected (the hook is registered at 5s today); Decision D1 records the one deliberate doctrine change; PR packaging replaces the wave sequencing; MIGRATION.md obligations added.
> All units are **Two-Way Doors** except U13 (an ADR) and the D1 decision inside U5c (One-Way-Door-Medium, recorded below). Trunk-based: every PR merges to `main` independently; dependent PRs branch from `main` **after** their prerequisite lands — never stacked.

## Design Principles (applied throughout)

- **SOLID** — Single responsibility: one hook = one concern; gate *detection* lives once in a lib, gate *enforcement* in each consumer. Open/closed: checks, packs, and harness cases extend by adding rows/files, not editing flow. Interface segregation: hooks read only the stdin fields they need. Dependency inversion: enforcers depend on small contracts (evidence stamp = timestamp + tree-hash, rules-hash footer, `paths:` frontmatter), not on other hooks' internals.
- **KISS** — Native platform features over invention: `TaskCompleted` event (verified: blocks via exit 2 or `decision:"block"`), native `paths:`-scoped rules, GitHub PR templates, `permissions.deny` backstop. Pure-shell fallbacks only where a hard rule must survive a missing dependency — and reusing the repo's existing sed idiom for JSON-field extraction rather than inventing raw-blob matching.
- **DRY** — Derive lists from the filesystem (gating check); define shared conventions once and reference (budget/waves in `swarm-coordination`; detection in `gate-lib.sh`; test cases in one harness table).
- **Hooks are tested code, not config** — the review's systemic finding: every behavioral claim about a hook gets a harness case (U15), and shellcheck runs in CI. Self-attestation is what this plan exists to eliminate; it doesn't get to live in the plan's own infrastructure.
- **Standard tools, right place** — git plumbing (`rev-parse`, `rev-list`, `write-tree`, `status --porcelain`); `shasum` for freshness; `awk`/`wc` matching existing check style; GitHub-native PR templates.

## Decision D1 — TaskCompleted gate ships default-on (One-Way-Door-Medium)

`docs/hooks.md:166-168` currently states blanket doctrine: opt-in recipes "ship disabled unless a project deliberately opts in." U5c reverses this for exactly one recipe: the quality gate becomes default-registered. **Rationale**: the audit's highest-stakes finding was that the framework's only true completion gate ships off; a hardening release that leaves it off fails its own purpose. **Alternative considered**: keep opt-in but more prominent — rejected because opt-in guardrails demonstrably don't get adopted (the audit found the recipe undocumented-in-practice: present, disabled, invisible). **Reversal path**: single settings.json entry removal; escape hatch `CLAUDE_SKIP_GATE_HOOK=1` honored by **both** the commit gate and the task gate (parity — review F18). **Consequences**: adopters who re-pull get a newly blocking default → mandatory `MIGRATION.md` entry (see Cross-cutting); `docs/hooks.md`'s general preamble is rewritten so the remaining recipe (skill-activation hook) keeps the opt-in framing without self-contradiction. U5c's PR carries a short `artifacts/adr_default_quality_gate.md` capturing this decision in house format.

---

## U15 — Hook-behavior test harness + shellcheck CI (new in Rev 2; review Critical F7/F8)

**Scope**
1. `scripts/test-hooks.sh` (~120 LOC): table-driven runner in the existing `report()`/PASS-FAIL idiom of `check-invariants.sh`. Each case: hook path, synthetic stdin JSON (heredoc), optional env/PATH override, expected outcome (deny/ask/allow/substring/exit code). Includes a no-`jq` PATH shim (temp dir of symlinks to everything except jq, ~12 lines).
2. `scripts/fixtures/failing-project/` (minimal package.json + one deliberately failing test) and `scripts/fixtures/slow-gate/` (a gate script that sleeps past the per-gate timeout) — reused by U1/U5 ACs.
3. CI: new `hook-tests` job running the harness + new `shellcheck` job (ubuntu runners ship shellcheck) in `framework-invariants.yml`. Fix the 3 pre-existing shellcheck findings (SC2034 ×2 `pre-commit-verification.sh:45,80`, SC2012 `session-start-loader.sh:35`) here so later units inherit a clean baseline.
4. Seed cases covering current behavior of all five hooks this plan touches (characterization tests), so every later unit's AC is "add your cases to the table."

**AC**: `./scripts/test-hooks.sh` green locally and in CI on the untouched hooks; shellcheck job green (baseline findings fixed); no-jq shim proven by one case asserting current fail-open behavior; harness ≤ ~200 LOC total; CHANGELOG entry. **This PR lands first — every other hook/CI unit's AC cites harness cases.**

## U1 — Fix the push-block matcher; add jq-free branch-aware fallback; visible degradation (O3, upgraded)

**Scope** *(review upgraded this from "add fallback": the jq path has a live, empirically reproduced false-positive — branch names like `feature/main-cleanup` and `domain-master-list` match `\b(main|master)\b` and get denied)*
1. `pre-push-main-blocker.sh` (both paths): extract the command via the repo's existing no-jq sed idiom (`branch-pr-discipline.sh:48` field-scoped extraction) — never raw-JSON substring matching; tighten branch detection to compare the actual trailing branch token for equality with `main`/`master` (not substring anywhere).
2. No-jq fallback closes the *real* gap (`permissions.deny` already hard-blocks explicit `git push origin main` forms; the unique value is the implicit case): compute `CURRENT_BRANCH` via `git rev-parse --abbrev-ref HEAD` (needs no jq) and deny a bare/implicit `git push` while on main/master, emitting the existing static deny-JSON.
3. `session-start-loader.sh`: jq check moved ahead of the guard; when absent, emit `[HOOK DEGRADATION]` context block naming the degraded set and noting `permissions.deny` still holds.
4. `docs/hooks.md`: one "Degradation visibility" subsection consolidating the fail-open disclosure (prose precision per review: the deny backstop already covers explicit forms).

**AC** (as harness cases): `git push origin feature/main-cleanup` → **allowed** (false positive fixed); explicit push to main → denied (jq present and absent); **bare `git push` with CURRENT_BRANCH=main → denied with jq absent**; jq-absent session start emits the degradation block; docs subsection lists the degraded set in one place; MIGRATION.md entry (new session-start output). Rung: hook, correctness-fixed + degradation visible.

## U2 — Stop-validator catches unpushed work, remote-aware (O4, amended)

**Scope**
1. `stop-validator.sh`: guard first — if `git remote` is empty, skip (or emit a one-line "no remote configured" note; never the unpushed-count phrasing with wrong `git push -u` advice — review F11, empirically confirmed the naive form warns on every local-only repo). With a remote: upstream-ahead via `git rev-list --count @{upstream}..HEAD` (missing upstream tolerated) and no-upstream unpushed via `git rev-list --count HEAD --not --remotes`, warn only when >0.
2. `docs/hooks.md` table row.

**AC** (harness cases): ahead>0 → reminder with count + push command; clean/pushed → silent; no-upstream-with-commits → `git push -u` guidance; **zero-remote repo → no unpushed warning**; CHANGELOG entry.

## U3 — Gating invariant derived from layout; count drift removed (O2)

**Scope**
1. `check-invariants.sh` #9 (in-place edit): every top-level `.claude/skills/*/SKILL.md` must carry `disable-model-invocation: true`; every nested one must NOT. Comment documents the layout convention and the acknowledged tradeoff: a future gated workflow skill must live top-level (flat hyphenated names are already the house idiom — review confirmed this forecloses nothing real).
2. `docs/customization.md:21`: count-free phrasing + the layout convention documented.

**AC**: flag removed from `land-the-plane` → red locally (blind spot provably closed); nested skill with flag → red; current tree green; no present-tense numeric gated-skill counts remain in docs; CHANGELOG entry.

## U4 — Hook-back tailor's promise + close the Bash secret-write blind spot (O6, extended)

**Scope**
1. `pre-tool-use-validator.sh`: ask-tier patterns for `.claude/settings.json`, `.claude/rules/*`, root `CLAUDE.md`, reason citing the propose-only contract; **remove the now-contradicting comment at line 49** ("settings.json and rules/ are user-configurable" — review F14).
2. Extend the six secret regexes to also scan `tool_input.command` when `TOOL_NAME == "Bash"` and the command contains a redirect/heredoc operator (`>`, `>>`, `<<`) — closing a blind spot the review found that neither the research audit nor Rev 1 named (heredoc'd `.env` writes currently bypass all secret detection).
3. `tailor/SKILL.md` one line (hook-backed at ask tier); `docs/hooks.md` row; honest limitation note (Write/Edit matcher; the new Bash scan covers the redirect path pre-commit, Trivy CI remains the backstop).

**AC** (harness cases): Write to `.claude/rules/x.md` → ask with contract reason; `Bash` heredoc writing an AWS-key-shaped string → ask; ordinary source writes unaffected; stale comment gone; MIGRATION.md entry (new ask prompts); CHANGELOG entry.

## U5a — Gate detection lib: rewrite to invocable commands (O1 part 1 — pure structure)

**Scope** *(review corrected the framing: today's block builds display labels, not commands — `VERIFICATION_COMMANDS` at line 45 is dead; this is a rewrite-to-commands, not a lift-and-shift)*
1. New `.claude/hooks/gate-lib.sh`: one function emitting **invocable** lint/typecheck/test/build command strings per detected stack (TS/JS via detected package manager, Python, Go, Rust), plus a human label per gate. Delete the dead `VERIFICATION_COMMANDS` variable.
2. `pre-commit-verification.sh` sources the lib for its existing advisory text — **zero behavior change** in this PR (Two Hats: structure only; harness characterization cases must pass unchanged).

**AC**: harness cases confirm advisory output identical pre/post for all four stack fixtures; lib function returns runnable commands (smoke-executed against the failing-project fixture); shellcheck clean; CHANGELOG entry.

## U5b — Commit gate: run, stamp content-bound evidence, block (O1 part 2 — behavior)

**Scope**
1. `pre-commit-verification.sh` enforcement rewrite: on `git commit` — trust cached evidence only if **fresh (≤5 min) AND `git write-tree` output matches** the stamped tree hash (review F8: time-only stamps ride post-edit changes; `write-tree` is the canonical index hash). Otherwise run detected gates (per-gate `timeout`, logs to `.state/gate-*.log`): green → hook writes stamp `{epoch, tree-hash}`; red → deny-JSON naming the failing gate + log path, **including the anti-test-deletion line** ("Do not delete or weaken tests to force a pass — fix the issue or ask the user" — preserves the sole existing O5 deterrent, review F2); gate timeout → ask with honest reason. `CLAUDE_SKIP_GATE_HOOK=1` escape hatch, disclosed in reason text.
2. **`settings.json`: raise this hook's timeout from 5 → 300 seconds** (review F9: gates cannot run inside the current 5s registration; per-gate timeouts sized to sum <240s; the early non-commit exits keep ordinary Bash calls instant). Verified platform behavior: hook-timeout fail-open/closed is undocumented — therefore the hook must always return its own decision within budget, never lean on harness timeout semantics.
3. Remove every instruction telling the agent to write the stamp; `docs/hooks.md` gate-behavior section.

**AC** (harness cases): failing-project fixture → commit denied naming the gate + log path + test-deletion warning; fix → green → stamp written by hook with tree-hash; **edit a file after green stamp → immediate re-run despite fresh timestamp (tree-hash mismatch)**; slow-gate fixture → ask, not silent kill (proves the 300s/per-gate budget ordering); jq-absent → advisory fallback; `grep -rn commit-verified` shows hook-only writers; MIGRATION.md entry (commits newly blocking); CHANGELOG entry.

## U5c — Task gate default-on + decision record (O1 part 3 — feature/doctrine)

**Scope**
1. `task-quality-gate.sh` (multi-stack via `gate-lib.sh`, exit 2 on red, honors `CLAUDE_SKIP_GATE_HOOK=1`), default-registered under `TaskCompleted` in `settings.json` (timeout 120).
2. `artifacts/adr_default_quality_gate.md` — Decision D1 above in house ADR format.
3. `docs/hooks.md`: recipe section → "shipped by default — how to disable"; **general opt-in preamble (166-168) rewritten** so it accurately describes only the remaining opt-in recipe.

**AC**: TaskCompleted blocks a completion over red gates (harness case with fixture; exit-2 semantics verified against official docs); disable path documented and tested; ADR present; preamble no longer self-contradicts (grep); MIGRATION.md entry (inherited default gate); CHANGELOG entry. *Execution note: U4's ask-tier will prompt on this unit's settings.json edit — expected, not a regression.*

## U6 — REVIEW.md freshness contract (O8)

Unchanged from Rev 1 (review confirmed hash scope exactly matches the skill's own compile-from set, and skip-when-absent is honest). Sequenced **last in the invariants PR** so new-check numbering (U8's, then U6's) is deliberate, not raced. **AC** adds: harness/fixture case for stale-hash red. CHANGELOG entry.

## U7 — Untrusted-content / prompt-injection defense (O9)

Unchanged in substance. Clarified per review F13: the "≤20 lines" cap applies to the CI-checked rules layer (`security.md` +14); the threat-modeling (+10) and worker-file (+4) additions are skill/agent prose outside that budget. Worker edits land in `## Constraints`, placed to avoid U14's edit region in `worker-research.md` (same-file proximity noted). CHANGELOG entry.

## U8 — Always-loaded rules budget + tier vocabulary (O12, math corrected)

As Rev 1, with corrected arithmetic (review F13, measured): current **409** lines; +14 (U7) +3 (U9) → ~426 of **500** budget; the check excludes `paths:`-frontmattered files and reports actuals. AC unchanged plus: budget figure in docs states it was measured at implementation time, not copied from this plan. CHANGELOG entry.

## U9 — Post-compaction re-orientation (O11)

Unchanged (review confirmed clean composition with U1: different file regions; SOURCE logic already jq-conditional). Same PR as U1, committed after it. **AC** via harness: `"source":"compact"` emits the block, `"startup"` doesn't. MIGRATION.md entry (new session-start output, shared with U1's). CHANGELOG entry.

## U10 — Orchestration cost circuit-breaker convention (O13, reframed)

As Rev 1 with two review fixes: (a) framing is **cost bound only** — it stops runaway spend after the fact; it does not detect step-repetition (drop that implication — review F21); (b) "wave counter in task metadata" replaced with an implementable convention: dispatched task titles carry a `[Wave N/M]` prefix (review F3 — no structured metadata convention exists in this repo's task tracking). CHANGELOG entry.

## U11 — PR template with provenance receipt (O16)

As Rev 1 plus: `swarm-review/SKILL.md` defines the lite pass in one line — "lite = single-perspective quality review; skip the security/performance/architecture panel" (review F4: the term was undefined). CHANGELOG entry.

## U12 — Dogfooded scoped rule via native `paths:` frontmatter (O18)

Unchanged. Lives in the **invariants PR** after U8 (same docs section — review moved it out of the conventions grab-bag). Its content becomes the natural home for the shell conventions U15/U1 establish (shellcheck, fail-open + visibility, sed extraction idiom, deny/ask contract). CHANGELOG entry.

## U13 — ADR: rules layering & parent-config drift (O19)

Unchanged; standalone PR. CHANGELOG entry.

## U14 — Worker output-protocol precedence + per-worker-type scoping (O20, extended)

As Rev 1 plus review F17's deeper instance: `swarm-research`'s blanket "workers write to assigned output files" rule is impossible for `worker-explorer` (no `Write` tool — structurally cannot comply). Add per-worker-type scoping to the dispatch rules: `worker-research`/`worker-architect` write assigned files (with the precedence sentence); `worker-explorer` always returns inline and the orchestrator persists. `docs/swarm.md` line covers the platform-default-vs-protocol layering. CHANGELOG entry cites both the 2026-07-23 incident and the structural explorer case.

---

## PR Packaging (replaces Rev 1 wave sequencing; answers "minimal set")

Eight PRs, six parallel lanes; each PR < 400 changed LOC (the repo's own review-effectiveness advisory); units are atomic commits inside their PR (house rules permit multi-commit PRs — "one logical change per commit" governs content, not count). Dependent PRs branch from `main` after the prerequisite merges (core-directives merge-order sequencing — no stacking).

| PR | Units (commit order) | ~LOC | blockedBy | Why grouped |
|---|---|---|---|---|
| **PR0 harness** | U15 | ~200 | — | Everything else's ACs cite it |
| **PR1 hooks** | U1 → U9 → U2 → U4 | ~180 | PR0 | Same files (`session-start-loader.sh`, `docs/hooks.md`); one review context |
| **PR2 invariants** | U3 → U8 → U12 → U6 | ~170 | PR0 | `check-invariants.sh` + `docs/customization.md`; check-numbering sequenced deliberately |
| **PR3 gates-extract** | U5a | ~175 | PR0 | Pure structure (Two Hats), zero behavior change |
| **PR4 gates-enforce** | U5b | ~200 | PR3 | The behavior change, isolated and revertible |
| **PR5 gates-default** | U5c (+ADR) | ~150 | PR3 (prefer after PR4) | The doctrine decision, separately reviewable |
| **PR6 adr-layering** | U13 | ~120 | — | Standalone document |
| **PR7 process-docs** | U7 → U10 → U11 → U14 | ~200 | — | Prose/conventions; `worker-research.md` U7/U14 proximity handled by commit order |

Coupling handled inside PRs: `session-start-loader.sh` (U1/U9), `check-invariants.sh` numbering (U3/U8/U6), `docs/customization.md` (U8/U12), `worker-research.md` (U7/U14), `docs/hooks.md` content dependency (U1's subsection cited by U5b/U5c docs — cross-PR but append-only). `CHANGELOG.md` is the one all-PR shared file: append at subsection end, `git pull --rebase` immediately before opening each PR, don't queue >2-3 unmerged CHANGELOG edits.

## Cross-cutting constraints

- Every unit: CHANGELOG `[Unreleased]` entry (append-at-end discipline) + harness cases for any behavioral claim in its AC.
- **MIGRATION.md entries required** for the adopter-visible behavior changes: U1/U9 (new session-start context), U4 (new ask prompts), U5b (commits newly blocking), U5c (inherited default task gate) — following the existing "Who is affected / What breaks / Action required" pattern.
- Shell: `shellcheck` + `bash -n` clean (CI-enforced from PR0 on; 3 pre-existing findings fixed in PR0); `scripts/check-invariants.sh` green before every commit.
- Fail-open philosophy preserved and *visible* (U1); `permissions.deny` remains the hard boundary; the only doctrine change is D1, recorded in its own ADR.
- Illustrative-first: every new mechanism ≤ ~120 lines, commented for adaptation; no new runtime dependencies (`jq` stays optional).

## Out of scope (deliberate, with honesty notes from review)

- **O5, O7, O10, O14, O15, O17** remain unselected. Specifics the review insists be named rather than implied:
  - `security.md:24`'s "automated dependency scanning" claim **remains false after this round** (O7 territory); its truth-in-labeling half was separable but not selected — do not mistake it for closed.
  - **O14 (correction capture)** was the research's most time-urgent deferred item ("before memory of this research fades") while U12/O18 pulls forward its lowest-urgency one — this inversion follows the option selection as given; flagged so O14 is the first addition next round, accepting that its value decays.
  - U13 documents and recommends; the parent-layer contradiction itself stays live until the owner acts outside this repo.
  - U5b's deny text preserves the existing anti-test-deletion prose, but mechanical test-deletion detection remains O5, unselected.

## Risks (expanded per review)

- **Gate runtime (U5b)**: bounded by per-gate timeouts summing <240s inside the raised 300s hook budget; timeout → ask; escape hatch; jq-absent → advisory. Slow-gate fixture exists specifically to catch budget-ordering regressions.
- **Doctrine change (D1/U5c)**: adopters inherit a blocking default — mitigated by ADR + MIGRATION entry + one-line disable + shared escape hatch.
- **Push-block matching**: trailing-token equality fixes the reproduced false-positive class; the no-jq fallback remains coarser than the jq path by design, with the deny reason explaining rewording.
- **Coupling surface**: five clusters named in Packaging (Rev 1 named two); the structurally risky pair (check-numbering U8/U6; docs content dependency U1↔U5b/c) have explicit ordering.
- **`paths:` version sensitivity (U12)** and **budget tuning (U8)**: unchanged from Rev 1 — harmless degradation, single-line tunables, actuals reported by the checks.
