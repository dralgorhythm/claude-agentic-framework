# Rust Golden-Path Pack

Exemplar current as of 2026-07.

Concrete, working files for this framework's Rust golden path: Rust 2024 edition, Tokio (general) or Monoio (high-throughput), Axum, sqlx, rkyv — plus `cargo test`, `cargo clippy`, and `cargo fmt`, the gate-suite commands `.claude/hooks/pre-commit-verification.sh` detects via `Cargo.toml`. Two files: `golden-path.skill.md` (the skill `/tailor` renders into an adopter's repo) and `ci-gates.yml` (the matching CI job).

## Why These Choices

The golden-path values baked into this pack aren't this pack's decision — they're pulled straight from the Rust row set in `.claude/rules/tech-strategy.md`, this framework's single source of truth for technology choices. Change the stack there and this pack drifts from it until someone updates the pack to match; the pack never carries its own copy of that table.

## How `/tailor` Adapts It

`Propose: Instantiate` (`.claude/skills/tailor/SKILL.md`) reads this pack only once Detect's fingerprint shows a `Cargo.toml` manifest. It then substitutes the exemplar's defaults for whatever the fingerprint evidences: no `clippy.toml` but a `rustfmt.toml` present cites that file's rules for the format-check step instead of assuming un-customized defaults; a `monoio` dependency in `Cargo.toml` names Monoio instead of the exemplar's default Tokio, cited to that dependency line; a root `Cargo.toml` carrying a `[workspace]` table notes every command as workspace-wide instead of single-crate — and anything with no signal stays a kept default instead of a guess.

## How to Adapt by Hand

Edit `golden-path.skill.md` and `ci-gates.yml` directly, then rename the containing directory to match the skill's `name:` field before committing it as `.claude/skills/<name>/SKILL.md` — this framework's `name-eq-dir` check enforces the match.
