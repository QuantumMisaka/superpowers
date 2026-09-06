---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch, observable behavior, interfaces, constraints, source references and acceptance checks. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

The approved spec may be HTML or Markdown. Read the supplied path directly.
For HTML, use section IDs when referencing requirements; for Markdown, use
headings. Do not duplicate the spec into the plan. Plans remain Markdown unless
the human partner explicitly requests another format.
If requirements were supplied directly and no spec exists, record that instead
of inventing a spec path.

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Bite-Sized Task Granularity

**Each step is a concrete action sized to the deliverable:**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Spec:** [path to the approved spec/design doc — e.g. `docs/superpowers/specs/<exact-approved-file>`,
or `none - requirements supplied directly`. The plan argues from the spec, so the spec
travels with it; executors read both]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

## Global Constraints

[Only the spec's cross-task invariants — version floors, dependency limits,
naming and copy rules, platform requirements — one line each. Reference spec
sections for detail instead of reproducing their prose. Every task's requirements
implicitly include this section.]

---
```

## Task Structure

The code below illustrates a behavior-changing task. Adapt steps to the actual
verification boundary; document/config tasks do not need a synthetic TDD cycle.
Provide code only for a critical algorithm, an ambiguous contract or a necessary
reproducer. Ordinary steps specify behavior and reference the existing API or
pattern by exact path and symbol.

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`

**Test strategy:**
- Behavior boundary: [exact public behavior this task changes]
- Existing suite to extend: `exact/path/to/test-file`
- New test file justification: [none, or why no existing suite owns the behavior or the task introduces a new independently runnable boundary]
- Temporary probes: [exact paths and required removal before commit, or none]

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Refactor the test portfolio**

Consolidate cases that protect the same behavior through the same setup,
remove temporary probes, and run the owning suite again with an exact command
and expected output.

- [ ] **Step 6: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

Replace every bracketed test-strategy field with concrete repository facts in
the generated plan; the brackets are template guidance, not valid plan output.

## Executable Task Contracts

Each task supplies exact files, observable behavior (including errors), consumed
and produced interfaces, applicable constraints, and acceptance commands with
expected results. A worker must be able to implement it without inventing a
product decision. Concrete test cases can be specified as inputs and expected
outputs; full implementation and test source are not required plan artifacts.

Reference a shared contract by exact path/section or task interface rather than
copying its code. Ensure that reference is included in the worker's brief and
accessible to it. Supply code for unresolved algorithmic detail only after the
decision is settled; a placeholder such as "add validation" is not a contract.
Undefined APIs, TODO decisions and missing expected results must be resolved.

## Self-Review

Check spec coverage, task acceptance and producer/consumer interface consistency
once. Fix gaps inline. Retain a short review record naming the plan/spec revision,
checked requirements and critical interfaces, plus any unresolved items. A clean
check needs no per-task-pair table. This is planning evidence, not implementation
acceptance; independent task and final reviews still inspect actual changes.

Executors can reuse this record while its inputs remain unchanged. Changes to
the plan, spec or relevant repository interfaces invalidate the affected part,
which must be checked again. Missing evidence requires the initial check, not an
assumption that an earlier author handled it.

## Execution Handoff

After self-review, give the exact plan path. If the human partner has already
authorized execution of the settled requirements, record that source in the
plan and proceed within its scope. An approved plan or an active goal with
settled, authorized scope does not need another approval ceremony. A goal is
not permission to invent scope or decide unresolved architecture. Otherwise,
ask for approval of the concrete plan; design agreement alone is insufficient.
Resolve implementation-changing ambiguity through brainstorming's Grill,
using repository evidence before asking.

Honor an execution mode already chosen by the user or project. When none was
chosen, select and record the lightest reliable mode without another question:

- Use **superpowers:subagent-driven-development** when scoped implementation
  handoffs and independent task review justify its coordination cost.
- Use **superpowers:executing-plans** for direct execution when that is simpler,
  including ordinary bounded work. Availability of subagents alone does not
  require SDD; independent evidence gathering can still be delegated.

Only a choice that changes an unapproved scope or external-action boundary
needs new authorization. This handoff preserves existing authorization
(2026-09-05 authorized workflow consistency review, F2/F4).
