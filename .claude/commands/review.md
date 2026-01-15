---
description: "Review current changes using the code-reviewer agent"
---

Review my current working copy changes using the **code-reviewer** agent.

**1. Gather changes:**
- Run `git diff` to see what has changed
- If there are no changes, report that and stop

**2. Launch review:**
Pass the diff to the code-reviewer agent to analyze for:
- Correctness and potential bugs
- Test integrity (flag removed tests or weakened assertions as **critical**)
- Adherence to project conventions (check CONTRIBUTING.md if it exists, or infer from codebase)
- Type safety issues
- Security concerns
- Test coverage gaps

**3. Output:**
Provide structured feedback grouped by severity:
- **Critical:** Must fix before merge — bugs, security issues, removed/weakened tests
- **High:** Should address — code quality, unclear code
- **Medium:** Consider — style, alternative approaches
- **Low:** Nice to have — minor improvements

**Done when:** Review findings are presented with severity levels.

**Note:** Use `/analyze` if you want parallel type-checker, bug-finder, and code-simplifier agents instead of a single code-reviewer.
