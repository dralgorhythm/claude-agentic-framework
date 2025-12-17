---
name: worker-[type]
description: [Brief description of worker purpose. Used for parallel [task type].]
tools: Read, Glob, Grep
model: haiku
# permissionMode: default
# skills: skill-name-1, skill-name-2
---

<!--
Agents are lightweight swarm workers spawned via Task tool.

Required fields:
  - name: lowercase, hyphens only, max 64 chars
  - description: max 1024 chars, include "when to use" triggers

Optional fields:
  - tools: Comma-separated list (inherits all if omitted)
  - model: haiku (fast), sonnet (balanced), opus (complex)
  - permissionMode: default|acceptEdits|bypassPermissions|plan
  - skills: Comma-separated skill names to auto-load

NOTE: Agents use "tools:" not "allowed-tools:" (unlike commands)
-->

# [Worker Type] Worker

[One-line description of worker focus]

## Focus

- [Primary task 1]
- [Primary task 2]
- [Primary task 3]

## Output Format

```
[Field 1]: [description]
[Field 2]: [description]
[Field 3]: [description]
```

## Constraints

- [Constraint 1 - e.g., "Read-only operations"]
- [Constraint 2 - e.g., "Single task focus"]
- [Constraint 3 - e.g., "Timeout at 5 min"]

## On Completion

Report: [what to report back to orchestrator]
