# OpenCode native adapter

Checked 2026-09-10 against installed OpenCode 1.18.30 and its tagged source.
Codex is the primary development entry; OpenCode is a native second entry,
sharing the same Superpowers core rather than invoking Codex underneath.
Use the active tool schema and resolved agent permissions when versions differ.

## Skills and entry

OpenCode natively discovers `~/.agents/skills` and project `.agents/skills`;
see [Skills documentation](https://opencode.ai/docs/skills/).
Reuse the existing shared source instead of installing a duplicate upstream copy.
Discovery makes a skill available; the global/project instructions request loading
`using-superpowers`, and the agent's `skill` permission controls access.
The optional bootstrap plugin is not required for this shared installation.
Discovery is cached per instance; restart the instance after source changes.
Avoid competing same-name copies: concurrent loading does not establish a
reliable directory precedence. Check the resolved location instead
([versioned discovery implementation](https://github.com/anomalyco/opencode/blob/v1.18.30/packages/opencode/src/skill/index.ts)).

## Dispatch and recovery

The native `task` accepts `description`, `prompt`, `subagent_type`, and optional
`task_id`; it is not Codex's spawn/message/wait API.
Select an available configured subagent and supply the bounded task, owned paths,
write boundary, relevant inputs, and acceptance evidence. SDD owns task/review
selection; this adapter only maps transport.

A new task creates a child session with `parentID`, not a copy of the parent's
conversation. Put needed context in the prompt. OpenCode's separate session-fork
API can copy history, but task creation does not call that API.
Continue using the returned `task_id` when appropriate. In this version an
unresolvable ID falls back to a new session; check the returned identity before
claiming that prior context was recovered. Use IDs from the intended task:
the implementation does not validate parent/agent ownership on recovery.

The target agent's configured model wins; otherwise the task uses the invoking
assistant's provider/model. A resumed task also receives the current selection,
so task identity alone does not guarantee a fixed model. Keep model choices in
harness configuration, not a second model matrix in SDD.

## Permissions, concurrency, and workspace

Task dispatch checks the parent's task permission for the target agent.
`subagent_depth` defaults to 1 in this version; depth and permissions separately
constrain nested delegation. Child rules carry parent deny/external-directory
rules and target-agent permissions; task/todowrite are denied unless explicitly
allowed by the target agent. Inspect resolved rules rather than inferring access
from a skill or the primary's name. Do not relax a restricted product agent to
make a development workflow run.

Independent calls may run concurrently when the active harness supports it.
Foreground task waits for its result. `background: true` is experimental here,
gated by `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS` (or the general experimental
flag); do not assume it is enabled or change the flag merely to follow SDD.
If available, use its completion notification rather than duplicate dispatch.

Task children share the current instance directory/worktree. Separate context
does not isolate files or the Git index. OpenCode has a separate worktree service,
but task creation does not invoke it. Use disjoint ownership and identifiable
dirty snapshots for shared-checkout work; coordinate shared writes and Git
operations. Explicit worktree isolation remains a separate workflow choice.

## Evidence and version boundary

- [v1.18.30 task implementation](https://github.com/anomalyco/opencode/blob/v1.18.30/packages/opencode/src/tool/task.ts)
- [Session creation and fork](https://github.com/anomalyco/opencode/blob/v1.18.30/packages/opencode/src/session/session.ts)
- [Subagent permission rules](https://github.com/anomalyco/opencode/blob/v1.18.30/packages/opencode/src/agent/subagent-permissions.ts)
- [Configuration schema](https://github.com/anomalyco/opencode/blob/v1.18.30/packages/core/src/v1/config/config.ts)
- [Worktree service](https://github.com/anomalyco/opencode/blob/v1.18.30/packages/opencode/src/worktree/index.ts)

Local `opencode debug skill --pure` confirmed shared discovery; resolved
`misaka-safe` permits skill/task. These are configuration checks, not a real
model-driven SDD run. V2 documentation is not evidence for this 1.x installation.
