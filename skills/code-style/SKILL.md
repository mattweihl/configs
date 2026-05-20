---
name: code-style
description: Matthew Weihl's language-agnostic coding style and clean-code review preferences. Use when writing, refactoring, or reviewing code to keep naming, function design, error handling, and structure aligned with these preferences.
disable-model-invocation: true
---

# Code Style

Apply these preferences across languages by translating each rule to the language's idioms.

## Core Principles

- Optimize for readability first. Prefer clear, boring code over clever code.
- Keep code simple. Add complexity only when it is clearly justified.
- Leave touched code cleaner than you found it.
- Prefer immutable data flow unless there is a strong reason not to.
- Favor explicitness over hidden behavior.

## Naming

- Use descriptive names that encode intent and domain meaning.
- Avoid abbreviations unless they are universally understood.
- For booleans, use `is` / `has` / `should` / `can` prefixes.
- Prefer positive boolean names by default, but choose the form that reads best in guard clauses and avoids negation.

## Functions

- Functions should do one thing and have one reason to change.
- Target small functions. Around 35-40 lines is a soft warning threshold, not a hard limit.
- Prefer early returns and guard clauses; avoid `else` after a terminal branch.
- Keep nesting shallow. Max 2 levels before extracting helpers.
- Avoid boolean function arguments. Prefer explicit mode values:
  - In TypeScript, prefer enum-like `as const` objects plus union value types (instead of native `enum`).
  - In other languages, use the idiomatic equivalent (`enum`, tagged union, constants, or sealed variants).
  Use separate functions or structured options when that reads better.
- Use positional arguments for small signatures; at 4+ arguments, switch to a structured input object/record/struct.
- Treat 4+ arguments as a smell: verify whether the function should be split.
- Prefer explicit `return` statements in function bodies.

## Control Flow

- Simple ternaries are fine.
- Never use nested ternaries.
- If branching becomes complex, extract a helper function first; only use mutable temporary assignment as a fallback.

## Data and Types

- Never mutate inputs.
- Prefer creating new values instead of mutating existing ones.
- Use language-native collection transforms by default (`map`/`filter`/`reduce` style).
- Use loops only when transform chains become harder to read or early termination is required.
- In typed languages, prefer named contracts over large inline structural types.
- Keep type definitions close to usage; extract shared types only when reuse is real and coupling stays clean.

## Constants and Literals

- Replace literals with named constants when the meaning is not immediately obvious.
- Keep universally obvious literals inline when they improve readability (for example, checks against 0 or 1).

## Null and Optional Values

- Use language shorthand for safe value access when reading nested data.
- Use explicit checks when nullability drives control flow decisions.

## Strings

- Use interpolation for composition.
- For iterative accumulation, use builder/join patterns.
- Avoid concatenation-based assembly.

## Organization

- Prefer one main export per file and keep private helpers colocated.
- Order dependencies from most distant to most local (external -> internal -> local).
- Prefer configuration-style APIs over wrapper-heavy composition chains.

## Errors

- Use the language's idiomatic error mechanism.
- Prefer exceptions for unexpected failures in languages that support them.
- In languages that prefer explicit error returns, follow that ecosystem's conventions.
- Never swallow errors silently.
- Handle errors at boundaries and return/log meaningful context.

## Comments

- Prefer self-documenting code.
- Add comments for intent, constraints, or non-obvious tradeoffs ("why", not "what").
- TODOs must include context so future cleanup is actionable.

## During Reviews

- Review from correctness and maintainability first, style second.
- Flag violations of these principles with concrete, actionable suggestions.
- Use numbered findings in severity order when giving review feedback.
- Call out missing tests for business logic changes and risky paths.

## Additional Notes

- Use this file as the source of truth for style decisions.
- For language examples and edge-case translations, read [examples.md](examples.md).
