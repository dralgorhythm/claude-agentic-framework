# TypeScript / JavaScript Golden-Path Pack

Exemplar current as of 2026-07.

Concrete, working files for this framework's TypeScript/JavaScript golden path: pnpm, Vite, Biome, Vitest, React 19, Node LTS. Two files: `golden-path.skill.md` (the skill `/tailor` renders into an adopter's repo) and `ci-gates.yml` (the matching CI job).

## Why These Choices

The golden-path values baked into this pack aren't this pack's decision — they're pulled straight from the TypeScript/JavaScript row set in `.claude/rules/tech-strategy.md`, this framework's single source of truth for technology choices. Change the stack there and this pack drifts from it until someone updates the pack to match; the pack never carries its own copy of that table.

## How `/tailor` Adapts It

`Propose: Instantiate` (`.claude/skills/tailor/SKILL.md`) reads this pack only once Detect's fingerprint shows a TypeScript/JavaScript manifest. It then substitutes the exemplar's package manager, test runner, and framework names for whatever the fingerprint evidences — e.g. a `yarn.lock` swaps every `pnpm` for `yarn`, cited to that lockfile — and flags anything with no signal as a kept default instead of guessing.

## How to Adapt by Hand

Edit `golden-path.skill.md` and `ci-gates.yml` directly, then rename the containing directory to match the skill's `name:` field before committing it as `.claude/skills/<name>/SKILL.md` — this framework's `name-eq-dir` check enforces the match.
