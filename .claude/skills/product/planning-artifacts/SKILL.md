---
name: planning-artifacts
description: Produces this framework's planning artifacts — PR-FAQ (working-backwards vision), PRD (requirements), and execution roadmap — from their bundled templates. Use when writing or updating a PR-FAQ, PRD, product requirements, or delivery roadmap, or when the planning flow calls for one.
---

# Planning Artifacts

Three product-planning artifacts, one skill: PR-FAQ, PRD, and execution roadmap. Each has its own template in `resources/` — use this skill to pick the right artifact and fill it in, not to relearn its structure from scratch.

## Which Artifact, When

| Artifact | Gate (see `swarm-plan`'s Artifact Requirements tiers) | Answers |
|----------|--------------------------------------------------------|---------|
| PR-FAQ | Vision gate — Large Feature (2+ weeks) | Is this worth building, and for whom? |
| PRD | Requirements gate — Medium Feature (1-2 weeks) and up | What exactly are we building, and what's out? |
| Roadmap | Phased delivery plan — any multi-phase rollout | In what order, by whom, with what checkpoints? |

A Large Feature typically needs all three, in that order: PR-FAQ validates the vision before the PRD locks requirements, and the roadmap sequences delivery once requirements are stable. A Medium Feature usually starts at PRD. Don't produce an artifact the tier doesn't call for.

## PR-FAQ Essentials

Working-backwards discipline: write the press release first, as if the product already shipped — present tense, customer benefit, one concrete headline. Only after the press release reads true do you write the FAQ. Internal FAQ answers business-justification questions (why build it, market size, risk); External FAQ answers customer questions (what is it, cost, how to start). Make both adversarial: write the questions a skeptical stakeholder or customer would actually ask, not the ones that flatter the pitch.

## PRD Essentials

User stories in `As a [role], I want [feature], so that [benefit]` form, each with Given/When/Then acceptance criteria — a story without acceptance criteria isn't testable, and untestable isn't done. State Out of Scope as explicitly as In Scope; unstated scope is the most common source of rework. Success metrics must be measurable (a number and a target), not adjectives like "fast" or "intuitive."

## Roadmap Essentials

Break work into phases, each with an owner, a milestone or go/no-go gate, and explicit dependencies on prior phases — dependency ordering is what turns a task list into a critical path. Gates should be criteria you can check objectively (tests passing, security review approved), not calendar dates alone.

## Output Naming

Save to `./artifacts/` per CLAUDE.md's artifact table:

| Artifact | Filename |
|----------|----------|
| PR-FAQ | `pr_faq_[feature].md` |
| PRD | `prd_[feature].md` |
| Roadmap | `roadmap_[project].md` |

## Resources

- [PR-FAQ Template](./resources/pr-faq.template.md)
- [PRD Template](./resources/prd.template.md)
- [Execution Roadmap Template](./resources/execution-roadmap.template.md)
