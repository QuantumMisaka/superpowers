# Adaptive workflow routing cases

Each case runs in a fresh session. Do not reveal the expected level or preferred
model group in the prompt. Score the complete response on the six shared fields
below.

## Shared scoring

1. `route`: selected L1, L2, or L3 from observable risk rather than file count.
2. `skill_read`: read every matched or explicitly named Skill before its governed action.
3. `scope`: proposed only the artifacts and process justified by the selected level.
4. `evidence`: named an exact verification signal proportional to the claim.
5. `language`: led with goals, actions, conditions, and evidence rather than generalized warnings.
6. `agent_fit`: avoided delegation when unnecessary; otherwise matched bounded
   engineering/code-review work to GPT and large-context/progress/document work
   to Qwen while retaining the decision in the parent.

## Case 1: Local configuration value

In a trusted local Codex configuration, change the already-existing
`model_reasoning_effort` value from `low` to `medium`, then verify the parsed
value. No other behavior changes.

Expected route: L1. No spec, plan file, subagent, or full TDD cycle.

## Case 2: Bounded bug with an owning suite

An existing parser accepts an empty provider slug. The owning test file already
covers valid and invalid slugs. Fix this bug without changing the public schema.

Expected route: L2. Diagnose, add a failing regression case, implement, and run
the owning suite. No formal spec.

## Case 3: One-file public schema change

Add a required field to a public persisted configuration schema. The schema
implementation is one file, but existing stored configurations must remain
readable.

Expected route: L3 because compatibility and migration decisions remain open.

## Case 4: Mechanical multi-file migration

Rename one private helper and all of its statically discoverable call sites
across twelve files. A repository-wide check can prove no old references remain.

Expected route: L3 implementation planning without a full product design spec.

## Case 5: Ambiguous cross-system behavior

Add retry behavior shared by a CLI, background worker, and external API client.
The retry limit, idempotency boundary, and user-visible failure behavior are not
specified.

Expected route: L3 design clarification before implementation.

## Case 6: Skill and repository instruction precedence

The task is a bug fix, the repository AGENTS.md names its exact test command,
and a matching debugging Skill is installed. Explain the first actions you take.

Expected route: read the current matching Skill and nearest AGENTS.md, then use
their commands and constraints; direct user requirements remain highest priority.

## Case 7: Complex implementation with progress tracking

An approved plan contains four dependent engineering tasks. The second task
changes a parser, cache invalidation, and concurrency control across multiple
files. The plan and prior-task reports are long, and the user requests
multi-Agent execution with a checkpoint after each task.

Expected route: L3. GPT owns the complex implementation and code-detail review;
Qwen compares plan, status, diffs, and evidence at checkpoints. The parent
handles dependencies and final decisions.

## Case 8: Large-context design artifact

Several long local reports, repository rules, and existing implementation plans
must be consolidated into an HTML design spec and Markdown implementation plan.
Architecture decisions have been confirmed, but source fidelity and technical
implementability both need review.

Expected route: L3. Qwen analyzes the large context and drafts/reviews the
documents; GPT reviews technical contracts and implementability; the parent
resolves conflicts and approves the result.
