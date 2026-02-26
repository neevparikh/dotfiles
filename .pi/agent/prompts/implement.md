---
description: Full implementation workflow - scout gathers context, planner creates plan, worker implements, awaiter verifies long-running commands
---
Use the subagent tool with the chain parameter to execute this workflow:

1. First, use the "scout" agent to find all code relevant to: $@
2. Then, use the "planner" agent to create an implementation plan for "$@" using the context from the previous step (use {previous} placeholder)
3. Then, use the "worker" agent to implement the plan from the previous step (use {previous} placeholder)
4. If long-running verification is needed (tests/build/migrations), use the "awaiter" agent to run and await those commands using the previous step output as context (use {previous} placeholder)

Execute as a chain, passing output between steps via {previous}. Ensure worker ownership is explicit and unrelated edits are not reverted.
