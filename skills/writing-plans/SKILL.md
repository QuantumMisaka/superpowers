---
name: writing-plans
description: Use when a settled requirement needs a multi-step implementation plan with dependencies, coordination, or reviewable completion criteria.
---

# Writing Plans

Use for complex work that benefits from structured sequencing, dependency coordination, or clear handoff deliverables. If an existing plan covers the scope, reuse and update it directly.

Write clear guidance so a capable engineer or agent can execute without guessing product or architectural decisions, while leaving ordinary implementation choices to the executor.

## 1. Ground the Plan

Save plans as Markdown under `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` (or the project's established path):
- Make the **goal, requirement source, technical approach, and verification strategy** immediately clear.
- Link to the governing spec or user requirement rather than duplicating its prose; note any relevant scope or authorization conditions.
- Markdown is the single editable source. For an optional HTML reading view, see the [presentation reference](../brainstorming/references/presentation.md).

## 2. Organize by Verifiable Outcomes

Structure tasks around meaningful, independently checkable increments:
- **Cohesive grouping**: Group changes that belong together and can be verified together; batch small, same-shape edits into a single task.
- **Clear deliverables and dependencies**: For each task, state **what outcome it delivers, what interfaces or files it touches, how to verify it, and what downstream task it unblocks**. Specify exact paths, signatures, or values only when an external contract requires them.
- **Proportional verification**: Separate immediate correctness checks (unit/integration tests via `test-driven-development`) from longer-running usage observations or benchmark evaluations, scheduling each according to real dependencies.
- **Formatting**: Use checkboxes (`- [ ]`) when helpful for tracking progress. If using the SDD `task-brief` extractor, format task headers as `### Task N: Title`.

Example of a well-scoped task:
> **Task 2: Support new input format in request validator**
> Extend the request validator to accept the new input format and return clear errors on invalid payloads. Verify both valid and invalid cases and run the validator test suite. Unblocks Task 3 (endpoint wiring).

## 3. Review and Execute

Verify that the plan covers the agreed goal, dependencies, and completion criteria (using [plan-document-reviewer-prompt.md](plan-document-reviewer-prompt.md) when an independent check is helpful).

- When the scope is authorized, proceed directly to implementation (`executing-plans` for direct execution, or `subagent-driven-development` when independent work packages benefit from delegation).
- If a key decision or external execution authorization is still needed, present the plan and ask for that specific decision.
