# Codex native subagent adapter

Codex is the primary development entry; OpenCode and dsh use their own native adapters (`opencode-tools.md`, `dsh-tools.md`). Always inspect the active session's tool schema and advertised roles first, since CLI versions, profiles, and transport surfaces differ.

## Dispatch, continuation, and lifecycle

- **Spawning (`spawn_agent`)**: Select an advertised `agent_type` whose configured capability fits the task. Pass `fork_turns: "none"` when supported so the child starts with a clean context; put the task goal, owned files, relevant context, and completion criteria in `message`. A full-history fork (`"all"`) copies the entire transcript and inherits parent model/effort without allowing overrides.
- **Continuation (`followup_task` / `send_input`)**: Reuse a retained implementer when its context helps; spawn a fresh child when an independent perspective is needed. On V2 surfaces, `followup_task` wakes an idle retained agent (`send_message` queues without waking). On V1 surfaces, use `send_input`.
- **Lifecycle and concurrency**: V2 surfaces do not expose `close_agent`; reuse retained agents or continue locally when thread limits are reached. On V1 surfaces with `close_agent`, close reviewers after their review returns and close implementers once the package passes. Respect the active profile's concurrency limit (`max_concurrent_threads_per_session`).
- **Shared checkout**: Separate agent context does not create a separate worktree or private Git index. Assign disjoint file ownership for concurrent writers and serialize shared index or generated-state operations.

## Waiting on children

`wait_agent` is an event subscription that wakes as soon as a child produces mailbox activity:

- While local work remains, continue working locally; completed children deliver results to your mailbox for the next turn.
- When idle with children running, call `wait_agent` with a timeout bounded by the active communication deadline rather than polling in short loops. If the wait times out without activity, report status and reconcile state before waiting again.

## Role and model selection

1. **Project and profile priority**: Follow routes declared in the project's `AGENTS.md` first, then select the matching role from the active profile's native family (`agent_type`). Role files own model, `model_reasoning_effort`, and sandbox settings; omit manual model/effort overrides when dispatching a configured role.
2. **Role mapping**:

| Role | Responsibility |
| --- | --- |
| `context-analyst` | Read-only code, document, and history analysis; execution tracing and root-cause diagnosis |
| `routine-worker` | Well-specified local implementation or independent behavior reproduction |
| `standard-worker` | Multi-file implementation, interface integration, and debugging |
| `task-reviewer` | Read-only task-scoped requirement, regression, and verification review |
| `final-reviewer` | Read-only whole-delivery review across integration, architecture, and verification |
| `document-writer` | Engineering proposals, project plans, and handoff memos organized for one primary reader |
| `document-reviewer` | Read-only review of document structure, factual grounding, coherence, and tone |
| `paper-analyst` | Read-only analysis of scientific claims, methods, evidence, and competing explanations |
| `paper-writer` | Scientific papers and research progress reports organized around the whole document’s scientific question and primary reader |
| `progress-reviewer` | Read-only outcome and gap check against goals and completion criteria |
| `monitor` | Read-only tracking of long-running jobs and logs until completion or actionable error |

3. **Generic fallback and overrides**: If `agent_type` is unavailable or no advertised role fits, dispatch a generic subagent using `[agents].default_subagent_model` and `default_subagent_reasoning_effort`. For an authorized explicit override on a generic isolated fork, set both `model` and `reasoning_effort` to values advertised in the active allowlist/catalog. A read-only prompt is a behavioral instruction, not sandbox enforcement.

## Cross-session review packages

When an independent review runs in a separate top-level session without direct subagent tools, exchange context through a repository-local package directory (`.superpowers/review-packages/<handoff-id>/` with `request.md`, `result.md`, and `decision.md`), or use the repository's governance review helper when applicable. The main session verifies cited evidence and owns the final accept/follow-up decision.

## Environment Detection and Codex App Finishing

Before creating worktrees or integrating branches, check workspace state with read-only git commands:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON`: check `git rev-parse --show-superproject-working-tree` to distinguish a submodule from a linked worktree (`using-git-worktrees`).
- Empty `BRANCH`: detached HEAD. When a managed Codex App sandbox blocks branch or push operations, commit the verified work locally and let the user finish via the App's **"Create branch"** or **"Hand off to local"** controls (`finishing-a-development-branch`).
