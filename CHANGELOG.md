# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

<!-- Add entries under Breaking / Added / Changed / Deprecated / Removed / Fixed / Security. scripts/release.sh stamps this section with a version and date at release time. -->

### Added

- `maxTurns` bound on every agent's frontmatter (`worker-explorer: 30`, `worker-builder: 60`, `worker-reviewer: 40`, `worker-research: 80`, `worker-architect: 40`), plus `isolation: worktree` on `worker-builder` so it runs in its own throwaway git worktree instead of the shared checkout
- Six new CI invariants in `scripts/check-invariants.sh` — `agent-maxturns`, `builder-isolation`, `preload-ungated`, `desc-style`, `evals-json`, `claudemd-lines` — bringing the total to 20 checks
- Two new `.github/workflows/framework-invariants.yml` jobs: a Trivy `fs --scanners secret` secret-scan job and a diff-size advisory job
- `CONTRIBUTING.md` with eval-first, evidence, and scope policies for new skill/rule proposals
- Exemplar eval set for the `testing` skill (`.claude/skills/core-engineering/testing/evals/evals.json` + `README.md`)
- Enforcement-ladder documentation in `.claude/rules/security.md` (prose < skills < hooks < `permissions.deny`/CI) and opt-in hook recipes in `docs/hooks.md`
- README "Why This Shape" section citing *Accelerate* / DORA 2025 evidence for the quality-gate and swarm-review design choices
- Dated (2026-07) model-tier assignment table in `docs/swarm.md` with per-tier `maxTurns` and rationale, including the Fable/Mythos premium-tier opt-out note
- Task-sizing guidance in `docs/swarm.md` (~200-400 changed LOC or 15-45 minutes per worker task, citing SmartBear/Cisco review-effectiveness research)
- Two-mode, isolation-aware "Landing the Plane" completion protocol in `AGENTS.md` — Mode A for `isolation: worktree` workers (commit + report SHA, orchestrator merges/pushes), Mode B for everyone else (push directly)

### Changed

- `architect`, `qa-engineer`, `security-auditor`, and `ui-ux-designer` skills rewritten as thin, user-invoked entry points that delegate methodology to always-on library skills (`designing-systems`, `application-security`, `accessibility`, `interface-design`, etc.) instead of restating it
- `builder` and `code-check` skills deduplicated to reference `testing`/`debugging` and `.claude/rules/code-quality.md` as the single source of truth instead of inlining SOLID/DRY/TDD content
- All 10 gated workflow-skill descriptions rewritten in third person for consistency with the new `desc-style` invariant
- `.claude/rules/core-directives.md` and `.claude/rules/security.md` single-homed several duplicated facts to their canonical detail-level location (e.g., "Landing the Plane" mechanics now live only in `AGENTS.md`); the always-loaded rules layer nets to 409 lines. Rule 6 ("Follow the Planning Flow") now scales ceremony with change scope instead of mandating the full PR-FAQ→PRD→ADR→Design Spec→Plan sequence for every change
- `docs/swarm.md` worker table and README worker counts updated from six workers to five

### Removed

- `worker-researcher` agent, consolidated into `worker-explorer` (quick web lookups) and `worker-research` (deep multi-source investigation) — see MIGRATION.md for the replacement mapping

## [3.0.0] - 2026-07-09

### Breaking

- Beads/`bd` CLI dependency removed entirely — task tracking now uses Claude Code's native task list plus GitHub Issues (two-tier convention)
- `.gitattributes` beads merge driver removed
- Init script no longer runs `bd init`
- Skill-activation hook removed (TypeScript hook, node_modules toolchain, and skill-rules.json) — skills are discovered natively from SKILL.md descriptions; a dependency-free opt-in example hook is documented in docs/examples/
- Skill catalog rationalized from 67 to 14 (generic language/framework skills that duplicate model training data removed; deleted skills remain recoverable from git history)
- `.claude/commands/` migrated to `.claude/skills/<name>/SKILL.md` (slash names unchanged); side-effecting workflows gated with `disable-model-invocation: true`

### Added

- `post-edit-lint` and `branch-pr-discipline` hooks (generic, fail-soft); `project-secret` and `push-to-default-branch` deny rules
- debugging-protocol rule (three-before-one, root-cause mandate, stale-context check)
- Plugin packaging (`.claude-plugin/plugin.json` + `marketplace.json` + `hooks/hooks.json`): the repo is `/plugin install`-able; raw drop-in remains the recommended full-featured path
- One-command release process (scripts/release.sh) and docs/releasing.md

### Changed

- Worker agents pinned to cost-efficient model tiers with least-privilege tool allowlists
- All hooks hardened to jq-optional fail-soft with explicit timeouts
- docs/personas.md renamed to docs/commands.md

### Removed

- pre-enabled frontend-design plugin and dangling IDE-tool allows from settings.json (neutral template ships no third-party plugin enablement)
- VERSION file (plugin.json is the machine version; CHANGELOG the human record)

### Fixed
- Installer crash on fresh installs (copied a file removed in v3; now optional)
- Installer copied machine-local files (`settings.local.json`, hook runtime state) into target projects; now scrubbed
- `.env` deny rules widened from four enumerated names to true globs (`**/.env`, `**/.env.*`) matching the documented claim
- Stale worker-model tables in README/docs (model columns removed; agent frontmatter is the single source of truth)
- CI model-drift check made case-insensitive
- docs/getting-started.md install switched from pipe-to-shell to clone-then-run
