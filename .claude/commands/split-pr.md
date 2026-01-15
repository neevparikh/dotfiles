---
description: "Split one PR into multiple smaller stacked PRs for easier review"
argument-hint: "[number-of-prs | commit-ranges]"
---

Split the current branch's PR into multiple smaller stacked PRs. Each PR will target the previous one, creating a review-friendly chain.

**Prerequisites:**
- Branch must be up-to-date with main (no pending rebases)
- All changes should be committed (clean working tree)
- The branch should have an existing PR or commits ready

## Step 1: Gather Information

```bash
git status
git branch --show-current
git log --oneline origin/main..HEAD
git fetch origin
```

- Verify the working tree is clean
- Get the current branch name (this becomes the "final" branch in the stack)
- Count commits ahead of main
- If fewer than 2 commits, inform user splitting isn't needed

## Step 2: Analyze Commits

List all commits with their details:
```bash
git log --format="%h %s" origin/main..HEAD --reverse
```

Look for logical groupings based on:
- Related functionality (same feature area)
- Refactoring vs new code vs tests
- Independent changes that don't depend on later commits

## Step 3: Present Split Options

Present the user with options for how to split. User provided: $ARGUMENTS

If user specified a number (e.g., "3"), suggest splitting commits evenly into that many PRs.

If user specified commit ranges (e.g., "abc123..def456, def456..HEAD"), use those.

Otherwise, suggest logical groupings based on commit messages. Present options like:
1. **By count**: Split into N equal parts
2. **By topic**: Group related commits together
3. **Manual**: Let user specify commit boundaries

Use AskUserQuestion to get user's preference if not clear from arguments.

## Step 4: Create Stacked Branches

For each PR in the stack (starting from oldest commits):

1. Determine the branch name pattern: `{original-branch}/part-{N}` (e.g., `feat/add-auth/part-1`)
2. Create the branch at the appropriate commit:
   ```bash
   git branch {branch-name} {commit-sha}
   ```
3. Push each branch:
   ```bash
   git push -u origin {branch-name}
   ```

Example for 3-way split of branch `feat/big-change`:
- `feat/big-change/part-1` - commits 1-3, targets `main`
- `feat/big-change/part-2` - commits 1-6, targets `part-1`
- `feat/big-change/part-3` (original branch) - all commits, targets `part-2`

## Step 5: Create Stacked PRs

For each branch (from first to last):

```bash
gh pr create --base {target-branch} --head {branch-name} --title "{title}" --body "$(cat <<'EOF'
## Stack Position
Part {N} of {total} in stack.

{previous_prs_if_any}

## Summary
{commit_summaries_for_this_part}

## Review Notes
- Review this PR independently
- Changes build on: {base_branch}
- Next in stack: {next_pr_or_none}

---
Part of stacked PR series. See full stack below.
EOF
)"
```

If the original branch already has a PR, update it to point to the last stacked branch:
```bash
gh pr edit {original-pr-number} --base {second-to-last-branch}
```

## Step 6: Summary

Output a summary table:
```
PR Stack Created:
┌─────┬─────────────────────────┬───────────────┬─────────────────┐
│ #   │ Branch                  │ Base          │ PR URL          │
├─────┼─────────────────────────┼───────────────┼─────────────────┤
│ 1   │ feat/big-change/part-1  │ main          │ github.com/...  │
│ 2   │ feat/big-change/part-2  │ part-1        │ github.com/...  │
│ 3   │ feat/big-change         │ part-2        │ github.com/...  │
└─────┴─────────────────────────┴───────────────┴─────────────────┘

Review order: Start from PR #1 (bottom of stack) and work up.
Merge order: Merge from #1 to #3 in sequence.
```

## Error Handling

- If working tree is dirty: ask user to commit or stash first
- If branch is behind main: suggest running `/sync-main` first
- If PR creation fails: report error and continue with remaining PRs
- If a branch name already exists: append a timestamp suffix

## Notes

- After merging PRs, the later branches may need rebasing
- Consider using `/sync-main-all` after merging each PR in the stack
- Reviewers should review from bottom to top of stack
