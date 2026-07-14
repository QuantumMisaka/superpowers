## Subagent dispatch requires multi-agent support

Add to your Codex config (`~/.codex/config.toml`):

```toml
[features]
multi_agent = true
```

This enables `spawn_agent`, `wait_agent`, and `close_agent` for skills like `dispatching-parallel-agents` and `subagent-driven-development`. When using subagent-driven-development, you should always close implementer and reviewer subagents when they have finished all their work.

## Capability-Aware Routing

Inspect the active `spawn_agent` schema; optional routing fields differ by
Codex surface and version. Skills use abstract roles, while Codex configuration
owns role identifiers, models, reasoning effort, sandboxing, and limits.

| Abstract role | Select an advertised role described for |
| --- | --- |
| Routine implementer | Bounded, mechanical implementation |
| Standard implementer | Bounded multi-file integration or debugging |
| Task reviewer | Task-scoped, read-only requirement and quality review |
| Final reviewer | Whole-change, high-judgment read-only review |
| Monitor | Read-only external-job waiting |

Keep controller work, unresolved architecture decisions, and escalation in the
parent. Planned implementation of an approved design may still use an
implementer role. Treat subagent-driven development as `sequential-gated`; its
implement-review-fix cycle stays serial. Treat parallel dispatch as
`independent-parallel`, only after the calling skill establishes independent
domains and disjoint writes.

When `agent_type` is visible, prefer the matching configured role and let its
configuration select model and effort. If `agent_type` is absent or no
advertised role matches, omit routing fields and dispatch a generic subagent;
mandatory reviews still proceed. When `fork_turns` is available, pass
`fork_turns: "none"`; otherwise omit it. Always put the complete task contract
in `message`.

## Environment Detection

Skills that create worktrees or finish branches should detect their
environment with read-only git commands before proceeding:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → already in a linked worktree (skip creation)
- `BRANCH` empty → detached HEAD (cannot branch/push/PR from sandbox)

See `using-git-worktrees` Step 0 and `finishing-a-development-branch`
Step 1 for how each skill uses these signals.

## Codex App Finishing

When the sandbox blocks branch/push operations (detached HEAD in an
externally managed worktree), the agent commits all work and informs
the user to use the App's native controls:

- **"Create branch"** — names the branch, then commit/push/PR via App UI
- **"Hand off to local"** — transfers work to the user's local checkout

The agent can still run tests, stage files, and output suggested branch
names, commit messages, and PR descriptions for the user to copy.
