---
name: executing-plans
description: Use when executing an existing implementation plan directly; ordinary unplanned L1/L2 work does not need this skill.
---

# Executing Plans

Load an approved plan, verify its assumptions against the codebase, execute the work packages, and deliver verified results.

Choose direct execution when coordination is simple; delegate independent packages via `subagent-driven-development` or `dispatching-parallel-agents` when isolated context or parallelism pays off.

## 1. Load and Check the Plan

1. Read the plan and any linked design spec or requirement source.
2. Check key interfaces, file paths, and dependencies against the current checkout. Choose the workspace according to the project's collaboration mode (`main` directly for `main`-first repos, or `using-git-worktrees` when isolation has a concrete benefit).
3. Resolve ordinary technical questions from the codebase and existing design. Pause and ask the user only when a missing product/architecture decision or external authorization prevents reliable execution.
4. Create todos for the work packages and begin execution.

## 2. Execute Work Packages

For each work package:
1. Mark the package `in_progress`.
2. Implement the planned outcome. File lists and step orders in a plan are estimates unless marked as external contracts; adapt ordinary implementation details when the codebase calls for it, and note significant technical tradeoffs in the plan or delivery record (using `Ruling: <decision> — <reason> — <cost if wrong>` when a structured log is helpful).
3. Run the verification specified for the package (`test-driven-development` for behavior changes, or direct checks for docs/config) and resolve any failures within scope.
4. Mark the package `completed`.

If an unexpected finding invalidates a later step, update the plan record and adjust the affected tasks while keeping completed work intact.

## 3. Verify and Finish

1. Confirm all planned deliverables meet their completion criteria with current-workstate evidence (`verification-before-completion`).
2. Report the delivered results, key evidence, and any decisions or tradeoffs that affect usage or scope.
3. If the user requested branch integration or worktree cleanup, complete it with `finishing-a-development-branch`; otherwise leave the verified workspace ready for inspection.
