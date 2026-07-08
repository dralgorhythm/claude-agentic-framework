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

## Skill catalog

v3 cuts the skill catalog from 67 skills down to 14. The following categories of
skills were removed in full:

- **Languages & Frameworks** — `typescript`, `python`, `go`, `rust`, `swift`,
  `kotlin`, `bash`, `terraform`, `react-patterns`, `biome`, `hono`,
  `tailwind-css`, `framer-motion`, `radix-ui`, `vite`, `expo-router`,
  `expo-sdk`, `react-native-patterns`, `nativewind`, `reanimated`
- Everything else that duplicated general engineering knowledge rather than
  encoding a project-specific or otherwise non-obvious workflow — e.g.
  `domain-driven-design`, `cloud-native-patterns`, `capacity-planning`,
  `defense-in-depth`, `implementing-code`, `refactoring-code`,
  `optimizing-code`, `dependency-management`, `data-management`,
  `data-to-ui`, `decomposing-tasks`, `requirements-analysis`, `documentation`,
  `estimating-work`, `brainstorming`, `agile-methodology`,
  `context-management`, `reaching-consensus`, `security-review`,
  `compliance`, `identity-access`, `infrastructure`, `incident-management`,
  `deploy-railway`, `deploy-aws-ecs`, `deploy-cloudflare`,
  `chaos-engineering`, `design-systems`, `visual-assets`,
  `component-recipes`, `demo-design-tokens`

The kept 14 — `designing-systems`, `designing-apis`, `writing-adrs`,
`debugging`, `testing`, `accessibility`, `interface-design`,
`swarm-coordination`, `observability`, `writing-pr-faqs`, `writing-prds`,
`execution-roadmaps`, `application-security`, `threat-modeling` — were
reorganized under `architecture/`, `core-engineering/`, `design/`,
`operations/`, `product/`, and `security/`. See
[docs/skills.md](docs/skills.md) for the current catalog.

**Why:** every skill's `name` and `description` is loaded into context on
every session (~100 tokens each), and Claude Code caps the total listing at a
small budget of the context window. At 67 skills that budget was tight enough
that descriptions could be silently dropped or truncated, breaking discovery.
Most of the removed skills also just restated things the model already knows
from training — generic language and framework guidance goes stale and adds
no value as a skill; use Context7 or the official docs instead for
version-specific detail. Keeping only single-responsibility,
non-training-duplicating skills gets the catalog small enough that nothing
is ever dropped from the listing budget.

**If you relied on a removed skill:**

- Nothing is destroyed — deleted skills remain fully recoverable from git
  history. Restore any individual skill with:

  ```bash
  git checkout v2.0.2 -- .claude/skills/<category>/<skill-name>
  ```

  For example, to restore the old `terraform` skill:

  ```bash
  git checkout v2.0.2 -- .claude/skills/languages/terraform
  ```

- After restoring one or more skills, run `/doctor` to confirm none of your
  skill descriptions are being dropped or truncated from the listing budget —
  re-adding enough skills can push you back over it. `/context` shows how
  much of the context window the skill listing currently consumes.

## Commands → skills

v3 migrates every file under `.claude/commands/` to `.claude/skills/<name>/SKILL.md`.
The directory `.claude/commands/` no longer exists in the framework.

**What's unchanged:**

- Slash names are identical — `/architect`, `/builder`, `/qa-engineer`,
  `/security-auditor`, `/ui-ux-designer`, `/code-check`, `/swarm-plan`,
  `/swarm-execute`, `/swarm-review`, and `/swarm-research` all still work
  exactly as before.
- If you added your own custom files under `.claude/commands/`, they continue
  to work — this is legacy-supported. The recommended home for new and
  migrated commands is `.claude/skills/`, and you should move your custom
  commands there when convenient.

**What's new:**

- Six side-effecting workflows — `builder`, `swarm-execute`, `swarm-plan`,
  `swarm-review`, `swarm-research`, and `code-check` — now carry
  `disable-model-invocation: true` in their frontmatter. This restricts them
  to explicit user invocation via `/name`; Claude will not trigger them on
  its own.
- Four advisory workflows — `architect`, `qa-engineer`, `security-auditor`,
  and `ui-ux-designer` — remain model-invocable, same as before.

**Action required:** the `disable-model-invocation` gating semantics require
a recent Claude Code version. After upgrading, run `/doctor` and confirm the
six gated skills do not auto-fire — if your Claude Code version predates
support for this field, the field is ignored and those skills may still be
model-invocable, so update before relying on the gate.

## Permissions

v3 denies reads of `.env*`, secrets, and keys at the permission layer (`permissions.deny` in `.claude/settings.json`). Previously this was only a claim in the README backed by a warn-only hook; it is now actually enforced and cannot be overridden by an allow rule from any scope. `.env.example` stays readable — the deny rule targets files that plausibly hold real secrets, not example/template files.

If your workflow legitimately needs to read a path that's now denied, don't work around it ad hoc — fork the deny rule deliberately: remove or narrow the specific `permissions.deny` line in your own `.claude/settings.json` (or `settings.local.json` for a machine-local exception), understanding that doing so re-opens the exposure the rule existed to close.

## Plugin distribution

v3 adds an optional second install path: the repo can now be installed as a Claude Code plugin (`/plugin marketplace add dralgorhythm/claude-agentic-framework` then `/plugin install agentic-framework@agentic-framework`). This is purely additive — nothing about the existing raw drop-in (clone/init-script) path changes or breaks.

The plugin path is intentionally narrower: it ships skills, agents, and hooks only. It does not include `.claude/settings.json` permission rules (notably the `permissions.deny` secret-file guards) or `.claude/rules/`, and plugin agents ignore `permissionMode` frontmatter. If you want the full guardrail set, keep using the raw drop-in — see [README.md — Two ways to adopt](README.md#two-ways-to-adopt) for the complete comparison.

## What's next

Additional v3 changes will land in subsequent updates. Entries documenting
those changes, and any further migration steps they require, will be
appended below.

<!-- Future v3 migration notes appended here. -->
