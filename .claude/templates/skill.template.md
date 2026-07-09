---
name: [skill-name]
description: [Clear description of what this skill does and when Claude should use it. Include trigger phrases like "Use when..." to help with skill invocation.]
argument-hint: [optional-arg-description]
disable-model-invocation: false
---

<!--
Skills are discovered via description matching, and can also be invoked
directly by slash name (e.g. /my-skill) — that's what a "command" is: a
skill invoked as /name instead of (or in addition to) auto-discovery.

Required fields:
  - name: lowercase, hyphens only, max 64 chars, must match directory name
  - description: max 1024 chars, CRITICAL for auto-discovery

Optional fields:
  - argument-hint: help text shown for a command-style skill's arguments
    (e.g. "[task-description]"). Omit for pure knowledge skills.
  - disable-model-invocation: set to true when the skill's workflow has side
    effects (writes files, runs shell commands, pushes to git, launches
    workers) — this restricts invocation to a user explicitly typing
    /skill-name and stops Claude from triggering it on its own. Leave false
    (or omit) for advisory/knowledge skills where auto-discovery is safe.

Description best practices:
  GOOD: "API design skill. Use when designing REST APIs, GraphQL schemas, or gRPC services."
  BAD:  "Helps with APIs"

Supporting files (auto-discovered):
  - FORMS.md: Input templates
  - REFERENCE.md: Technical reference
  - resources/: Additional materials

Location: .claude/skills/[domain]/[skill-name]/SKILL.md
  (command-style skills live directly at .claude/skills/[skill-name]/SKILL.md)

$ARGUMENTS is an optional placement marker: if present, user-typed arguments
substitute there; if omitted, arguments are appended to the end
automatically.

Reference convention: user-invoked workflow skills are cited as /name;
always-on library skills as bare name.
-->

# [Skill Name]

## Overview

[Brief description of this skill's purpose and scope]

## Workflows

- [ ] **Step 1**: [Description]
- [ ] **Step 2**: [Description]
- [ ] **Step 3**: [Description]

## Feedback Loops

1. [Action]
2. [Validation]
3. If [condition], [correction]
4. Repeat until [success criteria]

## Reference Implementation

```[language]
// Example code demonstrating the pattern
```

## Best Practices

- [Practice 1]
- [Practice 2]
- [Practice 3]

## Anti-Patterns

- [What to avoid 1]
- [What to avoid 2]

## Resources

- [Resource Name](./resources/resource.md)
- [External Link](https://example.com)
