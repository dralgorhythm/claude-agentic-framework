---
name: swarm-research
description: Coordinate parallel research workers to investigate a topic deeply and synthesize citation-backed findings — a user-invoked Research Orchestrator workflow.
argument-hint: [research-topic-or-question]
disable-model-invocation: true
---

# Research Orchestrator

Coordinate parallel research workers to investigate topics deeply and synthesize their findings into structured, citation-backed reports.

## MCP Tools

**Context7** (library/framework documentation): Verify current API patterns and version-specific behavior; cross-reference claims about libraries against official docs.

**Sequential Thinking** (synthesis and analysis): Evaluate conflicting findings across workers; identify patterns and gaps; structure synthesis reports.

## Research Workflow

1. **Scope** — Read the input and identify distinct research tracks
2. **Decompose** — Break scope into independent assignments, one per worker (see Scope Splitting)
3. **Prepare** — Create output file paths for each worker
4. **Dispatch** — Launch worker-research agents in parallel (up to 8 concurrent)
5. **Collect** — Read all worker outputs when complete
6. **Critique** — Apply cross-checking protocol across outputs
7. **Synthesize** — Produce deliverables appropriate to scope (see Deliverable Structure)
8. **Deliver** — Write outputs to correct paths

## Worker Dispatch

| Task Type | Worker | Max Concurrent |
|-----------|--------|----------------|
| Deep research | worker-research | Up to 8 |
| Quick fact-check | worker-explorer | Up to 8 |
| Architecture/design research | worker-architect | 1-2 |

Model tiers are pinned in each agent's frontmatter (`.claude/agents/`) — that is the single source of truth.

**Rules**:
- Each worker gets exactly one topic or sub-topic — never overload a single worker
- Workers write to assigned output files; orchestrator reads and synthesizes

### Scope Splitting

- If a prompt file has more than 150 lines or 6+ detailed sections, split into multiple workers (one per section or group of related sections)
- If a section specifies more than 20 discrete data points, assign it a dedicated worker
- When splitting, each worker receives the prompt's Context block + Output Format + their assigned section(s) only

### Dispatch Modes

**Mode 1: Template-Based** (for ad-hoc topics the orchestrator decomposes dynamically)

Include in every worker prompt: the specific research question, output file path, scope constraints (what NOT to research), and current date. Workers follow their full methodology from their agent instructions.

**Mode 2: Pass-Through** (for pre-authored prompts with detailed Research Scope and Output Format sections)

Pass the prompt verbatim — do NOT restructure into template format. Include only: output file path, current date, and a delimiter marking the prompt start/end. The specificity of the pre-authored prompt IS the value.

### Batch Ordering for Dependent Prompts

When dispatching a suite with cross-domain dependencies, order batches:

1. **Foundation batch** — Core domains that downstream prompts reference
2. **Domain-specific batch** — Independent category-specific topics
3. **Applied batch** — Scenarios that build on foundation knowledge
4. **Meta/integration batch** — Cross-domain synthesis prompts (always last)

## Output Paths

| Output Type | Path | When |
|-------------|------|------|
| Working notes | `scratchpad/research-<slug>.md` | Exploratory research, spikes, investigations |
| Cross-domain reports | `scratchpad/research-consistency-report-<slug>.md` | Post-collection cross-checking output |
| Durable artifacts | `artifacts/research_<domain>.md` | Architectural, strategic, or reference research |

## Cross-Checking Protocol

After collecting all worker outputs, apply cross-checking adapted to scope:

- **Independent topics**: Minimal — focus on terminology normalization and source diversity
- **Overlapping topics**: Reconcile specific figures (numbers, dates, thresholds) where two workers cite different values for the same thing; verify rule trigger conditions and thresholds match across outputs; spot-check domain-specific entity claims; normalize terminology
- **All research**: Verify high-impact claims appear in at least two independent worker outputs; dispatch follow-up workers for thin or low-confidence sub-topics; flag topics where all findings come from a single source type

## Deliverable Structure

### Single/Few Topics (1-8 workers)

Per-worker output files + a single synthesis report with: Key Findings, domain sections (merged/deduplicated findings), Cross-Cutting Themes, Contradictions & Unresolved Questions, Confidence Summary, Gaps & Follow-Up, and Source Index.

### Large Topic Suite (9+ workers)

Per-prompt outputs ARE the reference articles — do NOT attempt a single synthesis report. Produce instead:

1. **Per-prompt outputs** (N files) — Each worker's research article at the assigned path
2. **Cross-domain consistency report** (1 file) — Quantitative reconciliation, rule consistency, terminology normalization, coverage gaps, confidence distribution
3. **Domain cluster syntheses** (optional, 3-5 files) — Higher-level synthesis by domain cluster

## Quality Gates

Before declaring research complete:

- [ ] All dispatched workers have returned outputs
- [ ] Cross-checking protocol has been applied (adapted to scope)
- [ ] Contradictions are either resolved or explicitly flagged
- [ ] No high-impact claim rests on a single uncorroborated source
- [ ] Coverage gaps have been addressed or documented
- [ ] Deliverables are written to the correct output paths
- [ ] Source index is complete and deduplicated

## Scope Calibration

| Research Scope | Workers | Output |
|----------------|---------|--------|
| Single focused topic | 1-2 | `scratchpad/research-<topic>.md` |
| Multi-topic brief | 3-5 | `scratchpad/research-synthesis-<name>.md` |
| Comprehensive domain | 6-8 | `artifacts/research_<domain>.md` |
| Full topic suite (15+) | 8 per batch | Per-prompt outputs + consistency report |

## Task Tracking

Research tracking uses the orchestrator's native task list (`TaskCreate`/`TaskUpdate`) — workers do not touch it directly.

## Constraints

- Workers must not edit codebase files — research output only
- Every claim in the synthesis must trace to a worker output with source
- Do not synthesize by simply concatenating worker outputs — add analytical value
- Flag topics where the orchestrator's own judgment fills gaps (distinguish from sourced findings)
- Prefer dispatching a follow-up worker over guessing to fill a gap
- Respect the max concurrent worker limit (8)
- Worker model tiers are pinned in agent frontmatter; do not override them per-dispatch

## Error Handling

- **Empty/error output**: Check if topic was too broad (split and redispatch); try alternative search terms if sources are paywalled; document the gap rather than fabricating content
- **Contradicting workers**: Launch a fact-check worker-explorer targeting the specific contradiction; present both findings with evidence quality; mark as UNRESOLVED if neither can be definitively verified

## Related Skills

`swarm-coordination`

## Handoff

- To `/swarm-execute`: when research produces actionable implementation tasks
- To `/swarm-plan`: when research reveals scope or architecture decisions needed
- To `/swarm-review`: when research findings inform a code review
- From `/swarm-plan`: when planning identifies knowledge gaps requiring investigation
