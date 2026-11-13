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
- **Expected result**: The answer or deliverable the coordinator needs, with the evidence needed to verify and use it.

Example: assign this debugging package to the active profile’s `standard-worker` with the following brief.

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

Follow the project and active adapter’s role routing, using the current profile’s family by default. Choose an existing role by the result needed: `context-analyst` for a technical question, `routine-worker` for a well-specified local change, and `standard-worker` for multi-file implementation or debugging. Use the role’s configured model and reasoning effort. Resolve the registered role name and dispatch call through the active adapter: [Codex](../using-superpowers/references/codex-tools.md), [OpenCode](../using-superpowers/references/opencode-tools.md), or [dsh](../using-superpowers/references/dsh-tools.md).

Launch independent packages within the session’s slot limit, queue any excess work, and continue useful local work before waiting on completion events.

## 4. Verify and Integrate

When children return:
1. Inspect each agent's summary, actual diff, and verification output.
2. Reconcile the combined changes with the starting workspace and preserve concurrent work.
3. Run the check that covers the combined changes (or broaden verification if interfaces interact), then integrate and report the combined outcome.
