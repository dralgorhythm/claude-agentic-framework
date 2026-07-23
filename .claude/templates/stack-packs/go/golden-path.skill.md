---
name: go-golden-path
description: Runs this project's Go golden-path commands for day-to-day development — vet, lint, test, and build via the standard go tool and golangci-lint. Use when building, testing, linting, vetting, or running this Go project, or asking how to run it locally.
metadata:
  category: encoded-preference
---

<!-- Rendered by /tailor from .claude/templates/stack-packs/go/golden-path.skill.md.
     This file's containing directory must match `name:` above — commit it at
     .claude/skills/go-golden-path/SKILL.md, not anywhere else. -->

# Go Golden Path

This project's daily loop runs on the standard go tool and golangci-lint — golden-path choices recorded in `.claude/rules/tech-strategy.md`, not decided here.

## The Daily Loop

- While editing: keep `go vet` and `golangci-lint run` in a tight loop — run them after every meaningful change, not just before a commit.
- Before every commit: `go test ./...`.
- Before shipping: `go build ./...` — a passing test suite doesn't guarantee a passing build.

## The Four Commands

| Command | Gate |
|---------|------|
| `go test ./...` | Test suite |
| `go vet ./...` | Static analysis |
| `golangci-lint run` | Lint |
| `go build ./...` | Build |

## Module Discipline

Regenerate `go.sum` with `go mod tidy` after every dependency change — never hand-edit it. Commit `go.mod` and `go.sum` together in the same commit, every time.

## Gates Wiring

`.claude/hooks/pre-commit-verification.sh` auto-detects this stack from `go.mod` and reminds you to run these commands before a commit lands. CI runs the identical gates — see this pack's `ci-gates.yml`.

## Related Skills

Not this skill's job: `dependency-upgrade` (bumping a package), `land-the-plane` (shipping the finished work), `review-steering` (configuring automated code review).
