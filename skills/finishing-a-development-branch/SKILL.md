---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Handle requested integration or cleanup using the authorized choice and verified evidence.

**Core principle:** Resolve the requested action → Verify evidence → Detect environment → Execute authorized action → Apply retention rules.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

Choose the path from the user's request (2026-09-06 authorized redundancy review):

- An integration or retention choice is already authorized: execute that path
  without another menu. Ask only if a necessary target or authorization is missing.
- The request is implementation only: report verified results and retain the
  branch/workspace. No integration decision is required to complete that request.
- The user asks to choose an integration method: present applicable options in
  Step 4 once, then execute their choice.
- The user explicitly requests discard: use the separate discard procedure.

Authorization does not waive verification, operation permissions or project
retention rules. Reuse current revision-bound evidence under
verification-before-completion; verify after integration or relevant changes.

### Step 1: Verify Tests

Before the requested operation, inspect the current revision-bound execution
evidence, complete raw output and exit code. If it already covers the intended
claim, reuse it. When it is missing, stale or raises a concrete doubt, run the
smallest sufficient check; run the full suite only when that claim requires it.

```bash
# Only when the intended claim requires a new full-suite result
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Detect Environment

**Determine workspace state for the requested operation:**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# Capture now, while still inside the workspace — Step 5 changes directory
# before cleanup (Step 6) needs this value
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

This determines available actions and cleanup:

| State | Available integration | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Merge / PR / retain | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Merge / PR / retain | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | PR from named branch / retain | No cleanup (externally managed) |

### Step 3: Determine Base Branch

The base branch is whatever this work forked from — usually named in the
plan, the conversation, or the branch's upstream:

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Use the target already authorized and verify it against repository evidence.
Ask only when the target remains ambiguous; merging into the wrong base is
expensive to undo.

### Step 4: Choose an Unspecified Integration Method

Use this step only when the user requested help choosing integration and has
not already selected a method. Offer applicable choices:

1. Merge locally into the verified base (named branch only).
2. Push and create a PR (name the branch first for detached HEAD).
3. Retain the current branch/workspace.

Wait for the choice. Do not include discard in the normal menu; it is a
separate, explicit-request-only procedure. For implementation-only delivery,
use the retention path without a question.

### Step 5: Execute Choice

#### Option 1: Merge Locally

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>
```

If tests fail on the merged result: stop, leave the worktree and branch in
place, and investigate — nothing has been pushed, so the merge is local
and recoverable.

Only after the merged result is green: cleanup worktree (Step 6). If the
worktree was archived or retained, keep its branch and report both paths/state.
Branch deletion applies to a normal checkout (now on the confirmed base), or
after an owned linked worktree was actually removed. Archived, retained and
harness-owned linked worktrees keep their branches:

```bash
git branch -d <feature-branch>
```

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>
# From a detached HEAD, name the new branch on the remote:
# git push origin HEAD:refs/heads/<new-branch>
```

Then create the pull/merge request against <base-branch> with the forge's
tooling — its CLI if one is available, or the creation URL most forges
print when you push — following the repo's PR template and conventions if
present, and report the URL to your human partner.

**Do NOT clean up worktree** — user needs it alive to iterate on PR feedback.

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Explicit Request: Discard

This path exists only in response to an explicit request to throw the work
away. It is not an ordinary completion option.

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for that exact confirmation.

If confirmed:
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then run cleanup (Step 6). A retained, archived or harness-owned linked
worktree keeps its branch; report preservation rather than completed discard.
For an owned linked worktree, delete its branch only after allowed removal
actually completed. For a normal checkout, no worktree removal is needed:
first preserve any uncommitted work according to the project's retention
contract, then switch to the previously confirmed retained base branch:

```bash
git status --porcelain
# Proceed only once uncommitted work has been preserved and the checkout is clean.
git switch <base-branch>
```

If the base cannot be selected safely, report the missing decision; do not
force the switch. Once no retained worktree has the feature branch checked
out, the explicit discard authorization permits:
```bash
git branch -D <feature-branch>
```

### Step 6: Cleanup Workspace

**Only runs after local merge or explicitly confirmed discard.** PR and retention
always preserve the worktree. Both callers have already changed directory
to the main repo root — worktree removal must run from outside the worktree
— and use the `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` values captured in
Step 2, from before that directory change.

First honor the project's retention contract. If it requires archiving under
`~/scratch`, retain both the linked worktree and its checked-out branch instead of
removing either. Skip subsequent branch deletion. For a linked
worktree, use `git worktree move` to a unique archive destination so registration
stays valid; if the move is unsupported, preserve it in place and report its
path. Do not substitute deletion. The removal path below applies only when
deletion is allowed by the project's contract and the user's authorization.

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

**If worktree path is under `.worktrees/` or `worktrees/`:** Superpowers created this worktree — we own cleanup.

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**If removal is refused** (`contains modified or untracked files`): the
worktree holds files that exist nowhere else — uncommitted plans, notes,
or scratch work. Never `--force` on your own initiative. Show your human
partner what is at stake and ask:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
Worktree removal refused — these files were never committed:

<file list>

1. Commit them to <branch> before cleanup
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

Carry out the choice, then remove the worktree.

**Otherwise:** The host environment (harness) owns this workspace. Do NOT remove it. If your platform provides a workspace-exit tool, use it. Otherwise, leave the workspace in place.

## Quick Reference

| Request | Action | Workspace |
|---------|--------|-----------|
| Already authorized merge | Verify target, merge, verify result | Apply retention rules after success |
| Already authorized PR | Push/create PR with authorized target | Retain for feedback |
| Implementation only or explicit retain | Report evidence and paths | Retain; no menu |
| Help choosing integration, no choice yet | Step 4 menu once | Retain until chosen action succeeds |
| Explicit discard | Confirm concrete loss, then discard procedure | Retention contract takes precedence |

## Failure and Cleanup Boundaries

- Reuse valid revision-bound evidence; complete missing checks before claims.
  A failed relevant check prevents a passing completion claim. Diagnose it;
  preserve the branch/worktree while the merged result remains unverified.
- Verify the base from prior authorization and repository evidence. Ask for a
  target only when it remains ambiguous. A rejected push requires diagnosis;
  force-push needs explicit authorization.
- PR and retained work keep their workspace. Cleanup after merge or confirmed
  discard must follow Step 6, preserve uncommitted evidence and run outside the
  target worktree. Never remove a workspace whose ownership is unproven.
- Apply the project's archive/retention contract before branch deletion. A
  retained or archived linked worktree keeps its branch. Removal refusal is
  evidence of unique local files, not permission to force removal.
- Discard requires the concrete loss list and typed confirmation above. It is
  never inferred from completion or offered as the default next step.
