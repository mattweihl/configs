---
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "**/*.{py,go,rs,rb,java,kt,swift,c,h,cc,cpp,hpp,cs}"
  - "**/*.{sh,bash,zsh,lua,sql}"
---

<!--
Path-scoped user rule. Loads only when the agent reads a matching file, so it
costs nothing on sessions that never touch code.

Was a skill (skills/code-style/SKILL.md). It carried
`disable-model-invocation: true`, which made it user-invocable only -- the model
never loaded it on its own -- alongside `always-apply: true`, which is a Cursor
frontmatter field that Claude Code ignores. The net effect was a style guide
that applied only when typed as /code-style by hand. A rule is the mechanism
that actually means "always apply".
-->

# Code Style

Apply these preferences across languages by translating each rule to the language's idioms.

## Core Principles

- Write code whose behavior is easy to follow from its inputs to its result.
- Keep code simple. Add complexity only when it is clearly justified.
- Leave touched code cleaner than you found it.
- Keep related work together. Prefer direct operations over layers that only pass work along.
- Favor explicitness over hidden behavior.

## Naming

- Use descriptive names that encode intent and domain meaning.
- Avoid abbreviations unless they are universally understood.
- For booleans, use `is` / `has` / `should` / `can` prefixes.
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
- Prefer explicit `return` statements in function bodies.

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
- Avoid concatenation-based assembly.

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
- Handle errors at boundaries and return/log meaningful context.

## Comments

- Prefer self-documenting code.
- Add comments for intent, constraints, or non-obvious tradeoffs ("why", not "what").
- TODOs must include context so future cleanup is actionable.

## During Reviews

- Judge the complete operation, not how small its individual pieces look.
- Flag violations of these principles with concrete, actionable suggestions.
- Use numbered findings in severity order when giving review feedback.
- Call out missing tests for business logic changes and risky paths.

## Additional Notes

- Use this file as the source of truth for style decisions.
- For language examples and edge-case translations, read
  `~/configs/agents/reference/code-style-examples.md`. It is deliberately not a
  rule and is not loaded for you — a rule with no `paths:` frontmatter loads in
  every session, and 160 lines of examples are not worth that. Read it only when
  the preferred pattern is ambiguous in the current language.
