# ADR: Claude Config Modernization Direction

- **Status:** Accepted (2026-06-30); refined after adversarial review (see `scratchpad/review-*.md`)
- **Deciders:** Repo owner (decisions confirmed) + `/swarm-plan` orchestrator
- **Context source:** internal research synthesis + best-practice review (kept in local `scratchpad/`, not shipped)
- **Supersedes:** the partial "remove beads" commits (`83d8f39`, `41b5743`, `7e3794f`) which left the repo self-contradicting
- **Review refinements:** D2 viability requires pruning the skill *count* (new plan PR4) so descriptions fit the listing budget, plus a dependency-free opt-in discovery hook as fallback; D1 requires naming a durable task-tracking substitute (native Tasks are machine-local, not git-synced).

## Context

The public `claude-agentic-framework` is a neutral, drop-in `.claude/` template. Research found it well-built but (a) self-contradicting on Beads, (b) behind proven token-efficiency wins from a mature private reference configuration, and (c) predating three 2026 platform shifts: commands merged into skills, native skill discovery superseding activation hooks, and an elevated supply-chain bar for committed hooks. Four decisions set the modernization direction. Each was confirmed by the repo owner.

---

## Decision 1 — Remove Beads entirely

**Decision:** Strip all Beads/`bd` coupling from the template (34 tracked files) and replace task-tracking guidance with Claude Code's native `TaskCreate`/agent-`memory` features and a lightweight markdown convention. Delete the `beads-workflow` skill and `docs/beads.md`.

**Why:** The repo already deleted `.beads/` runtime data while ~34 files still mandate Beads — README calls it "required for swarm coordination," `init-framework.sh` auto-runs `bd init`. A neutral drop-in template should not hard-depend on a third-party CLI most adopters won't have. The owner's prior commits show clear intent to remove it.

**Consequences:** (+) Eliminates the Critical contradiction; lighter, dependency-free template; honest docs. (+) Aligns swarm orchestration with native, in-session task tracking. (−) Large edit footprint across skills, docs, hooks, commands, settings, templates. (−) Teams that liked Beads lose the built-in path (mitigation: document Beads as an optional add-on in a CHANGELOG/migration note). **Capability note (review):** native `TaskCreate` persists locally and shares across sessions but is **not git-synced / team-durable / dependency-graphed** like Beads — so the replacement must be **two-tier**: durable record via GitHub Issues or a committed `ISSUES.md`, plus in-flight native Tasks. Do not imply `TaskCreate` is a 1:1 Beads replacement.
**Reversibility:** One-way-door (Medium) — re-adding is moderate effort, but the decision is well-supported.

## Decision 2 — Native skill discovery (delete the activation hook)

**Decision:** Remove the `UserPromptSubmit` skill-activation hook and its toolchain — `skill-activation-prompt.ts`, the `.sh` wrapper, `package.json`, `package-lock.json`, `tsconfig.json`, the 63 MB `node_modules` install step, and `skill-rules.json`. Rely on Claude Code's native model-driven skill discovery via `SKILL.md` `description` fields.

**Why:** Native discovery is the 2026 default and is fully portable to the 40+ agents that adopted the open Agent Skills standard. The current hook is a maintenance and portability liability: it shells out to `npx tsx` every turn, only *suggests* skills (weaker than native), and creates a dual source of truth (frontmatter vs `skill-rules.json`, already drifted). Claude Code now ships the native controls (`paths`, `skillOverrides`, `skillListingBudgetFraction`, `/doctor`) that originally motivated such hooks.

**Consequences:** (+) Removes the node dependency, the install step, the 614-line `skill-rules.json`, and the description drift in one move; truly "drop-in." (+) Frontmatter `description` becomes the single, portable activation lever. (−) Loses deterministic injection; relies on description quality. (−) **Budget dependency (review — critical):** native discovery only works if the skill *listing* fits the budget (~1% of context ≈ 2,000 tokens). The current **67-skill catalog is ~1.5–3× over budget**, so descriptions would be **silently dropped least-used-first on a fresh clone**. Therefore D2 is contingent on **plan PR4 pruning the catalog count** (the reference config's model: `languages/` ~20→1) + `skillOverrides: name-only` for niche skills, verified by `/doctor` = 0 dropped. (−) Native discovery is **not deterministic** (field reports of ~coin-flip no-fires) → ship a **dependency-free opt-in bash hook** (reading SKILL.md frontmatter, no duplicate `skill-rules.json`) as a documented fallback, and add a discovery smoke test.
**Reversibility:** One-way-door (Medium) — the opt-in bash hook remains available for teams wanting deterministic injection.

## Decision 3 — Full migration of commands → skills (with gating)

**Decision:** Move all 10 `.claude/commands/<name>.md` files to `.claude/skills/<name>/SKILL.md` now (directory name preserves the `/name`), gate side-effecting/orchestration workflows with `disable-model-invocation: true`, and remove the legacy `.claude/commands/` files after migration.

**Why:** Custom commands have merged into skills; `.claude/skills/` is the feature-complete forward path. Post-merge, command descriptions load into context and Claude may auto-invoke them — side-effecting workflows (`/builder`, `/swarm-execute`) must be gated. Doing the full migration now avoids carrying a legacy layout and a second gating pass.

**Consequences:** (+) Future-proof; unlocks skill-only features (supporting files, `context: fork`); removes auto-invoke footgun. (+) One coherent change instead of gate-now-migrate-later. (−) Must preserve muscle-memory `/names` (dir name == old file name) and avoid duplicate command+skill names during transition. (−) Larger diff; touches the swarm-* workflows (also being de-beaded in D1).
**Reversibility:** Two-way-door — legacy `commands/` still works if rollback needed.

## Decision 4 — Distribution: raw `.claude/` primary + optional plugin

**Decision:** Keep raw `.claude/` as the zero-friction primary deliverable. Add an *optional* `.claude-plugin/{plugin.json,marketplace.json}` (later phase) so the same repo is `/plugin install`-able, accepting `/framework:` namespacing for the plugin path.

**Why:** Plugins are a distribution choice, not a capability upgrade. Raw `.claude/` stays best for clone-and-go; the optional marketplace entry adds versioned updates and discoverability without forcing namespacing on direct adopters.

**Consequences:** (+) Best of both; plugin work is deferrable and non-blocking. (−) Two distribution surfaces to keep in sync (mitigation: the migration guide / CI `claude plugin validate --strict`).
**Reversibility:** Two-way-door.

---

## Cross-cutting principles adopted (from research)

- **Token discipline:** model-tier workers (haiku/sonnet, opus only for architecture); lean CLAUDE.md with `@import` rules; progressive disclosure for large skills; native discovery over always-on hook injection.
- **Security posture:** hooks are guardrails, not a boundary — hard rules go in `permissions.deny`; committed hooks are dependency-light, fail-soft, exec-form, blocking-by-opt-in, with a prominent supply-chain note.
- **Consistency:** model assignments live in exactly one place (agent frontmatter); uniform skill/agent frontmatter; aliases not pinned model IDs; single source of truth per fact.

## Meta-note

The framework's own `swarm-plan` skill mandates "create Beads before planning is complete." Per **Decision 1**, Beads is being removed; this plan therefore tracks work in the plan artifact + native `TaskCreate`, and the swarm-* skills are themselves de-beaded during execution. This ADR records that intentional deviation.
