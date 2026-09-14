---
name: subagent-driven-development
description: Use for an existing implementation plan when independent work packages benefit from delegated context, ownership and review. Availability of subagents alone is not a trigger.
---

# Subagent-Driven Development

Delegate meaningful work packages when their independence, context isolation or
parallelism is worth the coordination. Direct execution remains appropriate
for tightly connected or small work. Group same-shape edits rather than
creating a child and review gate for each file.

The controller retains design decisions and final acceptance. Children may
investigate, draft and implement. Use the active harness's
`using-superpowers/references/*-tools.md` for actual tools, models and permissions;
separate context does not isolate the checkout or Git index.

## Set up the work

Read the plan and any referenced spec once, reusing unchanged context. Direct
requirements recorded in a plan need no separate spec. Reuse its progress
record for scope, material rulings, remaining work and recovery; optional helper
artifacts should improve handoff, not create a duplicate ledger.

Use `using-git-worktrees` to create or verify the isolated workspace for plan
execution. Existing authorization covers ordinary reversible setup; do not
start on main/master without explicit consent. Missing dependencies or facts
are resolved within scope, with only the affected path paused when necessary.

Reuse the plan's coverage/interface review when inputs are unchanged. Inspect
changed dependencies or concrete gaps instead of repeating a full preflight.
Requirements and approved decisions are binding; predicted file locations and
step order may change when an equivalent implementation better serves them.

## Select a package and executor

Give the executor its goal, ownership, relevant interfaces and acceptance
criteria, with the code locations or examples it needs. Keep the task bounded;
extra context is useful when it resolves a real ambiguity, not when it copies
the entire conversation. Ordinary technical choices remain the executor's.

Choose an advertised role suitable for the task, allowing the harness
configuration to supply model and effort. If no role fits, use the supported
default or an authorized explicit selection. Capability depends on the task
and observed results, not a permanent ranking in this skill. Repair missing
context, narrow the package or change the authorized route when needed.

### Shared state and review identity

Assign disjoint writes when packages overlap in time. Serialize shared index,
generated-state and integration operations, or isolate those writers. Review
and implementation can overlap for independent packages when the actual
harness supports it and each review has a stable attributable work state.

For committed work, record BASE before implementation and review the complete
BASE..HEAD range. For dirty work, retain the pre-dispatch owned-path contents
or complete diffs (including untracked contents), alongside status and paths,
so existing user edits can be distinguished from the package delta. Reuse the
existing record; status alone cannot establish authorship. A review snapshot includes staged and
unstaged diffs plus untracked owned files, with scoped writers quiescent during
capture/review. HEAD alone cannot identify these changes. If inputs change,
refresh the affected evidence rather than invalidating unrelated work.

## Dispatch and accept

Use [implementer-prompt.md](implementer-prompt.md) as a task brief shape. Supply
only applicable fields; no separate brief/report file is required when the
existing task context suffices. Include observable acceptance criteria and
existing commands when useful, not invented commands for missing tests.
Children return their changes, evidence and material concerns. The controller
coordinates any additional delegation or independent review rather than
allowing an executor to create uncoordinated review seats.

Do useful local work while a child runs. When idle, use the harness's completion
or wait mechanism within its communication deadline. Reuse a retained child
when its context helps; use a fresh context when the task needs it. Follow-up
and message tools have different wake-up behavior across adapters.

Accept results under `verification-before-completion`: inspect actual changes,
relevant raw output, exit status and artifacts against the acceptance criteria
and current work state. A success summary alone is not evidence. Valid existing
checks need not be rerun; a concrete gap calls for the smallest useful check.

## Select review where it adds judgment

Use `requesting-code-review` at a meaningful boundary based on changed risk,
ownership and integration needs. A small low-risk package can use self-review
and focused checks. A substantial or high-risk branch merits a whole-change
review; it is not an automatic extra stage for every task-scoped review.

When selected, give [task-reviewer-prompt.md](task-reviewer-prompt.md) the scope,
binding requirements, approved tradeoffs and relevant evidence. The reviewer
can question those decisions with evidence; providing their source is not
prejudging a verdict. Do not instruct a reviewer to hide a risk or lower its
severity. Planned file edits matter when they represent an explicit requirement,
not merely an estimate of where implementation might happen.

The reviewer may inspect nearby unchanged consumers for a concrete risk.
Missing context is resolved by a focused read or check, not presumed to be a
missing implementation. Out-of-scope observations retain their severity and
are routed to the controller, without automatically expanding this package.

## Resolve findings and continue

Adjudicate findings against the approved intent and evidence. Fix a real
Critical/Important acceptance gap; close a disproven finding with its reason.
Triage Minor suggestions for relevance, deferring them in the existing record
when appropriate. A suggestion is not automatically a new requirement.

Group repairs by ownership and dependency. A straightforward correction may be
made locally; resume an executor when useful. Verify the changed behavior and
use [re-review-prompt.md](re-review-prompt.md) when the repair changes a risk
surface that needs independent judgment. An isolated wording fix can use a
focused check. Re-review addresses the findings and new breakage in that fix;
unrelated issues go to controller triage.

A real unresolved acceptance gap prevents that package being called complete.
Independent packages may continue. Repeated identical attempts call for a new
strategy, not a fixed-count waiver or mandatory interruption. Continue a
feasible authorized repair; if no reliable path remains, report incomplete.
Material decisions can use the plan/report's existing
`Ruling: decision — reason — cost if wrong` record.

For authorization and design boundaries, follow `using-superpowers` and
`executing-plans`: ordinary implementation decisions do not stall; changing the
approved design or scope, missing authorization for sensitive/external actions,
or an absence of a reliable path returns only the affected decision to the user.

## Finish and optional helpers

Completion means the work meets acceptance with current evidence and any
selected review's real gaps resolved. Retain material decisions and remaining
uncertainty in the plan or report. The final response can link that record and
summarize the consequences rather than repeat every implementation choice.
Use `finishing-a-development-branch` when integration or cleanup is requested;
otherwise deliver the result and retained workspace without opening a menu.
Archive requested workspace records under the project's retention convention
(default ~/scratch), preserving recovery evidence rather than recursively
deleting it.

Existing helpers remain available without making their output compulsory:

- `scripts/sdd-workspace PLAN_FILE`: plan-specific ignored scratch directory.
- `scripts/task-brief PLAN_FILE N`: extracts a plan task for a durable handoff.
- `scripts/review-package PLAN_FILE BASE HEAD`: packages a committed range;
  use its documented dirty mode or an equivalent complete owned-path snapshot
  for uncommitted work.

If maintaining a scoped ledger, identify it as `# SDD ledger — plan: <plan file path>`
and reuse it only for that plan. Read another package's artifact only for an
authorized dependency handoff; do not browse unrelated scratch. Helpers are
conveniences; acceptance comes from the actual work and its evidence.
