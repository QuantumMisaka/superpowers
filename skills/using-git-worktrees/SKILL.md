---
name: using-git-worktrees
description: Use when feature work needs isolation from the current workspace; not every plan or local-main task needs a worktree. Prefer native tools, then git worktree fallback.
---

# Using Git Worktrees

Choose the workspace that matches the project's collaboration mode and the task's actual isolation need. Projects that develop directly on `main` stay in the current checkout unless isolation provides a concrete benefit (such as concurrent writers, risky migrations, or an explicit user request).

## 1. Detect Current Workspace and Decide Whether to Isolate

Check whether you are already in a linked worktree or a submodule:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
SUPERPROJECT=$(git rev-parse --show-superproject-working-tree 2>/dev/null)
BRANCH=$(git branch --show-current)
```

- **Already in a linked worktree** (`GIT_DIR != GIT_COMMON` and `SUPERPROJECT` is empty): Reuse it if it belongs to this task. For a detached HEAD, claim or resume its recovery ref as described below before making changes.
- **In a normal checkout or submodule**: Follow user instructions or project conventions without asking for extra permission on reversible setup:
  - Stay in the current checkout when the project works on `main` directly and no concurrent conflict exists.
  - Create an isolated worktree when the project or user expects branch/worktree isolation, or when concurrent tasks would collide. Note that worktrees isolate the git checkout, not external absolute paths or shared running services.

## 2. Create the Isolated Worktree

### 2a. Native Harness Tool (when compatible)

If the harness exposes a native worktree tool (`EnterWorktree`, `WorktreeCreate`, `/worktree`), use it when its mode matches the project's workflow. If the project requires a detached worktree without a topic branch and the native tool only creates named branches, use the Git command below instead.

### 2b. Git Worktree Command

1. **Choose directory location**: Use the user's configured directory first, then an existing `.worktrees/` or `worktrees/` directory, or default to `.worktrees/<name>` at the repo root.
2. **Verify ignore rule** (for project-local directories): Check the intended path from the repo root, e.g. `git check-ignore -q -- ".worktrees/$name/"`. If needed, add the directory to `.gitignore` first.
3. **Create worktree**:
   - **Detached mode** (for `main`-first projects needing temporary isolation):
     ```bash
     git worktree add --detach "$path" "$target_branch"
     ```
     After creation succeeds, claim a task-specific recovery ref in the detached worktree:
     ```bash
     ref="refs/superpowers/work/$name"
     tip=$(git -C "$path" rev-parse HEAD) && git -C "$path" update-ref "$ref" "$tip" ""
     ```
     The empty old value requires a new ref. If the name is taken, choose an unused name unless the task record identifies this worktree, ref and last recorded tip as yours; equal commits alone do not prove ownership. Retain that binding. After each new commit, use `git -C "$path" update-ref "$ref" HEAD "$tip"` and record the new tip only on success. On a mismatch, leave the existing ref intact and resolve ownership.
   - **Named branch mode**:
     ```bash
     git worktree add "$path" -b "$BRANCH_NAME"
     ```
   - **Creation blocked**: Use the current checkout only if isolation was optional and it is safe to share. If isolation is required, seek an authorized isolated workspace or defer the conflicting writes; independent read-only work can continue.

## 3. Task-Relevant Setup and Baseline

1. **Dependencies and submodules**: Reuse an already prepared environment. If `.gitmodules` declares submodules that this task or its checks require, initialize only those paths (`git submodule update --init --recursive -- <required-path>`). Install package dependencies only when required checks or builds need them.
2. **Relevant baseline check**: Run or reuse the narrowest check that distinguishes this task's changes from pre-existing state. If an unrelated test is already failing, record the failure with its output and continue authorized work; pause only if a broken dependency blocks this task and cannot be repaired in scope.
3. **Report readiness**: State the active workspace path, branch/HEAD state, and baseline check result.
