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

## Rubric

Read and apply [rubric.md](rubric.md) as the **complete** review rubric —
tone, approval bar, output ordering, verification bar, and the code-judo /
1k-line / spaghetti rules. It points at
`~/configs/agents/rules/code-style.md` for style preferences; read that too.

## Inputs

The review needs the diff (`git diff <base>...HEAD`, default base `main`) and
the full contents of every file it touches. Read the files — a diff alone
cannot show whether a change fits the module around it.

If your prompt already contains both, use them and read nothing further.

## Constraints

- Apply the rubric **only** to what the diff and file contents show.
- Trace cross-file impact when the change touches module boundaries.
- Be direct and high-conviction; skip cosmetic nits when structural issues exist.
- Verify any claim about tool, API, or config behavior before asserting it. See
  "Verify Before You Assert" in the rubric.
- Do **not** spawn nested subagents unless explicitly asked.

<!--
The `code-reviewer` subagent (claude/agents/code-reviewer.md) owns the procedure
for collecting inputs. This file owns the standard. Keep it that way: the two
drifted once already, when both spelled out the collection steps.
-->
