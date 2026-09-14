## Codex native subagent mechanism

Checked 2026-09-13: local CLI 0.154.0 and this session's advertised tool schema.
Codex is the primary development entry; OpenCode uses its own
[native adapter](opencode-tools.md), not nested Codex invocations.
The [official documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents)
describes parallel threads, model/effort inheritance, and inherited sandbox policy.
Installed CLI version and a hosted session's tool surface need not be identical.

Use the active schema first. This session exposes `spawn_agent`,
`followup_task`, `send_message`, `interrupt_agent`, `list_agents`, and
`wait_agent`. A follow-up starts an idle agent; a message alone does not.
The current `fork_turns` control supports none, all, or bounded history; a
full-history fork inherits model/effort and rejects overrides. Separate context
does not create a separate worktree or private Git index.

## Multi-agent availability

Current documented releases enable subagents by default. On a profile that
still gates them, the historical feature flag is:

```toml
[features]
multi_agent = true
```

This enables the multi-agent tools that skills like
`dispatching-parallel-agents` and `subagent-driven-development` use.
Which tools you get depends on the active profile and transport. Trust your
actual tool list over any table — including this one — when they
disagree.

### Profile split: V2 vs V1

The following is this fork's historical profile mapping, not a guarantee about
every current installation; transport follows the active schema:

- **Default OpenAI profile (GPT):** `multi_agent_v2 = true` → V2 surface
  (`followup_task`, no `close_agent`).
- **bailian / deepseek / scnet profiles:** overlay `multi_agent_v2 = false`
  → V1 surface (`send_input`, `wait_agent`, `close_agent`).

Rules below that apply to only one surface say so; untagged rules apply to
both. See `## Bailian Multi-Agent V1 Compatibility` for the proven matrix.

- **Spawning:** give children a clean context with
  `spawn_agent {fork_turns: "none"}`; the default `"all"` copies your
  entire transcript into the child. Select an advertised `agent_type`
  when its configured capability fits. The current full-history fork surface
  inherits model/effort and rejects their overrides; use an isolated or
  bounded-history fork when the active schema permits a deliberate override.
  Recheck the schema after harness updates, rather than extrapolating from
  a version number or an old successful call.
- **Fix rounds:** reuse an implementer when its context helps; use a fresh
  one when the task needs a different perspective. V2 `followup_task` starts
  a retained child; V1 uses `send_input`. If continuation is unavailable,
  supply the needed requirements, changes and findings to a new child.
- **Lifecycle:** This V2 surface has no `close_agent`. Do not invent it.
  Concurrent slots and total thread limits are separate constraints: this
  session rejected new threads even when earlier children had finished.
  Reuse a suitable retained child or continue locally; completion is not proof
  that spawning capacity was released. On V1 surfaces with `close_agent`, close
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
- When idle with children outstanding, use an event wait bounded by the
  active harness's communication deadline. Do not use short repeated polling;
  after a timeout, report status and reconcile agent state before waiting again.
- Completion mail cannot wake an idle controller (it is delivered
  without triggering a turn); covering that idle window is
  `wait_agent`'s only job. A stretch that times out with no activity
  is your cue to reconcile, not to shorten the next stretch.

## Model routing on spawns

Use one routing source per dispatch (2026-09-05 authorized consistency review):

1. Inspect the active schema and project routing, then choose an advertised
   role whose capability and tier fit. Role-file model/effort settings take
   precedence; omit those overrides when the role fixes them.
2. Without a fitting role, use a generic subagent and the configured backstop.
   For a task-authorized tier change, use a generic isolated fork and set both
   `model` and `reasoning_effort`, only if the schema supports them and the
   model/effort are advertised. Keep the full task and permission contract.
3. If the needed tier cannot be expressed, report that gap instead of claiming
   an upgrade. Use another authorized route or ask only for the missing decision.

Check existing `[agents].default_subagent_model` and
`default_subagent_reasoning_effort` before proposing a backstop change. These
settings avoid accidentally inheriting an expensive parent model; they do not
supersede a role file. Use a model's supported effort domain, not a universal
`medium` value. Selecting only a model without an effort may select its default
effort; it is not a reliable way to preserve the parent's tier.

The [official subagent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents)
describes role-file precedence. Actual tool schema and live runtime overrides
remain authoritative for each dispatch; role sandbox defaults alone do not
prove stronger isolation than the parent session grants.
Generic forks inherit the active permission profile. A read-only task prompt
is a behavior contract, not enforced sandbox isolation; if the task requires
enforced isolation, use a route that actually provides it rather than treating
a generic tier change as an equivalent replacement.

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
| Context analyst / progress reviewer | Bounded source analysis or acceptance/progress auditing |
| Document / paper writer or reviewer | Approved drafting or evidence-grounded document review |
| Monitor | Read-only external-job waiting |

The local preset catalog is the reusable design mechanism: each advertised
role packages a model/effort selection, permission defaults, and a bounded
input/output contract. Different task categories can therefore use different
models without changing the controller model. Inspect the live role descriptions
and their config files; this reference does not duplicate concrete model names.
A role name is not proof of enforced isolation.

For example, send a fully specified mechanical edit to the routine implementer,
a dependency integration to the standard implementer, a source-only diagnosis
to the context analyst, and the combined change to the final reviewer when its
risk warrants that review. Keep their task and evidence contracts explicit.
Choose a generic isolated fork when a fitting preset is absent or a permitted
tier adjustment needs it; follow the routing precedence above.

Keep controller work, unresolved architecture decisions, and escalation in the
parent. Planned implementation of an approved design may still use an
implementer role. Serialize dependent work and shared writes. Parallel dispatch
requires independent domains, disjoint ownership, and a review snapshot that
identifies each package's actual changes; the calling workflow owns that choice.

When `agent_type` is visible, prefer the matching configured role and let its
configuration select model and effort. If `agent_type` is absent or no
advertised role matches, dispatch a generic subagent using the backstop or
the task-authorized tier change described above; required reviews still proceed. When `fork_turns` is available, pass
`fork_turns: "none"`; otherwise omit it. Always put the complete task contract
in `message`.

Treat provider specialization as a local routing hypothesis, not a universal
model claim. Within routes actually advertised by the active profile, prefer the GPT engineering group for complex implementation,
debugging, code-detail review, and final architecture review. Prefer the Qwen
information group for large-context synthesis, progress review, document
review, and approved HTML/Markdown drafting. A GPT-only profile uses its own
matching roles; this preference does not authorize spawning an unavailable
Qwen role or opening a paid provider session. Ordinary bounded implementation
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

The following is historical compatibility evidence from Codex 0.146.0, not
a prescription to rewrite current configuration. The installed profile and
active tools decide which routes are available:

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

That historical probe covered GPT → GPT on V2, plus Qwen → Qwen and Qwen → GPT
on V1. It does not prove every route is currently registered or available.
Respect the active session's actual concurrency budget, including its counting
convention for the primary thread. For a
cross-model child, use an advertised role and an isolated child context
(`fork_turns: "none"` when the schema offers it), then send the complete task
contract in `message`.

GPT → Qwen task delivery failed on that tested V2 transport.
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

Ordinary production handoff uses independently opened top-level sessions.
Do not invent nested `codex exec` orchestration. A project-authorized bounded
review launcher may provide a separate controlled path; follow its current
contract and authorization rather than generalizing that exception.

## Environment Detection

Skills that create worktrees or finish branches should detect their
environment with read-only git commands before proceeding:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → check the submodule guard in using-git-worktrees
  before concluding that this is a linked worktree
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
