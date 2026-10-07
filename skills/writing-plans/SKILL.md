---
name: writing-plans
description: Use when a settled requirement needs a multi-step implementation plan with dependencies, coordination, or reviewable acceptance boundaries.
---

# Writing Plans

Use for work selected for plan-based execution. Reuse an adequate existing
plan; a clarified question or several edits alone does not require one.

Write enough for a capable engineer to continue without inventing product
decisions. Preserve the decisions they cannot make alone and leave ordinary
implementation choices open. Detail follows risk and handoff needs.

## Ground the plan

Save new plans as Markdown under
`docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`, unless the project has
another convention. Make the goal, requirement source, approach and verification
easy to find; these are information needs, not mandatory header fields.
Link and read the governing spec rather than copying it. When requirements
come directly from the user, identify that source instead. Record authorization
where it is needed to distinguish implementation from an unapproved action.

Markdown is the editable source. If an HTML reading view would help, use the
[presentation reference](../brainstorming/references/presentation.md).

## Organize by outcomes

Group changes that belong together and can be checked together. Split a task
when its result can be meaningfully accepted independently, or dependencies
and handoff make the boundary useful. Batch small same-shape edits.

Describe each task's deliverable and how to check it. Add affected components,
dependencies, interfaces, failure handling or rollout order where they help
execution. Expected file locations guide discovery; they are not an edit quota.
Specify exact paths, signatures and values when an existing contract or agreed
design requires them. Leave equivalent internal implementations available.

For example, a task may simply say:

> Extend the existing request validator to reject the newly excluded input
> while preserving documented valid inputs. Check both cases and run the
> owning suite. The parser task depends on this behavior.

A cross-owner migration needs more detail about interfaces, sequencing and
recovery. Neither case needs a transcript of the future code or a commit for
every small step. Use checkboxes when they help resume work. If using the
optional SDD `task-brief` extractor, use `Task N` headings (for example
`### Task N: Title`);
other plans need no fixed heading syntax.

## Review and continue

Check coverage of the agreed goal, important boundaries, dependencies and
verification. Consider realistic inputs and failures the spec leaves implicit;
add meaningful checks to the affected task. Recheck changed parts when new
facts affect the plan; unresolved product choices return to `brainstorming`.

Follow the router's verification guidance and use `test-driven-development`
for applicable behavior changes. If a different check is warranted, state
the reason and material limits where they affect acceptance. Documentation
edits need no synthetic code RED/GREEN.

When the settled scope is already authorized, continue with implementation;
writing the plan does not reopen that approval. Otherwise present the concrete
plan and ask only about the missing decision or authority. Use `executing-plans`
for direct execution, or `subagent-driven-development` when independent work
packages justify the coordination. Preserve actual acceptance evidence.
