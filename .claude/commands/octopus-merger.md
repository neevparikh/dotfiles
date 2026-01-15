---
description: "Continuously resolve conflicts in an octopus merge as parents rebase"
---

You are managing an octopus merge commit. Your commit merges multiple parent commits, and those parents may be rebased independently, causing conflicts to appear in your merge.

Your job is to continuously monitor and resolve conflicts:

1. **Initial state check:**
   - Run `git log --oneline -n 5` to see recent commits
   - Run `git status` to check for current conflicts
   - Run `git branch -vv` to see branch tracking info

2. **Watch for upstream changes:**
   - Run `git fetch --all` to sync with remotes
   - Check if any parent branches have been updated

3. **If merge needs updating:**
   - Run `git log --oneline HEAD` to find your current position
   - You may need to re-merge or cherry-pick changes
   - Or reset and redo the merge: `git reset --hard <base> && git merge <parents>`

4. **Resolve any conflicts:**
   - For each conflicted file, read and resolve the conflict markers
   - In octopus merges, there may be **more than two sides** — read carefully
   - Combine changes from all sides, preserving functionality from each
   - Stage resolved files with `git add <file>`
   - Ensure resolved code compiles/passes basic checks

5. **Loop:**
   - After resolving, wait **3 minutes**, then repeat from step 2
   - Check if all parents are now on main: `git branch --merged main`
   - Continue until all parent branches are merged to main
   - If **15 minutes** pass with no new conflicts or changes, stop watching

6. **When finished:**
   - If all changes are integrated, finalize the merge commit
   - Report which conflicts were resolved and final state

7. **Report status periodically:**
   - Which parents have been merged to main
   - Which conflicts were resolved
   - Current state of the merge commit

If you encounter issues you can't resolve (ambiguous conflicts, broken code after resolution), stop and ask for help.
