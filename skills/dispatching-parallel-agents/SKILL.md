---
name: dispatching-parallel-agents
description: Use when parallel work has clear benefit over coordination cost, with disjoint write sets and no shared state or sequential dependency.
---

# Dispatching Parallel Agents

Delegate independent work packages to concurrent subagents when parallel execution saves real time over doing the work sequentially or in one pass.

## 1. Decide Whether to Parallelize

Dispatch in parallel when:
- Each work package can be understood and completed without waiting on results from the others.
- Write sets, output directories, and mutable resources are disjoint (a shared Git index, generated file, or running service makes tasks coupled even if source files differ).
- The parallel speedup clearly outweighs dispatch and integration overhead, and fits within the active harness's concurrency budget.

Handle work sequentially or in the main agent when failures share a root cause, system-wide context is required first, or the main agent can finish directly with less coordination. When each package also needs staged implementation, review, and repair checkpoints, use `subagent-driven-development`.

## 2. Prepare Focused Work Packages

Group work by independent deliverable or investigation target, and give each child a self-contained brief:
- **Goal and completion criteria**: The observable result to produce and the command or check that verifies it.
- **File ownership**: The exact files or directories this agent may read/write, noting concurrent work to preserve.
- **Relevant context**: Error traces, test names, interface expectations, or artifact paths needed to start immediately.
- **Return format**: Summary of findings or changes, modified files, and verification evidence (plus any blocker or decision needed from the coordinator).

Example prompt:

```markdown
Fix the 3 failing tests in `src/agents/agent-tool-abort.test.ts`:
1. "should abort tool with partial output capture" — expects 'interrupted at' in message
2. "should handle mixed completed and aborted tools" — fast tool aborted instead of completed
3. "should properly track pendingToolCount" — expects 3 results but gets 0

You own `src/agents/agent-tool-abort.test.ts` and `src/agents/agent-tool-abort.ts`.
Trace the race condition, replace arbitrary timeouts with event-based waiting or fix the abort state tracking, and run `npx vitest run src/agents/agent-tool-abort.test.ts`.
Return the root cause, files changed, and test output.
```

## 3. Dispatch and Coordinate

Select the matching role for each package (`context-analyst`, `routine-worker`, `standard-worker`, etc.) using the active harness adapter (`references/*-tools.md`). Launch independent tasks concurrently within the session's slot limit, queue any excess packages, and continue useful local work before waiting on completion events.

## 4. Verify and Integrate

When children return:
1. Inspect each agent's summary, actual diff, and verification output.
2. Confirm write sets did not conflict and shared state remains clean.
3. Run the check that covers the combined changes (or broaden verification if interfaces interact), then integrate and report the combined outcome.
