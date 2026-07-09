# Debugging Protocol

Deep-dive reference for disciplined debugging. See Core Principle 2 ("Prove It Works") in CLAUDE.md for the essentials.

## Three-Before-One

Before touching any code, form three distinct hypotheses for what could be causing the failure. State them explicitly — in your response or in a working note — before making a single change.

- Hypotheses must be falsifiable: each should point to a specific mechanism you can confirm or rule out (a log line, a return value, a state transition), not a vague hunch.
- Rank them by likelihood and check the cheapest one to falsify first.
- If the first change doesn't fix it, return to the list — do not invent a fourth hypothesis on the fly without reconsidering the first three.

This exists to stop the reflex of changing code before understanding it. A change made before a hypothesis is confirmed is a guess, not a fix.

## Root Cause Mandate

Fix causes, not symptoms.

- A fix without an explanation of WHY the bug happened is not done. If you cannot articulate the causal chain from root cause to observed failure, keep investigating.
- Patching the symptom (retrying, catching and ignoring, widening a type, adding a null check) is acceptable only as a documented, temporary mitigation — never as the final commit message.
- Regression-test workflow: see the `testing` skill — if you can't write one that fails without your change, you haven't isolated the root cause yet.

## Stale Context Check

Long sessions degrade the reliability of what you remember about a file's contents.

- If more than roughly 20 tool calls have passed since you last read a file, re-read it before editing it. Do not trust your memory of its current state.
- After any context compaction event, re-read any file you are about to modify — compaction can silently drop the details you were relying on.
- When in doubt about whether context is stale, the cost of re-reading is always lower than the cost of editing blind.

## Red Flags

Stop and reassess if you notice any of these in your own behavior:

- "It works now but I don't know why" — an unexplained fix is not a fix, it's a coincidence waiting to regress.
- Stacking speculative fixes — applying a second or third change before verifying whether the first one worked.
- Editing from memory — modifying a file based on what you recall it says instead of what you just read.
- Suppressing errors instead of handling them — catch blocks that swallow exceptions, linter/type-checker overrides, or retries that mask an unresolved failure.

## Escalation

After three failed fix attempts on the same issue: stop. Do not attempt a fourth speculative change.

- Write up what you tried, what you observed, and which hypotheses you've ruled out.
- Ask the user for guidance, or open a task capturing the investigation so far.
- Thrashing — repeatedly changing code without a confirmed root cause — burns effort and increases the odds of introducing a second, unrelated bug on top of the first.
