# Evals: postmortem skill

Eval set for the `postmortem` skill. See CONTRIBUTING.md's eval-first policy
before adding or changing a skill.

## Running

Follow the same procedure as the `testing` skill's exemplar at
[.claude/skills/core-engineering/testing/evals/README.md](../../../core-engineering/testing/evals/README.md):

1. `/plugin install skill-creator@claude-plugins-official`
2. Point the plugin's eval runner at `evals.json` in this directory.
3. Run each case **twice**: once with the `postmortem` skill available, once with
   it disabled/removed — in a **fresh session** each time, not the session used to
   author the cases.
4. For `category: "negative"` cases, confirm the postmortem workflow does *not*
   fire — that's the pass condition, not a bug in the harness.

## Recording results

Same evidence policy as the `testing` exemplar: record the with-skill vs
without-skill comparison as a dated file under `scratchpad/` while iterating,
then promote a summary (sample size, task set, raw pass/fail per case, date,
model) into an `artifacts/` note before citing any improvement — per the
evidence policy in CONTRIBUTING.md. Do not assert an improvement without that
raw data attached.
