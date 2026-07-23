# Research: Stack Packs & Tailor v2

> 3-worker swarm (internal seams · scaffold prior art · skills-era delivery), 2026-07-23.
> Feeds `adr_stack_packs.md`. Raw worker reports: session records (gitignored scratchpad).

## Findings

1. **The ecosystem abandoned templating machinery.** Every 2026-era agent artifact ships concrete files, not
   placeholders: Anthropic's authoring checklist says "Examples are concrete, not abstract" and reserves rigid
   parameterization for fragile operations only; GitHub Spec Kit ships plain markdown templates agents fill in;
   awesome-copilot ships plain instruction files; shadcn/ui made "open code you copy and own" a pillar *because*
   LLMs read and adapt it. The agent-assisted-scaffolding pattern names the replacement mechanism outright:
   repository-aware generation instead of parameter filling. (HIGH — primary sources.)
2. **Heavy templating has a documented failure lineage.** Cookiecutter's jinja projects drift so badly a
   dedicated tool (cruft) exists just to diff generated repos against templates; unknown placeholders fail
   silently; Copier shifts the cost into maintainer-authored migrations. The no-engine systems (GitHub template
   repos, nix flake templates, create-vite's real-directory variants) are the legible, low-maintenance end of
   the spectrum. (HIGH.)
3. **Minimal pack content converges across ecosystems**: identity/date metadata + a few composable fragments +
   one entry-point doc + zero vendored tool internals — reference upstream mechanisms so staleness is upstream's
   problem (Renovate presets, VS Code extensions.json, devcontainer features, Actions starter workflows). (MEDIUM-HIGH.)
4. **Delivery is mechanically decided, not stylistic**: Claude Code plugins have *no template payload type* —
   only skills/agents/hooks/MCP/LSP/etc. are live-loaded, and a plugin CLAUDE.md is explicitly not project
   context. One-shot-rendered files can only come from a directory the installer copies (or a skill that
   Write-copies bundled files — indirection with no benefit here). In-repo `templates/` dir wins; plugin
   wrapping adds overhead for zero function. (HIGH — plugins-reference.)
5. **One rendered skill per pack has first-party precedent**: official best practice models a multi-domain
   capability as ONE skill + `reference/` files (zero cost until read) versus per-domain skills (each costs
   listing budget unconditionally); a ~20-skill community scaffold router is the cautionary counter-example.
   Adopter listing budget is the constraint that matters — pack-rendered skills live there, not in this repo's CI. (HIGH.)
6. **Education principles are specific**: Diátaxis — ruthlessly minimize explanation inside task material, state
   the why once near the top; README-driven — one load-bearing entry doc; Rule of Three — never parameterize a
   variation seen once; one default with an escape hatch, not an options menu. (HIGH.)
7. **Internal seams (this repo)**: tailor v1's Detect/Assess/Propose contract and tier precedence extend cleanly;
   `.claude/templates/` is recursively installer-copied (a new `stack-packs/` subdir reaches adopters with zero
   installer changes, scrub-safe); repo template convention is bracketed-placeholder-or-concrete — no handlebars
   anywhere; tech-strategy.md tables are the single source for *choices*, `pre-commit-verification.sh` already
   detects stacks, and quality gates are defined once in code-quality.md — a pack must operationalize, never
   restate, all three. Rendered skills must clear desc-style/spec-portability shape by construction, and their
   triggers must stay clear of `dependency-upgrade`, `land-the-plane`, `review-steering`. (HIGH — file-anchored.)

## What elegance looks like (synthesis)

Concrete runnable files, GitHub-legible with zero tooling; one README per pack read first by human and agent
alike; smallest working set, layered by composition; the why stated once, then the artifact; the LLM treated as
a literate engineer that substitutes names/paths/versions itself; no drift machinery because there is nothing
to drift — an exemplar is read once and adapted.

## Confidence & gaps

Concrete-over-template convergence, plugin payload constraint, listing-budget precedent: HIGH (primary sources,
quotes verified by workers 2026-07-23). Minimal-content convergence: MEDIUM-HIGH (one Actions-starter claim
unverified). No direct evidence found on nx/moon exclusion policy (nearest: moon's `--minimal` flag). Sources
indexed in the worker reports; key anchors: platform.claude.com skill best-practices, code.claude.com
plugins-reference, anthropics/skills, ui.shadcn.com/docs, cruft.github.io, diataxis.fr, containers.dev.
