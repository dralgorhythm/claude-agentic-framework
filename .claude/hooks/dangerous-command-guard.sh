#!/bin/bash
# Hook: dangerous-command-guard
# Event: PreToolUse (Bash)
# Purpose: Warn about dangerous commands before execution.
#          Does NOT block — outputs a warning message to stderr and exits 0.

INPUT=$(cat)

# jq is required to parse tool input; fail open if unavailable (hooks are
# guardrails, not a security boundary)
command -v jq >/dev/null 2>&1 || exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

# Only process Bash tool
[ "$TOOL_NAME" != "Bash" ] && exit 0
[ -z "$COMMAND" ] && exit 0

WARNING=""

# git push --force or --force-with-lease
if echo "$COMMAND" | grep -qE '\bgit\s+push\b.*--(force|force-with-lease)\b'; then
    WARNING="WARNING: Force push detected. This will overwrite remote history and may discard others' work."
fi

# git reset --hard
if echo "$COMMAND" | grep -qE '\bgit\s+reset\s+--hard\b'; then
    WARNING="WARNING: Hard reset detected. This will permanently discard all uncommitted changes and staged work."
fi

# rm -rf targeting dangerous paths (root, home, common project roots)
if echo "$COMMAND" | grep -qE '\brm\s+-[rRfF]{2,}\s+(/|~|/home|/usr|/etc|/var|/opt|\.\.?/)'; then
    WARNING="WARNING: Recursive delete on a potentially dangerous path detected. This cannot be undone."
fi

# terraform destroy
if echo "$COMMAND" | grep -qE '\bterraform\s+destroy\b'; then
    WARNING="WARNING: Terraform destroy detected. This will tear down infrastructure resources and may cause downtime."
fi

# terraform apply without -out plan file (i.e. -auto-approve or bare apply)
if echo "$COMMAND" | grep -qE '\bterraform\s+apply\b.*-auto-approve\b'; then
    WARNING="WARNING: Terraform apply with -auto-approve detected. Infrastructure changes will apply without review."
fi

# docker system prune
if echo "$COMMAND" | grep -qE '\bdocker\s+system\s+prune\b'; then
    WARNING="WARNING: Docker system prune detected. This will remove all unused containers, networks, images, and build cache."
fi

# kubectl delete
if echo "$COMMAND" | grep -qE '\bkubectl\s+delete\b'; then
    WARNING="WARNING: kubectl delete detected. This will remove Kubernetes resources and may cause service disruption."
fi

# No match — allow normally
[ -z "$WARNING" ] && exit 0

# Output warning to stderr so it is visible in the transcript without blocking
echo "$WARNING" >&2

exit 0
