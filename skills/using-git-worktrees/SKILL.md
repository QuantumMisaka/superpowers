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

- **Already in a linked worktree** (`GIT_DIR != GIT_COMMON` and `SUPERPROJECT` is empty): Stay in this worktree and proceed to Step 3. If on a detached HEAD, record a recovery ref (`git update-ref "refs/superpowers/work/<name>" HEAD`) so commits stay reachable until integration.
- **In a normal checkout or submodule**: Follow user instructions or project conventions without asking for extra permission on reversible setup:
  - Stay in the current checkout when the project works on `main` directly and no concurrent conflict exists.
  - Create an isolated worktree when the project or user expects branch/worktree isolation, or when concurrent tasks would collide. Note that worktrees isolate the git checkout, not external absolute paths or shared running services.

## 2. Create the Isolated Worktree

### 2a. Native Harness Tool (when compatible)

If the harness exposes a native worktree tool (`EnterWorktree`, `WorktreeCreate`, `/worktree`), use it when its mode matches the project's workflow. If the project requires a detached worktree without a topic branch and the native tool only creates named branches, use the Git command below instead.

### 2b. Git Worktree Command

1. **Choose directory location**: Use the user's configured directory first, then an existing `.worktrees/` or `worktrees/` directory, or default to `.worktrees/<name>` at the repo root.
2. **Verify ignore rule** (for project-local directories): Confirm `git check-ignore -q .worktrees` (or `worktrees`) succeeds before creating the worktree; if not ignored, add the directory to `.gitignore` first.
3. **Create worktree**:
   - **Detached mode** (for `main`-first projects needing temporary isolation):
     ```bash
     base=$(git rev-parse <target-branch>)
     git worktree add --detach "$path" "$base"
     git -C "$path" update-ref "refs/superpowers/work/$name" HEAD
     ```
     Refresh `refs/superpowers/work/$name` after new commits and keep it until integration and cleanup complete.
   - **Named branch mode**:
     ```bash
     git worktree add "$path" -b "$BRANCH_NAME"
     ```
   - **Sandbox fallback**: If sandbox permissions block worktree creation, note the restriction and continue in the current checkout.

## 3. Task-Relevant Setup and Baseline

1. **Dependencies and submodules**: Reuse an already prepared environment. If `.gitmodules` declares submodules that this task or its checks require, initialize only those paths (`git submodule update --init --recursive -- <required-path>`). Install package dependencies only when required checks or builds need them.
2. **Relevant baseline check**: Run or reuse the narrowest check that distinguishes this task's changes from pre-existing state. If an unrelated test is already failing, record the failure with its output and continue authorized work; pause only if a broken dependency blocks this task and cannot be repaired in scope.
3. **Report readiness**: State the active workspace path, branch/HEAD state, and baseline check result.
