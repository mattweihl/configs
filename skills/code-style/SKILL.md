---
name: code-style
description: >
  Matthew Weihl's language-agnostic code style and clean-code preferences.
  Use when reviewing code you did not write, when judging whether existing code
  meets these standards, or when the user asks about style, naming, function
  design, control flow, error handling, or structure. Also use on request via
  /code-style.
---

# Code Style

## Read the rules first

The preferences live in one file, which this skill does not duplicate:

- `~/configs/agents/rules/code-style.md` — the complete rule set.
- `~/configs/agents/reference/code-style-examples.md` — per-language examples.
  Read this only when the preferred pattern is ambiguous in the language at hand.

Read the rule file now, before you review anything.

<!--
Same file, two delivery paths, on purpose:

- As a user rule (linked into ~/.claude/rules/), it loads automatically whenever
  the agent reads a matching source file. That covers code being *written*.
- As this skill, it can be invoked deliberately against code that no rule fired
  for -- a pull request, a pasted diff, a repo you are reading but not editing.

The rule file is the single source of truth. Do not copy its contents here.
-->

## Reviewing someone else's code

The rule set was written for code being authored. Applying it to code you did
not write needs a different bar:

- Judge the code as it is. Do not rewrite it in your own style.
- Separate defects from preferences. State which one each finding is.
- A rule violation in untouched code is not a review finding. Raise it only when
  the change under review touches it, or when it causes the bug being discussed.
- Weight findings by blast radius: a leaked abstraction outranks a naming nit.
- Number findings in severity order.
- Give the concrete replacement, not the principle. "Extract the tier lookup to
  `getDiscountRate`" beats "this function does too much".
- Say when the code is fine. A review that finds nothing is a valid review.

For a full structural review — abstraction health, spaghetti growth, file-size
discipline — use the `super-code-review` skill instead. This one is about style.
