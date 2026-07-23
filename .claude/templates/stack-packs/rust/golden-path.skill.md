---
name: rust-golden-path
description: Runs this project's Rust golden-path commands for day-to-day development — clippy, format check, test, and build via cargo. Use when building, testing, linting, formatting, or running this Rust project, or asking how to run it locally.
metadata:
  category: encoded-preference
---

<!-- Rendered by /tailor from .claude/templates/stack-packs/rust/golden-path.skill.md.
     This file's containing directory must match `name:` above — commit it at
     .claude/skills/rust-golden-path/SKILL.md, not anywhere else. -->

# Rust Golden Path

This project's daily loop runs on cargo, clippy, and rustfmt — golden-path choices recorded in `.claude/rules/tech-strategy.md`, not decided here.

## The Daily Loop

- While editing: keep `cargo clippy` and `cargo fmt --check` in a tight loop — run them after every meaningful change, not just before a commit.
- Before every commit: `cargo test`.
- Before shipping: `cargo build` — a passing test suite doesn't guarantee a passing build.

## The Four Commands

| Command | Gate |
|---------|------|
| `cargo test` | Test suite |
| `cargo clippy` | Lint |
| `cargo fmt --check` | Format check |
| `cargo build` | Build |

## Lockfile Discipline

Cargo regenerates `Cargo.lock` automatically on any command that resolves dependencies (`cargo build`, `cargo update`) — never hand-edit it. Commit it in the same commit as the `Cargo.toml` change that produced it, every time.

## Gates Wiring

`.claude/hooks/pre-commit-verification.sh` auto-detects this stack from `Cargo.toml` and reminds you to run these commands before a commit lands. CI runs the identical gates — see this pack's `ci-gates.yml`.

## Related Skills

Not this skill's job: `dependency-upgrade` (bumping a package), `land-the-plane` (shipping the finished work), `review-steering` (configuring automated code review).
