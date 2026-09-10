---
name: writing-plans
description: Use when a settled requirement needs a multi-step implementation plan with dependencies, coordination, or reviewable acceptance boundaries.
---

# Writing Plans

Write enough for another capable engineer to execute without inventing product
decisions. Detail follows risk: a small local change needs a short plan; a
public contract, migration, or coordinated change needs explicit interfaces,
failure handling, and rollout. Do not turn a plan into a second implementation.

## Header

Save plans under `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` unless
the project says otherwise. Start with:

```markdown
# [Feature] Implementation Plan

**Goal:** [one sentence]
**Spec:** [approved spec path, or `none - requirements supplied directly`]
**Authorization:** [source of the settled requirement and execution authority]
**Architecture:** [short approach and boundaries]
**Verification:** [checks that can support the acceptance claims]
```

When the Spec line already records the requirement source and its authority —
the common `none - requirements supplied directly` case — Authorization may
fold into that line instead of a separate field.

Read the referenced spec directly. Do not duplicate it; point to the sections
that govern a task.

## Plan structure

Before listing steps, identify the files or components that change and the
responsibility each owns. Group edits that must be tested together. Split work
only when a reviewer could meaningfully accept one part while rejecting the
other; batch small same-shape edits.

Each task should state:

- the files or public boundary involved;
- the behavior or artifact it delivers;
- dependencies on earlier work, if any;
- the check that can establish it, with an expected result when useful.

Name exact functions, fields, paths, or error behavior only where the existing
interface or settled design makes them relevant. Leave implementation choices
open when they do not affect acceptance. Classify testing by behavior impact,
not file type; documentation-only edits need no synthetic code RED/GREEN.

For behavior changes, use `test-driven-development`. If the router has identified
missing test infrastructure or another applicable alternative, record that
constraint and the focused regression or manual check, its limits, and why it
supports the requested claim; the plan does not independently waive TDD.
Do not require a test
inventory, exact prose, or a commit after every tiny step unless the project
has a real consumer for that record.

## Example task

```markdown
### Task 1: Validate the new input boundary

**Files:** `src/validator.py`, nearest existing validator tests
**Behavior:** reject malformed input with the existing error contract and
accept the documented compatible form.
**Dependencies:** none.
**Verification:** focused test for both branches; then the owning suite.

- [ ] inspect the existing boundary and add the smallest regression test
- [ ] implement the validation using the existing helper
- [ ] run the focused check and owning suite
- [ ] remove temporary probes and review the resulting diff
```

This is a shape, not a requirement to copy every line. A task can be shorter
when the change is mechanical; a risky task should expose its interfaces and
rollback plan.

## Self-review and handoff

Check once that the plan covers the approved goal, non-goals, changed
interfaces, dependencies, and verification. Recheck only the affected section
when a producer, consumer, or requirement changes. Preserve unresolved product
decisions for `brainstorming` instead of guessing.

If execution is already authorized for the settled scope, proceed with the
plan and retain the exact commands and outputs used for acceptance. Otherwise
hand the concrete plan to the user for approval. Choose `executing-plans` for
direct execution or `subagent-driven-development` when independent work
packages and their reviews justify the coordination cost.
