# Adaptive Workflow and Dual-Provider Agent Routing Implementation Plan

**Status:** IMPLEMENTED_AND_VERIFIED on 2026-07-31.

**Current source of truth:** the linked SPEC, installed Codex profiles, Agent
matrix tests, and
`docs/superpowers/validation/adaptive-workflow-dual-provider-routing/README.md`.
The task steps below are retained as implementation history. Superseded
branches describe the investigation and are not current operating
instructions.

> **Historical execution note:** This plan originally used
> superpowers:subagent-driven-development or superpowers:executing-plans and
> checkbox steps. Implementation is complete; do not resume unchecked boxes as
> outstanding work without a new scoped plan.

**Goal:** Deliver a three-level Codex development workflow and a verified GPT/Qwen subagent matrix that supports native cross-provider dispatch when the installed Codex runtime can prove it works.

**Spec:** `docs/superpowers/specs/2026-07-31-adaptive-workflow-dual-provider-routing-design.html`

**Architecture:** Superpowers owns provider-neutral workflow and capability selection. Global Codex configuration activates a GPT engineering group and a Qwen engineering/information group; short role files own concrete model/provider settings, and a standard-library validator protects shared engineering contracts plus Qwen-specific information-role boundaries. Runtime routing is Provider-aware: OpenAI parents use V2 for GPT→GPT, Bailian parents use V1 for Qwen→Qwen and Qwen→GPT with four concurrent children, and GPT→Qwen uses the file-based review handoff until V2 task delivery becomes compatible.

**Tech Stack:** Markdown skills, HTML design artifact, Bash contract tests, Python 3.11+ `tomllib` and `unittest`, Codex TOML profiles, Codex JSONL execution output

## Global Constraints

- Follow spec sections `#workflow`, `#instruction-design`, `#agent-routing`, `#errors`, and `#testing`.
- Preserve the current OpenAI main default `gpt-5.6-sol` with `model_reasoning_effort = "medium"`.
- Superpowers entry Skills stay provider-neutral; the Codex-specific routing reference may name the local GPT/Qwen capability groups, while concrete model IDs remain under `/home/james/.codex`.
- Use positive conditional contracts for routing and output shape; reserve prohibitions for narrow safety or irreversible-action boundaries supported by observed failures.
- Run Skill behavior baselines before editing production Skill text.
- Use only Python standard-library modules for the Agent matrix validator.
- Keep architecture decisions, escalation, user gates, and final synthesis in the parent Agent.
- Route complex engineering implementation and code-detail review to GPT by default; route large-context synthesis, progress/document review, and HTML/Markdown drafting to Qwen by default.
- Treat this model split as a versioned local hypothesis measured by behavior, elapsed time, rework, and review yield rather than a universal model claim.
- Deploy each native route only with readable task/output evidence for its actual Provider and protocol version; retain the file handoff specifically for GPT→Qwen while Bailian V1 serves Qwen→Qwen and Qwen→GPT.
- Do not add nested `codex exec` orchestration.
- Do not sync or rebase the Superpowers fork against upstream v6.2 in this plan.
- Do not modify unrelated dirty files in `/home/james/.codex` or other repositories.

## Requirement Coverage

| Spec requirement | Owning task and evidence |
| --- | --- |
| R1 | Task 5 profile-default assertions and Task 7 final hashes |
| R2 | Tasks 1–2 Case 1, static L1 contract, and Task 7 forward evaluation |
| R3 | Tasks 1–3 Case 2, TDD evidence contract, and Task 7 forward evaluation |
| R4 | Tasks 1–2 Cases 3–5 and the L3/static brainstorming contracts |
| R5 | Tasks 1–2 Case 6 and current-Skill/instruction-priority assertions |
| R6 | Task 3 positive evidence-language contract and Task 7 behavior evaluation |
| R7 | Tasks 1–2 Cases 7–8 plus Tasks 4–5 matrix tests and twelve role files |
| R8 | Tasks 1–2 Agent-fit behavior plus Task 4 shared-contract and information-role boundary tests |
| R9 | Task 6 protocol-isolated evidence: OpenAI V2 GPT→GPT and Bailian V1 Qwen→Qwen / Qwen→GPT |
| R10 | Task 6 GPT→Qwen repository-local file-handoff fallback |
| R11 | Tasks 1 and 7 preserve auditable GPT/Qwen RED-GREEN terminal records |
| R12 | Task 2 parent-ownership wording, Task 5 role scopes, and Task 7 review |

---

## 2026-07-31 Runtime Compatibility Amendment

This amendment supersedes Task 6's original all-or-nothing gate. The first
probe set tested Multi-Agent V2 and correctly rejected its Qwen task channel.
A follow-up protocol-isolation probe found that Bailian Multi-Agent V1 delivers
plain task payloads and readable results.

- Default OpenAI profile: `multi_agent_v2 = true`, five GPT roles, concurrency 4.
- Bailian profile: `multi_agent_v2 = false`, seven Qwen roles plus inherited
  GPT roles, concurrency 4.
- Provider role storage: only `agents/gpt/*.toml` and `agents/qwen/*.toml`;
  base registrations use `gpt_*`, Bailian overlays use `qwen_*`, and no
  duplicate `agents/*.toml` aliases remain.
- Proven native routes: GPT→GPT (V2), Qwen→Qwen (V1), Qwen→GPT (V1).
- Compatibility fallback: GPT→Qwen uses the repository-local review package.
- Deployment evidence: one permanent-profile four-Qwen concurrent smoke and
  one permanent-profile Qwen→GPT smoke, both with persisted parent/child
  rollouts and exact-token results.

The remaining Task 6 text is retained as the historical execution record; this
amendment defines the installed target and final verification criteria.

---

### Task 1: Record the GPT/Qwen RED behavior baseline

**Files:**
- Create: `docs/superpowers/validation/adaptive-workflow-dual-provider-routing/cases.md`
- Create: `docs/superpowers/validation/adaptive-workflow-dual-provider-routing/baseline.md`

**Test strategy:**
- Behavior boundary: Current GPT and Qwen sessions must expose which routing and instruction-following cases fail before production Skill edits.
- Existing suite to extend: none; this is the behavior baseline required by `superpowers:writing-skills`.
- New test file justification: `cases.md` is the reusable prompt/rubric contract; `baseline.md` preserves auditable fresh-session evidence, including bounded timeouts.
- Temporary probes: isolated fresh Codex sessions only; no production file changes.

**Interfaces:**
- Consumes: current installed `using-superpowers`, `brainstorming`, `test-driven-development`, and `verification-before-completion`.
- Produces: eight fixed cases, six shared scoring fields, and sixteen terminal baseline records (eight GPT, eight Qwen). A terminal record is either a complete response or a bounded timeout with emitted events, timestamps, and exit status.

- [ ] **Step 1: Write the evaluation contract**

Create `cases.md` with these exact cases:

```markdown
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
```

- [ ] **Step 2: Run fresh GPT baseline sessions**

Use the default OpenAI profile. Run one fresh session per case and save the prompt, terminal response or bounded-timeout evidence, model/profile, and timestamp under `baseline.md`.

For each case, copy only the prose between its title and `Expected route` into
one fresh invocation:

```bash
ROUTING_CASE_PROMPT='In a trusted local Codex configuration, change the already-existing model_reasoning_effort value from low to medium, then verify the parsed value. No other behavior changes.'
codex exec --ephemeral --json "$ROUTING_CASE_PROMPT"
```

Repeat with the exact prompt prose for Cases 2–8. Expected: eight terminal JSONL
records. Preserve raw final responses or bounded-timeout events in `baseline.md`;
do not summarize away routing, language, elapsed-time, or exit-status evidence.

- [ ] **Step 3: Run fresh Qwen baseline sessions**

Use the same eight prompt strings with:

```bash
codex exec --profile bailian --ephemeral --json "$ROUTING_CASE_PROMPT"
```

Expected: eight terminal JSONL records using the Bailian profile. A complete
response is preferred. When the configured bound is reached, preserve emitted
events, elapsed time, exit status, and the first actionable error; score only
fields supported by that evidence and mark the rest `N/A`. Do not invent a
response or score. A harness-qualified diagnostic may explain routing behavior,
but it is not directly comparable to an exact-prompt run.

- [ ] **Step 4: Score and freeze the RED baseline**

For every output, record pass/fail for all five shared scoring fields with a short exact excerpt. Confirm at least one real failure exists before Task 2.

Run:

```bash
test -s docs/superpowers/validation/adaptive-workflow-dual-provider-routing/cases.md
test -s docs/superpowers/validation/adaptive-workflow-dual-provider-routing/baseline.md
rg -n '^## Case [1-8]|^### GPT output|^### Qwen output|^### Score' \
  docs/superpowers/validation/adaptive-workflow-dual-provider-routing/baseline.md
```

Expected: all files are non-empty and each case contains GPT output, Qwen output, and a score block.

- [ ] **Step 5: Commit the baseline**

```bash
git add docs/superpowers/validation/adaptive-workflow-dual-provider-routing
git commit -m "test: record adaptive workflow routing baseline"
```

---

### Task 2: Implement the three-level Superpowers routing contract

**Files:**
- Create: `tests/skill-content/test-adaptive-workflow-routing-contract.sh`
- Modify: `tests/skill-content/run-tests.sh`
- Modify: `skills/using-superpowers/SKILL.md`
- Modify: `skills/brainstorming/SKILL.md`
- Modify: `skills/using-superpowers/references/codex-tools.md`

**Test strategy:**
- Behavior boundary: L1, L2, and L3 are selected from ambiguity, behavior risk, coordination, and rework cost; Skill reading and instruction priority remain explicit.
- Existing suite to extend: `tests/skill-content/run-tests.sh`.
- New test file justification: the existing Codex routing contract covers subagent capabilities, not workflow-level selection or design escalation.
- Temporary probes: none.

**Interfaces:**
- Consumes: task intent, observable risk, nearest repository instructions, and the available Skill catalog.
- Produces: one workflow level, matched Skill reads, an escalation decision, and the next governed action.

- [ ] **Step 1: Write the failing static contract**

Create `tests/skill-content/test-adaptive-workflow-routing-contract.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROUTER="$REPO_ROOT/skills/using-superpowers/SKILL.md"
BRAINSTORM="$REPO_ROOT/skills/brainstorming/SKILL.md"

assert_literal() {
  local file="$1"
  local needle="$2"
  local label="$3"
  grep -Fq -- "$needle" "$file"
  printf '  [PASS] %s\n' "$label"
}

assert_literal "$ROUTER" 'L1 敏捷修改' 'L1 route'
assert_literal "$ROUTER" 'L2 有界行为开发' 'L2 route'
assert_literal "$ROUTER" 'L3 计划化开发' 'L3 route'
assert_literal "$ROUTER" '歧义、行为风险、跨模块协调和返工成本' 'risk-based escalation'
assert_literal "$ROUTER" '读取当前完整版本' 'fresh skill read'
assert_literal "$ROUTER" '用户直接要求' 'user priority'
assert_literal "$ROUTER" '最近层级' 'nearest repository instructions'
assert_literal "$ROUTER" '说明证据并升级' 'evidence-backed escalation'
assert_literal "$BRAINSTORM" '仅处理 L3' 'brainstorming scope'
assert_literal "$BRAINSTORM" '多文件机械迁移' 'mechanical-plan distinction'
assert_literal "$REPO_ROOT/skills/using-superpowers/references/codex-tools.md" \
  'GPT engineering group' 'GPT engineering default'
assert_literal "$REPO_ROOT/skills/using-superpowers/references/codex-tools.md" \
  'Qwen information group' 'Qwen information default'
assert_literal "$REPO_ROOT/skills/using-superpowers/references/codex-tools.md" \
  'local routing hypothesis' 'versioned empirical routing'

if rg -n '1% chance|没有选择|不能通过.*绕开|rationaliz' "$ROUTER" "$BRAINSTORM"; then
  printf '  [FAIL] router and brainstorming contain generalized coercive language\n'
  exit 1
fi

printf 'All adaptive workflow routing checks passed\n'
```

Append this exact invocation to `tests/skill-content/run-tests.sh`:

```bash
bash "$SCRIPT_DIR/test-adaptive-workflow-routing-contract.sh"
```

- [ ] **Step 2: Run the contract to verify RED**

Run:

```bash
bash tests/skill-content/test-adaptive-workflow-routing-contract.sh
```

Expected: FAIL on the first missing three-level routing literal.

- [ ] **Step 3: Rewrite `using-superpowers` as the compact router**

Keep the Skill compact and provider-neutral. Its body must contain:

```markdown
核心原则：选择能够可靠完成目标的最轻工作流；依据歧义、行为风险、跨模块协调和返工成本升级。

- L1 敏捷修改：目标和验收明确、局部可逆、无公共接口或数据边界变化。检查局部上下文，最小修改，聚焦验证。
- L2 有界行为开发：边界清楚的功能、bug 或重构。bug 先调查根因；行为变化使用回归测试或 TDD；按风险选择 task review。
- L3 计划化开发：未决架构、公共 API/schema/持久化数据/安全姿态、多任务协调或高返工成本。进入设计澄清或 writing-plans，再按任务实施和复核。

会话开始或任务意图变化时完成路由。命中或被用户点名的 Skill 在受管辖行动前读取当前完整版本。用户直接要求和最近层级的 AGENTS.md 高于通用 Skill。调查发现当前级别不足时，说明证据并升级。
```

The description must express session-start/task-intent-change triggering without summarizing all three workflow steps.

- [ ] **Step 4: Narrow `brainstorming` to L3 design decisions**

Preserve project exploration, decomposition, recommended answers, alternatives, design self-review, and user approval. Replace file-count gates with:

```markdown
本 Skill 仅处理 L3 中尚未解决的产品、架构、接口、安全或跨系统决策。

多文件机械迁移若目标、映射和验证都已确定，直接进入 writing-plans；它需要实施分解，不需要重新发明产品设计。

仅当错误假设会改变公共行为、架构边界、迁移策略或交付结果时提出阻塞问题。先从仓库和已有约定消除可查证歧义。
```

- [ ] **Step 5: Run focused and owning contracts**

Before running the contracts, update
`skills/using-superpowers/references/codex-tools.md` with this capability policy:

```markdown
Treat provider specialization as a local routing hypothesis, not a universal
model claim. Prefer the GPT engineering group for complex implementation,
debugging, code-detail review, and final architecture review. Prefer the Qwen
information group for large-context synthesis, progress review, document
review, and approved HTML/Markdown drafting. Ordinary bounded implementation
may use either engineering group. The parent owns unresolved decisions,
dependency ordering, and final synthesis.
```

Run:

```bash
bash tests/skill-content/test-adaptive-workflow-routing-contract.sh
bash tests/skill-content/run-tests.sh
```

Expected: both commands exit 0 and print the adaptive routing pass line.

- [ ] **Step 6: Commit the router**

```bash
git add \
  skills/using-superpowers/SKILL.md \
  skills/using-superpowers/references/codex-tools.md \
  skills/brainstorming/SKILL.md \
  skills/using-superpowers/references/codex-tools.md \
  tests/skill-content/test-adaptive-workflow-routing-contract.sh \
  tests/skill-content/run-tests.sh
git commit -m "refactor: route Codex work by change risk"
```

---

### Task 3: Replace moralized TDD and completion language with evidence contracts

**Files:**
- Create: `tests/skill-content/test-positive-evidence-language.sh`
- Modify: `tests/skill-content/run-tests.sh`
- Modify: `skills/test-driven-development/SKILL.md`
- Modify: `skills/verification-before-completion/SKILL.md`

**Test strategy:**
- Behavior boundary: TDD still requires a witnessed RED before production behavior changes; completion claims still require fresh matching evidence; failed verification reports actual status.
- Existing suite to extend: `tests/skill-content/run-tests.sh`.
- New test file justification: no existing test protects the technical invariants while rejecting the agreed moralized wording.
- Temporary probes: none.

**Interfaces:**
- Consumes: an L2/L3 decision to use TDD and a proposed work-state claim.
- Produces: red-green-refactor evidence for behavior work and claim-to-command evidence for completion.

- [ ] **Step 1: Write the failing language and invariant contract**

Create `tests/skill-content/test-positive-evidence-language.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TDD="$REPO_ROOT/skills/test-driven-development/SKILL.md"
VERIFY="$REPO_ROOT/skills/verification-before-completion/SKILL.md"

for needle in 'RED' 'GREEN' 'REFACTOR' 'expected failure' 'minimal implementation'; do
  grep -Fq -- "$needle" "$TDD"
done

for needle in 'fresh evidence' 'exact command' 'exit code' 'actual status'; do
  grep -Fq -- "$needle" "$VERIFY"
done

if rg -ni 'dishonest|dishonesty|lying|rationalization|you.ll be replaced|no exceptions|non-negotiable' \
  "$TDD" "$VERIFY"; then
  printf '  [FAIL] evidence skills contain moralized or generalized coercive language\n'
  exit 1
fi

printf 'All positive evidence language checks passed\n'
```

Append:

```bash
bash "$SCRIPT_DIR/test-positive-evidence-language.sh"
```

to `tests/skill-content/run-tests.sh`.

- [ ] **Step 2: Run the contract to verify RED**

Run:

```bash
bash tests/skill-content/test-positive-evidence-language.sh
```

Expected: FAIL with matches from the current moralized wording.

- [ ] **Step 3: Refactor the TDD Skill around observable evidence**

Preserve the technical cycle and examples. Replace the opening contract with:

```markdown
## Outcome

For a production behavior change, establish that the test can detect the
missing behavior before implementing it:

1. RED — add one focused behavior test and run it.
2. Confirm the expected failure is caused by the missing behavior.
3. GREEN — write the minimal implementation and run the owning test.
4. REFACTOR — improve structure while the owning suite stays green.

The RED observation is the evidence that the new test distinguishes the old
behavior from the requested behavior. If implementation already exists, use a
temporary revert or an equivalent isolated baseline to establish that evidence.
```

Retain narrow handling for generated code, configuration-only edits, prototypes, and test-infrastructure absence by routing them before this Skill is invoked rather than by weakening the cycle inside it.

- [ ] **Step 4: Refactor completion verification as a claim contract**

Replace moral judgments with:

```markdown
## Claim contract

Before reporting a work-state claim:

1. Name the exact command or observation that can support the claim.
2. Run it fresh and read the complete relevant output and exit code.
3. Compare the result with the claim.
4. If they match, report the claim with evidence.
5. If they do not match, report the actual status, failing check, and next actionable step.

Use the narrowest sufficient verification for the claim. A focused test can
prove the changed behavior; a full build claim requires the full build command.
```

Preserve the claim/evidence mapping table and regression-test red-green example.

- [ ] **Step 5: Run focused and owning contracts**

Run:

```bash
bash tests/skill-content/test-positive-evidence-language.sh
bash tests/skill-content/run-tests.sh
```

Expected: both exit 0; existing verification and routing contracts remain green.

- [ ] **Step 6: Commit the evidence-language refactor**

```bash
git add \
  skills/test-driven-development/SKILL.md \
  skills/verification-before-completion/SKILL.md \
  tests/skill-content/test-positive-evidence-language.sh \
  tests/skill-content/run-tests.sh
git commit -m "refactor: express testing discipline as evidence"
```

---

### Task 4: Build the provider-specific Agent matrix validator

**Files:**
- Create: `/home/james/.codex/tests/test_agent_matrix.py`
- Create: `/home/james/.codex/scripts/validate_agent_matrix.py`

**Test strategy:**
- Behavior boundary: twelve role files parse, implement the approved model matrix, contain required custom-agent fields, preserve shared engineering contracts, and enforce bounded Qwen information-role outputs.
- Existing suite to extend: none under `/home/james/.codex`.
- New test file justification: global Codex configuration is not part of the Superpowers repository and needs a directly runnable local contract.
- Temporary probes: `/tmp/codex-agent-matrix-test-*`, removed by `TemporaryDirectory`.

**Interfaces:**
- Consumes: `/home/james/.codex/config.toml`, `bailian.config.toml`, and `agents/{gpt,qwen}/*.toml`.
- Produces: a zero exit status plus one summary line, or a list of exact role/field mismatches.

- [ ] **Step 1: Write the failing unit test**

Create a `unittest` suite that imports `validate_agent_matrix.py` and asserts this exact matrix:

```python
EXPECTED = {
    "gpt_routine_worker": ("openai", "gpt-5.6-luna", "medium", "workspace-write"),
    "gpt_standard_worker": ("openai", "gpt-5.6-sol", "medium", "workspace-write"),
    "gpt_task_reviewer": ("openai", "gpt-5.6-terra", "medium", "read-only"),
    "gpt_final_reviewer": ("openai", "gpt-5.6-sol", "medium", "read-only"),
    "gpt_monitor": ("openai", "gpt-5.6-luna", "medium", "read-only"),
    "qwen_routine_worker": ("bailian", "qwen3.8-max-preview", "medium", "workspace-write"),
    "qwen_standard_worker": ("bailian", "qwen3.8-max-preview", "xhigh", "workspace-write"),
    "qwen_context_analyst": ("bailian", "qwen3.8-max-preview", "xhigh", "read-only"),
    "qwen_progress_reviewer": ("bailian", "qwen3.8-max-preview", "medium", "read-only"),
    "qwen_document_reviewer": ("bailian", "qwen3.8-max-preview", "medium", "read-only"),
    "qwen_document_writer": ("bailian", "qwen3.8-max-preview", "xhigh", "workspace-write"),
    "qwen_monitor": ("bailian", "qwen3.8-max-preview", "medium", "read-only"),
}
```

Required test methods:

```python
def test_expected_role_matrix(self): ...
def test_required_custom_agent_fields(self): ...
def test_shared_engineering_roles_keep_core_contracts(self): ...
def test_qwen_information_roles_have_bounded_contracts(self): ...
def test_base_config_registers_all_roles(self): ...
def test_main_profiles_select_expected_defaults(self): ...
def test_qwen_roles_load_local_catalog(self): ...
```

Shared-contract checks cover routine, standard, and monitor goals without requiring
word-for-word prompts. Information-role checks require:

```python
QWEN_INFORMATION_CONTRACTS = {
    "qwen_context_analyst": ("read-only", ("large context", "sources", "uncertainty")),
    "qwen_progress_reviewer": ("read-only", ("plan", "status", "evidence", "gaps")),
    "qwen_document_reviewer": ("read-only", ("structure", "readability", "evidence")),
    "qwen_document_writer": ("workspace-write", ("approved decisions", "HTML", "Markdown")),
}
```

Normalize case and whitespace before keyword checks. The document writer must
state that architecture and product decisions remain with the parent.

- [ ] **Step 2: Run the test to verify RED**

Run:

```bash
python -m unittest -v /home/james/.codex/tests/test_agent_matrix.py
```

Expected: FAIL because the provider-specific directories and validator do not exist.

- [ ] **Step 3: Implement the standard-library validator**

Implement these functions in `scripts/validate_agent_matrix.py`:

```python
def load_toml(path: Path) -> dict:
    with path.open("rb") as handle:
        return tomllib.load(handle)

def load_roles(codex_home: Path) -> dict[str, dict]:
    role_files = sorted((codex_home / "agents" / "gpt").glob("*.toml"))
    role_files += sorted((codex_home / "agents" / "qwen").glob("*.toml"))
    return {load_toml(path)["name"]: load_toml(path) for path in role_files}

def semantic_contract(role: dict) -> tuple[str, str, str]:
    instructions = " ".join(role["developer_instructions"].split())
    return role["description"], instructions, role["sandbox_mode"]

def validate(codex_home: Path) -> list[str]:
    """Return exact validation errors; an empty list means valid."""
```

The CLI entry point accepts `--codex-home`, defaults to `/home/james/.codex`, prints every error to stderr, and prints:

```text
Agent matrix valid: 12 roles, 3 shared contracts, 4 information roles
```

on success.

- [ ] **Step 4: Run unit tests at the expected intermediate state**

Run:

```bash
python -m unittest -v /home/james/.codex/tests/test_agent_matrix.py
```

Expected: validator import tests pass, matrix tests still fail because Task 5 has not created the role files. Preserve this expected intermediate state in the task report; Task 5 owns GREEN.

---

### Task 5: Install the twelve-role GPT/Qwen capability portfolio

**Files:**
- Create: `/home/james/.codex/agents/gpt/routine-worker.toml`
- Create: `/home/james/.codex/agents/gpt/standard-worker.toml`
- Create: `/home/james/.codex/agents/gpt/task-reviewer.toml`
- Create: `/home/james/.codex/agents/gpt/final-reviewer.toml`
- Create: `/home/james/.codex/agents/gpt/monitor.toml`
- Create: `/home/james/.codex/agents/qwen/routine-worker.toml`
- Create: `/home/james/.codex/agents/qwen/standard-worker.toml`
- Create: `/home/james/.codex/agents/qwen/context-analyst.toml`
- Create: `/home/james/.codex/agents/qwen/progress-reviewer.toml`
- Create: `/home/james/.codex/agents/qwen/document-reviewer.toml`
- Create: `/home/james/.codex/agents/qwen/document-writer.toml`
- Create: `/home/james/.codex/agents/qwen/monitor.toml`
- Modify: `/home/james/.codex/config.toml`
- Verify: `/home/james/.codex/bailian.config.toml`

**Test strategy:**
- Behavior boundary: both profiles discover twelve stable provider-specific roles, while the main-process defaults remain OpenAI medium and Bailian xhigh respectively.
- Existing suite to extend: `/home/james/.codex/tests/test_agent_matrix.py`.
- New test file justification: none; extend the Task 4 suite.
- Temporary probes: `/tmp/codex-agent-config-*` isolated homes for parse/discovery checks.

**Interfaces:**
- Consumes: the five current semantic role prompts in `/home/james/.codex/agents/*.toml` and GPT model assignments in `/home/james/.codex/backups/agents-20260728/*.toml`.
- Produces: five GPT engineering roles and seven Qwen engineering/information roles, all registered in base `config.toml`.

- [ ] **Step 1: Create a recoverable configuration snapshot**

Run:

```bash
tar -czf /home/james/.codex/backups/pre-dual-provider-routing-20260731.tar.gz \
  -C /home/james/.codex \
  config.toml bailian.config.toml agents
tar -tzf /home/james/.codex/backups/pre-dual-provider-routing-20260731.tar.gz
```

Expected: archive listing contains both profile files and all five current Agent TOMLs.

- [ ] **Step 2: Create the GPT role files**

Use the current role's `developer_instructions` and semantic description for
each matching role. For example, `agents/gpt/routine-worker.toml` starts with
these exact fields before the existing routine-worker instructions:

```toml
name = "gpt_routine_worker"
description = "Implements routine, bounded coding tasks with objective verification."
model_provider = "openai"
model = "gpt-5.6-luna"
model_reasoning_effort = "medium"
sandbox_mode = "workspace-write"
developer_instructions = """
You are a bounded implementation agent for routine, well-specified work.

Follow the task contract exactly and stay inside its write scope. Preserve
existing architecture and public behavior unless explicitly directed. Edit
files directly, run the requested verification, and report changed files,
exact results, unresolved risks, and any ambiguity that blocks safe work.

Escalate architectural ambiguity instead of redesigning the plan.
"""
```

For each remaining GPT file, copy the complete description and
`developer_instructions` from the named semantic source below and apply the
exact provider/model/effort/sandbox tuple from Task 4 `EXPECTED`:

```text
routine-worker.toml  → gpt_routine_worker
standard-worker.toml → gpt_standard_worker
task-reviewer.toml   → gpt_task_reviewer
final-reviewer.toml  → gpt_final_reviewer
monitor.toml         → gpt_monitor, with model changed to Luna and effort changed to medium
```

- [ ] **Step 3: Create the Qwen role files**

For `qwen_routine_worker` and `qwen_standard_worker`, retain the corresponding
current engineering contract. Create the four information roles with these
exact outcomes:

```text
qwen_context_analyst
  Read large code/document/history inputs; return source-linked facts,
  decisions, contradictions, uncertainty, and a compact handoff. Read-only.

qwen_progress_reviewer
  Compare the approved spec, implementation plan, status, diffs, and
  verification evidence; return completed items, unsupported claims, gaps,
  blockers, and the next checkpoint. Read-only.

qwen_document_reviewer
  Review HTML/Markdown documents for structure, decision fidelity,
  readability, internal consistency, evidence boundaries, and missing
  sections. Return findings; do not edit. Read-only.

qwen_document_writer
  Draft or revise HTML specs, Markdown plans, and delivery documents from
  approved decisions and cited sources. Preserve unresolved decisions for the
  parent and do not invent architecture or evidence. Workspace-write.

qwen_monitor
  Wait efficiently on long-running external work; inspect only the log slices
  needed to determine state, then return phase, progress, evidence, blocker,
  elapsed time, and next checkpoint. Read-only.
```

Each Qwen file contains:

```toml
model_provider = "bailian"
model = "qwen3.8-max-preview"
model_catalog_json = "/home/james/.codex/model-catalog.local.json"
```

Use the Qwen effort and sandbox assignments from Task 4 `EXPECTED`.

- [ ] **Step 4: Register all twelve roles in base config**

Replace the five generic `[agents.<role>]` registrations with:

```toml
[agents.gpt_routine_worker]
description = "GPT routine implementation worker for bounded, well-specified work."
config_file = "agents/gpt/routine-worker.toml"

[agents.gpt_standard_worker]
description = "GPT integration and debugging worker for bounded multi-file work."
config_file = "agents/gpt/standard-worker.toml"

[agents.gpt_task_reviewer]
description = "GPT task-scoped read-only requirement and code-quality reviewer."
config_file = "agents/gpt/task-reviewer.toml"

[agents.gpt_final_reviewer]
description = "GPT broad read-only reviewer for cross-task, architectural, and high-risk changes."
config_file = "agents/gpt/final-reviewer.toml"

[agents.gpt_monitor]
description = "GPT Luna monitor for concise external-job status extraction."
config_file = "agents/gpt/monitor.toml"

[agents.qwen_routine_worker]
description = "Qwen routine implementation worker for bounded, well-specified work."
config_file = "agents/qwen/routine-worker.toml"

[agents.qwen_standard_worker]
description = "Qwen integration and debugging worker for bounded multi-file work."
config_file = "agents/qwen/standard-worker.toml"

[agents.qwen_context_analyst]
description = "Qwen read-only analyst for large code, document, and history contexts."
config_file = "agents/qwen/context-analyst.toml"

[agents.qwen_progress_reviewer]
description = "Qwen read-only reviewer for plan progress, evidence, gaps, and checkpoints."
config_file = "agents/qwen/progress-reviewer.toml"

[agents.qwen_document_reviewer]
description = "Qwen read-only reviewer for HTML and Markdown document quality."
config_file = "agents/qwen/document-reviewer.toml"

[agents.qwen_document_writer]
description = "Qwen writer for approved HTML specs, Markdown plans, and delivery documents."
config_file = "agents/qwen/document-writer.toml"

[agents.qwen_monitor]
description = "Qwen monitor for long logs and multi-stage progress compression."
config_file = "agents/qwen/monitor.toml"
```

Preserve existing concurrency and runtime settings. Keep the Bailian provider definition in base `config.toml`.

- [ ] **Step 5: Verify main-profile defaults**

Confirm base config contains:

```toml
model = "gpt-5.6-sol"
model_provider = "openai"
model_reasoning_effort = "medium"
```

Confirm `bailian.config.toml` contains:

```toml
model = "qwen3.8-max-preview"
model_provider = "bailian"
model_reasoning_effort = "xhigh"
model_catalog_json = "~/.codex/model-catalog.local.json"
```

- [ ] **Step 6: Run the matrix GREEN**

Run:

```bash
python -m unittest -v /home/james/.codex/tests/test_agent_matrix.py
python /home/james/.codex/scripts/validate_agent_matrix.py
```

Expected: all seven unit tests pass and the validator prints `Agent matrix valid: 12 roles, 3 shared contracts, 4 information roles`.

---

### Task 6: Prove native cross-provider dispatch or activate the fallback

> **Superseded execution branch:** Steps 1–6B below preserve the original V2
> investigation and are no longer the installed target. Do not execute the
> all-or-nothing Step 6A/6B decision. The
> [2026-07-31 Runtime Compatibility Amendment](#2026-07-31-runtime-compatibility-amendment)
> controls deployment: OpenAI V2 serves GPT→GPT; Bailian V1 serves Qwen→Qwen
> and Qwen→GPT with concurrency 4; only GPT→Qwen uses the file handoff.

**Files:**
- Create: `docs/superpowers/validation/adaptive-workflow-dual-provider-routing/runtime-smoke.md`
- Conditional modify on fallback: `/home/james/.codex/config.toml`
- Conditional modify on fallback: `/home/james/.codex/bailian.config.toml`
- Conditional modify on fallback: `/home/james/.codex/tests/test_agent_matrix.py`
- Conditional modify on fallback: `/home/james/.codex/scripts/validate_agent_matrix.py`

**Test strategy:**
- Behavior boundary: GPT same-provider dispatch remains usable; Qwen same-provider and both cross-provider directions must deliver readable tasks/results, not only select the requested backend. If any Qwen child channel fails, Bailian becomes a main-session-only profile and must expose no Agent tool.
- Existing suite to extend: none; this is a live Codex runtime boundary.
- New test file justification: `runtime-smoke.md` is the durable decision record for enabling or rejecting native cross-provider routing.
- Temporary probes: `/tmp/codex-gpt-main-smoke.jsonl` and `/tmp/codex-qwen-main-smoke.jsonl`.

**Interfaces:**
- Consumes: twelve registered roles and both main profiles.
- Produces: `native-cross-provider` or `provider-per-session-main-only` rollout decision with four corrected child probes plus a Bailian main-only probe.

- [ ] **Step 1: Verify same-provider GPT dispatch**

Run a fresh default-profile session with this prompt:

```text
Use the gpt_monitor custom agent for one read-only task. Have it return only
ROLE_PROBE_OK and its configured role name. Wait for it and report the child
thread evidence without doing other work.
```

Command:

```bash
codex exec --ephemeral --json \
  "Use the gpt_monitor custom agent for one read-only task. Have it return only ROLE_PROBE_OK and its configured role name. Wait for it and report the child thread evidence without doing other work." \
  | tee /tmp/codex-gpt-main-smoke.jsonl
```

Expected: exit 0, `ROLE_PROBE_OK`, role `gpt_monitor`, and runtime event/session evidence identifying the OpenAI model.

- [ ] **Step 2: Verify same-provider Qwen dispatch**

Run:

```bash
codex exec --profile bailian --ephemeral --json \
  "Use the qwen_monitor custom agent for one read-only task. Have it return only ROLE_PROBE_OK and its configured role name. Wait for it and report the child thread evidence without doing other work." \
  | tee /tmp/codex-qwen-main-smoke.jsonl
```

Expected: exit 0, `ROLE_PROBE_OK`, role `qwen_monitor`, and runtime evidence identifying Bailian/Qwen.

- [ ] **Step 3: Verify GPT main → Qwen child**

Run:

```bash
codex exec --ephemeral --json \
  "Use the qwen_monitor custom agent for one read-only task. Have it return only CROSS_PROVIDER_OK and its configured role name. Wait for it and report the child thread evidence without doing other work." \
  | tee /tmp/codex-gpt-to-qwen-smoke.jsonl
```

Expected: exit 0, `CROSS_PROVIDER_OK`, role `qwen_monitor`, and runtime evidence identifying `bailian` plus `qwen3.8-max-preview`.

- [ ] **Step 4: Verify Qwen main → GPT child**

Run:

```bash
codex exec --profile bailian --ephemeral --json \
  "Use the gpt_monitor custom agent for one read-only task. Have it return only CROSS_PROVIDER_OK and its configured role name. Wait for it and report the child thread evidence without doing other work." \
  | tee /tmp/codex-qwen-to-gpt-smoke.jsonl
```

Expected: exit 0, `CROSS_PROVIDER_OK`, role `gpt_monitor`, and runtime evidence identifying `openai` plus `gpt-5.6-luna`.

- [ ] **Step 5: Inspect evidence independently**

Use a short Python JSONL reader to list event types and every field whose key contains `model`, `provider`, `agent`, `role`, or `thread`. Do not accept only the child Agent's textual self-identification as Provider proof.

Expected: both cross-provider probes contain runtime evidence for the configured child backend. Record exact evidence and commands in `runtime-smoke.md`.

- [ ] **Step 6A (historical, superseded): Select native cross-provider mode when all probes pass**

Record:

```markdown
## Decision

Mode: native-cross-provider

All four probes passed. Both main profiles may select any of the twelve
registered roles. Complex engineering and code-detail review prefer the GPT
engineering group. Large-context synthesis, progress/document review, and
HTML/Markdown drafting prefer the Qwen information group. Ordinary
implementation may use either engineering group.
```

- [ ] **Step 6B (historical, superseded): Select provider-per-session-main-only when a Qwen child channel fails**

Execute this branch when Step 2, Step 3, or Step 4 cannot prove readable native
task delivery and readable child output, even if the requested child backend is
selected correctly.

Update base `config.toml` to register five generic semantic slots backed by GPT:
`routine_worker`, `standard_worker`, `task_reviewer`, `final_reviewer`, and
`monitor`. Remove every Agent overlay from `bailian.config.toml`, keep its Qwen
main model, `xhigh` effort, and local catalog, and set both
`features.multi_agent=false` and
`features.multi_agent_v2.enabled=false`. Keep all twelve provider-specific
role TOMLs installed and validated as inactive capability templates and future
retry evidence.

Record:

```markdown
## Decision

Mode: provider-per-session-main-only

At least one native Qwen delegation channel failed. The default profile exposes
five GPT engineering/review roles. The Bailian profile is an independent Qwen
main session with both multi-agent feature gates disabled and no active Agent
overrides. Qwen work consumes a file-based review package opened in that
session. Nested `codex exec` orchestration is not enabled. All twelve role TOMLs
remain inactive templates for a future runtime retry.
```

Re-run:

```bash
python -m unittest -v /home/james/.codex/tests/test_agent_matrix.py
python /home/james/.codex/scripts/validate_agent_matrix.py
```

Adjust the validator's expected active-registration mode to the recorded
fallback while preserving all twelve role-file checks. Add a fresh Bailian
smoke whose persisted rollout proves `model_provider=bailian`, the configured
Qwen model/effort, `multi_agent_version=disabled`, and no collaboration tool
call. The corrected GPT same-provider probe may be reused.

- [ ] **Step 7: Commit only the corrected runtime decision record**

```bash
git add docs/superpowers/validation/adaptive-workflow-dual-provider-routing/runtime-smoke.md
git commit -m "fix: disable unsupported Bailian subagents"
```

Keep this plan and the HTML spec untracked for Task 7.

---

### Task 7: Run GREEN behavior evaluation and close the rollout

**Files:**
- Create: `docs/superpowers/validation/adaptive-workflow-dual-provider-routing/after.md`
- Modify if a real failure is observed: the smallest owning Skill or Agent configuration from Tasks 2–6

**Test strategy:**
- Behavior boundary: GPT and Qwen both apply the three-level route, current-Skill read contract, evidence language, proportional artifacts, and stage-aware Agent fit to the eight frozen cases.
- Existing suite to extend: Task 1 `cases.md` and baseline.
- New test file justification: `after.md` records forward behavior and baseline comparison.
- Temporary probes: fresh isolated sessions only.

**Interfaces:**
- Consumes: frozen cases, completed Skill edits, active Agent routing mode, and runtime smoke decision.
- Produces: sixteen terminal forward records, per-field scores, baseline comparison, requirement trace, and final hashes. Bounded timeout records remain valid empirical outcomes and are never rewritten as completed responses.

- [ ] **Step 1: Re-run all eight cases with GPT**

Use one fresh default-profile session per case. Save prompts and terminal outputs or bounded-timeout evidence in `after.md`.

Expected: each case selects the expected route and satisfies all five shared scoring fields.

- [ ] **Step 2: Re-run all eight cases with Qwen**

Use one fresh Bailian-profile session per case.

Expected: each case selects the expected route and satisfies all five shared scoring fields.

- [ ] **Step 3: Fix only observed failures**

If a case fails, classify it before editing:

```text
Skipped a known rule under pressure → narrow discipline wording based on the observed excuse.
Wrong output shape → positive ordered recipe.
Missing required field → structural slot.
Wrong conditional route → observable if-condition.
```

Run at least five fresh-context wording micro-tests with a no-guidance control before changing behavior-shaping text. Re-run the failed full case after the smallest change and preserve every iteration in `after.md`.

- [ ] **Step 4: Run all static and local configuration tests**

Run:

```bash
bash tests/skill-content/test-adaptive-workflow-routing-contract.sh
bash tests/skill-content/test-positive-evidence-language.sh
bash tests/skill-content/test-codex-subagent-routing-contract.sh
bash tests/skill-content/run-tests.sh
python -m unittest -v /home/james/.codex/tests/test_agent_matrix.py
python /home/james/.codex/scripts/validate_agent_matrix.py
```

Expected: every command exits 0.

- [ ] **Step 5: Add requirement trace and final file evidence**

Append a table mapping spec R1–R12 to exact files, tests, and runtime evidence. Record SHA-256 values for:

```text
skills/using-superpowers/SKILL.md
skills/brainstorming/SKILL.md
skills/test-driven-development/SKILL.md
skills/verification-before-completion/SKILL.md
/home/james/.codex/config.toml
/home/james/.codex/bailian.config.toml
/home/james/.codex/scripts/validate_agent_matrix.py
/home/james/.codex/agents/gpt/*.toml
/home/james/.codex/agents/qwen/*.toml
```

- [ ] **Step 6: Review exact diffs and configuration state**

Run:

```bash
git diff --check
git status --short
git diff -- \
  skills/using-superpowers/SKILL.md \
  skills/using-superpowers/references/codex-tools.md \
  skills/brainstorming/SKILL.md \
  skills/test-driven-development/SKILL.md \
  skills/verification-before-completion/SKILL.md \
  tests/skill-content \
  docs/superpowers/validation/adaptive-workflow-dual-provider-routing
```

Compare `/home/james/.codex/config.toml` and `agents/` with the Task 5 archive listing and record only intended differences. Do not alter unrelated files.

- [ ] **Step 7: Commit the verified Superpowers result**

```bash
git add \
  skills/using-superpowers/SKILL.md \
  skills/brainstorming/SKILL.md \
  skills/test-driven-development/SKILL.md \
  skills/verification-before-completion/SKILL.md \
  tests/skill-content \
  docs/superpowers/validation/adaptive-workflow-dual-provider-routing
git commit -m "feat: add adaptive Codex workflow routing"
```

- [ ] **Step 8: Stop for final user review**

Provide:

```text
1. The complete Superpowers diff.
2. The exact global Codex configuration diff against the recovery archive.
3. GPT and Qwen behavior scores.
4. The native-cross-provider or provider-per-session-main-only runtime decision.
5. Every verification command and result.
6. Residual risk and the separate upstream-v6.2 compatibility follow-up.
```

Do not push, open a PR, or start the upstream v6.2 migration without separate user approval.
