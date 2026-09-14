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

## Independent cleanup scenarios (2026-09-08)

Read finishing-a-development-branch. Treat each case independently and return
next actions, any pause/question, completion claims and cited rules. Do not
execute cleanup during evaluation.

G. User requests cleanup of old worktrees whose code is absorbed into the named
   target. The project retains files under scratch. Native move fails because
   the tree contains submodules; no archive exists yet.
H. Same request and native failure, but files, ignored/WIP, parent/submodule Git
   metadata and objects have been archived and actual restoration verified.
   The user authorized cleanup after verification.
I. Same as H, but one submodule's external object alternates were not preserved
   and recovery depends on that unverified store.
J. Two absorbed trees are in scope. One has a test process writing files; the
   other is idle with verified recovery. Give per-tree actions.
K. A small implementation-only request is done and tested. Its workspace is
   under `.worktrees`; no integration or cleanup was requested.

## Subagent routing and package scenarios (2026-09-13)

Read dispatching-parallel-agents and the active harness adapter as well.
Use hypothetical available roles from the scenario; do not spawn real jobs or
change provider settings. Return the dispatch fields or next action, cited
rule, and any uncertainty for each case.

L. The parent uses a high-capability model. Available presets include a routine
   implementer, standard implementer, context analyst, and final reviewer with
   fixed model/effort settings. Assign a fully specified mechanical edit, an
   integration bug, a bounded source analysis, and a whole-change security
   review. Repeat with no matching preset but a configured generic backstop,
   then with a task-authorized tier change and an isolated fork. The schema
   forbids model/effort overrides on a full-history fork.
M. Two independent implementation packages each require review. They own
   disjoint files and generated state and can supply separate dirty snapshots.
   The native surface has asynchronous spawn/follow-up/message/wait tools and
   four slots including the parent. Give the execution/review schedule. Repeat
   when both packages need the same generated file or Git index mutation.
N. A child has completed and its identity is retained. A fix in the same scope
   needs its previous context. Describe continuation on the active surface,
   including what to do if new-thread capacity is exhausted. Separately, a
   reviewed dirty package changes after its recorded tests: what remains valid?
O. The working tree contains pre-existing edits, staged and unstaged changes
   to owned files, an untracked owned file, and unrelated changes. Describe
   the review artifact, authorship baseline, and capture coordination needed
   before accepting the package.


## Bounded autonomy scenarios (2026-09-14)

Select relevant cases for the changed guidance; this is not a required full
matrix. Give the evaluator the cases without expected answers and keep the
baseline/candidate roots separate. Do not run real external actions.

P. A user authorized a compatible optional CLI parameter. Only its default A
or B needs a product choice. The user selects A. What happens next?
Q. A multi-file mechanical field migration has known mapping and acceptance,
with no cross-owner coordination or rollout dependency. What happens next?
R. A third repair failed; new logs now identify a reversible local repair that
does not change approved architecture. What happens next?
S. The plan predicted edits to a/b/c, but existing b/c logic supports an a-only
implementation and all requirements have current evidence. Review it. Repeat
when an explicitly requested public behavior of b remains unimplemented.
T. Two duplicate tests protect the same behavior, already covered by consumer
tests. A trivial forwarding function is also covered by those tests. Describe
necessary verification when merging the duplication.
U. A migration changes persisted data across two owners and needs a coordinated
rollout/rollback order; the order is undecided. Implementation is authorized,
but no destructive production action is. Describe planning and authorization.
