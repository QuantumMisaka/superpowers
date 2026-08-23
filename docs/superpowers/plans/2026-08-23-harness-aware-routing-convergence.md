# Harness-Aware Routing Convergence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 L3 执行链（SDD / dispatching-parallel-agents）与 requesting-code-review 里残留的硬编码 `codex-tools.md` 指针收敛为 harness 感知形式，并折叠两个执行相摩擦点（worktree 建与否从"提问"改"裁决"、SDD"永不并行实现者"的精确不变式），让同一套 skill 在 Codex 与 Kimi Code 上都能自洽落地。

**Spec:** none - requirements supplied directly（调查证据 + 用户拍板：`docs/superpowers/fork-design-philosophy.md` §2/§3 + `using-superpowers/SKILL.md:45` 已有 harness 感知规则；`references/kimi-code-tools.md` 已存在）

**Architecture:** harness 差异下沉到 `references/*-tools.md`（Codex / Kimi Code / Antigravity / pi / gemini），skill 正文只讲动作、不写死 transport。本次不改任何 reference 文件，只让 leaf skill 正文遵守 `using-superpowers:45` 已确立的"读当前 harness 的 `*-tools.md`"规则，并让契约测试锁住新形态、防回归。

**Tech Stack:** Markdown skill 文本 + bash 契约测试（`grep -Fq` / `rg` 断言）。

## Global Constraints

- **不新增 reference 文件，不改 `references/*-tools.md` 任何内容**（kimi-code-tools.md 已覆盖 Agent/subagent_type/resume/AgentSwarm/无 model 字段）。
- **正向优先**（fork 哲学 §4）：禁止性措辞只用于真实安全边界；本次两处摩擦点用"正向裁决 + 窄禁止"表达，不用道德化泛化词（`test-positive-evidence-language.sh` 的 BANNED_PATTERN）。
- **零和体积**（fork 维护纪律）：改动是收敛不是扩张——删硬编码指针、加一条 harness 感知句，净 token 不增（SDD 净负、dispatching 净负、其余持平）。
- **不碰** `writing-skills/SKILL.md`（已双兼容）、`using-superpowers/SKILL.md`（已在 60 行/6144 字节门禁内，不加内容）、`requesting-code-review/code-reviewer.md`、三个 `*-prompt.md`。
- **保留契约测试已锁的既有行为**：SDD 必须仍含 `most capable available model` / `fast, cheap model` / `standard model` / `capability-aware`；kimi-code-tools.md 的 `Never dispatch implementation subagents in parallel` 不动。
- 所有改动落在 fork 内，commit 到 fork；**push 前须本人发话**。

---

### Task 1: 契约测试改断言（先改测试，锁定新形态）

**Files:**
- Modify: `tests/skill-content/test-codex-subagent-routing-contract.sh:98-106`

**Test strategy:**
- Behavior boundary: leaf skill 不再硬编码 `codex-tools.md`，改为引用 harness 感知的 `references/*-tools.md`；并显式禁止回退到 Codex 专属指针。
- Existing suite to extend: `tests/skill-content/test-codex-subagent-routing-contract.sh`
- New test file justification: none（改既有契约）
- Temporary probes: none

**Interfaces:**
- Consumes: 三个 leaf skill（Task 2/3/4）的正文将包含字面量 `references/*-tools.md`
- Produces: 契约测试新断言 `references/*-tools.md` 存在 + `codex-tools.md` 不存在于三个 leaf skill

- [ ] **Step 1: 改断言 loop + 加防回归负断言**

将 `tests/skill-content/test-codex-subagent-routing-contract.sh` 第 98–106 行：

```bash
for skill in \
  subagent-driven-development \
  dispatching-parallel-agents \
  requesting-code-review; do
  assert_literal \
    "$REPO_ROOT/skills/$skill/SKILL.md" \
    'using-superpowers/references/codex-tools.md' \
    "$skill uses shared Codex routing"
done
```

改为：

```bash
for skill in \
  subagent-driven-development \
  dispatching-parallel-agents \
  requesting-code-review; do
  assert_literal \
    "$REPO_ROOT/skills/$skill/SKILL.md" \
    'references/*-tools.md' \
    "$skill uses the harness-aware routing reference"
done

if grep -Rq -- 'codex-tools\.md' \
  "$REPO_ROOT/skills/subagent-driven-development/SKILL.md" \
  "$REPO_ROOT/skills/dispatching-parallel-agents/SKILL.md" \
  "$REPO_ROOT/skills/requesting-code-review/SKILL.md"; then
  printf '  [FAIL] leaf skills must not hardcode the Codex routing reference\n'
  exit 1
fi
printf '  [PASS] leaf skills use the harness-aware form, not Codex-specific\n'
```

- [ ] **Step 2: 跑该契约测试，确认现在 FAIL（三个 leaf 还没改）**

Run: `bash tests/skill-content/test-codex-subagent-routing-contract.sh`
Expected: FAIL——三个 leaf skill 缺 `references/*-tools.md`（证明测试真的在锁新形态）

- [ ] **Step 3: 提交（本任务独立成 commit，与后续 skill 正文改动分离）**

```bash
git add tests/skill-content/test-codex-subagent-routing-contract.sh
git commit -m "test: leaf skills assert harness-aware routing reference, reject codex hardcode"
```

---

### Task 2: SDD 正文收敛（指针 + 两个摩擦点）

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md:189`
- Modify: `skills/subagent-driven-development/SKILL.md:211`
- Modify: `skills/subagent-driven-development/SKILL.md:127-130`
- Modify: `skills/subagent-driven-development/SKILL.md:289`

**Test strategy:**
- Behavior boundary: SDD 的模型路由指针、worktree 建与否、并行实现者红线，全部改为 harness 感知 / 执行相裁决。
- Existing suite to extend: `tests/skill-content/test-codex-subagent-routing-contract.sh`（Task 1 已改）
- New test file justification: none
- Temporary probes: none

**Interfaces:**
- Consumes: `references/*-tools.md`（已存在）、`references/kimi-code-tools.md`（已存在）
- Produces: SDD 正文含 `references/*-tools.md`；不含 `codex-tools.md`

- [ ] **Step 1: 改 189 行（模型路由指针）**

把：

```
On this fork, resolve abstract roles to concrete model/effort routing via `using-superpowers/references/codex-tools.md` (capability-aware, multi-provider: deepseek/qwen/GPT); routing must not change the serial implement-review-fix lifecycle.
```

改为：

```
On this fork, resolve abstract roles to concrete model/effort routing via your harness's routing reference (`references/*-tools.md`; Codex routes capability-aware across deepseek/qwen/GPT, Kimi Code exposes no model field so routing is omitted); routing must not change the serial implement-review-fix lifecycle.
```

- [ ] **Step 2: 改 211 行（schema 感知指针）**

把：

```
`using-superpowers/references/codex-tools.md` for schema-aware routing).
```

改为：

```
`references/*-tools.md` for schema-aware routing).
```

- [ ] **Step 3: 改 Setup 段 127–130 行（worktree 是裁决不是提问）**

把：

```
Ensure the work happens in an isolated workspace: use
superpowers:using-git-worktrees to create one or verify the existing one.
Never start implementation on a main/master branch without your human
partner's explicit consent.
```

改为：

```
Ensure the work happens in an isolated workspace: use
superpowers:using-git-worktrees to create one or verify the existing one.
In plan-execution mode, isolation is a ruling, not a question — plan or goal
approval already granted it, so do not stop to ask for worktree consent.
Never start implementation on a main/master branch without your human
partner's explicit consent.
```

- [ ] **Step 4: 改 289 行（并行红线的精确不变式 + 路由裁决）**

把：

```
- Never dispatch multiple implementation subagents in parallel (conflicts).
```

改为：

```
- Never dispatch implementation subagents in parallel. The implement-review-fix
  lifecycle is serial: the task review's diff range (`BASE..HEAD`) assumes one
  implementer's linear commits, and parallel implementers editing shared files
  interleave those commits. Read-only investigation and disjoint-file work are
  the parallel pattern's job (dispatching-parallel-agents), not this skill's.
```

- [ ] **Step 5: 跑契约测试，确认 SDD 相关断言转绿**

Run: `bash tests/skill-content/test-codex-subagent-routing-contract.sh`
Expected: PASS——SDD 含 `references/*-tools.md`、不含 `codex-tools.md`、仍含 `most capable available model` / `fast, cheap model` / `standard model` / `capability-aware`

- [ ] **Step 6: 提交**

```bash
git add skills/subagent-driven-development/SKILL.md
git commit -m "fix(sdd): harness-aware routing pointer + worktree ruling + serial-implementer invariant"
```

---

### Task 3: dispatching-parallel-agents 收敛（harness 感知 + 调查/实现边界）

**Files:**
- Modify: `skills/dispatching-parallel-agents/SKILL.md:76-79`
- Modify: `skills/dispatching-parallel-agents/SKILL.md`（"When NOT to Use" 列表，约 145–149 行处追加一条）

**Test strategy:**
- Behavior boundary: 并行派发走 harness 并行模式（Codex `independent-parallel` / Kimi `AgentSwarm`）；明确"实现带评审门 → SDD 串行，不并行"。
- Existing suite to extend: `tests/skill-content/test-codex-subagent-routing-contract.sh`
- New test file justification: none
- Temporary probes: none

**Interfaces:**
- Consumes: `references/*-tools.md`
- Produces: dispatching 正文含 `references/*-tools.md`；不含 `codex-tools.md`

- [ ] **Step 1: 改 76–79 行（并行模式 harness 感知）**

把：

```
On Codex, this is `independent-parallel` mode. Apply the capability-aware
routing and fallback rules in
[codex-tools.md](../using-superpowers/references/codex-tools.md), classifying
each domain independently as routine or standard.
```

改为：

```
Dispatch through your harness's parallel mode — Codex `independent-parallel`,
Kimi Code `AgentSwarm`. Apply the capability-aware routing and fallback rules
in your harness's routing reference (`references/*-tools.md`), classifying each
domain independently as routine or standard.
```

- [ ] **Step 2: "When NOT to Use" 追加调查/实现边界条**

在 `## When NOT to Use` 列表末尾（`**Decision-phase artifacts (fork-added):**` 条目之后）追加：

```
**Implementation with a review gate (fork-added):** tasks that write code,
commit, and require per-task spec/quality review go through
subagent-driven-development's serial implement-review-fix loop — not parallel
dispatch. Parallel is for read-only investigation or disjoint-file work with
no per-task review surface.
```

- [ ] **Step 3: 跑契约测试**

Run: `bash tests/skill-content/test-codex-subagent-routing-contract.sh`
Expected: PASS——dispatching 含 `references/*-tools.md`、不含 `codex-tools.md`

- [ ] **Step 4: 提交**

```bash
git add skills/dispatching-parallel-agents/SKILL.md
git commit -m "fix(parallel): harness-aware dispatch mode + investigation-vs-implementation boundary"
```

---

### Task 4: requesting-code-review 一行收敛

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md:34-35`

**Test strategy:**
- Behavior boundary: 评审角色解析走 harness 感知指针。
- Existing suite to extend: `tests/skill-content/test-codex-subagent-routing-contract.sh`
- New test file justification: none
- Temporary probes: none

**Interfaces:**
- Consumes: `references/*-tools.md`
- Produces: requesting-code-review 正文含 `references/*-tools.md`；不含 `codex-tools.md`

- [ ] **Step 1: 改 34–35 行**

把：

```
Resolve the reviewer with the capability-aware Codex rules in
[codex-tools.md](../using-superpowers/references/codex-tools.md), then fill
```

改为：

```
Resolve the reviewer with the capability-aware rules in your harness's routing
reference (`references/*-tools.md`), then fill
```

- [ ] **Step 2: 跑契约测试**

Run: `bash tests/skill-content/test-codex-subagent-routing-contract.sh`
Expected: PASS——requesting-code-review 含 `references/*-tools.md`、不含 `codex-tools.md`

- [ ] **Step 3: 提交**

```bash
git add skills/requesting-code-review/SKILL.md
git commit -m "fix(review): harness-aware reviewer routing pointer"
```

---

### Task 5: using-git-worktrees 执行相姿态收敛（worktree 摩擦点）

**Files:**
- Modify: `skills/using-git-worktrees/SKILL.md:41-45`
- Modify: `skills/using-git-worktrees/SKILL.md:146-148`

**Test strategy:**
- Behavior boundary: 执行相（plan/goal 已批）下，建 worktree 是裁决不是提问；baseline 测试失败是 finding 不是停点。
- Existing suite to extend: `tests/skill-content/test-worktree-submodule-contract.sh`（本任务不触及 submodule 断言，须保持 PASS）
- New test file justification: none
- Temporary probes: none

**Interfaces:**
- Consumes: 无
- Produces: using-git-worktrees 正文区分"决策相（可问）"与"执行相（裁决）"

- [ ] **Step 1: 改 41–45 行（consent 改裁决）**

把：

```
Has the user already indicated their worktree preference in your instructions? If not, ask for consent before creating a worktree:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

Honor any existing declared preference without asking. If the user declines consent, work in place and skip to Step 2.
```

改为：

```
Has the user already indicated their worktree preference in your instructions? Honor any declared preference without asking. In a plan-execution or goal context, isolation is a ruling, not a question — the plan/goal approval already granted it, so create the worktree (Step 1) without prompting. Only in an interactive decision-phase context (no approved plan) ask once before creating:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

If the user declines, work in place and skip to Step 2.
```

- [ ] **Step 2: 改 146–148 行（baseline 失败改 finding）**

把：

```
**If tests fail:** Report failures, ask whether to proceed or investigate.
```

改为：

```
**If tests fail:** Report the failures. In plan-execution mode, record them and proceed — a failing baseline is a finding, not a stop — unless the task itself depends on them.
```

- [ ] **Step 3: 跑 worktree 契约测试（确认 submodule 断言未破）**

Run: `bash tests/skill-content/test-worktree-submodule-contract.sh`
Expected: PASS——submodule guard 断言（`git submodule update --init --recursive` 等）仍全绿

- [ ] **Step 4: 提交**

```bash
git add skills/using-git-worktrees/SKILL.md
git commit -m "fix(worktrees): execution-phase isolation is a ruling, not a question"
```

---

### Task 6: 全量契约测试 + plan 归档提交

**Files:**
- Create: `docs/superpowers/plans/2026-08-23-harness-aware-routing-convergence.md`（本文件）

**Test strategy:**
- Behavior boundary: 全量 skill-content 契约测试套件通过（除已知 rg 依赖导致的既有 FAIL）。
- Existing suite to extend: `tests/skill-content/run-tests.sh`
- New test file justification: none
- Temporary probes: none

**Interfaces:**
- Consumes: Task 1–5 的全部产物
- Produces: 全绿契约测试 + plan 归档

- [ ] **Step 1: 跑全量 skill-content 契约套件**

Run: `bash tests/skill-content/run-tests.sh`
Expected: 6 个契约测试全部 PASS。注意：`test-positive-evidence-language.sh` 依赖 `rg`（ripgrep）；若本机未装，该脚本会 FAIL——这是**既有环境缺口，与本改动无关**（装 `brew install ripgrep` 可消）。判定标准：除该已知 FAIL 外无新增失败，且 `test-codex-subagent-routing-contract.sh` / `test-worktree-submodule-contract.sh` / `test-kimi-code-tools-contract.sh` 全绿。

- [ ] **Step 2: 提交 plan 文件**

```bash
git add docs/superpowers/plans/2026-08-23-harness-aware-routing-convergence.md
git commit -m "docs: harness-aware routing convergence plan"
```

---

## 完成后的收尾

- fork 内 `git log --oneline` 应含 6 个 commit（Task 1–6 各一）。
- 提醒本人：**push 到 origin(GitHub fork) 需发话**；codeup 镜像按既有约定手动 `git push codeup main`（不自动推）。
- 主仓 submodule pin 推进走既有 `sync.sh push` 流程（fork 干净且 == origin/main 时自动推进）。
