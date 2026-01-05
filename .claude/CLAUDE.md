## Coding Style & Naming Conventions
-   Python: 4-space indentation, type hints, `snake_case` for modules/functions/variables, constants in `UPPER_SNAKE_CASE`.
-   Ruff enforces formatting/lint rules; keep `ruff check` clean before pushing.
*   Never run Python directly, always wrap with `uv run`. 
-   BasedPyright runs in strict mode; follow existing typed helpers and prefer dataclasses/TypedDicts already used.
-   Keep docstrings concise and informative; add comments only for non-obvious logic.
-   Almost never add fallbacks to dictionary access (e.g. never do `dict_a.get(key, fallback)`) unless you are absolutely certain this is what the user wants.
-   No excessive error handling or try/catching
-   No excessive casting
-   No excessive input validation and checking. Please fail loudly if something is unexpected!! Be concise, reduce branching where possible.
-   Always run `uv run ruff check .` and `uv run basedpyright .` and fix all the errors after making code changes. If the issues tend to be with library code, it's okay to disable the pyright warnings if they're hard to fix
-   Always format at the end of a change by running `uv run ruff format .`
-   Never use Optional or Union or Tuple or List etc. for type hints, always prefer `| None` or `|` or `tuple` or `list` etc.
-   Try to import modules and use it like `from package.module_a import module_b; module_b.foo()`.
-   Be concise and do not edit files that aren't strictly necessary
*   Use `uv add` over `uv pip`, unless you have a good reason
- Prefer `match` statements over `isinstance` chains when dispatching on a set of types (e.g., `ChatMessageUser | ChatMessageAssistant | ChatMessageTool`)
- Use pattern matching to extract attributes directly in case clauses (e.g., `case ChatMessageTool(tool_call_id=id, function=fn):`)
- Extract shared logic into helper functions when match cases have common operations
- **Fail loudly on missing keys**: Almost never use `.get(key, "")` or `.get(key, default)` for dict access. If a key is expected to be present, use `dict[key]` directly so missing keys cause an immediate crash. Only use `.get()` with a fallback when the key is genuinely optional. Silent fallbacks hide bugs.
