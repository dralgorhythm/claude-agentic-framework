# Releasing

## What a release is

A release is exactly four things, produced together by `scripts/release.sh`:

1. **CHANGELOG stamp** — the `## [Unreleased]` section becomes `## [X.Y.Z] - YYYY-MM-DD`, and a fresh empty `[Unreleased]` stub is re-inserted above it.
2. **Version bump** — `.claude-plugin/plugin.json` `version` is set to `X.Y.Z` (plugin users receive updates at this moment).
3. **Commit + tag** — a `release: vX.Y.Z` commit and annotated tag `vX.Y.Z`, pushed to `origin`.
4. **GitHub Release** — created from the stamped CHANGELOG section as its body.

## How to cut one

```bash
./scripts/release.sh X.Y.Z "Release title"
```

Always run with `--dry-run` first to preview the plan and release notes without changing anything:

```bash
./scripts/release.sh X.Y.Z "Release title" --dry-run
```

Preflight will refuse to run if: you're not on `main`; the working tree is dirty; `main` is behind `origin/main`; the version isn't greater than the last tag; the `[Unreleased]` section is empty; or `./scripts/check-invariants.sh` is red.

## Semver policy

- **Breaking** change → major bump, and it needs a `MIGRATION.md` section written **before** the release.
- **Additive**, backward-compatible change → minor bump.
- **Fix** with no behavior contract change → patch bump.

## What adopters experience

- **Raw drop-in**: `git pull` in your clone, then re-run `scripts/init-framework.sh` — or pin to a known-good release with `git checkout vX.Y.Z` before running it.
- **Plugin install**: `/plugin update` delivers exactly what was published at the most recent tagged release, nothing from `main` in between.

One nuance worth knowing: between releases, `.claude-plugin/plugin.json` still holds the *last released* version number, so a mid-cycle install from `main` carries the previous release's version label even though it includes newer, unreleased commits. This is deliberate — it keeps "plugin users update at release" semantics honest rather than implying continuous versioning that the plugin channel doesn't actually offer.

---

[← Back to README](../README.md)
