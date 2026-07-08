# Skills

Skills are structured workflows that Claude suggests based on what you're doing.

## How It Works

You don't invoke skills directly. Just describe what you need:

```
"I need to design an API for user management"
```

Claude sees relevant skills suggested (like `designing-apis`) and uses them to give you a better response.

## Available Skills

14 skills across 6 categories.

### Architecture
- `designing-systems` — Design scalable, reliable software systems
- `designing-apis` — Design clean, consistent APIs
- `writing-adrs` — Document architectural decisions

### Core Engineering
- `debugging` — Troubleshoot and fix bugs systematically
- `testing` — Write effective tests for code quality and reliability

### Design
- `accessibility` — Ensure digital accessibility
- `interface-design` — Design user interfaces

### Operations
- `swarm-coordination` — Coordinate multi-agent swarm workflows
- `observability` — Implement observability solutions

### Product
- `writing-pr-faqs` — Write Press Release / FAQ documents
- `writing-prds` — Create Product Requirements Documents
- `execution-roadmaps` — Create execution roadmaps for projects

### Security
- `application-security` — Secure applications against common vulnerabilities
- `threat-modeling` — Identify and analyze security threats

## Workflow skills (invoked as /name)

10 additional skills, one per command, live directly under `.claude/skills/<name>/SKILL.md`. Unlike the 14 knowledge skills above, these are typed explicitly as slash commands (e.g. `/architect`) rather than relied on for auto-discovery.

- `architect`, `qa-engineer`, `security-auditor`, `ui-ux-designer` — advisory, model-invocable: Claude can also reach for these on its own.
- `builder`, `swarm-plan`, `swarm-execute`, `swarm-review`, `swarm-research`, `code-check` — side-effecting, gated with `disable-model-invocation: true`: only a user typing the slash name can invoke them.

See [commands.md](commands.md) for the full command reference.

## Catalog philosophy

This framework ships only high-value, single-responsibility skills — one skill per durable workflow, not one per topic. It deliberately does **not** duplicate the model's training data: generic language and framework guidance (TypeScript idioms, React patterns, Terraform syntax, and similar) has been removed, because Claude already knows it. For version-specific or fast-moving detail, use Context7 or the official docs instead of a skill — a skill would only go stale.

Every skill's `name` and `description` is loaded into context on every session, regardless of relevance, at a cost of roughly ~100 tokens each. Claude Code caps the total listing at a small budget of the context window; exceed it and descriptions start getting dropped or truncated, silently breaking discovery for whichever skill lost the coin flip. Keeping the catalog at 14 skills means the full listing comfortably fits — no description is ever dropped from the budget.

### Adding your own project-specific skills

Add skills for the workflows that are actually specific to your project or domain — not generic language help. Each one needs a strong, third-person `description` that states what it does and when to use it, with trigger phrases up front:

```yaml
---
name: my-skill
description: Guides X. Use when the user asks to Y or mentions Z.
---
```

See [customization.md](customization.md#adding-a-skill) for the full walkthrough.

After adding several skills, run `/doctor` to confirm none of your descriptions were dropped or truncated from the listing budget — that's the first symptom of a catalog that's grown too large. `/context` shows how much of the context window the skill listing is currently consuming.

## How Skills Activate

Skill discovery is **native and model-driven** — there is no hook and no registry file. At startup, Claude Code loads every skill's `name` and `description` from its `SKILL.md` frontmatter into context. When your prompt matches what a skill's description says it does, Claude reads that skill's full `SKILL.md` body and uses it to shape its response.

This means the `description` field is the entire activation mechanism. Write it well:

- **Third person**, stating both **what the skill does** and **when to use it**.
- Put **trigger phrases first** — the words a user would actually type — so the match happens early in the description.
- Example: `"Guides REST/GraphQL/gRPC API design. Use when designing a new API, choosing between API styles, or reviewing an existing API's contract."`

Every skill's name + description is **always loaded**, regardless of whether it's relevant to the current prompt — budget roughly **~100 tokens per skill**. The full set of listings is capped at a **listing budget of ~1% of the context window**. If you add enough skills to exceed that budget, Claude Code drops or truncates descriptions to fit.

- Run `/doctor` to see which skill descriptions were dropped or truncated.
- Run `/context` to see how much of the context window the skill listing is currently consuming.
- Raise the cap with the `skillListingBudgetFraction` setting if you have many skills and need more headroom.

Caveat: on large-context models, the ~1% budget is currently computed against a ~200K-token baseline rather than the model's true context window (an upstream tracking issue) — so budget math is conservative and the effective allowance may be smaller than 1% of the real window.

### Deterministic activation (optional)

Native discovery is probabilistic — it depends on the model matching your prompt to a description. If you need guaranteed, keyword-based activation instead, see [docs/examples/skill-activation-hook.sh](examples/skill-activation-hook.sh) for an opt-in example hook (disabled by default).

## Creating Your Own

See [customization.md](customization.md#adding-a-skill).

---

[← Back to README](../README.md)
