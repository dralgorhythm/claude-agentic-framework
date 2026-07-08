# Customization

Add your own commands, skills, rules, and hooks.

## Adding a Command

Create `.claude/commands/my-command.md`:

```yaml
---
description: What this command does
---
```

Add command instructions below the frontmatter.

See `.claude/templates/command.template.md` for the full format.

## Adding a Skill

1. Create `.claude/skills/[category]/my-skill/SKILL.md`:

```yaml
---
name: my-skill
description: What it does
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
description: What it does
permissionMode: acceptEdits
model: haiku
---
```

Models: `haiku` (fast), `sonnet` (capable), `opus` (complex reasoning)

Use `permissionMode: default` for workers that should prompt before editing (e.g., explorers).

## Required: Configure Your Tech Stack

**IMPORTANT**: The framework will not align with your project without this step.

Edit `.claude/rules/tech-strategy.md` to match your actual technology choices:

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
