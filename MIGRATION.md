# Migrating to v3

This guide covers the changes needed to move from the v2.x line (latest: v2.0.2) to v3.
v3 is a breaking release. More entries will be appended here as further v3 changes land.

## Who is affected

Anyone using the framework's default clone/init flow, and anyone whose workflows or
automation invoked the `bd` CLI or relied on the `.beads/` merge driver configured by
this repo. If you never used Beads-based task tracking, the only change relevant to
you right now is the two-tier task tracking convention described below.

## What breaks

### Beads / `bd` CLI removal

The framework no longer depends on Beads for task tracking. Specifically:

- The init script no longer runs `bd init`.
- The `.gitattributes` merge driver entry for Beads has been removed.
- No command, skill, or rule in this repo shells out to `bd` anymore.

**If you were using `bd`:**

- Your existing `.beads/` data is unaffected and stays in your repo — nothing deletes
  or migrates it.
- The `bd` CLI still works standalone; it is an independent tool and this removal does
  not uninstall it or break it.
- The framework simply no longer wires it in automatically. If you want to keep using
  Beads, re-add it yourself as an optional extra:
  - Keep (or restore) your `.beads/` directory and `bd` binary/install step.
  - Re-add a merge driver entry to `.gitattributes` if you need conflict-safe merges
    on the Beads data file.
  - Call `bd init` / `bd sync` from your own init script or CI step.

## How to adopt the two-tier task tracking convention

v3 replaces the built-in Beads workflow with a two-tier convention:

1. **Ephemeral / in-session work** — track short-lived, single-session tasks with
   Claude Code's native task list. Use it for anything that doesn't need to survive
   past the current session or be visible to other collaborators.
2. **Durable / cross-session work** — track anything that needs to persist, be
   assigned, or be visible outside the session as a GitHub Issue in your project's
   repo. Use standard GitHub Issues workflows (labels, milestones, assignees) instead
   of a bespoke tracker.

No migration script is provided for existing `.beads/` data — export or reference it
manually when opening corresponding GitHub Issues, if desired.

## Skill discovery

v3 removes the skill-activation hook — the TypeScript hook script, its `node_modules`
toolchain, and `.claude/skills/skill-rules.json` are all gone. Skills are now
discovered **natively**: Claude Code loads every skill's name and description from its
`SKILL.md` frontmatter at startup and reads the full body automatically when the
description matches what you're doing. There's nothing to install and nothing to
register.

**If you relied on the hook's keyword matching:**

- Any custom entries you had in `skill-rules.json` no longer do anything — activation
  now depends entirely on the quality of each skill's `description` field. Make sure
  your custom skills describe, in the third person, what they do and when to use them,
  with trigger phrases up front.
- If you need deterministic, keyword-based activation instead of native model-driven
  discovery, a dependency-free opt-in example hook is documented in
  [docs/examples/skill-activation-hook.sh](docs/examples/skill-activation-hook.sh). It
  is disabled by default and not required for skills to work.

## What's next

Additional v3 changes — including the command-to-skill migration — will land in
subsequent updates. Entries documenting those changes, and any further migration steps
they require, will be appended below.

<!-- Future v3 migration notes appended here. -->
