# Examples

This directory holds **opt-in** reference implementations that are not wired
into this framework's default configuration. Nothing here runs unless you
explicitly copy the relevant snippet into your own `.claude/settings.json`.

## Contents

- `skill-activation-hook.sh` — a dependency-free bash `UserPromptSubmit` hook
  that deterministically scans `.claude/skills/*/SKILL.md` frontmatter and
  suggests the top 3 matching skills for a given prompt. Native skill
  discovery is the default and needs no setup; this hook is an optional,
  deterministic layer on top of it, at the cost of a small per-turn latency
  hit. See the header comment in the script for the exact settings.json
  snippet to enable it.
- `worker-budget-hook.sh` — a dependency-free bash hook pair (`PreToolUse`
  on `Task` + `SubagentStop`) that counts concurrent worker dispatches and
  warns past 8 in flight, illustrating the `swarm-coordination` skill's
  "Budget & Waves" cost circuit-breaker convention. See the header comment
  for the exact settings.json snippet to enable it.

## Security note

**Anything you wire into `settings.json` — hooks in particular — executes
automatically on every collaborator's machine** who pulls this repo and has
hooks enabled, with no per-run confirmation. Before enabling any example
here, read the script in full, understand what it does with its inputs, and
review it the same way you would review a change to CI. Treat hook scripts
as production code, not sample text.
