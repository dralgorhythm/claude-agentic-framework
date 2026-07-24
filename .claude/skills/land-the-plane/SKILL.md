---
name: land-the-plane
description: "Lands in-flight work: quality gates, atomic commit, rebase, push, verified remote sync, then handoff — a user-invoked finish-line workflow."
argument-hint: "[scope or branch]"
disable-model-invocation: true
metadata:
  category: encoded-preference
---

# Land the Plane - Finish-Line Protocol

Turn "the code works" into "the work is shipped." This is the user-invocable
form of AGENTS.md's "Landing the Plane" → Mode B protocol (non-isolated
agents and sessions). Run it whenever `$ARGUMENTS` names a scope or branch
that is ready to close out. Work is NOT complete until the push is verified.

Isolated worktree workers (agent frontmatter declares `isolation: worktree`)
use Mode A instead — commit on the assigned branch and report to the
orchestrator, do not push. See AGENTS.md; do not apply this skill there.

## 1. Preflight — Inventory, Don't Sweep

- Run `git status`. Read every entry: modified, deleted, untracked.
- Account for each file explicitly — nothing is silently left behind, and
  nothing is blindly swept in.
- `git add -A` and `git add .` are FORBIDDEN. Stage with explicit pathspecs
  (`git add path/to/file.ts path/to/other.ts`) so the diff you review is the
  diff you commit.
- If `$ARGUMENTS` names a scope or branch, confirm the inventory matches it —
  don't land unrelated dirty files just because they happen to be present.

## 2. Gates — Never Commit Red

- Run the project's full quality gates per `.claude/rules/code-quality.md`:
  tests, linter, type checker, build.
- A failing gate STOPS the landing. Fix the failure, or explicitly hand it
  off (issue + task-list entry) — never commit past a red gate.
- See Failure Branches below for the exact stop condition.

## 3. Commit — Atomic and Explicit

- One logical change per commit; write an atomic, descriptive message.
- Put the commit on its own command line. Do NOT chain it with `&&` after
  staging or other commands — if an earlier segment exits non-zero, a
  chained commit silently skips and the failure goes unnoticed.
- Confirm the commit landed (`git log -1`) before moving to Sync.

## 4. Sync — Rebase, Push, Verify

```bash
git pull --rebase
git push
git status   # MUST show "up to date with origin"
```

- Resolve any rebase conflicts, then re-run the Gates step if the rebase
  touched code — a pre-rebase gate pass does not cover post-rebase code.
- Work is NOT complete until the push is verified. Report the pushed commit
  SHA (`git rev-parse HEAD`) as evidence, not just "pushed."

## 5. Handoff — Leave a Clean Trail

- Open a PR targeting `main` (trunk-based: every PR merges to `main`
  independently — never stack on another unit's branch); pass the body via
  a file (heredoc or temp file), never as an inline string — avoids
  quoting and escaping failures.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`'s Provenance fields (author/model,
  gates run with results, pushed SHA) and Risk Tier before requesting review.
- File remaining work as issues or task-list entries, each referencing the
  relevant artifact under `./artifacts/`.
- Release working state: drop stashes, remove temp files, release any
  locks, and keep `./scratchpad/` references out of anything you hand off —
  scratchpad is ephemeral and disposable, not a citable deliverable.
- **Retro**: if `scratchpad/corrections.log` is non-empty, map each entry
  to the strongest enforcement rung it can support (rule edit < skill edit
  < hook < permissions.deny/CI — same discipline as `postmortem`'s
  Prevention step), promote it via a small PR or filed issue, then remove
  the processed lines. Never end a session by silently discarding the log.

## Failure Branches

| Situation | Action |
|-----------|--------|
| Push rejected (non-fast-forward) | `git pull --rebase`, retry the push ONCE. Still rejected? Stop and report — do not force-push, do not loop. |
| Gate failure | Stop immediately. Report the failing command's output verbatim — no paraphrasing, no summarizing away the failure. |
| Nothing to commit | Do not exit silently. Still run Sync's verification (`git pull --rebase`, `git status`) and state explicitly that the tree was already clean and in sync. |

## Constraints

- NO `git add -A` / `git add .` — explicit pathspecs only
- NO chained `&&` commits — commit on its own command line
- NO committing past a failing gate
- NO force-push to resolve a rejected push
- NO treating "ready to push" as done — push, then verify, then report the SHA

## Related Skills

`testing` (Gates step) · `swarm-coordination` (Mode A vs Mode B)

## Handoff

- To `/swarm-review`: after landing, for code review on the pushed branch
- To issues/task list: for any remaining work discovered during Preflight

$ARGUMENTS
