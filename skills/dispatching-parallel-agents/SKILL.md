---
name: dispatching-parallel-agents
description: Use when parallel work has clear benefit over coordination cost, with disjoint write sets and no shared state or sequential dependency.
---

# Dispatching Parallel Agents

## 1. Decide Whether to Parallelize

Dispatch in parallel when:
- Each work package can be understood and completed without waiting on results from the others.
- Write sets, output directories, and mutable resources are disjoint (a shared Git index, generated file, or running service makes tasks coupled even if source files differ).
- The parallel speedup clearly outweighs dispatch and integration overhead, and fits within the active harness's concurrency budget.

Handle work sequentially or in the main agent when failures share a root cause, system-wide context is required first, or the main agent can finish directly with less coordination. When each package also needs staged implementation, review, and repair checkpoints, use `subagent-driven-development`.

## 2. Prepare Focused Work Packages

Give each child its question or deliverable, starting evidence, allowed writes, and what to return. For example, three failures in one abort handler belong to one investigation; a separate read-only review of an unrelated parser can proceed alongside it.

## 3. Dispatch and Coordinate

Choose a [role by deliverable](../using-superpowers/references/role-selection.md). Launch within the session’s slot limit, queue excess packages, and continue independent local work while they run.

## 4. Verify and Integrate

For investigations, inspect the cited evidence and reconcile conflicting findings. For implementation, compare each diff with its assigned scope, preserve concurrent changes, and check the combined behavior before reporting the result.
