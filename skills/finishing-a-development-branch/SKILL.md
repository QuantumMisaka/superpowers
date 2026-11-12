---
name: finishing-a-development-branch
description: Use when development is ready for integration or the user requests cleanup of completed worktrees.
---

# Finishing a Development Branch

Complete the requested delivery, integration, retention, or worktree cleanup using checks matched to the actual operation.

## 1. Select the Path and Verify Relevant Evidence

Match the path and verification to what the user requested:

| Requested Action | Verification Before Acting | Operation |
| --- | --- | --- |
| **Direct delivery on target branch** (or retain current workspace) | Verify or reuse current-workstate checks covering the task (`verification-before-completion`) | Report completed outcome, evidence, and workspace path; no branch/PR menu needed |
| **Local merge / fast-forward into target branch** | Task checks pass; target branch and `refs/superpowers/work/<name>` (if detached) verified | Switch to main checkout, merge/fast-forward target, rerun relevant checks on merged result, then clean up owned worktree if requested |
| **Push and create PR** | Task checks pass; remote and target branch verified | Push branch (or `HEAD:refs/heads/<branch>`), create PR, and retain worktree for review iteration |
| **Independent worktree cleanup** | Verify commits are absorbed into the target branch, worktree is not in active use, and any unmerged/dirty state is archived | Archive to `~/scratch` (or project retention path) and remove stale worktree registration; unrelated software test failures do not block cleanup |
| **Explicit discard** | User explicitly requested discard and confirmed the concrete commit/file loss list | Preserve any required recovery archive per project rules, remove worktree/branch as confirmed |

If the user asked for help choosing an integration method without specifying one, offer only the options that fit the project's collaboration mode (e.g., integrate into `main` vs. retain workspace for `main`-first repos; local merge vs. PR vs. retain for branch/PR repos).

## 2. Inspect Workspace and Target

Capture the workspace paths before switching directories:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
MAIN_ROOT=$(git -C "$GIT_COMMON/.." rev-parse --show-toplevel)
```

For a detached worktree, confirm `refs/superpowers/work/<name>` points to `HEAD` before leaving the worktree so the work commit stays reachable during integration.

## 3. Integrate Changes (When Requested)

### Local Merge or Fast-Forward

```bash
cd "$MAIN_ROOT"
git checkout <target-branch>
git merge <feature-branch-or-work-ref>
```

Run the relevant verification on the integrated result. If a check fails after merging, keep the worktree and recovery ref intact while diagnosing and fixing the issue.

### Push and Pull Request

Push the branch to the remote and create the PR with `gh pr create` (after `gh auth status`) or the repository's forge CLI. Keep the worktree in place until the PR is merged.

## 4. Clean Up or Archive Worktree

When cleaning up after a verified local merge or an independent cleanup request:

1. **Verify ownership and absorption**: Confirm the worktree is not used by another active session and its commits are reachable from the target branch (or archived).
2. **Preserve state under project retention rules**: Inspect `git status --porcelain` and submodule state. Instead of destructive deletion, prefer moving or archiving residual files/worktrees to `~/scratch/` with a clear recovery note. If submodules prevent `git worktree move`, archive the directory with intact metadata before removing the worktree registration.
3. **Release registration and temporary refs**: Once the target branch or archive is verified, remove the worktree registration and delete temporary `refs/superpowers/work/<name>` refs. Keep named branches unless branch deletion is part of the confirmed operation.
