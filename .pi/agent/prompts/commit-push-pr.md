---
description: Create a git commit and optionally push to remote and optionally make a PR
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Additional user instructions if provided: $@

## Your task

Before committing, if this is a Python project using `uv`, you MUST try to run the following linting checks and fix any issues:

1. `uv run ruff format .` - Format code
2. `uv run ruff check .` - Run linter
3. `uv run basedpyright .` - Run type checker

If any of these fail, fix the issues before proceeding with the commit. If the tool itself fails, report back to the user and stop.

Based on the above changes and user instructions, create a single git commit, and optionally push changes to remote. 

Follow the conventional commit style for git commits. The commit contains the following structural elements, to communicate intent to the consumers of your library:
fix: a commit of the type fix patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
types other than fix: and feat: are allowed, for example @commitlint/config-conventional (based on the Angular convention) recommends build:, chore:, ci:, docs:, style:, refactor:, perf:, test:, and others.
Additional types are not mandated by the Conventional Commits specification, and have no implicit effect in Semantic Versioning (unless they include a BREAKING CHANGE). A scope may be provided to a commit’s type, to provide additional contextual information and is contained within parenthesis, e.g., feat(parser): add ability to parse arrays.

If the user asks for it, only then push to main or make a PR. If making a PR, ensure to include a good PR description. 
