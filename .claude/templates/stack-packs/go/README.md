# Go Golden-Path Pack

Exemplar current as of 2026-07.

Concrete, working files for this framework's Go golden path: Go 1.25+, Gin or Chi, sqlc + pgx v5, golangci-lint — plus `go vet` and `go build`, the gate-suite commands `.claude/hooks/pre-commit-verification.sh` detects via `go.mod`. Two files: `golden-path.skill.md` (the skill `/tailor` renders into an adopter's repo) and `ci-gates.yml` (the matching CI job).

## Why These Choices

The golden-path values baked into this pack aren't this pack's decision — they're pulled straight from the Go row set in `.claude/rules/tech-strategy.md`, this framework's single source of truth for technology choices. Change the stack there and this pack drifts from it until someone updates the pack to match; the pack never carries its own copy of that table.

## How `/tailor` Adapts It

`Propose: Instantiate` (`.claude/skills/tailor/SKILL.md`) reads this pack only once Detect's fingerprint shows a Go manifest. It then substitutes the exemplar's lint tool and framework names for whatever the fingerprint evidences — e.g. no `.golangci.yml` but a `staticcheck.conf` present swaps golangci-lint's commands for staticcheck's, evidence-cited, or a `go.mod` require block naming `github.com/go-chi/chi` instead of `github.com/gin-gonic/gin` names Chi instead of Gin in the rendered skill, cited to that line — and flags anything with no signal as a kept default instead of guessing.

## How to Adapt by Hand

Edit `golden-path.skill.md` and `ci-gates.yml` directly, then rename the containing directory to match the skill's `name:` field before committing it as `.claude/skills/<name>/SKILL.md` — this framework's `name-eq-dir` check enforces the match.
