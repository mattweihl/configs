# Super Code Review Rubric

Review the change for functional risk and maintainability. Report only problems
that the change causes or exposes. Use wider repository context as evidence.

## Review order

Review each meaningful change in this order:

1. Correctness, security, data loss, and behavior regressions.
2. Missing tests for changed business logic and risky paths.
3. Maintainability regressions in structure, control flow, types, and ownership.
4. Refactoring opportunities that materially reduce existing complexity.
5. Code-style violations in changed or directly affected code.

This skill complements a specification review. It does not prove that the
change implements every requirement.

## Finding categories

Assign one category to each finding:

- **Defect**: The change can produce incorrect, unsafe, or unintended behavior.
- **Maintainability regression**: The change demonstrably makes future work
  harder, riskier, or more scattered.
- **Code-style preference**: The change conflicts with the repository rules but
  has no demonstrated functional or structural cost.
- **Refactoring opportunity**: An optional redesign can remove material
  complexity without changing behavior.

Defects and maintainability regressions can block approval. Code-style
preferences and refactoring opportunities do not block approval by default.

Do not promote a possible alternative into a blocker. Show the current cost,
the evidence, and why the remedy reduces that cost.

## Functional risk

Trace inputs, outputs, state changes, errors, and externally visible behavior.
Check changed edge cases and failure paths. Check concurrency, ordering, and
atomicity when the change relies on them.

Call out missing tests when they leave changed behavior or risky paths
unverified. Do not request tests that only mirror the implementation.

## Maintainability

Look for these regressions:

- Scattered feature checks or repeated conditionals.
- New modes represented by booleans, nullability, casts, or loose object shapes.
- Feature logic in a module that does not own the concept.
- Duplicate logic beside an established canonical implementation.
- Partial updates that can leave related state inconsistent.
- Unnecessary sequential orchestration of independent work.
- Hidden behavior, brittle conventions, or generic mechanisms that obscure a
  simple data shape.
- Wrappers or helper layers that add interface without hiding complexity.
- Refactors that move complexity without reducing concepts or coupling.

Prefer direct code when a new abstraction would only rename the same work.
Prefer a refactor when it removes branches, concepts, duplication, or leaked
knowledge.

Treat 1,000 lines as an investigation trigger, not a verdict. Consider
cohesion, generated content, language conventions, navigation cost, and change
frequency. A threshold crossing is not sufficient evidence for a finding.

## Refactoring quality

When a remedy adds or moves a module, interface, seam, or adapter, read and
apply `../codebase-design/SKILL.md`.

A useful refactor must improve at least one of these properties:

- **Locality**: Related knowledge and changes stay together.
- **Depth**: A smaller interface hides more useful behavior.
- **Concept count**: The reader tracks fewer modes, branches, or layers.
- **Test surface**: Tests exercise behavior through the same interface as callers.

Apply the deletion test. If removing the proposed module makes its complexity
disappear, the module is probably a pass-through. Do not prescribe a state
machine, helper, or abstraction without evidence that it improves the design.

## Code style

Read `../code-style/references/rules.md` as the source of truth. Repository
conventions, formatters, and linters take precedence.

Apply style rules to changed or directly affected code. Separate code-style
preferences from defects and maintainability regressions.

## Evidence and verification

Support every finding with code or observed behavior. Prefer repository tests,
documentation, vendored source, tool help, and primary documentation.

Use wider context when it establishes callers, contracts, ownership, or an
existing implementation. Do not report unrelated problems found during that
search.

Run code only when execution is safe, read-only, and useful. Use disposable
inputs for scripts. Do not execute untrusted or side-effecting code merely to
strengthen a review comment.

Label a material claim as unverified when available evidence cannot establish
it. Do not state uncertain behavior as fact.

## Output

List findings first. Order them by user impact, not by rubric section.

Each finding must include:

1. Severity and category.
2. File and line.
3. The observed cost or risk.
4. Supporting evidence.
5. A concrete remedy.
6. `Blocking` or `Optional` status.

Use these severity levels:

- **P0**: Immediate data loss, security compromise, or unusable behavior.
- **P1**: Likely serious regression without a practical workaround.
- **P2**: Real defect or maintainability regression with limited impact.
- **P3**: Code-style preference or optional refactoring opportunity.

Keep the finding title concise. Keep summaries secondary to findings. Skip
cosmetic nits while more important findings remain.

If no findings remain, say so explicitly. State any residual risk, unverified
behavior, or testing gap.

## Approval bar

Do not approve while a supported blocking finding remains. Do not block solely
on file length, personal taste, or the existence of another valid design.

Approve when the change has no demonstrated defect or maintainability
regression. List worthwhile redesigns separately as optional refactoring
opportunities.
