---
name: python-golden-path
description: Runs this project's Python golden-path commands for day-to-day development — lint, format, typecheck, and test via uv. Use when building, testing, linting, or type-checking this project, adding a uv script, or asking how to run it locally.
metadata:
  category: encoded-preference
---

<!-- Rendered by /tailor from .claude/templates/stack-packs/python/golden-path.skill.md.
     This file's containing directory must match `name:` above — commit it at
     .claude/skills/python-golden-path/SKILL.md, not anywhere else. -->

# Python Golden Path

This project's daily loop runs on uv, Ruff, pytest, and mypy — golden-path choices recorded in `.claude/rules/tech-strategy.md`, not decided here.

## The Daily Loop

- While editing: keep `ruff check` and `mypy` in a tight loop — run them after every meaningful change, not just before a commit.
- Before every commit: `uv run pytest`.

## The Four Commands

| Command | Gate |
|---------|------|
| `uv run pytest` | Test suite |
| `uv run ruff check .` | Lint |
| `uv run ruff format --check .` | Format check |
| `uv run mypy .` | Type check |

## Lockfile Discipline

Regenerate `uv.lock` with `uv lock` (`uv sync` regenerates it implicitly too) — never hand-edit it. Commit it in the same commit as the `pyproject.toml` change that produced it, every time.

## Gates Wiring

`.claude/hooks/pre-commit-verification.sh` auto-detects this stack from `pyproject.toml` and reminds you to run these commands before a commit lands. CI runs the same four gates plus a dependency-audit step (`uvx pip-audit`) that has no local pre-commit equivalent — see this pack's `ci-gates.yml`.

## Related Skills

Not this skill's job: `dependency-upgrade` (bumping a package), `land-the-plane` (shipping the finished work), `review-steering` (configuring automated code review).
