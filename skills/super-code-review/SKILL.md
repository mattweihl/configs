---
name: super-code-review
description: >
  Strict maintainability-focused code review. Covers structural quality,
  abstraction health, spaghetti growth, file-size discipline, code-judo
  simplification, and code style. Works standalone or as a subagent
  receiving pre-collected diff and file contents.
---

# Super Code Review

An extremely strict code quality review focused on maintainability,
abstraction quality, and codebase health.

## Inputs

This skill needs two things to operate:

1. **Git diff output** — the diff of the changes under review.
2. **Changed file contents** — full contents of each changed file (for cross-file reasoning).

### If you are the orchestrating agent

Collect inputs before applying the rubric:

1. Run `git diff <base>...HEAD` (default base: `main`) to get the diff.
2. Read the full contents of every file touched by the diff.
3. Apply the rubric from [rubric.md](rubric.md) to the collected material.

When delegating to subagents, collect diff and file contents in parallel,
then pass both as labeled sections (`### Git / diff output` and
`### Changed file contents`) to the reviewing agent.

### If you are the reviewing agent (receiving pre-collected inputs)

Your prompt already contains the diff and file contents. Proceed directly
to applying the rubric.

## Rubric

Read and apply [rubric.md](rubric.md) as the **complete** review rubric —
tone, approval bar, output ordering, code-judo / 1k-line / spaghetti
rules, and code style preferences.

## Constraints

- Apply the rubric **only** to what the diff and file contents show.
- Trace cross-file impact when the change touches module boundaries.
- Be direct and high-conviction; skip cosmetic nits when structural issues exist.
- Do **not** spawn nested subagents unless explicitly asked.
