# Python Golden-Path Pack

Exemplar current as of 2026-07.

Concrete, working files for this framework's Python golden path: Python 3.13+, uv, Ruff, Litestar, msgspec, asyncpg — plus pytest and mypy, the gate-suite tools `.claude/hooks/pre-commit-verification.sh` detects via `pyproject.toml`. Two files: `golden-path.skill.md` (the skill `/tailor` renders into an adopter's repo) and `ci-gates.yml` (the matching CI job).

## Why These Choices

The golden-path values baked into this pack aren't this pack's decision — they're pulled straight from the Python row set in `.claude/rules/tech-strategy.md`, this framework's single source of truth for technology choices. Change the stack there and this pack drifts from it until someone updates the pack to match; the pack never carries its own copy of that table.

## How `/tailor` Adapts It

`Propose: Instantiate` (`.claude/skills/tailor/SKILL.md`) reads this pack only once Detect's fingerprint shows a Python manifest. It then substitutes the exemplar's package manager, linter, and framework names for whatever the fingerprint evidences — e.g. a `poetry.lock` swaps every `uv` command for its poetry equivalent, cited to that lockfile, or a `pyproject.toml` with no `[tool.ruff]` table but a flake8 config present swaps Ruff's commands for flake8's, evidence-cited — and flags anything with no signal as a kept default instead of guessing.

## How to Adapt by Hand

Edit `golden-path.skill.md` and `ci-gates.yml` directly, then rename the containing directory to match the skill's `name:` field before committing it as `.claude/skills/<name>/SKILL.md` — this framework's `name-eq-dir` check enforces the match.
