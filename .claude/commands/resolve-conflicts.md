---
description: "Resolve merge conflicts after rebase and update PR"
---

There are merge conflicts on the current branch after rebasing onto main. Resolve them and update the PR.

**1. Ensure latest state:**
```bash
git fetch origin
git status
```

**2. Understand the situation:**
- Run `git log --oneline -5` to see recent commits and relationship to main
- Identify conflicted files (marked with "both modified" in status)

**3. For each conflicted file:**
- Read the file to see conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
- Understand what each side changed and why
- Resolution strategy:
  - **Different parts of file:** keep both changes
  - **Overlapping changes:** combine logically, preserving intent of both
  - **True conflict (mutually exclusive):** prefer our changes unless upstream clearly fixes a bug
- Stage resolved files with `git add <file>`
- Ensure resolved code is syntactically correct and logically sound

**4. Complete the rebase:**
- Run `git rebase --continue` after resolving each conflict
- Repeat until rebase is complete

**5. Verify resolution:**
- Run `git status` to confirm no conflicts remain
- Run the project's quality checks (type checking, linting, tests)

**6. Handle check failures:**
- If failure is related to conflict resolution, fix and re-verify
- If failure is unrelated to conflicts, report it as a separate issue

**7. Push and report:**
- Check if a PR exists: `gh pr view 2>/dev/null`
- Force push with `git push --force-with-lease`
- If PR exists, note that it will auto-update
- Report the resolution result

**Done when:** All conflicts resolved, checks pass, and changes are pushed.

If conflicts are complex or ambiguous, explain both sides and ask for guidance before resolving.
