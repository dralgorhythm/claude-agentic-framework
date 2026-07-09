# Plan: KISS Release Process

- **Date:** 2026-07-09 · **Scope:** Small (1 day) · **Reversibility:** Two-way door (plan artifact only; no ADR needed)
- **Goal:** One obvious, boring way to cut a release — matching the repo's existing habit (git tag + GitHub Release) — with zero speculative machinery.
- **Grounding:** release-surface audit + adopter-UX walkthrough (2 recon agents, 2026-07-09); historical releases v2.0.0–v2.0.2 inspected via `gh`.

## 0. Prerequisite discovered during planning (do FIRST)

**The v3 stack never reached `main`.** PRs #9–#17 were merged into each other's feature branches (bases were never retargeted because branches weren't deleted at merge). Only #8 landed. Corrective **[PR #18]** (branch `feat/pr8-ci-invariants`, byte-identical to the verified stack tip) is open → **merge it, then delete all `feat/pr*` + `claude/*` feature branches** (this prevents the trap recurring; enable GitHub's "Automatically delete head branches" repo setting).
**AC:** `git diff origin/main <stack-tip>` → empty; CI `framework-invariants` green on main; stale branches gone.

## 1. Decision record (what a release IS)

**A release = one command: `scripts/release.sh X.Y.Z`**, which produces atomically:
1. CHANGELOG's `Unreleased` section stamped `## [X.Y.Z] - YYYY-MM-DD`, with a fresh empty `## [Unreleased]` stub re-inserted above it (so the next PR has somewhere to append)
2. `.claude-plugin/plugin.json` `version` set to `X.Y.Z` — this is the **plugin delivery trigger**: `/plugin update` picks up new content exactly when this changes
3. One commit `release: vX.Y.Z` on `main`, an **annotated tag** `vX.Y.Z`, both pushed
4. A **GitHub Release** titled `vX.Y.Z — <short title>` with the stamped CHANGELOG section as its body (restoring the rich v2.0.0 style; the empty v2.0.1/v2.0.2 bodies were drift, not convention) + a `**Full Changelog**: compare/vPREV...vX.Y.Z` link

**DRY resolution — version sources go from 3 → 2, each with one job:**
- ~~`VERSION` file~~ → **deleted** (audited: zero consumers — not CI, not init-framework, not docs)
- `plugin.json` `version` = the machine version (drives plugin updates)
- `CHANGELOG.md` headings = the human record
- The release script is the **single writer** of both; its preflight is the consistency check

**Policy (YAGNI applied):**
- No `-dev` suffixes: `plugin.json` holds the last released version between releases. Mid-cycle installs from `main` carry the previous release's label — harmless, documented in `docs/releasing.md`, not in adopter docs.
- No release GitHub Action, no changelog generators, no release-please, no version-consistency check in CI (CHANGELOG is legitimately "Unreleased" between releases, so a CI check would be perpetually vacuous or force per-PR bumps — the check belongs in the release script's preflight, the only moment the invariant exists).
- `marketplace.json` is a catalog pointer with no version field — **never touched** by releases (audited).
- `main` is always releasable (framework-invariants CI is the gate; the release script re-runs it in preflight as belt-and-braces).

## 2. Tasks

### R1 — `scripts/release.sh` (~80 lines, bash, same conventions as sibling scripts)
**Preflight (all hard-fail with a one-line reason):** on `main` + clean tree + up-to-date with origin; `X.Y.Z` is valid semver and > latest `v*` tag; CHANGELOG has an `Unreleased` section with content; `gh auth status` OK; `./scripts/check-invariants.sh` green.
**Steps:** stamp CHANGELOG (rename `## [X.Y.Z·or·Unreleased] - Unreleased` → `## [X.Y.Z] - $(date +%F)`; **delete the trailer HTML comment from inside the section** — audit found it sits mid-body between `### Changed` and `### Fixed`; re-insert fresh `## [Unreleased]` stub + trailer comment above); set `plugin.json` version (jq or python3, preserving formatting); `git commit` → `git tag -a vX.Y.Z -m "vX.Y.Z"` → `git push origin main vX.Y.Z`; extract the stamped section body (awk from its heading to next `## [` or EOF, HTML comments stripped) → `gh release create vX.Y.Z --title "vX.Y.Z — <prompted-or-arg title>" --notes-file -` + append the Full-Changelog compare link.
**AC:** `bash -n` clean; a dry-run mode (`--dry-run` prints what would happen, changes nothing — the ONLY flag; no other options, KISS); running against a scratch clone produces tag+release+bump correctly; preflight rejects: dirty tree, non-main branch, version ≤ last tag, missing Unreleased content.

### R2 — Delete `VERSION` + CHANGELOG normalization
Delete `VERSION`. Normalize the current CHANGELOG heading `## [3.0.0] - Unreleased` → `## [Unreleased]` (the script stamps the number at release time — removes the premature version commitment; Keep-a-Changelog canonical form) and reorder subsections to canonical order (Breaking → Added → Changed → Removed → Fixed) while moving the trailer comment to the section top. Update `MIGRATION.md:3` "latest: v2.0.2" → "the v2.x line" (audit: de-brittles the prose so releases never need to edit it).
**AC:** `git grep -n "3.0.0-dev"` → 0; no `VERSION` file; invariants still 14/14 (audited: no coupling).

### R3 — Docs: `docs/releasing.md` + the 8 adopter-UX one-liners
**New `docs/releasing.md`** (~40 lines, maintainer-facing, following docs/ kebab-case one-topic convention): what a release is (the 4 artifacts), `./scripts/release.sh X.Y.Z [--dry-run]`, semver policy (breaking→major, additive→minor, fix→patch; MIGRATION.md gets a section for anything breaking *before* the release), the mid-cycle version-label nuance, and "main is always releasable."
**Adopter-UX one-liners (from the walkthrough — file:line anchored):**
1. README:26 — upgrades: "`git pull` your clone, then re-run the script"
2. README:~15 + getting-started:~9 — pinning: "`git checkout vX.Y.Z` before running the script"
3. README docs-index — add `CHANGELOG.md` + `MIGRATION.md` (+ `docs/releasing.md`) lines
4. getting-started Next Steps — add "check CHANGELOG/MIGRATION when upgrading"
5. README:~26 — discovery: point at the GitHub Releases page
6. README plugin section — "plugin content updates at each tagged release; run `/plugin update`"
7. getting-started plugin section — mirror #6 (one sentence)
8. Both plugin sections — "after `/plugin update`, check MIGRATION.md for breaking changes"
**AC:** every walkthrough gap closed at its cited location; no new machinery; README docs-index links resolve.

### R4 — Cut **v3.0.0** with the new process (dogfood = the real test)
After R1–R3 merge and PR #18 has landed: run `./scripts/release.sh 3.0.0` (title suggestion: "v3.0.0 — Zero-install modernization: native discovery, lean catalog, hardened guardrails"). Verify: tag exists; GitHub Release body = CHANGELOG section; `/plugin update` semantics (plugin.json = 3.0.0); CHANGELOG left with a fresh `[Unreleased]` stub; MIGRATION accurate.
**AC:** `gh release view v3.0.0` shows rich notes; `git tag --contains` sane; invariants green on the release commit.

## 3. Dependency graph
```
PR #18 merge + branch deletion (user)
        │
R1 release.sh ──┐
R2 VERSION/CHANGELOG ──┤→ one PR ("release process") → R4 cut v3.0.0
R3 docs ──┘
```
R1–R3 are one small PR (they're interdependent and tiny). R4 is the first use, run on `main` after merge.

## 4. Explicit YAGNI rejections (so nobody re-adds them)
Release GitHub Action · changelog generation from commits · release-please/semantic-release · version-consistency CI check · `-dev` prerelease channel · marketplace versioning · signed tags/artifacts · release branches. Any of these can be added later if a real need appears; none has one today.

## 5. Handoff
To `/swarm-execute`: this artifact + native tasks R1–R4. Prerequisite gate: PR #18 merged by the owner.
