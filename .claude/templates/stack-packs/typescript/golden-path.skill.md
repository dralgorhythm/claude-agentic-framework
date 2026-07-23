---
name: typescript-golden-path
description: Runs this project's TypeScript/JavaScript golden-path commands for day-to-day development — typecheck, lint, test, and build via pnpm. Use when building, testing, linting, or type-checking this project, adding an npm script, or asking how to run it locally.
metadata:
  category: encoded-preference
---

<!-- Rendered by /tailor from .claude/templates/stack-packs/typescript/golden-path.skill.md.
     This file's containing directory must match `name:` above — commit it at
     .claude/skills/typescript-golden-path/SKILL.md, not anywhere else. -->

# TypeScript Golden Path

This project's daily loop runs on pnpm, Vite, Biome, and Vitest — golden-path choices recorded in `.claude/rules/tech-strategy.md`, not decided here.

## The Daily Loop

- While editing: keep typecheck and lint in a tight loop — run them after every meaningful change, not just before a commit.
- Before every commit: `pnpm test`.
- Before shipping: `pnpm build` — a passing test suite doesn't guarantee a passing build.

## The Four Commands

| Command | Runs |
|---------|------|
| `pnpm test` | `vitest run` |
| `pnpm lint` | `biome check .` |
| `pnpm typecheck` | `tsc --noEmit` |
| `pnpm build` | `vite build` |

## Lockfile Discipline

Regenerate `pnpm-lock.yaml` with `pnpm install` — never hand-edit it. Commit it in the same commit as the `package.json` change that produced it, every time.

## Gates Wiring

`.claude/hooks/pre-commit-verification.sh` auto-detects this stack from `package.json` and reminds you to run these commands before a commit lands. CI runs the identical four gates — see this pack's `ci-gates.yml`.

## Related Skills

Not this skill's job: `dependency-upgrade` (bumping a package), `land-the-plane` (shipping the finished work), `review-steering` (configuring automated code review).
