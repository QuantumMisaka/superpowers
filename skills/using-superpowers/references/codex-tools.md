## Subagent dispatch requires multi-agent support

Add to your Codex config (`~/.codex/config.toml`):

```toml
[features]
multi_agent = true
```

This enables the multi-agent tools that skills like
`dispatching-parallel-agents` and `subagent-driven-development` use.
Which tools you get depends on the multi-agent version your model
preset selects (current presets run V2; older ones run V1). Trust your
actual tool list over any table — including this one — when they
disagree.

### Profile split: V2 vs V1

Multi-agent transport follows the profile, not just the Codex version:

- **Default OpenAI profile (GPT):** `multi_agent_v2 = true` → V2 surface
  (`followup_task`, no `close_agent`).
- **bailian / deepseek / scnet profiles:** overlay `multi_agent_v2 = false`
  → V1 surface (`send_input`, `wait_agent`, `close_agent`).

Rules below that apply to only one surface say so; untagged rules apply to
both. See `## Bailian Multi-Agent V1 Compatibility` for the proven matrix.

- **Spawning:** give children a clean context with
  `spawn_agent {fork_turns: "none"}`; the default `"all"` copies your
  entire transcript into the child. On Codex 0.145+, role files under
  `~/.codex/agents/` attach to isolated forks via `agent_type`.
  Full-history forks accept `model` and `reasoning_effort` overrides
  (only `agent_type` is refused there) — isolated forks are the SDD
  default for context hygiene, not because overrides require them.
- **Fix rounds:** resume the implementer instead of spawning fresh.
  V2: `followup_task` delivers your message, triggers a turn, and
  transparently reloads a child the harness evicted — on V2 a spawned
  agent can always be messaged again. V1: message the existing
  implementer with `send_input`. Only if your harness truly cannot
  message a spawned agent again, dispatch each fix round as a fresh
  implementer carrying the brief, the report file, and the findings.
- **Lifecycle:** V2 has no `close_agent`. Finished children are
  evicted automatically when slots are needed; leaving them unclosed
  costs nothing. Only V1 sessions have `close_agent` — there, close
  reviewers when their review returns, and close each implementer
  after its task's review passes.
- **Model names:** never copy a model name from a skill, table, or old
  session into `spawn_agent` without checking it against your current
  spawn allowlist — V2 accepts only V2-capable presets and hard-errors
  on the rest.

## Waiting on children

(V1 and V2 alike.) `wait_agent` is an event subscription, not a poll: a long wait wakes
the moment a child produces mailbox activity, with the same latency as
a short one. Short-timeout polling buys nothing and costs a tool call —
and a context rebill — per poll. In measured sessions, roughly
two-thirds of all wait calls were short polls that timed out.

- While you still have local work, do not wait at all. A completed
  child's final answer is pushed into your mailbox and arrives with
  your next turn.
- When you are genuinely idle with children outstanding, wait in
  bounded stretches: `wait_agent` with `timeout_ms` 300000-600000
  (5-10 minutes). After each stretch — wake or timeout — post one
  status line, run `list_agents`, and chase any child that finished
  without reporting. Never stack polls shorter than five minutes; the
  event subscription wakes a bounded stretch just as fast as a short
  one.
- Completion mail cannot wake an idle controller (it is delivered
  without triggering a turn); covering that idle window is
  `wait_agent`'s only job. A stretch that times out with no activity
  is your cue to reconcile, not to shorten the next stretch.

## Model routing on spawns

Every `spawn_agent` you issue — including when you are yourself a
spawned child running a fan-out — sets `model` AND `reasoning_effort`
explicitly, per the Model Selection rules of the skill you are
executing — but only set fields your active spawn schema exposes.
Setting `model` alone is a trap: the child's effort silently resets to
that model's default, not to yours.

Ask your human partner to add a machine-level backstop to
`~/.codex/config.toml` so any spawn that slips through still routes to
a deliberate tier instead of silently inheriting the session's most
expensive model:

```toml
[agents]
default_subagent_model = "<a mid-tier model from your spawn allowlist>"
default_subagent_reasoning_effort = "medium"
```

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

## Project-Configured Subagent Routing

Prefer subagent routing declared by the current project over generic role
routing: read the nearest project `AGENTS.md` (and project `.codex`
configuration) for explicitly configured subagent routes first, then fall
back to the capability-aware roles above, then to the configured generic
fallback. Skills never maintain project subagent lists — the project owns its
routes; this file only declares the priority.

## Bailian Multi-Agent V1 Compatibility

Codex 0.146.0 uses different working transport paths for these Providers. Keep
the default OpenAI profile on V2 and select V1 in the Bailian profile:

```toml
# config.toml
[features]
multi_agent = true
multi_agent_v2 = true

[agents]
enabled = true
max_concurrent_threads_per_session = 4

# bailian.config.toml overlay
[features]
multi_agent = true
multi_agent_v2 = false

[agents]
enabled = true
max_concurrent_threads_per_session = 4
```

The proven native matrix is GPT → GPT on V2, plus Qwen → Qwen and Qwen → GPT
on V1. A Bailian parent may start four Qwen children concurrently. For a
cross-model child, use an advertised role and an isolated child context
(`fork_turns: "none"` when the schema offers it), then send the complete task
contract in `message`.

GPT → Qwen task delivery is not compatible with the current V2 transport.
The file package is the compatibility fallback for that direction. Keep the Qwen
templates installed for Bailian routing, while the default GPT profile
advertises only routes that can receive their task payload.

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
