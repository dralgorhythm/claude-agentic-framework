# Evals: testing skill

Exemplar eval set for the `testing` skill. See CONTRIBUTING.md's eval-first policy
before adding or changing a skill.

## Running

1. `/plugin install skill-creator@claude-plugins-official`
2. Point the plugin's eval runner at `evals.json` in this directory.
3. Run each case **twice**: once with the `testing` skill available, once with it
   disabled/removed — in a **fresh session** each time. Do not reuse the session you
   used to author the eval cases; authoring context masks the gaps a fresh session
   would expose.
4. For `category: "negative"` cases, confirm the skill's methodology content does
   *not* fire — that's the pass condition, not a bug in the harness.

## Recording results

Record the with-skill vs without-skill comparison as a dated file under
`scratchpad/` while iterating, then promote a summary (sample size, task set,
raw pass/fail per case, date, model) into an `artifacts/` note before citing any
improvement in README.md or docs — per the evidence policy in CONTRIBUTING.md.
Do not assert an improvement without that raw data attached.
