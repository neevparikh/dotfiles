## General guidance
- **Inclusive Terms:** allowlist/blocklist, primary/replica, placeholder/example, main branch, conflict-free, concurrent/parallel
- Always try and reference your project-specific CLAUDE.md (or AGENTS.md) if they exist, during the planning stage! To reiterate, when you make a plan, at the end check for any guidance from the CLAUDE.md or AGENTS.md file and compare those instructions to your plan. If you notice any differences or missing parts, update your plan and note why you did this.

## Coding Style & Naming Conventions
- Python: 4-space indentation, type hints, `snake_case` for modules/functions/variables, constants in `UPPER_SNAKE_CASE`.
- Ruff enforces formatting/lint rules; keep `ruff check` clean before pushing.
- Never run Python directly, always wrap with `uv run`. 
- BasedPyright runs in strict mode; follow existing typed helpers and prefer dataclasses/TypedDicts already used.
- Keep docstrings concise and informative; add comments only for non-obvious logic.
- Almost never add fallbacks to dictionary access (e.g. never do `dict_a.get(key, fallback)`) unless you are absolutely certain this is what the user wants.
- No excessive error handling or try/catching
- No excessive casting
- No excessive input validation and checking. Please fail loudly if something is unexpected!! Be concise, reduce branching where possible.
- Always run `uv run ruff check .` and `uv run basedpyright .` and fix all the errors after making code changes. If the issues tend to be with library code, it's okay to disable the pyright warnings if they're hard to fix
- Always format at the end of a change by running `uv run ruff format .`
- Never use Optional or Union or Tuple or List etc. for type hints, always prefer `| None` or `|` or `tuple` or `list` etc.
- Try to import modules and use it like `from package.module_a import module_b; module_b.foo()`.
- Be concise and do not edit files that aren't strictly necessary
* Use `uv add` over `uv pip`, unless you have a good reason
- Prefer `match` statements over `isinstance` chains when dispatching on a set of types (e.g., `ChatMessageUser | ChatMessageAssistant | ChatMessageTool`)
- Use pattern matching to extract attributes directly in case clauses (e.g., `case ChatMessageTool(tool_call_id=id, function=fn):`)
- Extract shared logic into helper functions when match cases have common operations
- **Fail loudly on missing keys**: Almost never use `.get(key, "")` or `.get(key, default)` for dict access. If a key is expected to be present, use `dict[key]` directly so missing keys cause an immediate crash. Only use `.get()` with a fallback when the key is genuinely optional. Silent fallbacks hide bugs.
- **Style**: Prefer self-documenting code over comments

### Test Style
- **Use `mocker.patch` over `monkeypatch`**: Prefer `mocker: MockerFixture` with `mocker.patch()` for cleaner mocking syntax.
- **Use `side_effect` for sequences**: Instead of `nonlocal` counters, use `side_effect=[val1, val2, ...]` for sequential return values or `side_effect=Exception(...)` for consistent failures.
- **Use real classes over MagicMock**: When a class is simple (e.g., `Target`, `ChatCompletion`), use the real class instead of mocking it. For OpenAI types, use `openai.types.chat.ChatCompletion`, `CompletionUsage`, `CompletionTokensDetails`, etc.
- **Use type assertions over `# type: ignore`**: Prefer `assert x is not None` before accessing `x.attr` instead of `x.attr  # type: ignore`.
- **Parameterize similar tests**: Use `@pytest.mark.parametrize` with `pytest.param(..., id="descriptive_name")` instead of writing multiple near-identical test functions.
- **Avoid redundant test cases**: Don't add tests that don't increase coverage (e.g., testing 10 items when 3 items already tests the same logic).
- **Keep comments current**: Remove stale comments (e.g., "will fail due to bug" after the bug is fixed).
- Secrets: load API keys via `.env` per `README.md`; never commit secrets or local configs (e.g., `~/.dvc/config.local`).
- DVC controls large artifacts; commit `.dvc` metadata but avoid adding raw data directly to git. Check `dvc status` before PRs if data changed.
- **Tools**: Use rg not grep, fd not find, tree, where these commands are installed.

## Commit & Pull Request Guidelines

-   Commit messages mirror history: short and imperative, optionally prefixed (`feat:`) and often referencing the PR number `(#NNN)`.
-   **Git Commits**: Use conventional format: <type>(<scope>): <subject> where type = feat|fix|docs|style|refactor|test|chore|perf. Subject: 50 chars max, imperative mood ("add" not "added"), no period. For small changes: one-line commit only. For complex changes: add body explaining what/why (72-char lines) and reference issues. Keep commits atomic (one logical change) and self-explanatory. Split into multiple commits if addressing different concerns.
-   PRs should list scope, linked issue/PR, data or regenerated artifacts, commands run (tests, `dvc repro`), and screenshots/plots when visuals change.
-   Call out monitor spec/parameter changes and whether downstream data or plots were refreshed.
