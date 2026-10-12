---
name: super-code-review
description: >
  Review a diff for correctness and maintainability. Use for strict checks on
  structure, abstractions, branching, module depth, and code style. Do not use
  for a style-only review or a whole-codebase architecture scan.
metadata:
  opencode/slash: "true"
---

# Super Code Review

Review changed code for functional risk and long-term maintainability.

## Rubric

Read and apply [rubric.md](rubric.md). It defines the evidence bar, finding
categories, output format, and approval bar.

Read `~/configs/agents/rules/code-style.md` for style preferences.

Read `../codebase-design/SKILL.md` only when a proposed refactor adds or moves
a module, interface, seam, or adapter.

## Inputs

Use the supplied diff as the change scope. When you collect the diff, state
whether it includes committed, staged, unstaged, and untracked changes.

Read enough surrounding code to understand each meaningful change. Inspect
direct callers, callees, tests, contracts, and comparable implementations when
they provide material evidence. Read whole files only when their full context
matters.

## Constraints

- Report only findings caused or exposed by the change.
- Use wider repository context as evidence, not as extra review scope.
- Trace cross-file impact when the change touches a module interface or seam.
- Prefer a few supported findings over speculative improvement ideas.
- Follow the verification rules in the rubric.
- Do **not** spawn nested subagents unless explicitly asked.

<!--
The `code-reviewer` subagent (claude/agents/code-reviewer.md) owns the procedure
for collecting inputs. This file owns the standard. Keep it that way: the two
drifted once already, when both spelled out the collection steps.
-->
