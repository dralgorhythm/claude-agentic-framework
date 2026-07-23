# Customization

Add your own command-style skills, skills, rules, hooks, and swarm workers.

## Adding a Command-Style Skill

Commands are just skills invoked by their slash name. Create `.claude/skills/my-command/SKILL.md`:

```yaml
---
name: my-command
description: What this command does
argument-hint: "[task-description]"
disable-model-invocation: true
---
```

- `name` — must match the directory name.
- `description` — shown in autocomplete; also what Claude matches against if model-invocation is left enabled.
- `argument-hint` — optional help text shown for the command's arguments.
- `disable-model-invocation: true` — set this whenever the workflow has side effects (writes files, runs commands, pushes changes). It restricts invocation to a user explicitly typing `/my-command` and prevents Claude from triggering it on its own. Leave it unset only for purely advisory workflows where model-invocation is safe (e.g. a knowledge/library skill — this repo gates all ten of its shipped workflow skills).

Add command instructions below the frontmatter, and end the file with `$ARGUMENTS` so the user's trailing text is passed through:

```markdown
...instructions...

$ARGUMENTS
```

See `.claude/templates/skill.template.md` for the full format.

## Adding a Skill

1. Create `.claude/skills/[category]/my-skill/SKILL.md`:

```yaml
---
name: my-skill
description: Reviews database migrations for safety. Use when adding or editing migration files.
---
```

2. No registration needed. Discovery is automatic: Claude Code reads every `SKILL.md`'s frontmatter at startup, so as soon as the file exists, the skill is live.

   The only thing that determines whether it activates is the strength of its `description`. Write it in the **third person**, stating **what** the skill does and **when** to use it — lead with the trigger phrases a user would actually type:

   ```yaml
   ---
   name: my-skill
   description: Guides X. Use when the user asks to Y or mentions Z.
   ---
   ```

See `.claude/templates/skill.template.md` for the full format.

## Adding a Rule

Create `.claude/rules/my-rule.md`:

```markdown
# My Rule

Rules here. Keep it short — rules load on every request.
```

Rules auto-load. No registration needed.

The framework intentionally ships no stack-specific frontend rule (React, Vue, etc.) — that choice belongs to the adopter, not the template. Add your own under `.claude/rules/` using `.claude/templates/rule.template.md` as the starting point.

## Artifact Templates

Skills that produce planning artifacts bundle their templates inside the owning skill's `resources/` directory, so each skill stays self-contained (e.g. `.claude/skills/architecture/designing-systems/resources/adr.template.md`, `.claude/skills/product/planning-artifacts/resources/prd.template.md`). Three artifact types have no owning library skill; starter templates for those live in `.claude/templates/artifacts/`: `plan`, `design_spec`, `security_audit`. (The postmortem template moved into the `postmortem` skill's `resources/` when that skill was added.) Output naming for all artifact types is defined in CLAUDE.md's artifact table.

## Stack Packs

`.claude/templates/stack-packs/<stack>/` holds concrete, working exemplar files for one stack's golden path: a README, the one skill `/tailor` renders into your repo (`golden-path.skill.md`), and a CI job snippet (`ci-gates.yml`) — zero placeholder tokens, real commands.

Run `/tailor instantiate` once your stack is detectable; it adapts the exemplar to your repo's actual package manager, test runner, and framework, every substitution evidence-cited, and never renders a stack it didn't detect.

TypeScript/JavaScript, Python, Go, and Rust ship today. See `.claude/templates/stack-packs/README.md` for the full convention.

## Adding a Hook

See [hooks.md](hooks.md) for the full guide.

Quick version:

1. Create `.claude/hooks/my-hook.sh`
2. `chmod +x .claude/hooks/my-hook.sh`
3. Register in `.claude/settings.json`

## Adding a Swarm Worker

Create `.claude/agents/worker-mytype.md`:

```yaml
---
name: worker-mytype
description: What it does, third person. Use for [task type].
permissionMode: acceptEdits
model: haiku
maxTurns: 30
tools: Read, Grep, Glob
---
```

- `maxTurns` — required: CI (`agent-maxturns`) fails any agent without a positive integer turn bound. Shipped values range from 30 (`worker-explorer`) to 90 (`worker-builder`); start low and raise only from observed ceiling hits.
- `tools` — least-privilege allowlist; add `Write`, `Edit`, or `Bash` only if the worker genuinely needs them.
- Models: `haiku` (fast), `sonnet` (capable). CI (`model-tiering`) reserves `opus` for `worker-architect`, so new workers use `haiku` or `sonnet`.
- Use `permissionMode: default` for workers that should prompt before editing (e.g., explorers).

Then register the file in `.claude-plugin/plugin.json`'s `agents` array — CI (`plugin-agents-sync`) requires that list to exactly match `.claude/agents/*.md`:

```json
"agents": [
  "...existing entries...",
  "./.claude/agents/worker-mytype.md"
]
```

See `.claude/templates/agent.template.md` for the full format, and [swarm.md](swarm.md) for the model-tier table.

## Required: Configure Your Tech Stack

**IMPORTANT**: The framework will not align with your project without this step.

The fast path: once your repo has committed manifests/lockfiles, run `/tailor` — it detects your stack, proposes filled golden-path tables (plus REVIEW.md review steering and a prune list of framework pieces your stack doesn't need) as a reviewable plan, and you apply what you approve. Nothing is written without your sign-off.

The manual path: edit `.claude/rules/tech-strategy.md` to match your actual technology choices:

```markdown
### TypeScript
| Component | Choice |
|-----------|--------|
| Runtime | Deno |        # your choice
| Build | esbuild |       # your choice
```

The framework enforces these across all commands. Claude will use the technologies you specify here, not generic defaults.

---

[← Back to README](../README.md)
