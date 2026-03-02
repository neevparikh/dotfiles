
---
description: "Review current changes using the code-reviewer agent"
---

Use the subagent tool with the chain parameter to review changes. Use the "reviewer" agent.

Additional context if provided: $@

**1. Gather changes:**
- Run `git diff` to see what has changed
- If there are no changes, report that and stop, or if requested review the current codebase as a whole.

**2. Launch review:*
Pass the diff to the reviewer agent and report the results.
