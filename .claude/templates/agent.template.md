---
name: worker-[type]
description: [What this worker does, third person. Use for [task type 1], [task type 2].]
permissionMode: acceptEdits
model: haiku
maxTurns: 30
tools: Read, Grep, Glob
# isolation: worktree
# skills: designing-systems, writing-adrs
---

<!--
Agents are lightweight swarm workers spawned via the Task tool.
Canonical field order: name, description, permissionMode, model, maxTurns,
[isolation], tools, [skills] — see the shipped agents in .claude/agents/.

Required fields:
  - name: lowercase, hyphens only, max 64 chars; keep the filename matching
    (worker-[type].md)
  - description: max 1024 chars, third person. Convention: end with a
    "Use for ..." trigger list so the orchestrator picks the right worker.
  - maxTurns: positive integer turn bound — REQUIRED; CI (agent-maxturns)
    fails without it. Shipped values, sized from observed runs with headroom:
    worker-explorer 30, worker-architect 40, worker-reviewer 60,
    worker-research 80, worker-builder 90. Start near 30 for read-only
    workers and raise only from observed ceiling hits.

Recommended fields:
  - tools: least-privilege allowlist — every bundled agent has one.
    Read-only worker: Read, Grep, Glob (add WebFetch, WebSearch for
    research). Writing worker: add Write, Edit — and Bash only if genuinely
    needed.
  - permissionMode: default | acceptEdits | bypassPermissions | plan
      "acceptEdits" for workers that write files.
      "default" for read-only workers (no write tools) — they then prompt
      if they ever attempt an edit.
      "bypassPermissions" only when the orchestrator has already validated
      safety.
    tools and permissionMode work together: the allowlist bounds WHAT the
    worker can invoke; permissionMode governs HOW MUCH confirmation it needs.
  - model: haiku (fast, mechanical work) | sonnet (production default —
    implementation, review, research) | inherit (parent session's model).
    CI (model-tiering) requires alias names and reserves opus for
    worker-architect only.

Optional fields:
  - isolation: worktree — give the worker its own throwaway git worktree.
    Use for workers that WRITE in parallel with other writers: siblings
    sharing one worktree share the git index, so parallel staging races.
    See worker-builder and AGENTS.md.
  - skills: comma-separated skill names to preload. Names must be existing
    skill directory names and must be UNGATED library skills — CI
    (preload-ungated) fails on gated or unknown names. Real examples:
    "designing-systems, writing-adrs, designing-apis" (worker-architect),
    "application-security" (worker-reviewer).

Register the new agent (required in this repo): add
"./.claude/agents/worker-[type].md" to the "agents" array in
.claude-plugin/plugin.json — CI (plugin-agents-sync) requires that array
to exactly match the files under .claude/agents/.

Run bash scripts/check-invariants.sh before committing.
-->

# [Worker Type] Worker

[One-line description of worker focus]

## Focus

- [Primary task 1]
- [Primary task 2]
- [Primary task 3]

## Tool Use Rules

- **Never prefix Bash commands with shell comments** (`# comment\ncommand`). This breaks permission auto-approval pattern matching.
- Prefer dedicated tools (Read, Grep, Glob) over Bash equivalents.

## Output Format

```
[Field 1]: [description]
[Field 2]: [description]
[Field 3]: [description]
```

## Constraints

- [Constraint 1 - e.g., "Read-only operations"]
- [Constraint 2 - e.g., "Single task focus"]
- [Constraint 3 - e.g., "Stay within the maxTurns budget — report partial results before the ceiling"]

## On Completion

Report: [what to report back to orchestrator]
