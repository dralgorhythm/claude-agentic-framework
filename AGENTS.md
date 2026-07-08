# Agent Instructions

This repository is a drop-in framework for Claude Code: specialized commands, reusable skills, and safety hooks for AI-assisted development. These instructions apply to any coding agent working in this repo, not just Claude Code.

## Where Things Live

- `.claude/` — commands, skills, rules, hooks, and agent/worker definitions
- `./artifacts/` — durable planning documents (PR-FAQs, PRDs, ADRs, design specs, plans); committed to the repo
- `./scratchpad/` — ephemeral working notes and draft content; gitignored, disposable

## Task Tracking

Two-tier convention:

1. **Durable record**: GitHub Issues (or a committed `ISSUES.md` for repos without a tracker).
2. **In-flight work**: your tool's native task/todo list, owned by whichever agent is orchestrating — sub-agents receive focused prompts and return results rather than sharing mutable state.
3. **Handoffs**: reference concrete artifacts under `./artifacts/` by file path.

## Landing the Plane (Session Completion)

**When ending a work session**, complete ALL steps below. Work is NOT complete until `git push` succeeds.

1. **File issues for remaining work** — create tracker issues for anything that needs follow-up
2. **Run quality gates** (if code changed) — tests, linter, type checker, build
3. **Update issue status** — close finished work, update in-progress items
4. **Push to remote** — this is mandatory:
   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** — clear stashes, prune merged branches
6. **Verify** — all changes committed AND pushed
7. **Hand off** — leave clear context (and artifact references) for the next session

**Critical rules:**
- Work is NOT complete until `git push` succeeds
- Never stop before pushing — that leaves work stranded locally
- Never say "ready to push when you are" — push it yourself
- If push fails, resolve and retry until it succeeds
