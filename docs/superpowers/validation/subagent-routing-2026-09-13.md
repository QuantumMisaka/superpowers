# Subagent routing and local synchronization validation — 2026-09-13

## Scope and baseline

User authorized repairing the audited subagent mechanisms, especially task-based
model selection and preset-role design, and synchronizing the app-tools pinned
checkout with the installed personal/codex-sync checkout. Both started at
`9cddafcad666e74cd819b469b24120d80f223d56` with clean Superpowers worktrees.
Unrelated ABACUS working-tree edits are outside this change.

Baseline inspection and a separate read-only analyst identified three conflicts:
SDD claimed omitted models always inherit the parent; parallel dispatch named
an unavailable `independent-parallel` interface and confused response boundaries
with concurrency; the parallel guide forbade reviewed packages from overlapping
although SDD allowed independent packages. The routing structural lint passed
that baseline, so structural success alone did not detect these defects.

## Decisions

- Ruling: use task type, complexity, and risk to select available preset roles;
  keep concrete models/efforts in harness configuration — avoids duplicating
  the live catalog — an unsuitable selection costs rework and should trigger
  context repair, decomposition, or an authorized route change.
- Ruling: synchronize the changed local files and verify installed symlink
  resolution — both checkouts share the same baseline — this does not publish
  a commit, advance a parent gitlink, or update another machine.
- The entry remains within its 60-line / 6144-byte budget. Role configuration,
  permission profiles, and provider credentials are not changed.

## Candidate scenario evidence

An independent `gpt_task_reviewer` with `fork_turns: none` read the candidate
skills and answered scenarios L/M/N/O from
`tests/skill-content/workflow-consistency-scenarios.md`. This is bounded agent
interpretation evidence, not an end-to-end transport or model-quality benchmark.

Observed response:

- L: mechanical edit / integration / source analysis / whole-change security
  review select routine / standard / context analyst / final reviewer presets,
  with isolated context and omitted model/effort overrides. An unmatched task
  uses the configured generic backstop; an authorized tier change uses a
  generic isolated fork with both supported model and effort. Full-history
  overrides are rejected by the scenario contract.
- M: the parent and two independent implementers use three of four slots.
  A completed package can enter review while the other implementation runs;
  independent reviews may overlap when capacity permits. Shared generated
  files and Git index writes are serialized or separately isolated.
- N: `followup_task` resumes a retained idle child; `send_message` alone does
  not wake it. At thread capacity, reuse a suitable child or continue locally.
  Changed acceptance inputs invalidate affected evidence; unchanged evidence
  may be reused, with focused checks and review for the changed surface.
- O: retain an owned-path pre-dispatch baseline and a later scoped snapshot
  including status, staged/unstaged changes and untracked contents. Compare
  for authorship; exclude unrelated changes and quiesce scoped writers during
  capture/review. A snapshot is not atomic workspace isolation.

The evaluator found no internal routing conflict in these scenarios. It also
flagged the dirty helper interface while implementation was still in progress;
that finding is now closed by the implemented interface and the regression
results below.

## Verification and limits

- `abacus-env` interpreter/import and `adam-cli --help` preflight passed.
- `conda run -n abacus-env bash tests/skill-content/run-tests.sh`: exit 0.
  Structural checks do not establish model routing or permission enforcement.
- Runtime observation in this task: isolated native dispatch, result delivery,
  and same-identity follow-up completed. No multi-writer stress test or sandbox
  enforcement probe was performed.
- Dirty helper: the implementer observed RED before implementation (old helper
  rejected `--dirty`), then GREEN. After test cleanup and a portable temporary
  filename fix, the controller ran the final test suite against an isolated
  baseline helper and the candidate: baseline exit 1 with six failed checks;
  candidate exit 0 with 22 passing checks. Existing committed-range behavior,
  staged/unstaged and untracked text/binary contents, literal path selection,
  unrelated-file exclusion, index contents, unique outputs and argument errors
  are covered. These final runs are baseline/candidate evidence, not a claim
  that the final test cleanup preceded the original implementation.
- Command: `conda run -n abacus-env bash tests/claude-code/test-sdd-workspace.sh`.
  Final raw logs are retained locally under
  `~/scratch/subagent-routing-validation-jigtkigi/{baseline,candidate}.log`;
  the baseline runner substituted only the old helper in an isolated fixture.
- Test cleanup: strengthened content and whole-index assertions and required
  a nonempty artifact before checking exclusion; temporary fixtures remain
  under `~/scratch`. No new standalone test suite was added.
- Independent document review and final code review returned no remaining
  actionable findings. The code review found a GNU-only mktemp suffix usage;
  the final template ends in `XXXXXX`. Linux execution passed after this fix;
  macOS execution remains unverified.
- `conda run -n abacus-env bash -n` for the helper and owning shell suite, and
  `git diff --check`, passed. The structural suite passed on the candidate.
- Both local Superpowers checkouts contain byte-identical copies of all nine
  changed/new files. The installed `.codex/skills` and `.agents/skills` links for
  the three changed skills resolve to the personal checkout. Changes remain
  local and uncommitted at the end of initial validation. The user subsequently
  authorized commit, push, and parent-gitlink updates; release commit identities
  are recorded by the parent repositories rather than self-referenced here.
- Snapshots require quiescent scoped writers and a separate authorship baseline;
  this change does not provide atomic snapshots, recursive submodule-content
  capture, or stronger sandbox enforcement. Extreme path-name cases and actual
  concurrent writers were not exercised.
