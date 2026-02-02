# Customization

Add your own personas, skills, rules, and hooks.

## Adding a Persona

Create `.claude/commands/my-persona.md`:

```yaml
---
description: What this persona does
allowed-tools: Read, Write, Edit, Bash
---
```

Add persona instructions below the frontmatter.

See `templates/claude_mechanisms/command.template.md` for the full format.

## Adding a Skill

1. Create `.claude/skills/[category]/my-skill/SKILL.md`:

```yaml
---
name: my-skill
description: What it does
allowed-tools: Read, Write, Edit
---
```

2. Register in `.claude/skills/skill-rules.json`:

```json
{
  "name": "my-skill",
  "path": ".claude/skills/category/my-skill/SKILL.md",
  "triggers": {
    "keywords": ["keyword1", "keyword2"]
  },
  "priority": "medium"
}
```

See `templates/claude_mechanisms/skill.template.md` for the full format.

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
tools: Read, Glob, Grep
model: haiku
---
```

Models: `haiku` (fast), `sonnet` (capable), `opus` (complex reasoning)

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

The framework enforces these across all personas. Claude will use the technologies you specify here, not generic defaults.

---

[← Back to README](../README.md)
