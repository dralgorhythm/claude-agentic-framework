---
name: debugging
description: Troubleshoot and fix bugs systematically. Use when errors occur, tests fail, or unexpected behavior is observed. Covers root cause analysis and debugging strategies.
allowed-tools: Read, Bash, Glob, Grep
---

# Debugging and Troubleshooting

## Workflows

- [ ] **Reproduce**: Can you reliably reproduce the issue?
- [ ] **Isolate**: What is the minimal code that exhibits the bug?
- [ ] **Hypothesize**: What could cause this behavior?
- [ ] **Test**: Verify or disprove your hypothesis
- [ ] **Fix**: Implement the solution
- [ ] **Verify**: Confirm the fix and add regression test

## Debugging Strategy

### 1. Gather Information
- Read error messages and stack traces carefully
- Check logs for context around the error
- Identify when the issue started (recent changes?)

### 2. Reproduce Consistently
- Create a minimal test case
- Document exact steps to reproduce
- Note any environment differences

### 3. Binary Search
- If the bug is in a large codebase, use binary search
- Comment out half the code, check if bug persists
- Narrow down to the exact location

### 4. Common Causes
- **Null/undefined**: Check for missing null checks
- **Off-by-one**: Verify loop boundaries and array indices
- **Async timing**: Check race conditions and await usage
- **State mutation**: Look for unexpected side effects
- **Type coercion**: Verify type handling (especially in JS/TS)

## Tools

```bash
# Check logs
tail -f /var/log/app.log

# Search for error patterns
grep -r "ERROR" ./logs/

# Debug Node.js
node --inspect-brk app.js

# Python debugging
python -m pdb script.py
```

## Post-Fix Checklist

- [ ] Root cause identified and documented
- [ ] Regression test added
- [ ] Similar code checked for same issue
- [ ] Fix reviewed by another developer
