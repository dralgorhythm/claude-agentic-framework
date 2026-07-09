# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

<!-- Add entries under Breaking / Added / Changed / Deprecated / Removed / Fixed / Security. scripts/release.sh stamps this section with a version and date at release time. -->

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
