---
name: using-git-worktrees
description: Use when feature work needs isolation from the current workspace; not every plan or local-main task needs a worktree. Prefer native tools, then git worktree fallback.
---

# Using Git Worktrees

## Overview

Choose the workspace that matches the task's isolation need and the project's
collaboration mode. A project that develops on main directly should stay on
main unless isolation has a concrete benefit. Prefer your platform's native
worktree tools; fall back to manual git worktrees only when no native tool is
available.

**Core principle:** Detect existing isolation and the project's declared
collaboration mode first. Then use native tools. Then fall back to git. Never
fight the harness.

**Announce at start:** "I'm using the using-git-worktrees skill to choose the workspace."

## Step 0: Detect Existing Isolation

**Before creating anything, check if you are already in an isolated workspace.**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside git submodules. Before concluding "already in a worktree," verify you are not in a submodule:

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If `GIT_DIR != GIT_COMMON` (and not a submodule):** You are already in a linked worktree. Skip to Step 2 (Project Setup). Do NOT create another worktree.

Report with branch state:
- On a branch: "Already in isolated workspace at `<path>` on branch `<name>`."
- Detached HEAD: "Already in isolated workspace at `<path>` (detached HEAD). Record the base commit; ensure `refs/superpowers/work/<name>` points to the current worktree HEAD; integrate into the target branch at finish time unless the project requires a branch."

```bash
git -C "<path>" update-ref "refs/superpowers/work/<name>" HEAD
```

If the work ref already exists, verify it belongs to the current worktree.

**If `GIT_DIR == GIT_COMMON` (or in a submodule):** You are in a normal repo checkout.

Has the user already indicated their worktree preference or the project's
collaboration mode? Honor it without asking. If the project develops on main
directly, stay in the current checkout and skip Step 1. If the project expects
isolation for plan execution, create the worktree without prompting. If neither
the project nor the task indicates isolation, default to the current checkout;
create a worktree only when isolation has a concrete benefit (for example, a
concurrent writer, a risky migration, or an explicit user request). Do not ask
for consent merely to create a reversible workspace; ask only when the user
requested a workspace choice or the workspace affects an irreversible operation.

A worktree isolates the checkout, not shared absolute paths, running services
or external output directories. If a concurrent writer shares those, serialize
or give each job a disjoint output path instead of relying on the worktree.

## Step 1: Create Isolated Workspace

**You have two mechanisms. Try them in this order.**

### 1a. Native Worktree Tools (preferred)

You have decided that isolation has a concrete benefit (Step 0). Do you already have a way to create a worktree? It might be a tool with a name like `EnterWorktree`, `WorktreeCreate`, a `/worktree` command, or a `--worktree` flag. If you do, use it and skip to Step 2.

Native tools handle directory placement, branch creation, and cleanup automatically. Using `git worktree add` when you have a native tool creates phantom state your harness can't see or manage.

If the native tool only creates branch-backed worktrees and the project requires
detached work, use the git fallback instead.

If the native tool creates a detached worktree, do not run `git worktree add`
again. Record only the base and work refs, using the base/work ref-recording
commands from the detached fallback after verifying `<target-branch>`.

Only proceed to Step 1b if you have no native worktree tool available.

### 1b. Git Worktree Fallback

**Only use this if Step 1a does not apply** — you have no native worktree tool available. Create a worktree manually using git.

#### Directory Selection

Follow this priority order. Explicit user preference always beats observed filesystem state.

1. **Check your instructions for a declared worktree directory preference.** If the user has already specified one, use it without asking.

2. **Check for an existing project-local worktree directory:**
   ```bash
   ls -d .worktrees 2>/dev/null     # Preferred (hidden)
   ls -d worktrees 2>/dev/null      # Alternative
   ```
   If found, use it. If both exist, `.worktrees` wins.

3. **If there is no other guidance available**, default to `.worktrees/` at the project root.

#### Safety Verification (project-local directories only)

**MUST verify directory is ignored before creating worktree:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:** Add to .gitignore, commit the change, then proceed.

**Why critical:** Prevents accidentally committing worktree contents to repository.

#### Create the Worktree

```bash
# Named branch mode
path="$LOCATION/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

For a project that uses detached worktrees, create without a topic branch and
record the base commit and a recovery ref:

```bash
base=$(git rev-parse <target-branch>)
name="<task-name>"
path="$LOCATION/$name"
git worktree add --detach "$path" "$base"
```

Use a task-specific name; if the work ref already exists, verify it belongs to
this worktree.

Verify `<target-branch>` from the project's collaboration mode; do not assume
the current checkout is the target. After committing in the detached worktree,
protect the work commit:

```bash
git -C "$path" update-ref "refs/superpowers/work/$name" HEAD
```

Refresh this ref after each later commit; it must match the worktree HEAD at
handoff.

Keep the work ref until integration and cleanup/archival are verified. Then
delete it with `git update-ref -d "refs/superpowers/work/$name"` and remove or
archive the worktree under the project's retention rules.

**Sandbox fallback:** If `git worktree add` fails with a permission error (sandbox denial), tell the user the sandbox blocked worktree creation and you're working in the current directory instead. Then apply Steps 2–3 in place.

## Step 2: Task-Relevant Setup

Choose setup from the task's files, required checks and repository instructions.
Reuse inspected evidence that the needed environment is ready. A package
manifest alone does not require installation; a documentation-only change may
need only its link or formatting checker. When dependencies are missing, use
the repository's documented package manager and lockfile workflow for the
needed check, then verify readiness.

**Submodules:** `git worktree add` does not check out submodule contents.
Inspect declared submodules and identify which the task or its checks need:

```bash
if [ -f .gitmodules ]; then
  git submodule status --recursive
fi
# Initialize only required, missing paths before their dependent setup/checks:
git submodule update --init --recursive -- <required-path>
```

If a required submodule cannot initialize, identify its path and failure and
diagnose it before dependent work. Continue independent work; pause that path
only when no reliable repair is available within scope. An unrelated missing
submodule does not require initialization or block this task.

## Step 3: Establish the Relevant Baseline

Choose the smallest check that distinguishes this task's effects from existing
failures. Reuse retained raw output and exit code only when they cover the
unchanged relevant files and environment. Run a focused check when evidence
is absent, stale or in doubt; a full suite is needed only for a claim that
requires it. State when no executable baseline applies and what inspection
supports starting instead.

**Failure rule:** Diagnose relevance first. Record an unrelated pre-existing
failure and its evidence in the task record, then continue authorized work.
Repair a relevant failure within scope; pause dependent work only if it prevents
reliable implementation or validation and cannot be resolved within scope.
Ask only for the missing decision or authorization. Never report a failing
check as passing or claim an unverified acceptance condition is complete.

Report the workspace/branch, checks run or evidence reused, known failures and
remaining limitations. "Ready for this task" does not mean the whole suite is
green.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already in linked worktree | Skip creation (Step 0) |
| In a submodule | Treat as normal repo (Step 0 guard) |
| Required submodule missing | Initialize that path before dependent setup/checks (Step 2) |
| Native worktree tool available | Use it (Step 1a) |
| No native tool | Git worktree fallback (Step 1b) |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check instruction file, then default `.worktrees/` |
| Directory not ignored | Add to .gitignore + commit |
| Permission error on create | Sandbox fallback, work in place |
| Baseline failure | Apply Step 3 relevance and reliability rule |
| Required environment already ready | Reuse evidence; skip installation |

## Common Mistakes

### Fighting the harness

- **Problem:** Using `git worktree add` when the platform already provides isolation
- **Fix:** Step 0 detects existing isolation. Step 1a defers to native tools.

### Skipping detection

- **Problem:** Creating a nested worktree inside an existing one
- **Fix:** Always run Step 0 before creating anything

### Skipping ignore verification

- **Problem:** Worktree contents get tracked, pollute git status
- **Fix:** Always use `git check-ignore` before creating project-local worktree

### Assuming directory location

- **Problem:** Creates inconsistency, violates project conventions
- **Fix:** Follow priority: explicit instructions > existing project-local directory > default

### Losing failure provenance

- **Problem:** New failures cannot be distinguished from existing ones
- **Fix:** Retain baseline evidence and apply Step 3 before proceeding

## Red Flags

**Never:**
- Create a worktree when Step 0 detects existing isolation
- Use `git worktree add` when you have a native worktree tool (e.g., `EnterWorktree`). This is the #1 mistake — if you have it, use it.
- Skip Step 1a by jumping straight to Step 1b's git commands
- Create worktree without verifying it's ignored (project-local)
- Claim baseline readiness without relevant evidence
- Treat an unresolved relevant failure as passing

**Always:**
- Run Step 0 detection first
- Prefer native tools over git fallback
- Follow directory priority: explicit instructions > existing project-local directory > default
- Verify directory is ignored for project-local
- Select setup by task dependencies (Step 2)
- Establish the relevant baseline and apply its failure rule (Step 3)

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'm obviously not in a worktree — no need to check" | Run Step 0. Harness-created isolation and submodules both fool eyeballing; the detection commands settle it. |
| "`git worktree add` is quicker than hunting for a native tool" | A native tool (e.g. `EnterWorktree`) owns placement, branching, and cleanup. Bypassing it is the #1 mistake — it creates phantom state your harness can't see or manage. |
| "The worktree directory is surely ignored already" | Run `git check-ignore`. An unignored worktree directory commits the whole tree into the repo. |
| "Any directory name works" | Explicit instructions beat an existing project-local directory, which beats the `.worktrees/` default. |
| "The workspace is fresh — baseline tests can wait" | Establish relevant baseline evidence under Step 3; unrelated known failures do not require another permission round. |
