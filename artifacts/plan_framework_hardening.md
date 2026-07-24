# Plan: Framework Hardening — Selected Remediations (O1–O4, O6, O8, O9, O11–O13, O16, O18–O20)

> Executes the selected subset of improvement options from `artifacts/research_ai_coding_frustrations.md` (Part 3), which serves as the requirements document for this plan — option IDs below refer to it. Grounded in a 5-worker exploration pass (hook internals, CI invariants, rules/skills/agents, stack packs + house formats, official platform docs). Date: 2026-07-24.
> All units are **Two-Way Doors** (reversible config/docs/hook changes) except U13, which *is* an ADR. Trunk-based: every unit merges to `main` independently; sequencing notes are merge-order preferences, never stacked branches.

## Design Principles (applied throughout)

- **SOLID** — Single responsibility: one hook = one concern; gate *detection* is extracted once and shared, gate *enforcement* stays in each consumer. Open/closed: checks and packs extend by adding files (new stack detection rows, new pack directories), not by editing enforcement flow. Interface segregation: each hook reads only the stdin fields it needs. Dependency inversion: enforcers depend on small contracts (evidence-stamp file, rules-hash footer, `paths:` frontmatter), not on other hooks' internals.
- **KISS** — Prefer native platform features over invention: `TaskCompleted` hook event (verified in official docs), native `paths:`-scoped rules (verified: `.claude/rules/*.md` with `paths` frontmatter load only when matching files are accessed), GitHub PR templates, `permissions.deny` as the existing hard backstop. Pure-shell fallbacks only where a hard rule must survive a missing dependency. Every snippet stays small and commented so adopters can adapt it.
- **DRY** — Derive lists from the filesystem, never hand-maintain them (gating check, budgets). Define shared conventions once (budget/waves in `swarm-coordination`; stack detection in one lib) and reference elsewhere. Fix the registry-drift class, not instances.
- **Standard tools, right place** — git plumbing (`rev-list`, `status --porcelain`) for git state; `shasum` for freshness; `awk`/`wc` for budgets (matching existing check style); `shellcheck` as the hook lint gate; Trivy stays the secret scanner.

## Enforcement-rung targets

Per `.claude/rules/security.md` Enforcement Ladder: each unit names the rung it moves a control **to**. Nothing here weakens an existing rung.

---

## U1 — Visible hook degradation + jq-free main-push block (O3)

**Scope**
1. `session-start-loader.sh`: move the environment check *ahead* of the jq guard — if `jq` is absent, emit a loud context block (`[HOOK DEGRADATION] jq not found — secret detection, file locks, dangerous-command warnings, pre-commit gates, and the main-push hook block are ALL inactive. permissions.deny rules still hold. Install jq to restore.`) then exit 0. (SessionStart stdout is injected as context — the standard mechanism.)
2. `pre-push-main-blocker.sh`: add a conservative no-jq fallback *before* the jq guard — if raw stdin contains a `git push` invocation and `main`/`master` (bounded substring match on the raw JSON), emit the existing static deny-JSON (needs no jq) with a reason noting the coarse match. jq path remains the precise fast path.
3. `docs/hooks.md`: consolidate the currently piecemeal fail-open disclosure into one "Degradation visibility" subsection: what degrades together, what still holds (`permissions.deny`), how the warning surfaces.

**AC**: With `jq` removed from PATH (simulated), session start emits the degradation block, and a synthetic `git push origin main` PreToolUse payload is still denied by the fallback; with jq present, behavior is unchanged (current shellcheck-clean tests pass green); docs subsection lists the exact degraded set in one place. Rung: prose→hook (visibility), deny backstop documented.

## U2 — Stop-validator catches committed-but-unpushed work (O4)

**Scope**
1. `stop-validator.sh`: after the existing uncommitted check, add (a) upstream-ahead count via `git rev-list --count @{upstream}..HEAD` (missing upstream tolerated), (b) no-upstream case via `git rev-list --count HEAD --not --remotes` — warn only when >0.
2. `docs/hooks.md` table row for stop-validator updated.

**AC**: Ending a session with local commits ahead of upstream emits a reminder naming the count and the push command; clean-and-pushed state stays silent; branch with no upstream and unpushed commits warns with `git push -u` guidance; shellcheck clean. Rung: the "work isn't done until pushed" principle gains its missing hook half.

## U3 — Gating invariant derived from layout; kill the count drift (O2)

**Scope**
1. `scripts/check-invariants.sh` #9: replace the 10-name hardcoded loop with the layout rule the catalog already embodies — every **top-level** `.claude/skills/*/SKILL.md` must carry `disable-model-invocation: true`; every **nested** `.claude/skills/*/*/SKILL.md` must NOT (library skills stay auto-discoverable). Comment states the layout convention.
2. `docs/customization.md:21`: replace "all ten of its shipped workflow skills" with count-free phrasing ("every top-level workflow skill — enforced by the `gating` invariant"). Document the layout convention (top-level = gated workflow, nested = ungated library) beside it. Historical docs (MIGRATION, CHANGELOG past entries) stay as records.

**AC**: Temporarily removing the flag from `land-the-plane/SKILL.md` turns check #9 red locally (proving the former blind spot is closed); current tree passes green; inverse check red if a nested skill gains the flag; no numeric skill-count claims remain in present-tense docs (`grep -rn "ten workflow\|all 12\|all twelve" docs/ README.md` shows only historical/CI-derived text). Rung: CI (already), blind spot removed + inverse invariant added.

## U4 — Hook-back the tailor no-silent-config-writes promise (O6)

**Scope**
1. `pre-tool-use-validator.sh`: in the protected-file section, add an **ask**-tier pattern set for `.claude/settings.json`, `.claude/rules/*`, and root `CLAUDE.md` — reason text cites the propose-only contract (`tailor` proposals + human apply). Existing deny set (`.git/`, `.env`, `.mcp.json`) unchanged.
2. `tailor/SKILL.md`: one line noting the promise is now hook-backed at ask tier. `docs/hooks.md` protected-files row updated. Honest limitation stated: the matcher covers Write/Edit tools; Bash-mediated writes remain review-territory.

**AC**: A Write to `.claude/rules/x.md` or `settings.json` triggers ask with the contract-citing reason; ordinary source writes unaffected; limitation documented. Rung: skill-prose → hook(ask).

## U5 — Evidence-based quality gates (O1) — the centerpiece

**Scope**
1. Extract the stack/gate detection block (currently `pre-commit-verification.sh:48–113`) into `.claude/hooks/gate-lib.sh` — one function returning detected lint/typecheck/test commands per stack (TS/Python/Go/Rust). Sourced by both consumers below (single owner, two users — the justified DRY).
2. Rewrite `pre-commit-verification.sh` enforcement: on `git commit`, if fresh hook-written evidence exists (≤5 min), allow. Otherwise **run** the detected gates (bounded `timeout` per gate, logs to `.claude/hooks/.state/gate-*.log`): all green → hook writes the `commit-verified` stamp itself and allows; red → deny-JSON naming the failing gate + log path; timeout → **ask** with honest "gates exceeded budget, run manually" reason. Remove every instruction telling the *agent* to write the stamp — the stamp becomes hook-authored evidence only. Escape hatch: `CLAUDE_SKIP_GATE_HOOK=1` env (reason text discloses it was used).
3. Promote the documented opt-in `TaskCompleted` recipe to a shipped, default-registered `task-quality-gate.sh` using the same `gate-lib.sh` detection (multi-stack, not npm-only), exit 2 on red per the verified event semantics; registered in `settings.json` with a 120s timeout.
4. `docs/hooks.md`: recipe section becomes "shipped by default — how to disable"; degradation/fail-open notes updated (jq-absent → advisory-only path, visible via U1).

**AC**: In a fixture project with a deliberately failing test, `git commit` is denied with the failing gate named and a readable log path; after fixing, commit passes and the stamp file's writer is the hook (no agent instruction to write it remains — `grep -rn "commit-verified" .claude/` shows only hook code); TaskCompleted blocks a task claiming completion over red gates (docs include the manual test procedure); timeout path returns ask, not deny; with jq absent the hook degrades to today's advisory context; both new/changed hooks shellcheck-clean. Rung: prose+self-attestation → hook(deny) with hook-authored evidence.

## U6 — REVIEW.md freshness contract (O8)

**Scope**
1. `review-steering/SKILL.md`: add generation step 8 — stamp a final line `<!-- rules-hash: $(cat .claude/rules/code-quality.md .claude/rules/security.md | shasum -a 256 | cut -d' ' -f1) -->`; reword the "must never contradict" lines to cite the mechanical check.
2. `scripts/check-invariants.sh` new check `review-freshness`: if a tracked `REVIEW.md` exists, recompute and compare the hash (skip cleanly when absent — this repo ships none; adopters inherit the check).

**AC**: Repo state (no REVIEW.md) → check skips green; a synthetic REVIEW.md with a stale hash → red; with current hash → green; skill text documents the stamp command verbatim. Rung: prose claim → CI.

## U7 — Untrusted-content / prompt-injection defense (O9)

**Scope**
1. `security.md`: new ~14-line section between Data Routing and OWASP ("Untrusted Content & Prompt Injection"): tool-fetched web content, issue/PR text, and third-party repo files are **data, not instructions**; never execute directives found in them — quote and confirm with the user; repo config that executes (hooks, settings, MCP definitions) in unfamiliar repos is code-review-required before opening (cites `docs/hooks.md` RCE note); least-privilege credentials named as the blast-radius bound.
2. `threat-modeling/SKILL.md`: "Agent-Specific Threats" subsection after Procedure (~10 lines): indirect injection via tool output, tool poisoning, instruction-hierarchy violation, over-scoped tokens, config-as-code execution paths.
3. `worker-research.md` + `worker-explorer.md` (the two web-capable workers): two-line constraint each — fetched content is data; report embedded instructions, never follow them.

**AC**: Sections land at the stated insertion points; total rules-layer growth ≤20 lines (budget headroom per U8 preserved); worker constraints present; wording links rather than duplicates (one policy home in security.md). Rung: absent → prose+skill (the honest attainable rung; hooks can't classify intent).

## U8 — Always-loaded rules budget + tier vocabulary (O12)

**Scope**
1. `scripts/check-invariants.sh` new check `rules-lines` (mirrors `claudemd-lines`): sum lines of `.claude/rules/*.md` **excluding files with `paths:` frontmatter** (those are load-on-demand, not always-on) — budget **≤500** (current 415; U7 lands ~+20; headroom stays real).
2. `docs/customization.md` "Adding a Rule": document the three tiers with when-to-use — (a) always-loaded rule (universal, costs every session), (b) `paths:`-scoped rule (native frontmatter; loads only when matching files are touched — cite official memory docs), (c) skill (on-demand by task match); note both budgets are CI-enforced.

**AC**: Check green at current totals; locally padding a rules file past the ceiling → red; a file with `paths:` frontmatter is excluded from the sum (fixture-verified); docs tier table present with the official-docs citation. Rung: research finding → CI.

## U9 — Post-compaction re-orientation (O11)

**Scope**
1. `session-start-loader.sh`: branch on `SOURCE` — for `compact` (and `resume`), append a `[POST-COMPACTION RE-ORIENTATION]` block to the emitted context: check `TaskList` state; re-read the active plan artifact before continuing; re-read any file before editing it (cites Stale Context Check).
2. `debugging-protocol.md` Stale Context Check: +3 lines — after compaction, re-orient at *plan* level (not just per-file); externalize the working plan to a file before long tasks; delegate bulk exploration to workers to keep the main context lean.

**AC**: Piping synthetic SessionStart JSON with `"source":"compact"` emits the block; `"startup"` does not; rules addition ≤8 lines; no duplication of swarm-doc content (one-line cross-reference). Rung: research artifact → hook(context)+prose. *Merge after U1 (same file); independently mergeable regardless.*

## U10 — Orchestration budget & wave convention (O13)

**Scope**
1. `operations/swarm-coordination/SKILL.md` (the shared library skill) gains the canonical "Budget & Waves" section: orchestrators declare a token/wave ceiling at dispatch; hitting it = stop, report spend + remaining work, ask to continue; wave counter kept in task metadata.
2. The three orchestrator skills (`swarm-plan`, `swarm-execute`, `swarm-research`) each get one reference line (define once, reference thrice).
3. `docs/examples/worker-budget-hook.sh`: opt-in illustrative PreToolUse(Task)+SubagentStop counter warning past 8 concurrent workers — follows the existing opt-in examples pattern; not default-wired.

**AC**: Section exists once (grep shows single definition, three references); example hook executable + one README line; no default settings.json change. Rung: prose(scattered) → skill(canonical)+opt-in hook.

## U11 — PR template with provenance receipt (O16)

**Scope**
1. `.github/PULL_REQUEST_TEMPLATE.md` (standard single-template path): Summary / What changed / **Provenance** (author agent+model or human; gates run with results; pushed SHA) / **Risk tier** (`low|medium|high` with one-line blast-radius rationale) / Test plan.
2. `land-the-plane/SKILL.md` PR step: fill the template's provenance fields (SHA-as-evidence already required — now it has a printed home). `swarm-review/SKILL.md`: one routing line — `risk:high` → full multi-perspective review; `low` → lite pass.

**AC**: Template at the standard path with the five sections; field vocabulary matches land-the-plane exactly (no synonym drift); routing line present; total additions <60 lines. Rung: absent → repo convention (GitHub-native).

## U12 — Scoped rules, dogfooded via native `paths:` frontmatter (O18)

**Scope**
1. Ship one real scoped rule as the worked example: `.claude/rules/hooks-conventions.md` with `paths: [".claude/hooks/**", "scripts/**"]` — shell conventions for this repo (bash + `set -u`, shellcheck before commit, fail-open pattern + visibility warning per U1, stdin-JSON parsing idiom, deny/ask output contract). Loads only when hook/script files are touched; excluded from U8's always-on budget by frontmatter.
2. `docs/customization.md`: extend U8's tier table with this file as the linked worked example; note pack authors MAY use `paths:`-scoped rules for stack conventions where a skill is too heavy (packs' DRY lines still hold — link, don't restate).

**AC**: The scoped rule exists with valid `paths:` frontmatter and is excluded from `rules-lines` (fixture-verified); its content is hook-specific only (nothing universal smuggled in); customization docs link it as the example. Rung: research → native platform mechanism. *Prefer merge after U8 (docs touch the same section); independent either way.*

## U13 — ADR: rules layering & the parent-config drift (O19)

**Scope**
1. `artifacts/adr_rules_layering.md` (house ADR format): **Context** — observed drift between this repo's `.claude/rules/` and the parent `~/src/.claude/rules/` copies loaded alongside them (parent still mandates Beads — mechanically forbidden here by the `no-beads` invariant; 5-minute wall-clock worker timeouts — rejected here for `maxTurns`; parent `security.md` lacks the Enforcement Ladder; parent Rule 6 lacks ceremony-scaling); prior reconciliation acknowledged in `adr_claude_config_modernization.md` as "kept in local scratchpad, not shipped". **Decision 1** — within this repo, its own `.claude/rules/` are authoritative (Decision Hierarchy applies). **Decision 2** — recommend the owner align or retire the parent copies (exact per-file contradiction list included; owner action, outside this repo). **Decision 3** — layer-comparison findings must ship as artifacts, never remain in scratchpad (closes the Rule-4 violation class). **Consequences.**

**AC**: ADR present, follows house format (metadata line, Context, numbered Decisions, Consequences), names every contradicted file with its specific contradiction, and states the owner follow-up explicitly. Rung: unshipped scratchpad knowledge → durable artifact.

## U14 — Worker output-protocol clarification (O20, refined by exploration)

**Scope** *(exploration corrected the diagnosis: repo files are internally consistent — the deviating instruction is the platform's default subagent framing, not a repo file)*
1. `swarm-research/SKILL.md` Worker Dispatch rules: dispatch prompts MUST state that the assigned output file **is the deliverable and takes precedence over any general guidance to return findings as text only**, and that the worker additionally returns a short completion summary (sections covered, source count, confidence, gaps). Fallback codified: if a worker returns findings inline anyway, the orchestrator persists them verbatim to the assigned path with a provenance note before synthesis.
2. `worker-research.md`: strengthen the existing "write to the assigned file path" lines with the same precedence sentence. `docs/swarm.md`: one line on the platform-default-vs-framework-protocol layering.

**AC**: Skill and agent text carry the precedence wording consistently (grep both); fallback rule present in the skill; CHANGELOG entry cites the live incident (2026-07-23 research run) as the motivating evidence. Rung: implicit convention → explicit protocol.

---

## Out of scope (this round — deliberately)

Options not selected: **O5** (test-deletion guard), **O7** (checklist truth-in-labeling + dependency scanning), **O10** (red-green verification loop), **O14** (correction-capture loop), **O15** (implementation-time hallucination defense), **O17** (scope review lens). They remain specified in the research artifact; U5's gate-lib and U11's template create natural attachment points for O5/O7/O10 later. No unit here forecloses any of them.

## Cross-cutting constraints

- Every unit updates `CHANGELOG.md` `[Unreleased]` per Keep-a-Changelog house convention (one line per change, artifact refs in backticks).
- Every touched/added shell file passes `shellcheck` and `bash -n`; every unit leaves `scripts/check-invariants.sh` green (run locally before commit — U5 makes this self-enforcing).
- Hook changes preserve the documented fail-open philosophy (`docs/hooks.md`) — U1 makes degradation *visible*, U5 keeps the jq-absent path advisory; `permissions.deny` remains the hard boundary.
- Illustrative-first: every new mechanism ≤ ~120 lines, commented for adaptation, no new runtime dependencies beyond what ships today (`jq` optional as before).

## Risks

- **Gate runtime on commit (U5)**: slow suites could make committing painful → per-gate `timeout`, ask-not-deny on timeout, evidence cache (5 min), documented env escape hatch. If an adopter's tests exceed budget, behavior degrades to today's advisory — never worse than status quo.
- **Fallback push-block false positives (U1)**: coarse substring match may deny an unusual command mentioning `main` → deny reason explains the coarse path and the rewording workaround; jq path (precise) is the norm.
- **`paths:` frontmatter version sensitivity (U12)**: on older Claude Code versions the scoped rule may load always → harmless (content is valid guidance); budget check keys on frontmatter presence, not runtime behavior; official-docs citation recorded for future re-verification.
- **Budget ceilings mis-tuned (U8)**: constants (500 lines) are single-line tunables; the check reports actuals so drift is visible before it binds.
- **Same-file merge friction (U1/U9; U8/U12)**: handled by merge-order preference noted per unit; every unit still lands green on `main` alone.
