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

Treat provider specialization as a local routing hypothesis, not a universal
model claim. Prefer the GPT engineering group for complex implementation,
debugging, code-detail review, and final architecture review. Prefer the Qwen
information group for large-context synthesis, progress review, document
review, and approved HTML/Markdown drafting. Ordinary bounded implementation
may use either engineering group. The parent owns unresolved decisions,
dependency ordering, and final synthesis.

Give the Qwen information group a bounded handoff that uses its large context
window while keeping exploration tied to the task:

- Inputs: named source paths or artifacts, the exact question or decision
  boundary, and the acceptance evidence.
- Output contract: source-backed findings or
  an HTML/Markdown draft grounded in approved decisions, explicit gaps, and a
  recommended next action.
- Stop condition: the named inputs have been reviewed and the output contract
  is satisfied. A missing decision or source is returned to the parent as a
  gap; further material starts with a new parent handoff.

## Provider-per-session main-only file handoff

Use this contract when the target Provider runs as a main session and its
multi-agent tool surface is disabled or unavailable. Create one stable,
repository-local package directory per handoff:

```text
.superpowers/review-packages/<handoff-id>/
├── request.md
├── result.md
└── decision.md
```

Use a collision-resistant `<handoff-id>` such as
`YYYYMMDDTHHMMSSZ-short-topic`. The default GPT parent creates
`.superpowers/review-packages/<handoff-id>/request.md` with this contract:

```markdown
# Review Request

### Inputs
- Exact repository-relative source and artifact paths.
- Resolve every Input path from the repository root, not the package directory.
- The question or decision boundary.
- Acceptance evidence the review must evaluate.

### Output
- Required findings, source references, explicit gaps, and recommended action.
- Write the completed review to `result.md` in this package.

### Stop condition
- Stop after every named input is reviewed and the output contract is met.
- Report a missing source or unresolved decision as a gap; do not expand scope.

### Parent decision
- Reserved for the default GPT parent after it reads `result.md`.
- The Qwen reviewer recommends; it does not make or record the final decision.
```

A user or controller opens an independent Bailian main session at the same
repository root. That session reads only the request and named inputs, writes the result file at
`.superpowers/review-packages/<handoff-id>/result.md`, and returns the result
path plus a concise completion status. It stops at the request boundary.

The default GPT main session reads the result file, checks its cited evidence,
and owns the accept, reject, follow-up, architecture, and final-synthesis
decision. It records that bounded outcome and rationale in
`.superpowers/review-packages/<handoff-id>/decision.md`.

Production handoff uses independently opened top-level sessions: never launch one main session from the other with nested `codex exec`. A bounded CLI probe
may exercise this file protocol as validation evidence, but it is not the
production orchestration path.

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
