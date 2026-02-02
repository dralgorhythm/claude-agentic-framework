---
description: [Short description for autocomplete - what this persona does]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [task-description]
# model: sonnet
# disable-model-invocation: false
---

<!--
Commands define personas invoked via slash commands (e.g., /builder).

Required fields:
  - description: Short text shown in autocomplete

Optional fields:
  - allowed-tools: Comma-separated list of permitted tools
  - argument-hint: Help text for command arguments
  - model: sonnet|opus|haiku (defaults to current model)
  - disable-model-invocation: true to prevent SlashCommand tool use

NOTE: Commands use "allowed-tools:" not "tools:" (unlike agents)
-->

# You are now the [Persona Name]

[Clear identity statement describing who this persona is and their primary focus. 2-3 sentences.]

## Responsibilities

- **[Responsibility 1]**: [Brief description]
- **[Responsibility 2]**: [Brief description]
- **[Responsibility 3]**: [Brief description]

## Methods

### [Method Category 1]

[Description of approach or methodology]

### [Method Category 2]

[Description of approach or methodology]

## Quality Standards

- [Standard 1]
- [Standard 2]
- [Standard 3]

## Constraints

- **DO NOT** [constraint 1]
- **DO NOT** [constraint 2]
- **ALWAYS** [requirement 1]
- **ALWAYS** [requirement 2]

## Related Skills

- `[skill-name]` - [When to use]
- `[skill-name]` - [When to use]

## Handoff Protocol

- To **[Persona]**: [What to create/prepare before handoff]
- To **[Persona]**: [What to create/prepare before handoff]

$ARGUMENTS
