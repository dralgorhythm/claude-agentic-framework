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
- Check for first-party collision before proposing anything: run `/skills` to see what's
  already bundled or plugin-installed in your session, and check
  [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
  and [anthropics/skills](https://github.com/anthropics/skills) for trigger- or name-overlap.
  A skill that restates a first-party built-in or plugin isn't novel, no matter how useful it is.
- Prefer extending an existing skill over adding a new one if the workflows are related.

## Spec portability

`.claude/skills/` isn't Claude-only anymore: skills are read in place by other tools
through the Agent Skills standard, not just Claude Code. That constrains what belongs
in `SKILL.md` frontmatter.

The spec defines exactly six fields: `name` (must equal the parent directory),
`description`, and the optional `license`, `compatibility`, `metadata`, and
`allowed-tools`. Everything else is unrecognized by non-Claude readers. This repo
maintains one deliberate, small allowlist on top of the spec for fields Claude Code
actually functions on — currently `argument-hint` and `disable-model-invocation` —
rather than letting arbitrary keys accumulate. A new field needs one of two
justifications: Claude Code reads it directly (add it to the allowlist, deliberately),
or it's genuinely spec-portable metadata (nest it under `metadata`).

YAML values that could parse as something other than a plain string — most commonly
one starting with `[` or containing `: ` — must be quoted. PR #24 is the precedent: an
unquoted `argument-hint` value broke skill loading on Copilot CLI ≥1.0.65, because its
YAML parser read the value as a list where Claude Code's own parser didn't. Quote
defensively; don't assume your own client is the most permissive one that will ever
read the file.

## Retirement policy

Every skill records which of the two legitimate reasons it exists for — capability
uplift or encoded preference — see `docs/skills.md`'s Portfolio doctrine section for
the taxonomy. Uplift depreciates as models improve; encoded preference doesn't, but
only as long as the workflow it encodes stays current.

That's why uplift-flavored skills carry a standing re-eval expectation instead of an
indefinite one. Periodically — at minimum, each model-generation bump — rerun the
skill's own eval scenarios against the bare base model with the skill unloaded. If it
passes unaided, that's the redundancy test from the eval-first policy catching up with
reality, not a flaw in the skill: open a retirement PR citing the run, the same way
you'd cite evidence to add a skill in the first place.

## Standing self-improvement loop

This is the loop the eval-first and retirement policies above feed into, not a separate
program: **capture** — a mid-session correction that contradicts standing guidance lands
in `scratchpad/corrections.log` (`core-directives.md`'s Correction Capture convention);
**escalate** — `land-the-plane`'s retro step maps each entry to the strongest enforcement
rung it can support (rule edit / skill edit / new hook / CI check); **verify** — promoted
skills go through the eval-first policy above, promoted hooks/CI checks get a harness case
(`scripts/hook-tests.d/`) that demonstrates the failure they now block; **re-audit** — at
each model-generation bump, alongside the retirement re-evals above, re-run the
failure-taxonomy coverage audit from `artifacts/research_ai_coding_frustrations.md` against
the then-current framework and diff against its coverage matrix. This is how the framework
compounds instead of re-discovering the same failure twice.

## Getting started

- Read [CLAUDE.md](CLAUDE.md) and `.claude/rules/` — they define the standards this repo
  holds itself to.
- Run `./scripts/check-invariants.sh` before opening a PR; it must exit 0.
- Follow the commit and branch conventions in `.claude/rules/core-directives.md`.
