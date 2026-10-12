---
name: code-style
description: >
  Matthew Weihl's language-agnostic preferences for straightforward, readable code.
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

## Reviewing someone else's code

The rule set was written for code being authored. Applying it to code you did
not write needs a different bar:

- Judge the code as it is. Do not rewrite it in your own style.
- Judge the complete operation, not how small its individual pieces look.
- Separate defects from preferences. State which one each finding is.
- A rule violation in untouched code is not a review finding. Raise it only when
  the change under review touches it, or when it causes the bug being discussed.
- Weight findings by blast radius: a leaked abstraction outranks a naming nit.
- Number findings in severity order.
- Give a concrete replacement. For example: "Keep this calculation in the loop so its inputs remain visible."
- Call out missing tests for business logic changes and risky paths.
- Say when the code is fine. A review that finds nothing is a valid review.

For a full structural review — abstraction health, spaghetti growth, file-size
discipline — use the `super-code-review` skill instead. This one is about style.
