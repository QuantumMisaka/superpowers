---
name: subagent-driven-development
description: Use for an existing implementation plan when independent work packages benefit from delegated context, ownership, and review.
---

# Subagent-Driven Development

Coordinate multi-package plans by delegating independent work packages to specialized subagents, reviewing their results against requirements, and integrating the verified outcomes. Use direct execution (`executing-plans`) when tasks are tightly coupled or small enough to finish directly.

## 1. Prepare the Workspace and Packages

1. Read the plan and linked design spec once, reusing existing progress records.
2. Select the workspace via `using-git-worktrees` according to the project's collaboration mode (stay on `main` for `main`-first repos unless isolation has a concrete benefit).
3. Group related edits into packages with independently verifiable outcomes and identify which packages must wait for others.

## 2. Dispatch Work Packages

Choose a [role by deliverable](../using-superpowers/references/role-selection.md) and supply a focused brief ([implementer-prompt.md](implementer-prompt.md)):
- **Goal and completion criteria**: Observable behavior or artifact to deliver, plus existing verification commands.
- **File ownership and shared state**: Separate agent contexts share the checkout and Git index. Assign disjoint file write sets when packages run concurrently, and serialize Git index, generated-file, or integration steps.
- **Attribution baseline**: Record `BASE` before committed work, or capture pre-dispatch diffs/untracked state for dirty worktrees so package changes are cleanly attributable.

For a document, give one writer ownership of the argument and voice for its genre and primary reader.

Continue local coordination or independent work while subagents run, using the harness's event wait mechanism when idle.

## 3. Accept Results and Run Proportional Review

Check the returned evidence against the package criteria: sources for an investigation, or the attributable diff, outputs and artifacts for an implementation. Where an independent judgment would affect acceptance, use [requesting-code-review](../requesting-code-review/SKILL.md) with the [package review brief](task-reviewer-prompt.md).

Keep a package open while a finding still blocks acceptance; independent packages can continue. Use the [re-review brief](re-review-prompt.md) if a repair needs fresh judgment.

## 4. Integrate and Finish

Once all packages pass verification and any required review:
1. Run the integration checks covering the combined changes.
2. Summarize the delivered outcome, key evidence, and any material technical decisions.
3. If integration or worktree cleanup was requested, execute it via `finishing-a-development-branch`.

Optional repository helpers remain available when needed (`scripts/sdd-workspace`, `scripts/task-brief`, `scripts/review-package`).
