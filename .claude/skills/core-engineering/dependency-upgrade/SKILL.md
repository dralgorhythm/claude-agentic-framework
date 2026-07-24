---
name: dependency-upgrade
description: Sequences safe dependency upgrades — verified pins, staged rollout, changelog gates. Use when upgrading or bumping a dependency, reviewing a Dependabot or Renovate PR, resolving a lockfile conflict, applying a CVE-driven update, or pinning a GitHub Action or git tag.
metadata:
  category: encoded-preference
---

# Dependency Upgrade

A version string is a claim, not a fact — verify it before you pin it. Isolate majors so a bad one is a one-line revert. Read the changelog before the diff, not after something breaks.

A brand-new dependency's registry-existence check is `builder`'s Hallucination Defense step, not this skill's — this protocol begins once the dependency is already in the manifest and due for a version change.

## Order of Operations

Work the queue in this order, not commit-arrival order:

1. **Security advisories first.** A CVE fix jumps ahead of routine bumps already in flight — patch, then resume the queue.
2. **Dev-dependencies before runtime dependencies.** Lower blast radius, cheaper to revert, and they exercise the upgrade workflow before it touches anything user-facing.
3. **Minors: batch per ecosystem.** One commit per ecosystem's batch of minor/patch bumps — they're supposed to be backward compatible.
4. **Majors: ONE AT A TIME.** Each major version bump gets its own commit and its own full gate run. Never combine two majors in one change — if the gate fails, you won't know which one broke it.

## Per-Upgrade Protocol

Run every step, in order, for every upgrade. Urgency (CVE) changes queue position, never skips a step.

1. **Read the changelog / breaking notes for the target version before touching a manifest.** This is a gate, not a courtesy.
2. **Verify the target version or tag exists upstream. Never trust a version string** typed from memory, a doc, or a bot's PR title.
   - Git refs (GitHub Actions, git dependencies): `git ls-remote --tags <repo-url>` and confirm the exact tag string.
   - Registry packages: check the registry directly (`npm view <pkg> versions`, `pip index versions <pkg>`, etc.).
   - For GitHub Actions, prefer resolving the verified tag to its full 40-char commit SHA and pinning that, with
     the version as a trailing comment (`uses: owner/action@<sha>  # vX.Y.Z`) — tags are mutable and can be
     retargeted upstream; a SHA cannot. Tag verification still applies to what the SHA was resolved from.
   - **Lesson from this repo**: a CI workflow once pinned `aquasecurity/trivy-action@0.28.0` — the real tag was `v0.28.0`. Offline/text review graded the missing `v` a style nit ("should SHA-pin"); only a live run failing with "unable to resolve action" caught that the ref didn't exist at all. Text review can't catch this — network verification can.
3. **For composite/meta packages, inspect their own internal pins.** A pin at the top level is not a pin all the way down.
   - Read the action's `action.yml` (or the package's manifest) for dependencies it resolves at run/install time; prefer releases that SHA-pin their own internals.
   - **Lesson from this repo**: `aquasecurity/trivy-action@v0.28.0` SHA-pinned itself but internally depended on `aquasecurity/setup-trivy@v0.2.1` — a tag aquasecurity later deleted upstream. The job broke at action-resolution time in CI, months after the pin landed clean. The fix was `v0.36.0`, a release that SHA-pins its own `setup-trivy` dependency (see `.github/workflows/framework-invariants.yml`). Same rule for anything that resolves further dependencies at run/install time: composite Actions, lockfile-less installers, `go install`'d tools.
4. **Regenerate the lockfile with the ecosystem's own manager — never hand-edit one:**
   - TypeScript/JavaScript: `pnpm install`
   - Python: `uv lock`
   - Go: `go mod tidy`
   - Rust: `cargo update`
5. **Run the full quality gate suite** — tests, linter, type checker, build — not just the touched package's own tests.
6. **If anything fails, root-cause it before proceeding.** Never stack a second upgrade on top of an unexplained gate failure; you lose the ability to tell which change caused which break.

## Regression and Rollback

- Add a regression test for any behavior the upgrade changed — a new default, a changed error type, a removed field — the same discipline as a bug fix.
- Rollback unit is one upgrade commit (`git revert <sha>`). This is why majors stay isolated: reverting a single-package commit is clean; reverting a batched commit means re-diffing which of several packages actually caused the regression.

## Verify the Claims, Don't Just Trust the Build

- After upgrading, grep the codebase for any API the breaking notes list as removed, renamed, or deprecated. Don't rely on the build or type-check alone — types and tests don't reliably cover dynamic paths (string-keyed access, reflection, config-driven wiring, optional peer plugins).
- Re-verify the original claims after any late fix round on the same dependency — a follow-up patch, a second review pass. Don't assume the first changelog read still holds. This repo's trivy-action pin needed a second fix after the first was believed complete; re-checking after the fact is what would have caught the internal-pin issue sooner.

## Reviewing Dependabot / Renovate PRs

- Treat reviewing a bot-opened PR as an upgrade decision, not a rubber stamp — the full protocol above applies to it too.
- Read the linked changelog/release notes before approving, especially for majors.
- Verify the bot's target ref actually exists and, for composite/meta packages, that its own internal pins are sound — the bot does not check either for you.
- Batch bot PRs the same way as manual ones: minors within one ecosystem can merge together; majors get their own merge and their own gate run.

## CVE-Driven Updates

- A CVE fix skips the batching queue — patch immediately, don't wait for the next scheduled batch.
- Urgency reorders priority; it does not waive verification. Still run the full per-upgrade protocol: changelog, tag verification, lockfile regen, gates.
