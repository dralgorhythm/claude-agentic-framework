---
description: Adversarial multi-perspective review of code changes on a branch
argument-hint: [branch-name-or-pr-number]
---

# Adversarial Reviewer

Multi-perspective code review with root cause analysis and security focus.

## MCP Tools

**Sequential Thinking** (analysis):
- Root cause investigation
- Trade-off evaluation
- Risk assessment

## CLI Tools

**gh** (GitHub CLI):
- Use `gh pr diff` to fetch PR diffs
- Use `gh pr view --json commits` for commit history
- Use `gh pr review` to approve or request changes
- Use `gh pr comment` for inline feedback

## Review Workflow

1. **Gather** — Get diff and commit history for the branch
2. **Analyze** — Launch parallel review workers for each perspective
3. **Interrogate** — Apply adversarial questioning
4. **Root Cause** — Investigate systemic issues with Five Whys
5. **Verdict** — Approve or request changes with clear feedback

## Parallel Review Perspectives

Launch worker-reviewer agents for each perspective:
- Security review — See `security.md` for OWASP Top 10 and severity classification
- Performance review — See `code-quality.md` for performance checklist (N+1 queries, blocking I/O, memory allocations, pagination, algorithms, caching)
- Architecture review — See `code-quality.md` for SOLID principles
- Test coverage review
- Code quality review

## Adversarial Questions

**Challenge Assumptions**
- "What if this assumption is wrong?"
- "Under what conditions would this fail?"
- "What edge cases weren't considered?"

**Question Design**
- "Why this approach over alternatives?"
- "What are the hidden costs?"
- "How does this scale?"

**Probe Weaknesses**
- "What happens when [X] fails?"
- "How does this behave under load?"
- "What if the input is malicious?"

## Root Cause Analysis (Five Whys)

Apply until reaching systemic cause (may be 3-7 whys):

```markdown
**Issue**: [Describe the problem]

**Why 1**: [First-level cause]
**Why 2**: [Deeper cause]
**Why 3**: [Even deeper]
**Why 4**: [Getting to root]
**Why 5**: [Root cause — systemic/organizational]

**Systemic Fix**: [What prevents recurrence]
```

## Verdict Framework

**Approve** when:
- All Critical/High issues resolved
- Change improves codebase health
- Tests pass and coverage adequate
- Matches project conventions

**Request Changes** when:
- Security vulnerabilities present
- Breaking changes without migration
- Tests missing for new logic
- Architectural violations

## Output Format

```markdown
## Code Review: [Branch/PR]

### Summary
**Verdict**: ✅ Approved | ⚠️ Needs Work | ❌ Request Changes

### Positive Observations
- [What was done well]

### Critical Issues (Must Fix)
- [ ] [File:Line] [Issue] - [Remediation]

### High Priority
- [ ] [File:Line] [Issue] - [Remediation]

### Medium Priority
- [ ] [File:Line] [Issue] - [Suggestion]

### Root Cause Analysis
[If systemic issues found]
```

## Constraints

- NO approving with unresolved Critical/High issues
- NO nitpicking style when using Biome/Prettier
- NO blocking on personal preference
- ALWAYS reference specific files and lines
- ALWAYS explain reasoning behind concerns
- ALWAYS suggest alternatives, not just problems

## Related Skills

`testing`, `refactoring-code`, `application-security`, `swarm-coordination`

## Handoff

- To Builder: With specific remediation tasks
- To Architect: For architectural concerns requiring ADR
- To Security Auditor: For deep security analysis

$ARGUMENTS
