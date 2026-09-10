---
name: writing-skills
description: Use when creating, editing, or validating a reusable agent skill or its supporting guidance.
---

# Writing Skills

A skill is a reusable technique, pattern, or reference. Write the smallest
guidance that helps an agent produce the intended result, and validate that
result with evidence appropriate to the skill's risk. This skill is not a
license to add process gates to every repository task.

## Before writing

1. Define the user-facing outcome, trigger, and safety boundary.
2. Inspect existing skills and supporting references so the new guidance has a
   clear owner and does not duplicate another contract.
3. Choose a validation method:
   - a reference skill: check discovery, links, examples, and factual usage;
   - a behavioral skill: run one or more realistic baseline/candidate scenarios
     when feasible, including a case that could expose the target failure;
   - a structural contract: use a focused check for required metadata, fields,
     routing tokens, or executable behavior.

The baseline/candidate comparison is useful evidence, not a universal ritual.
Use more scenarios when the consequence or ambiguity warrants them, and stop
when the target behavior is adequately exercised. A finite sample does not
prove every model or transport.

## Authoring shape

Keep `SKILL.md` focused:

- frontmatter with `name` and a concise trigger description in the skill's
  working language; no fixed English opening is required;
- a short overview and when/not-when boundary;
- the core pattern, decision points, and one good example;
- common mistakes and links to heavy references or reusable tools.

Use a positive recipe or a conditional keyed to an observable state when the
problem is output shape or omission. Reserve prohibitions for real safety,
authorization, data-loss, or compatibility boundaries. Explain a judgment once;
cross-reference it instead of repeating it in every skill.

Descriptions help discovery and should not replace the body. Supporting files
are appropriate for long references, executable helpers, templates, or tests;
they are not a reason to create a new process ledger.

## Validate and refine

Run the narrowest structural or behavioral checks that support the intended
claim. For an existing implementation, a fresh candidate run plus a focused
baseline comparison is enough when a true RED run is unavailable or would
require mutating shared state. Record the scenario, observed decision/output,
and remaining uncertainty.

If validation reveals a real failure, revise the smallest relevant guidance and
repeat the affected check. Stop when the documented outcome is reliable for the
tested boundary; do not keep adding hypothetical loophole clauses until the
skill is “bulletproof.”

## Scope and release

TDD remains the right method for production behavior changes. A skill edit is
documentation: apply TDD-style evidence when it changes a behavior contract,
but do not force a synthetic code RED/GREEN cycle or exact prose assertions on
every wording change. Review related skills together when they share a routing
or evidence contract.

Commit, publish, deploy, or push a skill only when the surrounding task and
user authorization include that external action. Local validation is complete
without a per-skill deployment ceremony.

For the optional scenario method, see
[testing-skills-with-subagents.md](testing-skills-with-subagents.md). For
official authoring guidance, see [anthropic-best-practices.md](anthropic-best-practices.md).
