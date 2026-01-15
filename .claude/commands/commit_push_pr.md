---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(uv run ruff format:*), Bash(uv run ruff check:*), Bash(uv run basedpyright:*)
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Additional user instructions: $ARGUMENTS

Before committing, you MUST run the following linting checks and fix any issues:

1. `uv run ruff format .` - Format code
2. `uv run ruff check .` - Run linter
3. `uv run basedpyright .` - Run type checker

If any of these fail, fix the issues before proceeding with the commit.

Based on the above changes and user instructions, create a single git commit, and optionally push changes to remote. 
