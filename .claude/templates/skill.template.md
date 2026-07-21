---
name: [skill-name]
description: [Third person: what this skill does. Use when [trigger 1] or [trigger 2].]
# Command-style (slash-invoked, side-effecting) skills add these two lines:
# argument-hint: [task-description]
# disable-model-invocation: true
---

<!--
Skills are discovered via description matching, and can also be invoked
directly by slash name (e.g. /my-skill) — that's what a "command" is: a
skill invoked as /name instead of (or in addition to) auto-discovery.

Required fields:
  - name: lowercase, hyphens only, max 64 chars, must match directory name
    (CI: name-eq-dir)
  - description: CRITICAL for auto-discovery. CI (desc-style) enforces:
    non-empty, <=500 chars (the platform allows 1024; CI does not), third
    person — must not open with "I", "You", "This skill", or "A skill" —
    and, for ungated skills, it MUST contain the phrase "Use when". CI
    (desc-budget) also caps the sum of all skill descriptions at 6,000
    chars, so keep it tight.

Optional fields:
  - argument-hint: help text shown for a command-style skill's arguments
    (e.g. "[task-description]"). Omit for pure knowledge skills.
  - disable-model-invocation: set to true when the skill's workflow has side
    effects (writes files, runs shell commands, pushes to git, launches
    workers) — this restricts invocation to a user explicitly typing
    /skill-name and stops Claude from triggering it on its own. Omit the
    field entirely for library skills where auto-discovery is safe — do not
    write "false" explicitly (no shipped skill does). When true, the
    "Use when" requirement is waived: the description becomes /skill-name
    menu text rather than an auto-invocation trigger.

Description best practices:
  GOOD: "API design skill. Use when designing REST APIs, GraphQL schemas, or gRPC services."
  BAD:  "Helps with APIs"

Body: keep under 500 lines (CI: skill-length).

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
