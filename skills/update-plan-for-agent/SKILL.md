---
name: update-plan-for-agent
description: Expand an existing implementation plan for another coding agent and write it in Simplified Technical English.
argument-hint: "[plan path, plan artifact, or pasted plan]"
disable-model-invocation: true
---

# Spec Plan

Turn the supplied plan into an implementation-ready plan for a lower-capability coding agent. Edit the plan itself. Preserve its intent and scope while replacing discovery work, ambiguity, and design choices with verified instructions.

Work on the plan only. Leave production code unchanged.

## Process

1. Locate the source plan and its output destination. Prefer the plan artifact or file named by the user; otherwise use the plan in the current conversation. If no plan is available, ask for it. Done when the exact plan to rewrite and where to write it are known.

2. Ground the plan in the repository:
   - Read applicable agent guidance and command documentation.
   - Trace the relevant call paths, data flow, types, schemas, and tests.
   - Inspect existing implementations that establish the pattern to follow.
   - Verify every referenced path and symbol. Mark files that must be created as new.

   Done when every proposed change has a verified landing point and the current behavior is understood well enough to explain why each change belongs there.

3. Close implementation decisions:
   - Resolve choices from repository conventions and the stated goal.
   - Ask the user only about missing product decisions whose answers materially change behavior or architecture.
   - Record necessary assumptions explicitly.
   - Convert alternatives such as "consider," "maybe," and "either" into one selected approach with a reason.

   Done when the implementing agent will not need to choose behavior, architecture, ownership boundaries, or testing seams.

4. Rewrite the source plan using the structure below and the ASD-STE100 rules in this skill. Keep useful existing content, but replace vague instructions with concrete implementation packets. Done when the quality gate passes for every step.

## Simplified Technical English

Write the completed plan in Simplified Technical English (ASD-STE100):

- Use short, direct sentences in the active voice.
- Give one instruction in each sentence.
- Use one term for each concept. Do not use synonyms for variety.
- Use simple words when they preserve the technical meaning.
- Keep approved code identifiers, file paths, commands, and domain terms unchanged.
- Define each necessary technical term at its first use.
- Use imperative verbs for implementation steps.
- Use vertical lists for conditions, alternatives, and sequences.
- Avoid idioms, contractions, rhetorical language, and ambiguous pronouns.
- Keep procedural sentences to 20 words or fewer when practical.
- Keep descriptive sentences to 25 words or fewer when practical.

## Plan structure

# <Plan title>

## Goal

State the observable outcome and why it is needed.

## Current behavior

Describe the relevant existing flow, naming exact files, symbols, contracts, and boundaries. Include only context needed to implement the change.

## Implementation approach

State the selected design, responsibility boundaries, data flow, and important invariants. Explain decisions that are not obvious from repository conventions.

## Implementation steps

Use an ordered list. Each step is an implementation packet containing:

1. **Outcome** - the concrete state established by this step.
2. **Code locations** - exact file paths and symbols to add or modify. Identify new files.
3. **Changes** - precise logic, control flow, types, interfaces, schemas, state transitions, and interactions to implement.
4. **Behavior** - expected success, empty, boundary, and failure behavior relevant to the step.
5. **Tests** - exact test files or new test locations, setup, cases, assertions, and the behavior each case proves.
6. **Dependencies** - earlier steps or migrations that must exist first.

Use short pseudocode or type shapes only when they encode a contract or algorithm more precisely than prose. Follow existing abstractions and name the precedent.

## Acceptance criteria

List checkable, externally observable outcomes. Map each criterion to an implementation step and test, or identify the verification method.

## Verification

List the repository-native commands to run, from narrow checks to the required final checks. Include any manual verification with exact setup, action, and expected result.

## Assumptions and decisions

Record assumptions made while refining the plan and decisions that constrain implementation.

## Out of scope

Name adjacent work deliberately excluded.

## Quality gate

The plan is complete only when all statements below are true:

- Every requested behavior is represented by an implementation step and acceptance criterion.
- Every step names verified files and symbols, or clearly marks a file as new.
- Every step specifies behavior and tests deeply enough to implement without further design work.
- Interfaces, schemas, data transformations, errors, edge cases, and ownership boundaries are explicit wherever affected.
- Existing patterns to copy are named by path and symbol.
- Tests prove behavior rather than implementation details, and every acceptance criterion has a verification path.
- Commands come from current repository guidance or configuration.
- Steps are dependency-ordered and do not hide required work behind phrases such as "wire up," "update logic," "handle errors," or "add tests."
- The plan contains no unresolved alternatives. Remaining unknowns are explicit blockers requiring user input.
- The plan is self-contained apart from the repository files and links it names.
- The plan uses Simplified Technical English consistently without changing code or domain terminology.

Write the completed plan back to its source artifact or file. If the source exists only in chat, return the full rewritten plan. Report the updated location and any unresolved blockers.
