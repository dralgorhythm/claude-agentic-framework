# Pack Discovery & Adaptation

Mechanical rules for the Propose: Instantiate phase — the pack-side counterpart to `detection.md` (that file maps signals to golden-path rows; this one maps a detected stack to a rendered skill).

## Discovery

Scan `.claude/templates/stack-packs/` for subdirectories. Each subdirectory is one pack, named after its stack (`typescript`, `python`, ...). A pack qualifies for instantiation only if Detect already found that stack's manifest/lockfile signal — the directory scan proves a pack exists, not that its stack applies here. Adding a pack is a new directory under `stack-packs/`; no code path in this skill changes.

## Adaptation Rules

- Substitute only values the fingerprint table evidences — a `yarn.lock` swaps every `pnpm` for `yarn`, cited to that file; no `yarn.lock` means no substitution.
- No signal for a given value (package manager, test runner, framework, version)? Flag it in the proposal as "no signal, exemplar default kept" — never guess.
- Preserve the exemplar's structure and line budget. Adapting is substitution, not a rewrite: don't add sections, don't pad, don't restate what the pack already links elsewhere.
- Never render a pack whose stack Detect did not find, even if the pack directory exists.

## Listing-Budget Warning

Every rendered `golden-path.skill.md` becomes a live, always-loaded skill in the adopter's own repo the moment it's committed. Flag this in the proposal so the user weighs it the same way they'd weigh adding any other skill — instantiation isn't free just because the content was pre-written.
