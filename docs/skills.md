# Skills

Skills are structured workflows that Claude suggests based on what you're doing.

## How It Works

You don't invoke skills directly. Just describe what you need:

```
"We need to record the decision about our database choice"
```

Claude sees relevant skills suggested (like `writing-adrs`) and uses them to give you a better response.

## Available Skills

6 library skills across 5 categories. (Generic-knowledge skills were retired in the 2026-07 rationalization after base-model evals showed the model produces that content unaided — see `artifacts/evals_catalog_rationalization.md` and MIGRATION.md for where each one's guidance lives now.)

### Architecture
- `designing-systems` — Produce this framework's ADR and system-design artifacts with trade-off analysis
- `writing-adrs` — Document architectural decisions

### Core Engineering
- `testing` — Verification-loop-first testing discipline: red-green, regression per bugfix, deterministic suites

### Operations
- `swarm-coordination` — Coordinate multi-agent swarm workflows

### Product
- `planning-artifacts` — PR-FAQ, PRD, and execution-roadmap artifacts from bundled templates

### Security
- `threat-modeling` — STRIDE threat-analysis procedure with Grep-backed data-flow tracing

## Workflow skills (invoked as /name)

10 additional skills, one per command, live directly under `.claude/skills/<name>/SKILL.md`. Unlike the 6 library skills above, these are typed explicitly as slash commands (e.g. `/architect`) rather than relied on for auto-discovery.

- `architect`, `builder`, `qa-engineer`, `security-auditor`, `ui-ux-designer`, `code-check`, `swarm-plan`, `swarm-execute`, `swarm-review`, `swarm-research` — all gated with `disable-model-invocation: true`: only a user typing the slash name can invoke them. The four role skills (`architect`, `qa-engineer`, `security-auditor`, `ui-ux-designer`) are user-invoked entry points: `architect` delegates methodology to the always-on `designing-systems` and `writing-adrs` library skills, while the others carry their procedures inline (accessibility gates in `qa-engineer`/`ui-ux-designer`) or lean on the always-loaded rules (`security.md`, `debugging-protocol.md`) — nothing auto-discovery needed is hidden behind the gate.

See [commands.md](commands.md) for the full command reference.

## Catalog philosophy

This framework ships only high-value, single-responsibility skills — one skill per durable workflow, not one per topic. It deliberately does **not** duplicate the model's training data: generic language and framework guidance (TypeScript idioms, React patterns, Terraform syntax, and similar) has been removed, because Claude already knows it. For version-specific or fast-moving detail, use Context7 or the official docs instead of a skill — a skill would only go stale.

Every skill's `name` and `description` is loaded into context on every session, regardless of relevance, at a cost of roughly ~100 tokens each. Claude Code caps the total listing at a small budget of the context window; exceed it and descriptions start getting dropped or truncated, silently breaking discovery for whichever skill lost the coin flip. Keeping the catalog this small — 6 ungated library skills after the 2026-07 rationalization — means the full listing comfortably fits with headroom for the adopter's own skills; no description is ever dropped from the budget.

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

## Portfolio doctrine

The catalog philosophy above is the intuition; this is the actual acceptance test. It's the bar every skill in this repo — existing or proposed — is measured against, not just new additions.

### The inclusion bar: Useful × Novel × Standard

A skill earns its place only if all three hold:

- **Useful** — eval-backed lift on an observed failure mode, verified against a fresh-session baseline. "This seems useful" is not evidence.
- **Novel** — passes the redundancy test below, and no first-party Claude Code built-in or bundled plugin already owns the same trigger, and its description doesn't collide with one that does.
- **Standard** — spec-portable: clean frontmatter, `name` matches its directory, core value expressed in prose/scripts rather than Claude-only machinery.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for how each axis is checked in practice.

### Capability uplift vs. encoded preference

Anthropic's own skill-authoring guidance names exactly two legitimate reasons for a skill to exist: **capability uplift** (something the base model can't do reliably on its own) and **encoded preference** (a sequencing of things the model already can do, done the specific way this repo wants it done). Restating what the model already knows — language syntax, framework idioms, textbook definitions — is the named anti-pattern, not a third category.

The redundancy test operationalizes this: run the skill's own eval scenarios against the bare base model with the skill unloaded. If it passes anyway, the skill isn't adding capability — retire it.

Encoded-preference skills clear this test by construction — the model could improvise *a* workflow; the point is it wouldn't improvise *this one* — but they still owe Useful and Novel like everything else.

### Four delivery tiers

Not everything belongs in the always-loaded listing:

- **Ungated core** — encoded-preference skills that must auto-trigger; the only tier every adopter's context budget pays for.
- **Gated workflows** (`disable-model-invocation: true`) — slash-invoked orchestration and role entry points; zero listing cost.
- **Opt-in packs** *(roadmap)* — domain-specific bundles distributed through the plugin marketplace; adopters pay only if they install them.
- **Generated by tailor** *(roadmap)* — stack- and policy-specific skills manufactured into an adopter's own repo from their `tech-strategy.md`; never listed here at all.

### The depreciation clock

Capability uplift has a shelf life; encoded preference doesn't. Uplift-flavored skills carry a standing re-eval expectation: on a periodic cadence — at minimum, each model-generation bump — rerun the skill's evals against the then-current bare base model. A pass means the model caught up, not that the skill was wrong; it triggers a retirement PR citing the run, per CONTRIBUTING.md's retirement policy.

## How Skills Activate

Skill discovery is **native and model-driven** — there is no hook and no registry file. At startup, Claude Code loads every skill's `name` and `description` from its `SKILL.md` frontmatter into context. When your prompt matches what a skill's description says it does, Claude reads that skill's full `SKILL.md` body and uses it to shape its response.

This means the `description` field is the entire activation mechanism. Write it well:

- **Third person**, stating both **what the skill does** and **when to use it**.
- Put **trigger phrases first** — the words a user would actually type — so the match happens early in the description.
- Example: `"Guides REST/GraphQL/gRPC API design. Use when designing a new API, choosing between API styles, or reviewing an existing API's contract."`

Every skill's name + description is **always loaded**, regardless of whether it's relevant to the current prompt — budget roughly **~100 tokens per skill**. The full set of listings is capped at a **listing budget of ~1% of the context window**. If you add enough skills to exceed that budget, Claude Code drops or truncates descriptions to fit.

Measured 2026-07 for this repo: the 10 workflow skills carry `disable-model-invocation: true` and cost nothing in the listing until invoked, leaving 6 ungated library skills at roughly **~0.6k tokens** of always-loaded listing — against a **~2k-token budget on a 200K-context session** (**~10k on a 1M-context session**; state whichever denominator your session actually uses). Both figures move as the catalog or platform changes — treat them as a snapshot, not a guarantee.

- Run `/doctor` to see which skill descriptions were dropped or truncated.
- Run `/context` to see how much of the context window the skill listing is currently consuming.
- Raise the cap with the `skillListingBudgetFraction` setting if you have many skills and need more headroom. The catalog's budget headroom is enforced in CI as a static character-count proxy (`scripts/check-invariants.sh` desc-budget — it sums all 16 skill descriptions, gated and ungated, currently ~2.7k chars against a 6,000-char budget; the always-loaded listing is just the 6 ungated descriptions, ~1.3k chars); run `/doctor` and `/context` in a live session for the authoritative measurement on your setup.

Caveat: on large-context models, the ~1% budget is currently computed against a ~200K-token baseline rather than the model's true context window (an upstream tracking issue) — so budget math is conservative and the effective allowance may be smaller than 1% of the real window.

### Deterministic activation (optional)

Native discovery is probabilistic — it depends on the model matching your prompt to a description. If you need guaranteed, keyword-based activation instead, see [docs/examples/skill-activation-hook.sh](examples/skill-activation-hook.sh) for an opt-in example hook (disabled by default).

## Creating Your Own

See [customization.md](customization.md#adding-a-skill).

## Evaluating skills

Skills are prompt-driven, not compiled — the only way to know one actually changes
behavior is to test it. Before shipping a new skill or a material change to an existing
one, see [.claude/skills/core-engineering/testing/evals/](../.claude/skills/core-engineering/testing/evals/)
for a worked exemplar (eval scenarios + fresh-session baseline comparison) and
[CONTRIBUTING.md](../CONTRIBUTING.md) for the eval-first policy this repo holds itself to.

---

[← Back to README](../README.md)
