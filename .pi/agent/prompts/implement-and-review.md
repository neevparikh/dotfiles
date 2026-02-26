---
description: Worker implements, reviewer reviews, worker applies feedback, awaiter verifies long-running checks
---
Use the subagent tool with the chain parameter to execute this workflow:

1. First, use the "worker" agent to implement: $@
2. Then, use the "reviewer" agent to review the implementation from the previous step (use {previous} placeholder)
3. Then, use the "worker" agent to apply the feedback from the review (use {previous} placeholder)
4. If long-running validation is needed, use the "awaiter" agent to run and await the final verification commands from the previous step output (use {previous} placeholder)

Execute this as a chain, passing output between steps via {previous}. Keep worker changes scoped and preserve unrelated edits.
