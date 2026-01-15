---
description: "Sync all worktrees: rebase onto main, resolve conflicts, skip active ones"
---

Sync all git worktrees in the project with the latest main branch.

**CRITICAL: Some worktrees may have active Claude sessions working in them. Do not interfere with those.**

## Step 1: Fetch latest and list worktrees

```bash
git fetch origin
git worktree list
```

Note the current directory so you can return to it later.

## Step 2: Identify active vs inactive worktrees

For each worktree, check if it appears to be actively in use:

```bash
# Check for Claude processes in the worktree
pgrep -f "claude.*<worktree_path>" || echo "No Claude process found"

# Check for recent file modifications (last 5 minutes)
find <worktree_path> -type f \( -name "*.ts" -o -name "*.py" -o -name "*.rs" \) -mmin -5 2>/dev/null | head -5
```

If either check suggests activity, **skip this worktree**.
If uncertain, **leave it alone** — safer to skip than to interfere.

## Step 3: For each INACTIVE worktree

Navigate to the worktree and perform the sync:

```bash
cd <worktree_path>
git status
git log --oneline -10  # review recent history
```

**Before rebasing, check for work in progress:**
- Run `git status` to see modified files in the working copy
- Run `git log --oneline origin/main..HEAD` to see commits not yet on main
- If there are changes that could be lost, **stop and report** — do not proceed

**Rebase onto main:**
```bash
git rebase origin/main
```

**If there are merge conflicts:**
1. Check `git log` to see what diverged
2. Review the content of conflicting commits — understand what each side changed
3. Resolve conflicts preserving ALL functionality from both sides
4. Stage resolved files with `git add <file>`
5. Continue with `git rebase --continue`
6. Never delete local changes without explicit permission
7. Run `git status` to confirm no conflicts remain

## Step 4: Return and verify

Return to the original working directory.

Summarize:
- Which worktrees were synced successfully
- Which worktrees were skipped (and why — active agent, conflicts needing review, etc.)
- Any working copy changes or commits that need attention

**The goal:** Every worktree is either:
1. Clean and up-to-date with main, OR
2. Left untouched because an agent is actively working there

**Nothing should be lost.** If in doubt, skip the worktree and report.
