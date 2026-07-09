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

This protocol has two modes. Check which one applies before following either — it depends on whether the current agent's frontmatter declares `isolation: worktree`.

### Mode A — Isolated workers (`isolation: worktree` in agent frontmatter)

An isolated worker runs in its own throwaway git worktree, not the shared checkout — this exists specifically to stop parallel workers from racing on one git index. Because the worktree is throwaway and the branch is not the integration branch, the worker does not push; the orchestrator does.

1. **Run quality gates** (if code changed) — tests, linter, type checker, build
2. **Commit** on the assigned worktree branch — atomic, complete, working changes only
3. **Report back to the orchestrator**: the commit SHA and a summary of files changed, tests added/modified, and any follow-up work discovered
4. **Stop there** — do NOT `git push`, do NOT merge, do NOT switch branches. The orchestrator merges the worktree branch into the feature branch, re-runs gates, pushes, and cleans up the worktree.

#### Recovery

Three failure cases and how the orchestrator recovers from each:

1. **Worker stops at its `maxTurns` ceiling without a completion report.** Inspect the worktree state (`git -C <worktree-path> status`, `git -C <worktree-path> log`) to see what was actually done. Resume the SAME worker with a focused continuation message — its context is preserved — rather than respawning a new worker from scratch.
2. **Orchestrator session is lost after a worker committed but before merge.** Reclaim in-flight work by listing worktree branches (`git branch --list 'worktree-agent-*'`) and diffing each against the feature branch (`git log <branch> --not <feature-branch>`) to find unlanded commits. Review what's there, then merge or discard deliberately — do not assume the commits are safe to drop.
3. **`git merge --ff-only` is rejected because the feature branch advanced** (e.g., parallel workers landed from the same base). Rebase the worker branch onto the current feature-branch tip, re-run quality gates on the rebased result, then retry the fast-forward merge.

### Mode B — Non-isolated agents and sessions (no `isolation: worktree`)

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
