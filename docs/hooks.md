# Hooks

Hooks run automatically at key points in Claude Code's lifecycle.

## Built-in Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `session-start-loader.sh` | SessionStart | Load session context, detect active swarm agents, process handoffs, cleanup stale sessions |
| `pre-tool-use-validator.sh` | PreToolUse | File locking, secret detection (Write/Edit + Bash redirects/heredocs), protected file enforcement, config-write ask-gate |
| `dangerous-command-guard.sh` | PreToolUse (Bash) | Guard against dangerous shell commands (force push, rm -rf, etc.) |
| `pre-push-main-blocker.sh` | PreToolUse (Bash) | Block direct pushes to main/master branch |
| `pre-commit-verification.sh` | PreToolUse (Bash) | Pre-commit quality checks |
| `post-tool-use-tracker.sh` | PostToolUse | Track file changes |
| `stop-validator.sh` | Stop | Release file locks, cleanup session state, warn about uncommitted/unpushed work and unprocessed `scratchpad/corrections.log` entries |
| `subagent-stop-validator.sh` | SubagentStop | Log swarm worker completion |
| `post-edit-lint.sh` | PostToolUse | Auto-format after edits; surfaces only unfixable issues |
| `branch-pr-discipline.sh` | PreToolUse (Bash) | Warn-only branch/PR hygiene checks |

**Optional examples**: Skills are discovered natively (no hook required — see [docs/skills.md](skills.md#how-skills-activate)). Teams that want deterministic, keyword-based skill activation instead can opt into [docs/examples/skill-activation-hook.sh](examples/skill-activation-hook.sh); it is dependency-free and disabled by default.

## Key Capabilities

### File Locking (pre-tool-use-validator.sh)

Prevents concurrent file edits in multi-agent swarm environments:
- Atomic lock acquisition via `mkdir` (race-condition safe)
- Lock auto-expires after 120 seconds
- Session-based: locks are tied to the session that created them
- Automatic release on session stop

### Secret Detection (pre-tool-use-validator.sh)

Scans Write/Edit content for 6 secret patterns:
1. Generic API keys, passwords, tokens
2. AWS access keys (`AKIA...`)
3. JWT tokens
4. Environment variable exports with secrets
5. GitHub personal access tokens (`ghp_...`)
6. Private keys (PEM format)

Test files (`*.test.ts`, `*.spec.ts`, etc.) are excluded to reduce false positives. The same 6 patterns also scan `Bash` commands that redirect or heredoc content into a file (`>`, `>>`, `<<`) — closing the gap where a heredoc'd `.env` write bypassed Write/Edit-only detection entirely.

**Limitation**: this is a Write/Edit + Bash-redirect matcher, not a general secret scanner — it can't see secrets written by any other means (a script invoked some other way, an MCP tool, etc.), and pattern matching always has false negatives. Trivy's CI secret-scan job (`framework-invariants.yml`) is the actual backstop; treat this hook as an early, partial warning, not the guarantee.

### Protected Files (pre-tool-use-validator.sh)

Blocks modifications to critical system files:
- `.git/`
- `.env`
- `.mcp.json`

### Config-Write Ask-Gate (pre-tool-use-validator.sh)

Asks for confirmation (not a hard block) before a direct Write/Edit to:
- `.claude/settings.json`
- `.claude/rules/*`
- root `CLAUDE.md`

These are the same paths `/tailor` proposes changes to rather than writing directly (see `tailor/SKILL.md`'s Output Contract) — this hook backs that contract mechanically instead of leaving it as convention only.

### Push Blocking (pre-push-main-blocker.sh)

Enforces trunk-based development by blocking pushes to main/master:
- Detects explicit pushes (`git push origin main`)
- Detects implicit pushes (`git push` while on main branch)
- Provides remediation instructions (create feature branch, push there, create PR)

### Session Management (session-start-loader.sh + stop-validator.sh)

- Tracks active sessions in `.claude/hooks/.state/`
- Detects active swarm agents for coordination awareness
- Supports handoff messages between sessions
- Auto-cleans stale sessions older than 24 hours
- Warns about uncommitted changes on session stop
- Warns about unpushed commits too, remote-aware: ahead-of-upstream count (with the push command) or `git push -u` guidance when no upstream is configured — silent in repos with no `git remote` configured at all
- Releases file locks before exit

## Creating a Hook

1. Create `.claude/hooks/my-hook.sh`:

```bash
#!/bin/bash
input=$(cat)
# your logic
echo '{"continue": true}'
```

2. Make executable:
```bash
chmod +x .claude/hooks/my-hook.sh
```

3. Register in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/my-hook.sh",
        "timeout": 5
      }]
    }]
  }
}
```

See `.claude/templates/hook.template.sh` for the full template.

## Hook Input

Hooks receive JSON via stdin:

```json
{
  "session_id": "abc123",
  "cwd": "/workspace",
  "prompt": "user message",
  "tool_name": "Write",
  "tool_input": {}
}
```

## Hook Output

For PreToolUse hooks, return a permission decision:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Explanation"
  }
}
```

## Runtime Directories

| Directory | Purpose | Gitignored |
|-----------|---------|------------|
| `.claude/hooks/.state/` | Session tracking files | Yes |
| `.claude/hooks/.locks/` | File lock files | Yes |

## Tips

- Keep hooks fast (< 5 seconds timeout)
- Test with: `echo '{}' | ./my-hook.sh`
- Override hooks via `settings.local.json`

## Security model

Committed hooks are executable code. Once you trust a workspace, every hook registered in `.claude/settings.json` runs automatically, on every collaborator's machine, without a per-run confirmation. Treat hook scripts with the same scrutiny as any other code that executes on checkout — review them before trusting a repo. 2026 supply-chain research demonstrated remote code execution via malicious committed agent-config hooks; this is not theoretical.

The hooks shipped in this repo are **guardrails, not a security boundary**. They are designed to **fail open**: if `jq` is missing, or the hook receives input it can't parse, the check is skipped and the tool call proceeds. This is a deliberate tradeoff for reliability over strict enforcement — do not rely on a hook to be the only thing standing between an agent and a destructive or unsafe action.

HARD rules — the ones that must always hold — live in `settings.json` under `permissions.deny`. A deny entry there cannot be overridden by an allow rule from any scope (project, user, or local settings). If something absolutely must never happen, it belongs in `permissions.deny`, not in a hook.

Only **exit code 2** blocks an action. Exit code 1 (or any non-zero code other than 2) is treated as a non-blocking error and does not stop the tool call — our blocking hooks either exit with code 2 or return deny-JSON (`permissionDecision: "deny"`) explicitly. If you write a hook intended to block, verify it actually exits 2 or returns deny-JSON; anything else is advisory only.

### Enforcement ladder

Hooks are one rung on a broader enforcement ladder, from weakest to strongest:

prose rules (advisory) < skills (on-demand advisory) < hooks (deterministic guardrails, fail-open by design in this repo) < `permissions.deny` + CI (boundaries).

See `.claude/rules/security.md` for the full ladder and rationale. In short: nothing below `permissions.deny` and CI is guaranteed to run, and hooks specifically are guaranteed to skip rather than block when they can't parse their input.

### Degradation visibility

"Fails open" used to also mean "fails silently." `session-start-loader.sh` now checks for `jq` before anything else and, when it's absent, prints a `[HOOK DEGRADATION]` block at session start naming exactly what's degraded instead of just skipping quietly:

- Secret detection & file-lock coordination (`pre-tool-use-validator.sh`)
- Dangerous-command warnings (`dangerous-command-guard.sh`)
- Pre-commit verification reminders (`pre-commit-verification.sh`)

`pre-push-main-blocker.sh`'s branch-block is **not** on that list: its command extraction is a jq-free sed idiom, so it keeps enforcing with or without `jq`. And `permissions.deny` is unaffected either way — it's enforced at the permission layer, independent of hooks or `jq` entirely. Install `jq` to restore the degraded set above.

**How to disable a hook:**

- Remove its entry from `.claude/settings.json` (`hooks` section) to disable it for everyone who pulls that config.
- Set `"disableAllHooks": true` in your local `settings.local.json` to disable all hooks for your own machine only.

## Opt-in recipes

These recipes are **not enabled by default**. They are documented here as copy-paste starting points, consistent with this repo's fail-soft hook doctrine: hooks in this repo ship disabled unless a project deliberately opts in. Wiring one in is a per-project choice, not something this framework turns on for you.

### (a) `TaskCompleted` quality-gate hook

Blocks task completion until quality gates (tests, lint, types, build) pass. Exit code 2 is what makes this blocking rather than advisory — see "Only exit code 2 blocks an action" above.

```bash
#!/bin/bash
# .claude/hooks/task-quality-gate.sh
input=$(cat)

if ! npm test --silent >./scratchpad/gate-test.log 2>&1; then
  echo "Quality gate failed: tests. See ./scratchpad/gate-test.log" >&2
  exit 2
fi

if ! npm run lint --silent >./scratchpad/gate-lint.log 2>&1; then
  echo "Quality gate failed: lint. See ./scratchpad/gate-lint.log" >&2
  exit 2
fi

echo '{"continue": true}'
```

Install (add to `.claude/settings.json`):

```json
{"hooks": {"TaskCompleted": [{"hooks": [{"type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/task-quality-gate.sh", "timeout": 120}]}]}}
```

### (b) Forced-eval skill-activation hook

Before proceeding on a matching prompt, requires the agent to state explicit YES/NO reasoning about whether a skill applies, rather than relying on native discovery alone.

```bash
#!/bin/bash
# .claude/hooks/forced-skill-eval.sh
input=$(cat)

cat <<EOF
{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "Before responding, evaluate each skill in .claude/skills/ against this prompt and state YES or NO with one-line reasoning for whether it applies. Only then proceed."}}
EOF
```

Install (add to `.claude/settings.json`):

```json
{"hooks": {"UserPromptSubmit": [{"hooks": [{"type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/forced-skill-eval.sh", "timeout": 5}]}]}}
```

Evidence: single disclosed-methodology test, N=50, 84% vs 20% activation (MEDIUM confidence). This is one internal test, not a peer-reviewed benchmark — treat the effect size as directional, not a guarantee, and re-validate against your own prompt mix before relying on it.

---

[← Back to README](../README.md)
