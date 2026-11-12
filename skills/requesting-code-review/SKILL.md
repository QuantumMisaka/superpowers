---
name: requesting-code-review
description: Use when an implementation has enough risk, scope, or independent judgment value that another reviewer should inspect it before integration.
---

# Requesting Code Review

Use independent review where a second perspective can catch regressions, cross-module issues, security/data risks, or gaps against requirements. Group related small tasks into a coherent review package; small, low-risk mechanical edits can rely on self-review and focused checks.

## 1. Prepare and Dispatch the Review

Select the appropriate review role (`task-reviewer` for a work package, `final-reviewer` for a whole delivery, or `document-reviewer` for specs/plans) via the active harness adapter (`references/*-tools.md`), and supply the review brief ([code-reviewer.md](code-reviewer.md)):
- **Delivery goal and completion criteria**: The user requirement, approved design, or plan section.
- **Actual changes**: The commit range (`BASE..HEAD`) or an attributable dirty worktree snapshot (including staged, unstaged, and untracked files).
- **Relevant context and verification**: Key interfaces, affected callers, and the test or command outputs already collected.

## 2. Evaluate and Act on Findings

When the reviewer returns:
- **Address actionable issues**: Fix valid Critical or Important findings and verify the updated behavior.
- **Triage minor suggestions**: Apply low-cost improvements in scope or note them in the project record when deferred.
- **Verify disputed findings**: If code and execution evidence show a finding does not hold, document the technical reason.
- **Re-review when risk changes**: Request a follow-up check only when a fix alters a non-trivial logic or interface path; isolated fixes need only their focused verification.
