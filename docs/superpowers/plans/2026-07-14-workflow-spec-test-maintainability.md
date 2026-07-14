# Superpowers Workflow, Spec, and Test Maintainability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix workflow over-triggering, make full design specs better human review artifacts while keeping plans in Markdown, and preserve strict TDD without leaving fragmented or redundant tests behind.

**Architecture:** Keep Superpowers' existing mandatory-skill and evidence-first philosophy, but add an explicit routing layer before workflow selection. Full brainstorming produces a standalone HTML spec from a reusable template; lightweight work produces no spec, and implementation plans remain Markdown. TDD remains red-green-refactor, while test selection and refactoring move from function-by-function coverage toward durable behavior boundaries and a maintained test portfolio.

**Tech Stack:** Markdown skill documents, standalone HTML/CSS, Bash structural checks, Node/Bun project tests, and Quorum live behavior scenarios from the separately cloned `superpowers-evals` repository.

## Global Constraints

- Preserve zero runtime dependencies.
- Preserve session-start loading of `using-superpowers` and the acceptance behavior that `Let's make a react todo list` invokes brainstorming before implementation.
- Preserve mandatory execution after a workflow skill is selected; only workflow selection becomes lighter.
- Preserve red-green-refactor, root-cause debugging, code review, and verification-before-completion gates.
- New full-design specs use `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.html`; existing Markdown specs remain valid inputs and are not migrated.
- Implementation plans remain `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`.
- A test is required for changed observable behavior, but a new function or method does not automatically require its own direct unit test.
- Skill behavior is proven with Quorum sessions, not source-text assertions.
- Keep the combined word count of the four frequently loaded workflow skills at or below baseline; put heavy templates and references in on-demand files.
- Optimize and live-evaluate Codex behavior; do not add Claude-specific guidance for this change.
- Do not open an upstream PR until open and closed related PRs are searched, the complete diff and eval evidence are shown to the human partner, and the human partner explicitly approves submission.

## Compatibility Audit of the Current Diff

The current changes contain the right product direction, but are not safe to accept unchanged.

| Current change | Decision | Reason |
| --- | --- | --- |
| Add direct, lightweight, debugging, design, and planning routes | Keep | Matches the existing cost calibration pair in `superpowers-evals`: trivial checkbox work must not brainstorm, while an open-ended notification system must brainstorm. |
| Remove the unconditional `1% chance` trigger | Revise | The old wording causes over-triggering, but the replacement also removes the explicit rule that a selected applicable skill is mandatory. Keep mandatory execution after routing. |
| Replace `EXTREMELY-IMPORTANT` with general guidance | Revise | This weakens a load-bearing bootstrap contract. The hard gate should move from “invoke every possibly relevant skill” to “classify first; then invoke every skill required by the selected route.” |
| Add lightweight alignment | Keep | It fills the gap between direct execution and a full design process without inventing a new skill. |
| Scope full brainstorming to meaningful design uncertainty | Keep | This is consistent with existing paired behavior evals and avoids using design ceremony for mechanical edits. |
| Make HTML the default full-design artifact | Keep with compatibility work | It supports richer human review, but the current diff breaks the existing `cost-spec-plan-duplication` scenario, which expects `*.md`, and does not teach `writing-plans` to consume HTML anchors. |
| Embed a complete HTML skeleton inside `brainstorming/SKILL.md` | Move to a supporting template | The template is reusable supporting material and should not enlarge a frequently loaded behavior skill. |
| Keep implementation plans in Markdown | Keep | Markdown is diffable, task-oriented, and already integrated with execution skills. |
| Add `tests/skill-content/test-routing-and-html-artifacts.sh` | Replace | Its exact-string assertions prove prose presence, not agent behavior. Keep only deterministic HTML-template contract checks in `tests/`; put routing and TDD behavior in Quorum. |
| Leave TDD and writing-plans test guidance unchanged | Fix | The third reported problem is otherwise completely unaddressed. |

## File Ownership

- `skills/using-superpowers/SKILL.md`: workflow classification and mandatory routing contract.
- `skills/brainstorming/SKILL.md`: full-design versus lightweight-alignment behavior and artifact handoff.
- `skills/brainstorming/design-template.html`: reusable standalone HTML spec structure.
- `skills/brainstorming/spec-document-reviewer-prompt.md`: format-neutral completeness review.
- `skills/writing-plans/SKILL.md`: accepts HTML or legacy Markdown specs, emits Markdown plans, and selects durable test locations.
- `skills/executing-plans/SKILL.md`: reads task-cited HTML sections or Markdown headings before inline execution.
- `skills/subagent-driven-development/SKILL.md`: carries task-cited spec context into file-based handoffs.
- `skills/test-driven-development/SKILL.md`: red-green-refactor contract and behavior-boundary test scope.
- `skills/test-driven-development/writing-good-tests.md`: positive test quality and portfolio-maintenance rules.
- `skills/requesting-code-review/code-reviewer.md`: whole-change test maintainability review.
- `skills/subagent-driven-development/task-reviewer-prompt.md`: task-scoped test placement and redundancy review.
- `skills/subagent-driven-development/implementer-prompt.md`: implementation report includes durable test disposition.
- `tests/skill-content/test-design-artifact-contract.sh`: deterministic checks for the reusable HTML artifact.
- `tests/skill-content/run-tests.sh`: local entry point for the deterministic artifact checks.
- `README.md`, `RELEASE-NOTES.md`, and `docs/testing.md`: user-facing workflow, artifact, and verification contracts.
- `evals/scenarios/*`: behavior scenarios in the separately versioned eval repository; these changes must be committed there separately from the core plugin change.

---

### Task 1: Establish Behavior Baselines and Guardrails

**Files:**

- Create: `evals/scenarios/tdd-consolidates-existing-test-boundary/story.md`
- Create: `evals/scenarios/tdd-consolidates-existing-test-boundary/setup.sh`
- Create: `evals/scenarios/tdd-consolidates-existing-test-boundary/checks.sh`
- Create: `evals/scenarios/tdd-consolidates-existing-test-boundary/fixtures/package.json`
- Create: `evals/scenarios/tdd-consolidates-existing-test-boundary/fixtures/src/discount.js`
- Create: `evals/scenarios/tdd-consolidates-existing-test-boundary/fixtures/test/discount.test.js`
- Create: `evals/docs/experiments/2026-07-14-workflow-spec-test-maintainability.md`
- Modify: `evals/scenarios/cost-spec-plan-duplication/story.md`
- Modify: `evals/scenarios/cost-spec-plan-duplication/checks.sh`

**Interfaces:**

- Consumes: Quorum's directory-based scenario format, `setup-helpers run init_repo_from_fixtures`, and the existing `check-transcript`/filesystem check DSL.
- Produces: a before/after evidence matrix for routing, artifact format, TDD discipline, and test-suite consolidation.

- [ ] **Step 1: Add the test-maintainability pressure scenario**

Create a fixture with one production module and one existing table-driven test file. The story asks for a new discount boundary while a task note suggests creating a separate test file. Acceptance requires the agent to preserve TDD, extend the existing behavior table, keep one test file, and leave the suite green.

The deterministic postconditions are:

```bash
post() {
    file-exists 'test/discount.test.js'
    not file-exists 'test/discount-boundary.test.js'
    command-succeeds 'node --test'
    command-succeeds 'test "$(find test -type f -name "*.test.js" | wc -l | tr -d " ")" = 1'
}
```

The story's acceptance criteria must distinguish consolidation from test skipping:

```markdown
- The agent engaged test-driven-development before implementation.
- The new `100`/`101` boundary is covered by an executable assertion.
- The agent extended the existing table in `test/discount.test.js` instead of
  creating `test/discount-boundary.test.js` or a one-off script.
- `node --test` reports at least one passing test and zero failures.
```

- [ ] **Step 2: Update the spec/plan cost scenario for the new artifact contract**

Change only the spec-format expectation. Keep the plan expectation in Markdown:

```bash
post() {
    file-exists 'docs/superpowers/specs/*.html'
    file-exists 'docs/superpowers/plans/*.md'
}
```

Update the story to require that the Markdown plan links to the HTML spec path and references section IDs instead of restating the full requirements.

- [ ] **Step 3: Run the baseline matrix against the unmodified `HEAD` checkout**

Run Codex for these scenarios:

```bash
cd evals
bun run quorum run scenarios/cost-checkbox-over-trigger --coding-agent codex
bun run quorum run scenarios/brainstorming-resists-jump-to-implementation --coding-agent codex
bun run quorum run scenarios/cost-spec-plan-duplication --coding-agent codex
bun run quorum run scenarios/tdd-holds-under-tests-later-pressure --coding-agent codex
bun run quorum run scenarios/writing-good-tests-no-coverage-over-correction --coding-agent codex
bun run quorum run scenarios/tdd-consolidates-existing-test-boundary --coding-agent codex
```

Record run IDs, agent/model versions, pass/fail results, token counts, and exact failure rationalizations in the experiment document. The expected RED signal is over-triggering cost and/or failure to consolidate tests; existing discipline scenarios must establish the non-regression floor.

- [ ] **Step 4: Commit the eval baseline separately in the eval repository**

```bash
cd evals
git add scenarios/tdd-consolidates-existing-test-boundary \
  scenarios/cost-spec-plan-duplication \
  docs/experiments/2026-07-14-workflow-spec-test-maintainability.md
git commit -m "eval: cover workflow routing, HTML specs, and test consolidation"
```

---

### Task 2: Make Workflow Routing Lightweight Without Weakening Skill Discipline

**Files:**

- Modify: `skills/using-superpowers/SKILL.md`
- Modify: `README.md`

**Interfaces:**

- Consumes: session-start bootstrap injection and native harness skill-loading mechanisms.
- Produces: one routing decision followed by mandatory invocation of the skills required by that route.

- [ ] **Step 1: Replace possibility-based triggering with route-based triggering**

Keep a compact hard gate near the beginning of `using-superpowers`:

```markdown
<EXTREMELY-IMPORTANT>
Classify the request before acting. Once a route requires a skill, invoke that
skill before taking the action it governs. Routing may be lightweight; selected
skill instructions are mandatory.
</EXTREMELY-IMPORTANT>
```

Use exactly four routes:

```markdown
| Route | Trigger | Required workflow |
| --- | --- | --- |
| Direct | Read-only question, command output, lookup, or explanation | Answer or inspect directly |
| Lightweight delivery | Small, well-scoped change with clear success criteria | Relevant implementation discipline and verification; no brainstorming or plan |
| Investigation | Bug, failing test, flaky behavior, or unexplained symptom | systematic-debugging, then the relevant implementation discipline |
| Full design | New behavior with meaningful choices, UX/architecture work, multiple subsystems, or unclear success criteria | brainstorming, then writing-plans after design approval |
```

Remove `usually test-driven-development`; a selected implementation discipline must not be optional. Keep explicit user-requested skills mandatory.

- [ ] **Step 2: Keep lightweight alignment as a bounded intent check**

The alignment contract is:

```markdown
For bounded but under-specified work: inspect repo facts, state the intended
change and success check, ask at most one blocking question with a recommended
default, then proceed through the selected route. Lightweight alignment never
creates a spec unless it uncovers design uncertainty.
```

Do not duplicate this process in every skill; `brainstorming` may reference it in one paragraph.

- [ ] **Step 3: Enforce a bootstrap token non-regression budget**

Move examples and extended rationale out of the bootstrap. The modified file must not exceed the original `HEAD` word count:

```bash
test "$(wc -w < skills/using-superpowers/SKILL.md)" -le \
  "$(git show HEAD:skills/using-superpowers/SKILL.md | wc -w)"
```

Expected: exit 0. This keeps the session-start skill from becoming a larger tax while fixing over-triggering.

- [ ] **Step 4: Update the README workflow description**

Describe the same four routes and retain the core philosophy: TDD, systematic investigation, evidence before claims, and design before implementation when design uncertainty exists. Do not claim every code edit produces a spec.

- [ ] **Step 5: Run the paired routing evals**

```bash
cd evals
bun run quorum run scenarios/cost-checkbox-over-trigger --coding-agent codex
bun run quorum run scenarios/brainstorming-resists-jump-to-implementation --coding-agent codex
```

Expected: checkbox does not call brainstorming; notification system calls brainstorming before implementation in Codex. Compare token counts with Task 1.

- [ ] **Step 6: Commit the routing change**

```bash
git add skills/using-superpowers/SKILL.md README.md
git commit -m "fix: route small work without weakening skill gates"
```

---

### Task 3: Introduce HTML Design Specs With Legacy Markdown Compatibility

**Files:**

- Modify: `skills/brainstorming/SKILL.md`
- Create: `skills/brainstorming/design-template.html`
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `skills/executing-plans/SKILL.md`
- Modify: `skills/subagent-driven-development/SKILL.md`
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `RELEASE-NOTES.md`

**Interfaces:**

- Consumes: approved full-design discussion and either a new HTML spec or an existing Markdown spec.
- Produces: one standalone HTML design artifact for new full designs and one Markdown implementation plan that links back to its spec.

- [ ] **Step 1: Retain the scoped brainstorming gate**

Keep the current diff's full-brainstorming triggers and exclusions, but make the gate explicit:

```markdown
For full brainstorming, do not write implementation code or invoke an
implementation workflow until the design is approved. Small, clear edits do
not enter full brainstorming; route them through lightweight delivery.
```

Preserve one-question-at-a-time clarification, 2-3 approaches, incremental human approval, YAGNI, scope decomposition, and the transition to `writing-plans`.

- [ ] **Step 2: Move the HTML skeleton into a reusable template**

Create `skills/brainstorming/design-template.html` as standalone semantic HTML with inline CSS and these stable section IDs:

```html
<main>
  <section id="summary"><h2>Summary</h2></section>
  <section id="goals"><h2>Goals and Non-Goals</h2></section>
  <section id="requirements"><h2>Requirements</h2></section>
  <section id="decisions"><h2>Decisions and Alternatives</h2></section>
  <section id="architecture"><h2>Architecture and Data Flow</h2></section>
  <section id="errors"><h2>Error Handling</h2></section>
  <section id="testing"><h2>Testing</h2></section>
  <section id="rollout"><h2>Rollout</h2></section>
  <section id="risks"><h2>Risks and Open Questions</h2></section>
</main>
```

The template must be directly openable, responsive, printable, readable without JavaScript, and free of external fonts, images, scripts, and stylesheets.

- [ ] **Step 3: Make the brainstorming artifact contract concise and format-aware**

Replace the inline skeleton in `brainstorming/SKILL.md` with:

```markdown
For an approved full design, copy `design-template.html` to
`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.html` and fill every section.
The HTML file is the source of truth for new designs. Existing `.md` specs stay
valid; do not convert them. A project or explicit human preference may select
Markdown instead.
```

Retain the self-review and human-review gates. Require the agent to tell the human partner the exact artifact path before transitioning to `writing-plans`.

- [ ] **Step 4: Make spec review independent of file format**

Update `spec-document-reviewer-prompt.md` to accept `*.html` and `*.md`. For HTML, it must inspect rendered-content semantics rather than grade CSS aesthetics. Keep completeness, consistency, clarity, scope, and YAGNI as the only blocking categories.

- [ ] **Step 5: Teach writing-plans to consume both formats and keep plans in Markdown**

Add this input contract near the top of `writing-plans/SKILL.md`:

```markdown
The approved spec may be HTML or Markdown. Read the supplied path directly.
For HTML, use section IDs when referencing requirements; for Markdown, use
headings. Do not duplicate the spec into the plan. Plans always remain Markdown
unless the human partner explicitly requests another format.
```

Add a required header line:

```markdown
**Spec:** `docs/superpowers/specs/<exact-approved-file>`
```

The plan's global constraints should copy only cross-task invariants; task steps should link back to spec sections rather than reproduce their prose.

Teach both execution paths to read only the HTML section IDs or Markdown
headings cited by a task. Pass the exact spec path to subagent implementers and
reviewers instead of copying the whole spec into prompts.

- [ ] **Step 6: Document the format transition without migrating history**

Update `RELEASE-NOTES.md` to state that new full brainstorming artifacts default to HTML, plans remain Markdown, and existing Markdown specs remain supported. Do not rename or rewrite the 14 historical Markdown specs.

- [ ] **Step 7: Run the artifact and duplication eval**

```bash
cd evals
bun run quorum run scenarios/cost-spec-plan-duplication --coding-agent codex
```

Expected: one HTML spec, one Markdown plan, and a plan that references the HTML path/section IDs without duplicating the design.

- [ ] **Step 8: Commit the artifact contract**

```bash
git add skills/brainstorming/SKILL.md \
  skills/brainstorming/design-template.html \
  skills/brainstorming/spec-document-reviewer-prompt.md \
  skills/writing-plans/SKILL.md RELEASE-NOTES.md
git commit -m "feat: use HTML for full design specs"
```

---

### Task 4: Preserve TDD While Managing the Test Portfolio

**Files:**

- Modify: `skills/test-driven-development/SKILL.md`
- Rename: `skills/test-driven-development/testing-anti-patterns.md` to `skills/test-driven-development/writing-good-tests.md`
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `skills/requesting-code-review/code-reviewer.md`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `skills/subagent-driven-development/implementer-prompt.md`

**Interfaces:**

- Consumes: a behavior change, existing test topology, and the red-green-refactor cycle.
- Produces: the smallest durable test set that protects observable behavior at stable boundaries.

- [ ] **Step 1: Reframe direct test coverage around observable behavior**

Keep the iron law `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`. Change the completion checklist from “every new function/method has a test” to:

```markdown
- [ ] Every changed observable behavior is protected by a test that failed first
- [ ] Each test names the production break it catches
- [ ] New helpers are covered through the nearest stable public boundary unless
      they independently validate, normalize, default, derive, or cause side effects
```

Clarify that “one behavior” means one reason for failure, not one new test file, one test per production function, or one assertion per test.

- [ ] **Step 2: Add test-suite refactoring to the REFACTOR phase**

Add these actions after production refactoring:

```markdown
- Extend an existing table or nearby suite before creating a new test file.
- Merge cases that exercise the same behavior through the same setup.
- Delete tautologies, exact-source-text checks, and coverage-only assertions.
- Promote a characterization test to a durable contract test only when the
  behavior is relied upon; otherwise remove the temporary probe.
- Move reusable setup into test utilities without adding test-only production APIs.
```

Deleting redundant tests is allowed only after the remaining suite proves the same realistic production mutations are still caught.

- [ ] **Step 3: Replace prohibition-only anti-pattern guidance with positive test design**

Rename `testing-anti-patterns.md` to `writing-good-tests.md` and preserve its existing real-behavior/mock guidance. Add two governing principles:

```markdown
1. Every test names the break it catches.
2. Every test exercises the real behavior at the narrowest stable boundary.
```

Add a `Test Portfolio Maintenance` section covering nearest-suite placement, table-driven consolidation, durable versus temporary tests, one-off script cleanup, and mutation-based redundancy checks. Base this rewrite on the already evaluated positive-reframe experiment at commit `0e69a4d32c2db00ebc012310d303907cc5507c6f`, then limit new prose to the portfolio-maintenance gap reported here.

- [ ] **Step 4: Stop writing-plans from defaulting to a new test file per task**

Replace the task template's single `Test:` entry with:

```markdown
**Test strategy:**
- Behavior boundary: [exact public behavior this task changes]
- Existing suite to extend: `exact/path/to/test-file`
- New test file justification: none; create one only when no existing suite owns
  the behavior or the task introduces a new independently runnable boundary
- Temporary probes: list the exact path and require removal before commit
```

During implementation, replace the bracketed instructional examples with concrete values from the repository; they are template fields, not permitted output in a generated plan.

Keep failing-test, verify-red, minimal-implementation, verify-green, and commit steps. Add a test-refactor step before commit that consolidates redundant cases and runs the owning suite again.

- [ ] **Step 5: Add maintainability checks to implementation and review prompts**

Require implementer reports to include:

```markdown
- TDD evidence: failing command/result, then passing command/result
- Durable test disposition: existing suite extended or justified new suite
- Temporary artifacts removed: exact paths, or `none`
- Redundant tests removed or consolidated: exact cases, or `none`
```

Add these reviewer questions to both task and whole-change review:

```markdown
- Does each new test catch a named production regression?
- Was the nearest existing suite extended where practical?
- Are there duplicate cases, exact-source-text checks, test-only scripts, or
  test-only production APIs that should not ship?
- Would removing a proposed redundant test leave the same behavior protected?
```

- [ ] **Step 6: Run discipline and over-correction evals**

```bash
cd evals
bun run quorum run scenarios/tdd-holds-under-tests-later-pressure --coding-agent codex
bun run quorum run scenarios/writing-good-tests-no-coverage-over-correction --coding-agent codex
bun run quorum run scenarios/writing-good-tests-rejects-test-only-teardown --coding-agent codex
bun run quorum run scenarios/tdd-consolidates-existing-test-boundary --coding-agent codex
```

Expected: TDD remains mandatory under pressure, valid boundary coverage is retained, test-only production methods are rejected, and the new boundary is consolidated into the existing suite.

- [ ] **Step 7: Commit the TDD maintainability change**

```bash
git add skills/test-driven-development \
  skills/writing-plans/SKILL.md \
  skills/requesting-code-review/code-reviewer.md \
  skills/subagent-driven-development/task-reviewer-prompt.md \
  skills/subagent-driven-development/implementer-prompt.md
git commit -m "fix: keep TDD tests durable and consolidated"
```

---

### Task 5: Replace Prose Assertions With Artifact Contract Tests

**Files:**

- Replace: `tests/skill-content/test-routing-and-html-artifacts.sh` with `tests/skill-content/test-design-artifact-contract.sh`
- Create: `tests/skill-content/run-tests.sh`
- Modify: `docs/testing.md`

**Interfaces:**

- Consumes: `skills/brainstorming/design-template.html`.
- Produces: deterministic proof that the shipped template is standalone and contains the required stable review sections; routing remains covered only by live behavior evals.

- [ ] **Step 1: Remove exact skill-prose assertions**

Do not assert that `SKILL.md` contains slogans, headings, or removed phrases. Those checks would pass even if agents ignore the instructions and would fail harmless rewording.

- [ ] **Step 2: Add deterministic HTML artifact checks**

The test must verify:

```bash
test -f skills/brainstorming/design-template.html
rg -q '<!DOCTYPE html>' skills/brainstorming/design-template.html
rg -q '<meta name="viewport"' skills/brainstorming/design-template.html
rg -q 'id="requirements"' skills/brainstorming/design-template.html
rg -q 'id="decisions"' skills/brainstorming/design-template.html
rg -q 'id="architecture"' skills/brainstorming/design-template.html
rg -q 'id="testing"' skills/brainstorming/design-template.html
rg -q 'id="risks"' skills/brainstorming/design-template.html
! rg -q '<script|https?://|@import' skills/brainstorming/design-template.html
```

The script must resolve `REPO_ROOT` from its own location so it works from any current directory.

- [ ] **Step 3: Add and document the test entry point**

`tests/skill-content/run-tests.sh` runs `bash tests/skill-content/test-design-artifact-contract.sh`. Add `tests/skill-content/` to the plugin-test inventory in `docs/testing.md`, while explicitly stating that skill routing and compliance belong in `evals/`.

- [ ] **Step 4: Run the artifact contract checks**

```bash
bash tests/skill-content/run-tests.sh
```

Expected: exit 0 with each required section and zero external dependencies confirmed.

- [ ] **Step 5: Commit the deterministic checks**

```bash
git add tests/skill-content docs/testing.md
git commit -m "test: validate standalone design artifact contract"
```

---

### Task 6: Complete Cross-Skill Verification and Human Review

**Files:**

- Modify: `evals/docs/experiments/2026-07-14-workflow-spec-test-maintainability.md`
- Review: all files changed by Tasks 2-5

**Interfaces:**

- Consumes: the complete core diff and all before/after Quorum results.
- Produces: a compatibility verdict, explicit residual risks, and a human-approved diff ready for a fork commit or a separately reviewed upstream contribution.

- [ ] **Step 1: Run static and plugin verification**

```bash
git diff --check
bash tests/skill-content/run-tests.sh
bash tests/codex/test-marketplace-manifest.sh
bash tests/codex/test-package-codex-plugin.sh
bash tests/codex-plugin-sync/test-sync-to-codex-plugin.sh
bash tests/kimi/run-tests.sh
bash tests/opencode/run-tests.sh
bash tests/antigravity/run-tests.sh
node --test tests/pi/test-pi-extension.mjs
```

Expected: every command exits 0. Report unavailable harness binaries as explicit unverified gaps rather than treating them as passes.

- [ ] **Step 2: Run eval harness static validation**

```bash
cd evals
bun install
bun run check
bun run quorum check
```

Expected: exit 0. These commands do not launch live agents.

- [ ] **Step 3: Re-run the complete live eval matrix**

Run all scenarios from Tasks 2-4 on Codex. Record run IDs, pass/fail results, token counts, and agent/model versions beside the baseline results. The acceptance gate is:

```text
Routing: trivial task skips brainstorming; design-worthy task invokes it first.
Artifacts: new full design is HTML; implementation plan is Markdown and references it.
Discipline: TDD still triggers before production code under pressure.
Coverage: legitimate boundary tests are retained.
Maintainability: existing suites are extended; duplicate test files and probes do not ship.
```

- [ ] **Step 4: Review compatibility with repository contracts**

Verify all of the following directly against the final diff:

```text
Session-start bootstrap still loads on every supported harness.
The clean-session React todo acceptance prompt still triggers brainstorming.
Selected skills remain mandatory.
Existing Markdown specs remain readable by writing-plans.
New design artifacts require no browser server or third-party dependency.
Plans remain Markdown.
Red-green-refactor and verification gates remain intact.
No unrelated skill voice or architecture was rewritten.
```

- [ ] **Step 5: Search related upstream work before any PR decision**

Search open and closed upstream PRs for routing/over-triggering, HTML specs, and TDD test-quality work. Explicitly inspect the existing positive test-writing experiment associated with commit `0e69a4d32c2db00ebc012310d303907cc5507c6f`; do not submit a duplicate of that work. Record how this change differs: it adds workflow routing, an HTML-spec/Markdown-plan contract, and test-portfolio consolidation driven by a real user session.

- [ ] **Step 6: Show the complete diff and eval report to the human partner**

```bash
git status --short
git diff --stat HEAD
git diff HEAD
```

Do not push or open a PR. Wait for explicit human approval of the complete diff and the intended destination: local fork only, a branch for continued testing, or an upstream `dev` PR.

## Self-Review

- **Problem 1 coverage:** Tasks 1-2 establish paired routing evidence and preserve mandatory selected-skill gates.
- **Problem 2 coverage:** Tasks 1, 3, and 5 establish HTML full-design specs, Markdown plans, legacy Markdown compatibility, and standalone artifact validation.
- **Problem 3 coverage:** Tasks 1 and 4 preserve test-first discipline while adding stable-boundary selection, nearest-suite reuse, consolidation, temporary-test cleanup, and reviewer enforcement.
- **Architecture preservation:** Existing skills, handoff sequence, zero-dependency policy, human approval gates, and Quorum evaluation method remain in place.
- **Scope control:** No harness, runtime dependency, third-party service, or unrelated workflow is added.
- **Ambiguity check:** “Lightweight” changes workflow selection only; it never makes a selected quality gate optional.
