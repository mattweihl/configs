---
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "**/*.{py,go,rs,rb,java,kt,swift,c,h,cc,cpp,hpp,cs}"
  - "**/*.{sh,bash,zsh,lua,sql}"
---

# Code Style

Follow repository conventions, formatters, and linters first. Apply these preferences where they leave a choice.
Translate each preference to the language's idioms.

## Core Principles

- Write code whose behavior is easy to follow from its inputs to its result.
- Keep code simple. Add complexity only when it is clearly justified.
- Improve touched code when the cleanup stays local and supports the requested change.
- Keep related work together. Prefer direct operations over layers that only pass work along.
- Favor explicitness over hidden behavior.

## Naming

- Use descriptive names that encode intent and domain meaning.
- Avoid abbreviations unless they are universally understood.
- Name booleans as predicates according to the language's conventions.
- Prefer positive boolean names by default, but choose the form that reads best in guard clauses and avoids negation.

## Functions

- Give each function a coherent purpose. Keep related work together when it shares data or computation.
- Extract helpers when they clarify intent, isolate a policy, or remove meaningful duplication.
- Preserve debugging locality: keep a sequence together when understanding its helpers requires repeatedly opening their implementations.
- Judge function length by comprehension. Keep a readable algorithm together regardless of line count.
- Prefer early returns and guard clauses; avoid `else` after a terminal branch.
- Keep nesting shallow where practical. Extract helpers when they improve comprehension, not at a fixed nesting depth.
- Avoid boolean function arguments. Prefer explicit mode values:
  - In TypeScript, prefer enum-like `as const` objects plus union value types (instead of native `enum`).
  - In other languages, use the idiomatic equivalent (`enum`, tagged union, constants, or sealed variants).
  Use separate functions or structured options when that reads better.
- Use positional arguments for small signatures. At 4+ arguments, consider a structured input when the values form a concept.
- Follow the language's return conventions. Use explicit returns for early exits.

## Control Flow

- Simple ternaries are fine.
- Never use nested ternaries.
- Choose direct branches, local assignment, or a helper based on which makes the complete operation easiest to follow.

## Data and Types

- Preserve caller-owned inputs unless the contract explicitly permits mutation or transfers ownership.
- Use local mutation for accumulators, builders, and owned buffers. Copy when isolation or value semantics require it.
- Use loops or collection transforms, whichever makes the operation clearest. Avoid unnecessary intermediate collections and repeated traversal.
- Prefer a single pass when related operations can share work without obscuring their purpose.
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

## Organization

- Group related operations and data by module. Keep private helpers colocated; allow multiple cohesive exports.
- Order dependencies from most distant to most local (external -> internal -> local).
- Prefer configuration-style APIs over wrapper-heavy composition chains.
- Choose data structures around the operations the module performs.
- Use direct branches or tagged data for a fixed set of cases. Introduce runtime polymorphism when implementations need independent extension.
- Let module internals use their data representation directly. Preserve encapsulation at the module boundary.

## Errors

- Use the language's idiomatic error mechanism.
- Prefer exceptions for unexpected failures in languages that support them.
- In languages that prefer explicit error returns, follow that ecosystem's conventions.
- Never swallow errors silently.
- Add context while propagating errors. Log errors once where the program handles them.

## Comments

- Prefer self-documenting code.
- Add comments for intent, constraints, or non-obvious tradeoffs ("why", not "what").
- TODOs must include context so future cleanup is actionable.

## Additional Notes

- Read `~/configs/agents/reference/code-style-examples.md` only when a preference
  is ambiguous in the current language.
