---
description: "Push changes and open a PR"
---

Push my current changes and create a pull request.

**1. Review current state:**
- Run `git status` to see working copy changes
- Run `git log --oneline -1` to see the current commit
- Run `git diff` to review unstaged changes
- Run `git diff --cached` to review staged changes
- If there are no changes (staged or unstaged), report that and stop

**2. Check for existing PR:**
- Run `git branch --show-current` to get the current branch name
- If on a feature branch, check if a PR exists: `gh pr view 2>/dev/null`
- If PR exists, skip to pushing updates

**3. Commit and push to remote:**
- If there are uncommitted changes, commit them first
- If on main/master: create a new branch first
  - Derive a branch name from the commit description (e.g., `fix-typo-in-readme`, `add-user-auth`)
  - Create and switch: `git checkout -b <branch-name>`
- Push with `git push -u origin <branch-name>`

**4. Create or update Pull Request:**
- If PR already exists: report the PR URL and note that changes were pushed
- If no PR exists: create with `gh pr create`
  - Title: concise summary of the change
  - Body: brief description of what changed and why
  - Include `Closes #N` if this addresses a known issue

**Done when:** Changes are pushed and PR exists (new or updated).

If any command fails, report the error and stop.
