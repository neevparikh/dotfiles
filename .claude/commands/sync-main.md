---
description: "Fetch latest and rebase onto main"
---

Sync the current branch with the latest main branch.

**1. Check current state:**
```bash
git status
git branch --show-current
```

**2. Fetch and rebase:**
```bash
git fetch origin && git rebase origin/main
```

If fetch fails (network, auth), report the error and stop.

**3. If there are merge conflicts:**
1. Run `git log --oneline -10` to see divergent commits and understand what changed
2. For each conflicted file:
   - Read the conflict markers
   - Understand what each side changed
   - Resolution strategy:
     - **Different parts of file:** keep both changes
     - **Overlapping changes:** combine logically, preserving intent of both
     - **True conflict:** prefer our changes unless upstream clearly fixes a bug
3. Stage resolved files with `git add <file>`
4. Continue with `git rebase --continue`
5. Run `git status` to confirm no conflicts remain

**4. Summarize:**
- Run `git log --oneline origin/main..HEAD` to see your commits ahead of main
- Run `git log --oneline HEAD..origin/main` to see if anything was missed
- Briefly list what came in (titles only)
- Note any that might affect your current work

**Done when:** Branch is rebased onto main with no conflicts.
