---
name: requesting-code-review
description: Use when an implementation has enough risk, scope, or independent judgment value that another reviewer should inspect it before integration.
---

# Requesting Code Review

Use independent review where a second perspective can catch regressions, cross-module issues, security/data risks, or gaps against requirements. Group related small tasks into a coherent review package; small, low-risk mechanical edits can rely on self-review and focused checks.

## 1. Prepare and Dispatch the Review

Choose a [review role for the deliverable](../using-superpowers/references/role-selection.md) and supply the [review brief](code-reviewer.md):
- **Delivery goal and completion criteria**: The user requirement, approved design, or plan section.
- **Actual changes**: The commit range (`BASE..HEAD`) or an attributable dirty worktree snapshot (including staged, unstaged, and untracked files).
- **Relevant context and verification**: Key interfaces, affected callers, and the test or command outputs already collected.

When findings return, use [receiving-code-review](../receiving-code-review/SKILL.md) to decide what needs to change.
