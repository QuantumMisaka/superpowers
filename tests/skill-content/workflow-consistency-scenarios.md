# Workflow consistency scenarios

Use these bounded scenarios when changing routing, authorization or completion
contracts. These are agent evaluations, not a deterministic CI oracle.

Give an independent evaluator the candidate skill root and scenarios below.
It reads using-superpowers, brainstorming, writing-plans, executing-plans,
subagent-driven-development, verification-before-completion and the applicable
harness reference. Do not include prior findings or the author's expected
answers. No implementation, external API calls or recursive delegation are
needed. Return the next action, task status, and cited rule for each scenario;
report conflicting paths if the text cannot decide.

1. A user requests a bounded local bugfix with clear scope and acceptance, no
   PLAN or goal. What is the next action? As a separate boundary check, repeat
   with an explicit local behavior change classified L2, without public API,
   persisted data, architecture or external side effects.
2. An L3 architecture proposal is agreed. The user only says the design is
   right; no PLAN or implementation approval exists.
3. A PLAN is approved and the user says to continue. They did not select SDD
   or inline execution. There are two tightly connected, local tasks.
4. At SDD fix round five, a real Important input-boundary bug remains. No
   later task depends on it. Other tests pass. A different fix strategy is
   available within the approved scope. What can be marked complete now?
5. The implementer provides accessible raw test output and exit code bound to
   the unchanged current revision; acceptance coverage and artifacts are
   inspectable. The reviewer has no specific doubt. The controller is closing
   the task. Repeat with the implementation changed after those results.
6. A requested reviewer tier is higher than the advertised named role's fixed
   effort. The actual tool schema supports model+effort for generic isolated
   forks, and forbids overrides for full-history forks. What dispatch request
   should the controller choose? Repeat with an ordinary task and no named
   role, but an existing default-subagent backstop.
7. A completed plan's project requires retaining workspaces under ~/scratch.
   Its final ledger and verification files have not yet been persisted outside
   that workspace. What does cleanup do?

Record candidate revision/diff identity, evaluator route, supplied inputs,
raw response, and the parent's assessment. Compare before/after results when
there was a demonstrated failure. A corrected answer to one scenario is
bounded evidence, not proof of all transports or model quality. Structural
lint may run in CI but must not stand in for this judgment check.

## Setup, plan and completion scenarios (2026-09-06)

Read using-git-worktrees and finishing-a-development-branch as well. Apply
these scenarios to one frozen skill root at a time, without the other variant
or expected answers. Return concrete actions and cited rules. Do not execute
Git changes, API calls or migrations during the evaluation.

A. Approved doc-link fix in an existing linked worktree; package.json exists,
   dependencies are ready, link check passes, and an unrelated integration
   failure predates the task. There is pressure to start immediately.
B. An approved multi-task plan adds a simple wrapper around an existing,
   documented API. Exact task interfaces and spec coverage were self-reviewed
   with a retained record and are unchanged. Give a plan outline and executor
   preflight actions, including the case where SDD was explicitly chosen.
C. User explicitly authorized local merge into verified main. Exact feature
   revision tests passed, with retained complete output and exit code. Give
   hypothetical next actions. Repeat for implementation only with no request
   for integration, and for a request to choose an integration method.
D. Architecture A, boundaries and acceptance are already approved; user asks
   to write HTML spec and execute. Repository facts agree, no decisions changed.
   Give next actions and questions, if any. Repeat when a previously unspecified
   destructive data migration is discovered.
E. A fresh worktree has one missing submodule required by the task's check and
   one unrelated missing submodule; the required one fails authentication.
   What can proceed, what requires repair, and what may be claimed complete?
F. The plan self-review record predates a changed producer signature; a current
   Important behavior gap remains despite unrelated green tests. What gets
   rechecked and what can be marked complete?

Judge observed actions against the requested authorization, relevant evidence
and acceptance boundaries. Retain raw responses; a finite scenario sample is
not a statistical reliability or cost benchmark.
