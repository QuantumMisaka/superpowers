---
name: subagent-driven-development
description: Use for an existing implementation plan when independent work packages benefit from delegated context, ownership, and review.
---

# Subagent-Driven Development

Coordinate multi-package plans by delegating independent work packages to specialized subagents, reviewing their results against requirements, and integrating the verified outcomes. Use direct execution (`executing-plans`) when tasks are tightly coupled or small enough to finish directly.

## 1. Prepare the Workspace and Packages

1. Read the plan and linked design spec once, reusing existing progress records.
2. Select the workspace via `using-git-worktrees` according to the project's collaboration mode (stay on `main` for `main`-first repos unless isolation has a concrete benefit).
3. Group related or same-shape edits into coherent work packages. Keep a clear process budget per milestone (normally one plan and one independent review where risk warrants it).

## 2. Dispatch Work Packages

Follow the project and active adapter’s role routing, using the current profile’s family by default. Choose an existing role by the work package’s goal: `context-analyst` to resolve a technical question, `routine-worker` for a well-specified local change, or `standard-worker` for multi-file implementation and integration. Use the role’s configured model and reasoning effort. Resolve the registered role name and dispatch call through the active adapter: [Codex](../using-superpowers/references/codex-tools.md), [OpenCode](../using-superpowers/references/opencode-tools.md), or [dsh](../using-superpowers/references/dsh-tools.md).

Provide a focused brief ([implementer-prompt.md](implementer-prompt.md)):
- **Goal and completion criteria**: Observable behavior or artifact to deliver, plus existing verification commands.
- **File ownership and shared state**: Separate agent contexts share the checkout and Git index. Assign disjoint file write sets when packages run concurrently, and serialize Git index, generated-file, or integration steps.
- **Attribution baseline**: Record `BASE` before committed work, or capture pre-dispatch diffs/untracked state for dirty worktrees so package changes are cleanly attributable.

For writing work, determine the whole document’s genre and primary reader first. Assign a scientific paper or research progress report to `paper-writer`, and an engineering proposal, project plan, or handoff memo to `document-writer`; one writer carries the document’s argument and voice throughout.

Continue local coordination or independent work while subagents run, using the harness's event wait mechanism when idle.

## 3. Accept Results and Run Proportional Review

1. **Verify returned work**: Under `verification-before-completion`, inspect the actual diff, raw test/check outputs, and produced artifacts against the package's completion criteria. For review or analysis milestones, verified subagent findings can directly inform the user-facing deliverable; for implementation milestones, synthesize the integrated code and behavior before closing the milestone.
2. **Independent review where it adds judgment**: Request an independent review ([task-reviewer-prompt.md](task-reviewer-prompt.md) or `requesting-code-review`) when the package changes public behavior, security, data handling, or cross-module interfaces. Select `task-reviewer` for one implementation package, `final-reviewer` for the integrated delivery, or `document-reviewer` for a document. Small low-risk changes can rely on coordinator inspection and focused checks.
3. **Resolve findings**: Fix valid Critical/Important gaps, record Minor notes when deferred, or document the evidence when a finding does not hold. Re-review ([re-review-prompt.md](re-review-prompt.md)) only when a repair changes a risk surface that needs fresh judgment.

## 4. Integrate and Finish

Once all packages pass verification and any required review:
1. Run the integration checks covering the combined changes.
2. Summarize the delivered outcome, key evidence, and any material technical decisions.
3. If integration or worktree cleanup was requested, execute it via `finishing-a-development-branch`.

Optional repository helpers remain available when needed (`scripts/sdd-workspace`, `scripts/task-brief`, `scripts/review-package`).
