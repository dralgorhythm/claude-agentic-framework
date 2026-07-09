#!/usr/bin/env bash
# Framework invariants checker — the PR8 CI gate, runnable locally at every PR boundary.
# Usage:  ./check-invariants.sh              # run all checks
#         SKIP="no-beads gating" ./check-invariants.sh   # skip named checks (pre-landing phases)
# Exits non-zero if any non-skipped check fails.

set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
FAIL=0
SKIP="${SKIP:-}"

skipped() { case " $SKIP " in *" $1 "*) return 0;; *) return 1;; esac; }
report() { # $1=check $2=status(0 pass) $3=detail
  if skipped "$1"; then echo "SKIP  $1"; return; fi
  if [ "$2" -eq 0 ]; then echo "PASS  $1"; else echo "FAIL  $1 — ${3:-}"; FAIL=1; fi
}

# 1. no-beads: no beads/bd references in tracked files (outside artifacts/changelog/migration)
hits=$(git grep -Iiw -e beads -e bd -- ':!artifacts/' ':!CHANGELOG*' ':!MIGRATION*' ':!scripts/check-invariants.sh' 2>/dev/null | wc -l | tr -d ' ')
report no-beads "$([ "$hits" = 0 ]; echo $?)" "$hits tracked reference(s): git grep -Iiw -e beads -e bd -- ':!artifacts/' ':!CHANGELOG*' ':!MIGRATION*' ':!scripts/check-invariants.sh'"

# 2. no-node-deps: no Node toolchain files tracked under .claude/
hits=$(git ls-files '.claude/**/package.json' '.claude/**/package-lock.json' '.claude/**/tsconfig.json' '.claude/**/node_modules/**' '.claude/**/*.ts' 2>/dev/null | wc -l | tr -d ' ')
report no-node-deps "$([ "$hits" = 0 ]; echo $?)" "$hits Node file(s) tracked under .claude/"

# 3. no-skill-rules: skill-rules.json must not exist (native discovery)
hits=$(git ls-files '**/skill-rules.json' 'skill-rules.json' 2>/dev/null | wc -l | tr -d ' ')
report no-skill-rules "$([ "$hits" = 0 ]; echo $?)" "skill-rules.json still tracked"

# 4. skill-length: every SKILL.md body < 500 lines
bad=""
while IFS= read -r f; do
  n=$(wc -l < "$f" | tr -d ' ')
  [ "$n" -ge 500 ] && bad="$bad $f($n)"
done < <(git ls-files '*SKILL.md')
report skill-length "$([ -z "$bad" ]; echo $?)" "over 500 lines:$bad"

# 5. name-eq-dir: SKILL.md frontmatter name == parent directory name
bad=""
while IFS= read -r f; do
  dir=$(basename "$(dirname "$f")")
  nm=$(awk '/^---$/{c++;next} c==1 && /^name:/{sub(/^name:[ ]*/,"");gsub(/["'"'"']/,"");print;exit}' "$f")
  [ -n "$nm" ] && [ "$nm" != "$dir" ] && bad="$bad $f(name=$nm dir=$dir)"
done < <(git ls-files '*SKILL.md')
report name-eq-dir "$([ -z "$bad" ]; echo $?)" "mismatch:$bad"

# 6. settings-valid: settings.json parses as JSON and declares $schema
if command -v jq >/dev/null 2>&1; then
  jq -e '."$schema"' .claude/settings.json >/dev/null 2>&1; rc=$?
  report settings-valid "$rc" ".claude/settings.json fails to parse or lacks \$schema"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool .claude/settings.json >/dev/null 2>&1; rc=$?
  report settings-valid "$rc" ".claude/settings.json fails to parse (python3 json.tool)"
else
  report settings-valid 0 "(no jq or python3 — parse check skipped)"
fi

# 7. model-tiering: agents use aliases; only worker-architect may be opus
bad=""
while IFS= read -r f; do
  m=$(awk '/^---$/{c++;next} c==1 && /^model:/{sub(/^model:[ ]*/,"");print;exit}' "$f")
  case "$m" in haiku|sonnet|opus|fable|inherit|"") ;; *) bad="$bad $f(non-alias:$m)";; esac
  if [ "$m" = "opus" ] && [ "$(basename "$f")" != "worker-architect.md" ]; then bad="$bad $f(opus)"; fi
done < <(git ls-files '.claude/agents/*.md')
report model-tiering "$([ -z "$bad" ]; echo $?)" "violations:$bad"

# 8. no-model-drift: docs must not pair reviewer/research workers with opus
hits=$(git grep -IniE 'worker-(reviewer|research)[^a-z].*opus' -- ':!artifacts/' ':!CHANGELOG*' ':!MIGRATION*' 2>/dev/null | wc -l | tr -d ' ')
report no-model-drift "$([ "$hits" = 0 ]; echo $?)" "$hits stale opus pairing(s)"

# 9. gating: all workflow skills must carry disable-model-invocation: true
bad=""
for s in builder swarm-execute swarm-plan swarm-review swarm-research code-check architect qa-engineer security-auditor ui-ux-designer; do
  f=".claude/skills/$s/SKILL.md"
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    grep -q '^disable-model-invocation: true' "$f" || bad="$bad $s"
  fi
done
report gating "$([ -z "$bad" ]; echo $?)" "ungated workflow skill(s):$bad"

# 10. no-private-ids: no private-reference identifiers in tracked files
hits=$({ git grep -IniwE 'argo|42gen' -- ':!scripts/check-invariants.sh' 2>/dev/null | grep -viE 'cargo|argocd'; git grep -InE 'ENG-[0-9]+|/Users/[a-z]+' -- ':!scratchpad/' ':!scripts/check-invariants.sh' 2>/dev/null; } | wc -l | tr -d ' ')
report no-private-ids "$([ "$hits" = 0 ]; echo $?)" "$hits private identifier hit(s)"

# 11. desc-budget: total always-on description chars under ~6000 (~1.5k tokens proxy for the 1% listing budget)
total=$(git ls-files '.claude/skills/*/SKILL.md' '.claude/skills/*/*/SKILL.md' | while IFS= read -r f; do
  awk '/^---$/{c++;next} c==1 && /^description:/{sub(/^description:[ ]*/,"");print}' "$f"
done | wc -c | tr -d ' ')
report desc-budget "$([ "${total:-0}" -lt 6000 ]; echo $?)" "description total ${total} chars (budget proxy 6000)"

# 12. worktrees-ignored: swarm worktrees path must be gitignored
grep -q '^\.claude/worktrees/' .gitignore; report worktrees-ignored $? ".gitignore lacks .claude/worktrees/"

# 13. hooks-valid: every shipped hook must be syntactically valid bash
bad=""
while IFS= read -r f; do
  bash -n "$f" 2>/dev/null || bad="$bad $f"
done < <(git ls-files '.claude/hooks/*.sh')
report hooks-valid "$([ -z "$bad" ]; echo $?)" "bash -n failed:$bad"

# 14. plugin-agents-sync: plugin.json must list every agent file (validate requires explicit paths)
if git ls-files --error-unmatch .claude-plugin/plugin.json >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  python3 - <<'PYEOF'
import json, subprocess, sys
listed = set(json.load(open('.claude-plugin/plugin.json')).get('agents', []))
actual = set('./' + f for f in subprocess.run(['git','ls-files','.claude/agents/*.md'],capture_output=True,text=True).stdout.split())
sys.exit(0 if listed == actual else 1)
PYEOF
  report plugin-agents-sync $? "plugin.json agents list out of sync with .claude/agents/*.md"
else
  report plugin-agents-sync 0 "(no plugin manifest or python3 — skipped)"
fi

# 15. agent-maxturns: every agent frontmatter has a positive integer maxTurns
bad=""
while IFS= read -r f; do
  mt=$(awk '/^---$/{c++;next} c==1 && /^maxTurns:/{sub(/^maxTurns:[ ]*/,"");gsub(/["'"'"']/,"");print;exit}' "$f")
  case "$mt" in ''|0|*[!0-9]*) bad="$bad $f(maxTurns=${mt:-missing})";; esac
done < <(git ls-files '.claude/agents/*.md')
report agent-maxturns "$([ -z "$bad" ]; echo $?)" "missing/non-integer maxTurns:$bad"

# 16. builder-isolation: worker-builder.md declares isolation: worktree
f=".claude/agents/worker-builder.md"
if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
  iso=$(awk '/^---$/{c++;next} c==1 && /^isolation:/{sub(/^isolation:[ ]*/,"");print;exit}' "$f")
  report builder-isolation "$([ "$iso" = "worktree" ]; echo $?)" "worker-builder.md isolation=${iso:-missing}, want worktree"
else
  report builder-isolation 1 "$f not tracked"
fi

# 17. preload-ungated: skills preloaded via an agent's `skills:` field must not be gated
bad=""
while IFS= read -r agent_file; do
  line=$(awk '/^---$/{c++;next} c==1 && /^skills:/{sub(/^skills:[ ]*/,"");print;exit}' "$agent_file")
  [ -z "$line" ] && continue
  IFS=',' read -ra names <<< "$line"
  for raw in "${names[@]}"; do
    nm=$(echo "$raw" | tr -d ' ')
    [ -z "$nm" ] && continue
    skill_file=$(git ls-files '*SKILL.md' | while IFS= read -r sf; do
      [ "$(basename "$(dirname "$sf")")" = "$nm" ] && echo "$sf" && break
    done)
    if [ -z "$skill_file" ]; then
      bad="$bad $agent_file->$nm(not-found)"
    elif grep -q '^disable-model-invocation: true' "$skill_file"; then
      bad="$bad $agent_file->$nm(gated)"
    fi
  done
done < <(git ls-files '.claude/agents/*.md')
report preload-ungated "$([ -z "$bad" ]; echo $?)" "preloaded-but-gated or missing skill(s):$bad"

# 18. desc-style: every SKILL.md description is non-empty, <=500 chars, third-person
#     (not "I "/"You "/"This skill"/"A skill" — self-referential openers slip into
#     first/second person and read like a chatbot, not spec prose), and — for
#     ungated skills only — contains "Use when" (the official guidance: ungated
#     descriptions are the model's auto-invocation trigger text and need an explicit
#     when-clause; gated skills are human `/name` menu text where the when-clause is
#     optional because the user already decided to invoke it).
bad=""
while IFS= read -r f; do
  d=$(awk '/^---$/{c++;next} c==1 && /^description:/{sub(/^description:[ ]*/,"");print;exit}' "$f")
  if [ -z "$d" ]; then bad="$bad $f(empty)"; continue; fi
  [ "${#d}" -gt 500 ] && bad="$bad $f(len=${#d})"
  echo "$d" | grep -qiE '^(i |you |this skill|a skill)' && bad="$bad $f(self-referential)"
  if ! grep -q '^disable-model-invocation: true' "$f"; then
    case "$d" in *"Use when"*) ;; *) bad="$bad $f(missing-use-when)";; esac
  fi
done < <(git ls-files '*SKILL.md')
report desc-style "$([ -z "$bad" ]; echo $?)" "violations:$bad"

# 19. evals-json: every evals.json under .claude/skills/ must parse as valid JSON
if command -v python3 >/dev/null 2>&1; then
  bad=""
  while IFS= read -r f; do
    python3 -m json.tool "$f" >/dev/null 2>&1 || bad="$bad $f"
  done < <(git ls-files '.claude/skills/*evals.json')
  report evals-json "$([ -z "$bad" ]; echo $?)" "failed to parse:$bad"
else
  report evals-json 0 "(no python3 — parse check skipped)"
fi

# 20. claudemd-lines: CLAUDE.md must stay a short summary layer (<= 200 lines)
n=$(awk 'END{print NR}' CLAUDE.md | tr -d ' ')
report claudemd-lines "$([ "${n:-9999}" -le 200 ]; echo $?)" "CLAUDE.md is $n lines (budget 200)"

echo ""
[ "$FAIL" -eq 0 ] && echo "ALL CHECKS GREEN" || echo "INVARIANT FAILURES PRESENT"
exit "$FAIL"
