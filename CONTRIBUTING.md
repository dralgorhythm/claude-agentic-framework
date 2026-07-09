# Contributing

## Contribution model

This repository is a **public template repo**. Contributions here should improve the
template itself — skills, agents, hooks, rules, docs, and tooling that make sense for
any adopter, not just for one team's stack or workflow.

Project-specific customization (your tech stack, your extra skills, your house rules)
belongs in the repo you copy this template *into*, not here. See
[docs/customization.md](docs/customization.md) for the supported extension points. If
you're unsure whether a change is template-level or project-level, ask: "would most
adopters want this?" If the answer is no, it's customization, not a contribution.

## Eval-first policy

Skills are prompt-driven, not compiled — the only way to know a skill actually changes
behavior is to test it, not to read it and reason that it should work. Before adding a
new skill or materially changing an existing one:

1. **Ship ≥3 eval scenarios.** Concrete prompts with expected assertions about behavior
   (e.g. "writes a failing test before implementation," not "acts test-driven").
2. **Ship a fresh-session baseline comparison.** Run the same prompt with the skill
   available and with it removed/disabled, in a *fresh session* each time — not the
   session you used to author the skill. Authoring context leaks intent into your own
   judgment and masks gaps a fresh session would expose.
3. **If the skill is auto-invocable** (no `disable-model-invocation: true`), additionally
   ship trigger tests: prompts that should invoke the skill, and genuinely-tricky
   near-miss prompts that should **not** — not obvious non-matches, but adjacent requests
   a reasonable description could over-match on.

Use the first-party tooling for this: `/plugin install skill-creator@claude-plugins-official`.
See [.claude/skills/core-engineering/testing/evals/](.claude/skills/core-engineering/testing/evals/)
for a worked exemplar and run instructions.

## Evidence policy

Don't claim a change improves anything in README.md, docs/, or a PR description without
disclosing methodology: sample size, the task set used, and raw pass/fail (or before/after)
numbers. "Cuts errors by 40%" with no methodology is not a finding, it's a guess dressed
as a fact — and this framework has already surveyed the ecosystem for exactly that pattern.
See [artifacts/research_token_management_and_skill_design.md](artifacts/research_token_management_and_skill_design.md)
for why this matters here specifically: every clean round-number improvement claim checked
during that research failed methodology verification.

## Scope discipline

The skill catalog's size is a defended design decision, not an oversight. Every skill's
`name` and `description` loads into every session's context regardless of relevance, and
the listing budget is shared across *everything* an adopter has installed — this
framework's skills plus their own. A catalog that grows without discipline degrades
discovery for every skill in it, including ones this repo didn't add.

Before proposing a new skill:

- It needs an eval-backed case per the policy above — not "this seems useful."
- Check for description overlap against existing skills first (`docs/skills.md` has the
  full list). Overlapping descriptions cause the wrong skill to load, or the right one to
  get silently dropped from the budget.
- Prefer extending an existing skill over adding a new one if the workflows are related.

## Getting started

- Read [CLAUDE.md](CLAUDE.md) and `.claude/rules/` — they define the standards this repo
  holds itself to.
- Run `./scripts/check-invariants.sh` before opening a PR; it must exit 0.
- Follow the commit and branch conventions in `.claude/rules/core-directives.md`.
