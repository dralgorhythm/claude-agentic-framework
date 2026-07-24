---
paths: [".claude/hooks/**", "scripts/**"]
---

# Hooks & Scripts Conventions

Scoped via `paths:` frontmatter — loads only when a file under `.claude/hooks/`
or `scripts/` is read or edited (see
[code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)),
never as part of the always-loaded rules layer. Content here is
hook/script-specific only; universal engineering rules live in
`code-quality.md` and `security.md`.

## Shell Baseline

- `#!/usr/bin/env bash` (or `#!/bin/bash` for existing hooks) with `set -u` —
  fail loudly on an unset variable instead of silently expanding to empty.
- Run `shellcheck` and `bash -n` before committing; both are CI-enforced
  (`framework-invariants.yml`'s `shellcheck` job over `.claude/hooks/*.sh` +
  `scripts/*.sh`; `check-invariants.sh`'s `hooks-valid` check runs `bash -n`
  over every shipped hook).
- Keep each hook/script to roughly ≤120 lines and commented for adaptation —
  these are illustrative references an adopter edits for their own repo, not
  a framework to extend indefinitely in place.

## Fail-Open, Visibly

Hooks are guardrails, not a security boundary — `permissions.deny` is the hard
boundary (`security.md`'s Enforcement Ladder). The house idiom for an optional
dependency is a one-line early exit:

```bash
command -v jq >/dev/null 2>&1 || exit 0
```

Guard early and exit 0 rather than let a missing optional tool fail the tool
call the hook was meant to check — a broken guardrail must never become a
broken workflow. Where the guarded behavior is more than incidental (an
entire hook's checks are skipped, not just one branch), also emit a visible
one-line degradation notice naming what's disabled — a hook that quietly does
nothing hides the gap from the person who could act on it.

## Extracting Fields Without `jq`

`jq` stays optional — no new runtime dependency. When it's unavailable,
extract a single field with a field-scoped `sed` capture; never match a raw
substring across the whole JSON payload, which both false-positives on
unrelated content and mis-parses escaped quotes. Reuse the existing idiom
(`branch-pr-discipline.sh:48`) rather than inventing a new one:

```bash
cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -n1)"
```

## Deny/Ask JSON Output Contract

A `PreToolUse` hook that wants to block or interrupt a tool call emits exactly
one JSON object on stdout:

```bash
echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"<why>\"}}"
```

`permissionDecision` is `"deny"` (block outright) or `"ask"` (prompt the
user); write nothing to stdout to allow silently. Always include a
`permissionDecisionReason` — it's the only signal the person on the other end
of a denied or ask-gated call gets for why.
