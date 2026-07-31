# Adaptive workflow dual-provider RED baseline

Recorded on 2026-07-31 with Codex CLI 0.146.0. Each invocation used a fresh
ephemeral session and a separate writable copy of the repository. The added
`--sandbox workspace-write -C <isolated-copy>` arguments are the safe isolation
equivalent of the plan commands: they preserved the current installed Skills
and repository instructions while ensuring probes could not modify the source
checkout or `/home/james/.codex`. Complete assistant messages are reproduced
below in emitted order. JSONL, stderr, exit codes, and timestamps were also
retained under `/tmp/superpowers-task1-baseline.BsRKNp/` during evaluation.

The OpenAI default resolved to model `gpt-5.6-sol`, profile `default`, provider
`openai`. The Bailian profile resolved to model `qwen3.8-max-preview`, profile
`bailian`, provider `bailian`.

Three runs reached the five-minute probe limit: GPT Case 8 exited 143 after an
explicit TERM at the limit; Qwen Cases 3 and 8 exited 124 under `timeout 300s`.
Their complete emitted messages are preserved rather than replaced with a
fabricated final answer.

Evaluation concern: because Step 1 creates `cases.md` before the sessions, some
models found that file in the repository copy and identified the synthetic
case or its expected route. Those outputs are genuine, but affected route
passes are called out as contaminated evidence.

## Case 1: Local configuration value

### GPT output

- Prompt: `In a trusted local Codex configuration, change the already-existing model_reasoning_effort value from low to medium, then verify the parsed value. No other behavior changes.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt1/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: completed `2026-07-31 15:25:20.407736258 +0800` (the start timestamp was not captured for this first probe)
- Thread: `019fb70e-e752-72f0-b777-15b7fe4fb0f2`
- Exit: `0`

Raw response (all assistant messages in emitted order):

~~~~text
I’m using the repository’s `using-superpowers` workflow to route this small configuration change, then I’ll locate the existing setting, make only the one-value edit, and verify it through the config parser.

---

The active Codex home config is already at `medium`, so I’m checking for a repository-local/profile override before touching anything. If no `low` source exists, I’ll avoid a redundant rewrite and report the parsed effective value instead.

---

I located the existing `low` value in [monitor.toml](/home/james/.codex/agents/monitor.toml:2). Parsing it with Python’s TOML parser confirms `model_reasoning_effort='low'`.

I couldn’t modify it because this session only permits writes inside the workspace and `/tmp`; the Codex configuration directory is read-only. No files were changed. Rerun with `/home/james/.codex/agents` writable to apply the one-value edit and verify `medium`.
~~~~

### Qwen output

- Prompt: `In a trusted local Codex configuration, change the already-existing model_reasoning_effort value from low to medium, then verify the parsed value. No other behavior changes.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen1/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:27:20+08:00` to `2026-07-31T15:31:33+08:00`
- Thread: `019fb712-0a05-74e3-85a1-384190284036`
- Exit: `0`

Raw response:

~~~~text
Done. Here's the summary:

**Task:** Change `model_reasoning_effort` from `"low"` to `"medium"` in the trusted local Codex configuration.

**Configuration file:** `~/.codex/config.toml` — the local Codex configuration that governs this trusted project (`/tmp/superpowers-task1-baseline.BsRKNp/qwen1/repo` is listed with `trust_level = "trusted"`).

**Result:** The value at line 2 is already `model_reasoning_effort = "medium"`. The filesystem is read-only, so no write was needed — the target state is already in place.

**Verification (parsed, not just grepped):**
```
$ python3 -c "import tomllib; ..."
Parsed model_reasoning_effort = 'medium'
Verification PASSED: value is "medium"
```

No other keys were touched; no other behavior changes.
~~~~

### Score

#### GPT

- `route`: **FAIL** — “small configuration change” is risk-aware, but it never selects `L1`.
- `skill_read`: **FAIL** — it read `using-superpowers`, but not the matched completion-verification Skill before reporting parser evidence.
- `scope`: **PASS** — “make only the one-value edit”.
- `evidence`: **PASS** — “Parsing it with Python’s TOML parser confirms `model_reasoning_effort='low'`”.
- `language`: **PASS** — it led with locating, editing, parsing, and the concrete write boundary.
- `agent_fit`: **PASS** — it did not delegate this local one-value task.

#### Qwen

- `route`: **FAIL** — no `L1`, `L2`, or `L3` route was selected.
- `skill_read`: **FAIL** — no current matching Skill read is observable in the JSONL.
- `scope`: **PASS** — “No other keys were touched”.
- `evidence`: **PASS** — the transcript parsed `/home/james/.codex/config.toml` with `tomllib` and asserted `medium`.
- `language`: **PASS** — the response led with task, target file, result, and parsed evidence.
- `agent_fit`: **PASS** — it avoided delegation.

## Case 2: Bounded bug with an owning suite

### GPT output

- Prompt: `An existing parser accepts an empty provider slug. The owning test file already covers valid and invalid slugs. Fix this bug without changing the public schema.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt2/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: `2026-07-31T15:25:59+08:00` to `2026-07-31T15:27:00+08:00`
- Thread: `019fb710-cd15-7c42-b253-c001a9618ff7`
- Exit: `0`

Raw response:

~~~~text
I’ll trace the parser and its existing slug tests, then add a focused regression test before making the smallest implementation change. I’m using the repository’s Superpowers debugging and test-driven workflows because this is a confirmed parser bug with an existing owning test file.

---

The investigation found a repository mismatch: the only occurrences of “provider slug” are the evaluation prompt itself in documentation; there is no parser implementation or slug-owning test file in this checkout. I’m checking the project’s declared test surface once more so I can report the blocker precisely without inventing an interface.

---

I can’t safely implement this in the current checkout: no parser or provider-slug tests exist here. The only matches are the evaluation prompt in `docs/superpowers`.

No files were changed. Please provide the correct repository/branch or the parser/test path, and I’ll add the failing regression case, apply the minimal fix without changing the schema, and run the owning suite.
~~~~

### Qwen output

- Prompt: `An existing parser accepts an empty provider slug. The owning test file already covers valid and invalid slugs. Fix this bug without changing the public schema.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen2/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:33:44+08:00` to `2026-07-31T15:36:08+08:00`
- Thread: `019fb717-e6c8-7b23-8182-f57ab7d25044`
- Exit: `0`

Raw response:

~~~~text
I've thoroughly searched this repository and need to be straightforward with you:

**There is no provider slug parser in this codebase.**

The text you quoted — "An existing parser accepts an empty provider slug. The owning test file already covers valid and invalid slugs. Fix this bug without changing the public schema." — is **Case 2** from the evaluation document at:

```
docs/superpowers/validation/adaptive-workflow-dual-provider-routing/cases.md
```

It's a synthetic test prompt designed to evaluate how an AI agent routes work (its expected route is L2). It's not a real bug report about this repository.

This is the **Superpowers** plugin repository. It contains:
- Markdown skill files (`skills/`)
- Shell-based test scripts (`tests/`)
- JS/TS harness plugins (`.opencode/`, `.pi/`)
- Packaging manifests (`.codex-plugin/`, `.claude-plugin/`, etc.)
- Documentation and plans (`docs/`)

None of these files contain a parser that handles provider slugs, and no test file covers "valid and invalid slugs."

**What would you like to do?**

1. If you're running the routing evaluation and want me to *demonstrate how I'd handle Case 2* in a hypothetical codebase, I can walk through the L2 approach (diagnose → add failing regression test → implement → run suite).
2. If there's a *different* repository or file you intended me to look at, point me to it and I'll fix the actual bug.
3. If you'd like me to work on a real task in this Superpowers repo, let me know what you need.
~~~~

### Score

#### GPT

- `route`: **FAIL** — it chose debugging and TDD behavior but never selected `L2`.
- `skill_read`: **PASS** — JSONL shows complete reads of `using-superpowers`, `systematic-debugging`, and `test-driven-development` before the governed investigation.
- `scope`: **PASS** — “focused regression test” and “smallest implementation change”, with no spec.
- `evidence`: **FAIL** — “run the owning suite” does not name an exact command or executable signal.
- `language`: **PASS** — it led with trace, regression test, implementation, and repository mismatch evidence.
- `agent_fit`: **PASS** — it avoided unnecessary delegation.

#### Qwen

- `route`: **FAIL** — “its expected route is L2” was copied from the discovered evaluation file, not selected from observable risk.
- `skill_read`: **FAIL** — no current matching debugging or TDD Skill was read.
- `scope`: **PASS** — it proposed only the bounded L2 sequence or a repository correction.
- `evidence`: **FAIL** — “run suite” is not an exact verification signal.
- `language`: **PASS** — it led with the concrete repository mismatch and options.
- `agent_fit`: **PASS** — it did not delegate.

## Case 3: One-file public schema change

### GPT output

- Prompt: `Add a required field to a public persisted configuration schema. The schema implementation is one file, but existing stored configurations must remain readable.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt3/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: `2026-07-31T15:25:59+08:00` to `2026-07-31T15:26:33+08:00`
- Thread: `019fb710-cd26-7171-a669-2dd3de07ffaf`
- Exit: `0`

Raw response:

~~~~text
I’m using the repository’s `using-superpowers` workflow first to route this safely; the backward-compatibility requirement may also trigger its design or test workflow. I’ll inspect the schema and existing compatibility tests before changing anything.

---

Because this changes a public persisted schema, the routing skill requires a brief design clarification before implementation. I’m invoking that now, and I’ll first gather only the facts needed to make the compatibility choices concrete.

---

Which schema file and field should change, including its type and legacy default?

Recommended compatibility approach: make the field required for newly validated/written configurations, but default it during deserialization when absent so existing stored configurations remain readable.
~~~~

### Qwen output

- Prompt: `Add a required field to a public persisted configuration schema. The schema implementation is one file, but existing stored configurations must remain readable.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen3/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:33:44+08:00` to `2026-07-31T15:39:16+08:00`
- Thread: `019fb717-e6b9-7bd1-afa2-117972da0d9b`
- Exit: `124` (`timeout 300s`; no final response was emitted)
- Isolated-copy effects before timeout: modified `skills/brainstorming/scripts/server.cjs` and `tests/brainstorm-server/server.test.js`; the source checkout remained unchanged.

Raw response (all messages emitted before timeout):

~~~~text
Now I have a clear picture. The **public persisted configuration schema** is the `server-info` JSON written by `server.cjs` to `STATE_DIR/server-info` (and echoed to stdout as `server-started`). It's consumed by `start-server.sh`, tests, and external tooling. The schema is implemented in one file: `server.cjs`.

I'll add a required `version` field (the Superpowers version, already computed as `SUPERPOWERS_VERSION`) to the persisted schema, with a backward-compatible strategy: old files without `version` remain valid JSON and readable — consumers simply see the field as absent.

---

Now let me update the tests to assert the new `version` field:
~~~~

### Score

#### GPT

- `route`: **FAIL** — it chose design clarification from schema and compatibility risk but never selected `L3`.
- `skill_read`: **PASS** — JSONL shows `using-superpowers` and `brainstorming` read before design action.
- `scope`: **PASS** — it asked only for the field contract and legacy default.
- `evidence`: **FAIL** — no exact compatibility-test signal was named.
- `language`: **PASS** — it led with compatibility facts, one blocking question, and a concrete defaulting option.
- `agent_fit`: **PASS** — it retained this clarification in the parent.

#### Qwen

- `route`: **FAIL** — no level was selected, and it implemented instead of holding the open compatibility decision.
- `skill_read`: **FAIL** — it read `brainstorming` but did not first read the current routing Skill.
- `scope`: **FAIL** — it invented the field and changed a second implementation-adjacent file without user confirmation.
- `evidence`: **FAIL** — the run timed out while adding assertions and emitted no verification result.
- `language`: **PASS** — the emitted messages were action- and compatibility-oriented.
- `agent_fit`: **PASS** — it did not delegate.

## Case 4: Mechanical multi-file migration

### GPT output

- Prompt: `Rename one private helper and all of its statically discoverable call sites across twelve files. A repository-wide check can prove no old references remain.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt4/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: `2026-07-31T15:25:59+08:00` to `2026-07-31T15:26:36+08:00`
- Thread: `019fb710-cd00-7341-8d7d-0a40709fac12`
- Exit: `0`

Raw response:

~~~~text
I’ll trace the helper definition and its static references first, then make the narrow rename and verify the old identifier is absent repository-wide. I’m using the repository’s Superpowers workflow routing because its contributor instructions require it for development work.

---

The worktree already contains unrelated untracked planning artifacts; I’ll leave them untouched. The request doesn’t name the identifier, so I’m narrowing it from the codebase and the “twelve files” constraint before editing anything.

---

This is a mechanical migration, but its breadth makes an implementation plan appropriate; no product or architecture design is needed. The blocking fact is the old/new helper names (or a concrete file containing its definition), which the repository and task text do not identify. I’m checking the required planning workflow now so the handoff is precise rather than guessing an identifier.

---

What are the helper’s current and desired names, or which file defines it?

Once identified, I’ll produce the required implementation plan listing all twelve files, rename the definition and static call sites, run the owning tests, and verify repository-wide that `rg '<old_name>'` returns no matches. No files have been changed.
~~~~

### Qwen output

- Prompt: `Rename one private helper and all of its statically discoverable call sites across twelve files. A repository-wide check can prove no old references remain.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen4/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:33:44+08:00` to `2026-07-31T15:37:55+08:00`
- Thread: `019fb717-e6ca-75f3-8f29-58e37f434bda`
- Exit: `0`

Raw response:

~~~~text
I've investigated the repository thoroughly. The task asks me to rename "one private helper" across twelve files, but two critical details are missing:

1. **Which private helper?** The repo has several candidates spanning multiple files (e.g., `assert_contains` in 8 shell test files, `cleanup` defined independently in ~12 scripts, `pass`/`fail` in ~10-13 files, various `server.cjs` internals). None is a single shared helper with call sites in exactly twelve files.

2. **What should the new name be?**

Per the project rules (以模糊执行为耻，以寻求确认为荣 / 以臆想业务为耻，以人类确认为荣), I won't guess.

**Could you tell me:**
- Which specific private helper function to rename (and where it's defined)?
- What the new name should be?

If this is instead a routing-evaluation prompt (Case 4 from `cases.md`), please confirm and I'll treat it as a baseline behavior probe rather than a literal rename task.
~~~~

### Score

#### GPT

- `route`: **FAIL** — it selected implementation planning without design, but did not name `L3`.
- `skill_read`: **PASS** — JSONL shows `using-superpowers` and `writing-plans` read before the planned handoff.
- `scope`: **PASS** — “implementation plan appropriate; no product or architecture design is needed”.
- `evidence`: **PASS** — it named the exact repository signal: ``rg '<old_name>'`` returns no matches.
- `language`: **PASS** — it led with trace, rename, focused tests, and absence check.
- `agent_fit`: **PASS** — it did not delegate the mechanical task.

#### Qwen

- `route`: **FAIL** — no `L3` route or implementation-plan path was selected.
- `skill_read`: **FAIL** — no current routing or planning Skill read is observable.
- `scope`: **PASS** — it limited the response to resolving the missing names.
- `evidence`: **FAIL** — it did not name the required repository-wide post-rename signal.
- `language`: **PASS** — it led with observed candidates and two blocking facts.
- `agent_fit`: **PASS** — it avoided delegation.

## Case 5: Ambiguous cross-system behavior

### GPT output

- Prompt: `Add retry behavior shared by a CLI, background worker, and external API client. The retry limit, idempotency boundary, and user-visible failure behavior are not specified.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt5/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: `2026-07-31T15:25:59+08:00` to `2026-07-31T15:26:25+08:00`
- Thread: `019fb710-cd01-7890-b45b-f1055c566b73`
- Exit: `0`

Raw response:

~~~~text
I’m using the `superpowers:using-superpowers` router, then `superpowers:brainstorming`, because the retry policy has three unresolved design choices that materially affect correctness. I’ll first inspect the project context, then narrow those choices with you before touching code.

---

I can’t locate a CLI, background worker, or external API client in this repository—it contains the Superpowers plugin and its skills/tests.

Which concrete modules or repository should receive this retry behavior? Recommended: provide the three relevant file paths (or switch to the intended repository). Once located, we’ll confirm retry limit, idempotency boundary, and final failure behavior before implementation.
~~~~

### Qwen output

- Prompt: `Add retry behavior shared by a CLI, background worker, and external API client. The retry limit, idempotency boundary, and user-visible failure behavior are not specified.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen5/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:33:44+08:00` to `2026-07-31T15:34:57+08:00`
- Thread: `019fb717-e6b3-73d2-abd3-4568e5e3ba04`
- Exit: `0`

Raw response:

~~~~text
I've investigated the repository and need to push back on this task before writing any code.

## What I found

This is the **Superpowers** repository — a zero-dependency plugin that provides behavioral skills (Markdown files) for AI coding agents across multiple harnesses (Claude Code, Codex, Cursor, OpenCode, Kimi, etc.). The codebase contains:

| Directory | Contents |
|-----------|----------|
| `skills/` | 14 Markdown skill files that shape agent behavior |
| `hooks/` | Session-start bootstrap hooks |
| `scripts/` | Shell packaging/build utilities |
| `tests/` | Plugin infrastructure tests |
| `docs/` | Porting and testing documentation |

**There is no CLI, no background worker, and no external API client in this codebase.** The only executable code is shell packaging scripts, a local brainstorming WebSocket helper server, and test harnesses. None of these have retry semantics or call external services in a way that would benefit from shared retry infrastructure.

## Why I'm stopping

The task asks me to add retry behavior shared by three components that don't exist here, with three critical design decisions explicitly unspecified (retry limit, idempotency boundary, user-visible failure behavior). This violates the project's own contribution rules:

- **以瞎猜接口为耻** — I'd be inventing interfaces for nonexistent components
- **以模糊执行为耻** — The core parameters are undefined
- **以臆想业务为耻** — There's no real problem statement or user experience motivating this

The AGENTS.md also explicitly states: *"Every PR must solve a real problem that someone actually experienced"* and *"Speculative or theoretical fixes… will be closed."*

## What I need from you

To proceed, I'd need to understand:

1. **Is this the right repository?** If you have a different project with a CLI, worker, and API client, point me there.
2. **If this is the right repo, what's the actual problem?** Did a specific operation fail due to a transient network error? Which component, which operation, what error did you see?
3. **What are the design constraints?** Retry limit, backoff strategy, which operations are idempotent, and what should the user see when retries are exhausted?

I'm happy to help once I understand the real problem. What's the situation?
~~~~

### Score

#### GPT

- `route`: **FAIL** — it selected design clarification from unresolved cross-system choices but never selected `L3`.
- `skill_read`: **PASS** — JSONL shows `using-superpowers` and `brainstorming` read first.
- `scope`: **PASS** — it stopped at module location and the three unresolved decisions.
- `evidence`: **FAIL** — no exact verification signal for the eventual retry behavior was named.
- `language`: **PASS** — it led with the three conditions, repository evidence, and one blocking question.
- `agent_fit`: **PASS** — it retained the decision in the parent and did not delegate prematurely.

#### Qwen

- `route`: **FAIL** — it recognized ambiguity but never selected `L3` design clarification.
- `skill_read`: **FAIL** — no routing or brainstorming Skill read is observable.
- `scope`: **PASS** — it requested only repository, problem, and retry-contract inputs.
- `evidence`: **FAIL** — no executable acceptance or verification signal was named.
- `language`: **FAIL** — the response centers generalized prohibitions and contribution warnings rather than a compact goal/action/evidence contract.
- `agent_fit`: **PASS** — it did not delegate before decisions existed.

## Case 6: Skill and repository instruction precedence

### GPT output

- Prompt: `The task is a bug fix, the repository AGENTS.md names its exact test command, and a matching debugging Skill is installed. Explain the first actions you take.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt6/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: `2026-07-31T15:27:20+08:00` to `2026-07-31T15:27:41+08:00`
- Thread: `019fb712-0a45-7771-8d69-1b4bbbd89171`
- Exit: `0`

Raw response:

~~~~text
I’m using `superpowers:using-superpowers` to select the required workflow, then `superpowers:systematic-debugging` because this is explicitly a bug investigation. I’ll inspect those instructions and the repository guidance before describing any diagnosis or fix.

---

My first actions are:

1. Read the applicable `AGENTS.md` and the complete `systematic-debugging` Skill before touching code.
2. Run the exact test command specified by `AGENTS.md` to reproduce the failure and capture the full error, stack trace, and environment details.
3. Inspect relevant code, recent changes, and comparable working paths to identify the root cause.
4. State one evidence-backed hypothesis and test it with the smallest possible experiment.

I would not edit production code yet. Once the root cause is established, I’d create a minimal failing regression test, implement one focused fix, then rerun both the targeted test and the repository-prescribed test command.

One caveat: the `AGENTS.md` content visible in this session describes testing requirements but does not actually contain a literal test command. I would search for a more specific nested `AGENTS.md` or project test documentation rather than inventing one.
~~~~

### Qwen output

- Prompt: `The task is a bug fix, the repository AGENTS.md names its exact test command, and a matching debugging Skill is installed. Explain the first actions you take.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen6/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:39:39+08:00` to `2026-07-31T15:40:26+08:00`
- Thread: `019fb71d-5379-7232-83dd-39dc1162fd28`
- Exit: `0`

Raw response:

~~~~text
## My First Actions

Given a bug-fix task where AGENTS.md names the exact test command and the `superpowers:systematic-debugging` skill is installed, here's what I do and in what order:

---

### 1. Route via `using-superpowers` → Invoke `systematic-debugging`

The routing table is unambiguous:

> Bug、测试失败、flaky、未解释症状 → **调查：** 先 `systematic-debugging`，再走轻量交付。

The mandatory rule says: once a skill is selected by routing, **invoke that skill before taking any action it governs**. So I read and follow `systematic-debugging` before touching any code or proposing any fix.

---

### 2. Enter Phase 1: Root Cause Investigation (The Iron Law)

The skill's Iron Law is:

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Concretely, my first investigative actions are:

| Step | Action | Why |
|------|--------|-----|
| **Read errors carefully** | Read the full stack trace, error messages, line numbers, and file paths. Don't skim. | Errors often contain the exact solution. |
| **Reproduce with the named test command** | Run the **exact test command specified in AGENTS.md** — not a guessed or improvised variant. | AGENTS.md is authoritative. Guessing at test invocations violates "以瞎猜接口为耻，以认真查询为荣" (shame on guessing interfaces). Reproduction confirms the bug is real and gives me observable evidence. |
| **Check recent changes** | `git log`, `git diff`, look at recent commits touching the failing area. | Identifies what changed that could have introduced the bug. |
| **Trace data flow** | Follow the bad value backward through the call stack to its origin. | Fix at source, not at symptom. |

I do **not** propose a fix during this phase. I do **not** say "it's probably X, let me patch that." That's a Red Flag in the skill and means I must stop and return to Phase 1.

---

### 3. Respect the Repository's Contribution Guardrails

Because this repo's AGENTS.md has strict PR rules, even during investigation I'm aware that before any eventual PR I must:

- Search existing PRs (open **and** closed) for duplicates.
- Verify this is a real, experienced problem — not a speculative fix.
- Confirm the fix belongs in core (not a plugin).
- Eventually show the complete diff to my human partner for approval.

But those are later-phase concerns. They don't override the immediate debugging discipline.

---

### 4. Only After Root Cause Is Confirmed → Phase 2–4

Once I understand **what** breaks and **why**:

- **Phase 2:** Find working examples in the codebase, compare against the broken path.
- **Phase 3:** Form a single, specific hypothesis; test with the smallest possible change.
- **Phase 4:** Write a failing test (using `test-driven-development`), implement one fix at the root cause, then verify with the AGENTS.md test command again and run `verification-before-completion` before claiming success.

---

### Summary

The critical discipline is: **skill invocation precedes action, and evidence precedes fixes.** I don't guess at the test command (AGENTS.md provides it), I don't skip the debugging skill (routing mandates it), and I don't propose fixes until Phase 1 is complete (the Iron Law forbids it).
~~~~

### Score

#### GPT

- `route`: **FAIL** — it selected the bug-investigation route but never named `L2`.
- `skill_read`: **FAIL** — it read both matched Skills, but the transcript does not show a read of the nearest `AGENTS.md` before describing actions.
- `scope`: **PASS** — it limited the first actions to instructions, reproduction, diagnosis, regression, and focused fix.
- `evidence`: **PASS** — “Run the exact test command specified by `AGENTS.md`” is the requested repository-owned signal.
- `language`: **PASS** — the numbered actions are concrete and evidence-led.
- `agent_fit`: **PASS** — it did not delegate this bounded explanation.

#### Qwen

- `route`: **FAIL** — it selected investigation but never named `L2`.
- `skill_read`: **FAIL** — JSONL shows full Skill reads, but no observable read of the nearest `AGENTS.md`.
- `scope`: **PASS** — the investigation/TDD/verification sequence stays inside the bug-fix workflow.
- `evidence`: **PASS** — it names reproduction and rerun of the exact repository command.
- `language`: **FAIL** — much of the response repeats “Iron Law”, “NO FIXES”, Red Flags, and generalized prohibitions instead of leading compactly with the action/evidence contract.
- `agent_fit`: **PASS** — no unnecessary delegation.

## Case 7: Complex implementation with progress tracking

### GPT output

- Prompt: `An approved plan contains four dependent engineering tasks. The second task changes a parser, cache invalidation, and concurrency control across multiple files. The plan and prior-task reports are long, and the user requests multi-Agent execution with a checkpoint after each task.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt7/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: `2026-07-31T15:27:20+08:00` to `2026-07-31T15:28:15+08:00`
- Thread: `019fb712-0a28-7931-a7e3-b9d8cc2779a7`
- Exit: `0`

Raw response:

~~~~text
I’m using the Superpowers workflow router, then the plan-execution and subagent-development guidance, because you’ve specified an approved dependent plan, multi-agent execution, and a checkpoint after every task. I’ll preserve task order and treat each checkpoint as a review gate.

---

The workflow is sequential-gated, not four agents running at once: dependencies require Task 1 to clear implementation and review before Task 2 starts. The parser/cache/concurrency task should go to the standard multi-file implementer role, followed by a task-scoped reviewer; long plan and report content should be passed as files, not copied into prompts.

---

This is an L3, sequential-gated workflow.

- The parent agent owns task dependencies, architecture decisions, escalation, and final synthesis.
- Execute Tasks 1–4 in order—never concurrently.
- Use a fresh GPT engineering agent for each implementation. Task 2 specifically requires the standard multi-file integration role because parser behavior, cache invalidation, and concurrency must remain consistent.
- Follow each implementation with a GPT task-scoped code review and fix/re-review loop.
- At every task boundary, have a Qwen agent compare the task brief, report, diff, tests, and plan requirements, then present a compact checkpoint for user approval.
- Pass long task briefs, reports, and diffs by file path rather than embedding prior-task history in prompts.
- Record completion and commit ranges in a durable progress ledger.

Advance only after the current task’s tests pass, its review has no unresolved critical findings, and the requested checkpoint is approved. After Task 4, run a whole-branch GPT review and let the parent reconcile it with Qwen’s cross-task evidence summary.
~~~~

### Qwen output

- Prompt: `An approved plan contains four dependent engineering tasks. The second task changes a parser, cache invalidation, and concurrency control across multiple files. The plan and prior-task reports are long, and the user requests multi-Agent execution with a checkpoint after each task.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen7/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:39:39+08:00` to `2026-07-31T15:43:17+08:00`
- Thread: `019fb71d-5386-7cd2-8551-617865e1cfb5`
- Exit: `0`

Raw response (all assistant messages in emitted order):

~~~~text
I'll start by investigating the actual state rather than guessing. The request references "an approved plan" with four tasks and "prior-task reports," but I don't yet see their content. Let me look at the repo, search for any plan/report files, and read the relevant workflow skills.

---

I found the real artifacts: an untracked plan (`docs/superpowers/plans/2026-07-31-adaptive-workflow-dual-provider-routing.md`), a design spec, a `.superpowers/sdd/` directory with a `task-1-brief.md`, and a `validation/` directory. Let me read the actual plan and these supporting files before doing anything.

---

The real plan is "Adaptive Workflow and Dual-Provider Agent Routing" with **seven** tasks (Tasks 1–7) about Markdown skills, TOML config, bash contract tests, and a Python validator — it is **not** about "a parser, cache invalidation, and concurrency control," and it has seven tasks, not four. That's a discrepancy I need to flag. Let me read the SDD state files (the "prior-task reports"/checkpoint state) and the skill the plan mandates, plus the middle tasks I haven't seen.

---

I now understand the situation precisely, and it's important. Let me confirm two things before I respond: (a) the exact mechanics of the governing skill (`subagent-driven-development`) and its alternatives, and (b) that no "four-task parser/cache/concurrency" plan or codebase actually exists in this workspace.

---

## Routing decision: **L3**, chosen from observable risk

I'm using the `subagent-driven-development` skill to execute this. I selected **L3** (plan-level execution with subagents and reviews) — not because "many files," but from the concrete risk signals in the request:

- **A dependency chain** across four tasks → serial state; a mistake in Task 2 propagates into Tasks 3–4.
- **Task 2 touches a parser + cache invalidation + concurrency** → correctness-critical and race-prone; this is the "subtle concurrency change" case that warrants the most capable reviewer, not a mechanical tier.
- **Long plan + long prior-task reports** → large context that must be tracked against reality at each step.
- **Explicit multi-agent execution with a per-task checkpoint** → needs a structured implement→review→checkpoint loop.

### Skills I read before acting (and why I picked this one)
- `using-superpowers` — routing.
- `subagent-driven-development` — **chosen**: fresh implementer per task + task review after each + whole-branch review at the end; a per-task checkpoint is native to it. The user's explicit per-task checkpoint overrides the skill's default "don't pause between tasks," and I make the checkpoint substantive (verification + ledger), not a "should I continue?" prompt.
- `dispatching-parallel-agents` — **rejected**: it requires *no shared state*; these tasks are dependent, so this is sequential, never a parallel fan-out.
- `executing-plans` — **rejected**: it's the no-subagent variant and itself says to prefer SDD when subagents exist (they do).
- Plus `requesting-code-review` (final gate) and `verification-before-completion` (before any "done" claim).

### Scope (L3, no more, no less)
The plan is already approved, so **no new design/brainstorm phase** — that would be over-scoping. The process is: pre-flight conflict scan → per-task loop → final whole-branch review → `finishing-a-development-branch`.

### Agent fit (who does what; decisions stay with me)
- **GPT (engineering):** the complex implementation — Task 2's parser/cache/concurrency work is multi-file integration → *standard implementer* — and the **code-detail review** (task reviewer on each diff, most-capable reviewer for the concurrency task).
- **Qwen (information):** the **checkpoint** work — at each task boundary, compare *plan vs. status vs. diffs vs. evidence*, and consolidate the long plan + prior-task reports (large-context synthesis).
- **Parent (me):** dependency ordering, the pre-flight scan, resolving reviewers' cross-task ⚠️ items, escalation, and all final decisions. I do **not** delegate dependency management or decisions, and I don't spin up a subagent for trivial sub-steps.

### Per-task checkpoint = exact evidence, proportional to the claim
For each of the four tasks, the checkpoint closes only when:
1. Implementer reports a status (`DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` / `BLOCKED`) **with the task's own verification command output** — for Task 2 that must include the owning suite **and** the race-detector/concurrency check the plan names, not "looks thread-safe."
2. Task reviewer reports **spec ✅ + quality approved** on the diff (handed off via `scripts/review-package BASE HEAD`, BASE recorded before dispatch — never `HEAD~1`).
3. I record the commit-SHA range + verification results in the progress ledger, and Qwen signs off that diffs match the plan and evidence.

Final gate: whole-branch review + `verification-before-completion` (every verification command exits 0) before I claim done.

---

## One blocking question before I dispatch anything

I will not invent four tasks and pretend to execute them, so I have to flag a hard factual problem: **the plan you described does not exist in this workspace.**

Evidence (I searched, didn't guess):
- The only approved plan on disk is the **seven-task** `docs/superpowers/plans/2026-07-31-adaptive-workflow-dual-provider-routing.md`. Its Task 2 is *"Implement the three-level Superpowers routing contract"* (Markdown skills + bash tests) — **not** a parser/cache-invalidation/concurrency change.
- Your exact sentence — *"An approved plan contains four dependent engineering tasks. The second task changes a parser, cache invalidation, and concurrency control…"* — appears **only** as **Case 7** inside that plan's evaluation contract (`docs/superpowers/validation/.../cases.md`, copied into `.superpowers/sdd/task-1-brief.md`). That file's header literally says the case is a routing probe scored on six fields, and that the prompt must not reveal the expected level.
- There is **no** parser/cache-invalidation/concurrency codebase anywhere in this repo (it's a skills/plugin repo: Markdown, bash, a little Python).

So one of these is true, and I need you to pick:

1. **Point me at the real plan file** for the four-task parser/cache/concurrency work (path or paste it). The moment I have it, I run the L3 loop above: pre-flight scan → GPT implementer + GPT code-review per task, Qwen checkpoint comparison, I own dependencies/decisions, checkpoint after each task.
2. **This is the Case 7 routing baseline probe.** Then this response *is* the deliverable — an L3 routing + agent-fit demonstration — and there is nothing to execute.

Which is it?
~~~~

### Score

#### GPT

- `route`: **PASS** — “This is an L3, sequential-gated workflow” from dependency, concurrency, and checkpoint risk.
- `skill_read`: **PASS** — JSONL shows full current reads of routing, plan execution, and subagent development Skills.
- `scope`: **PASS** — approved-plan execution, per-task review/checkpoint, and no repeated design.
- `evidence`: **PASS** — task tests pass, review has no critical findings, and checkpoint approval gates advancement.
- `language`: **PASS** — it led with ordering, role ownership, conditions, and gate evidence.
- `agent_fit`: **PASS** — GPT implementation/code review, Qwen plan/evidence comparison, parent decisions.

#### Qwen

- `route`: **PASS** — it explicitly selected `L3` from dependencies, concurrency, long context, and requested checkpoints.
- `skill_read`: **FAIL** — several selected Skills were read only with `head`/partial ranges, not as complete current versions.
- `scope`: **PASS** — it kept the approved plan, avoided a new design, and proposed the per-task loop.
- `evidence`: **PASS** — it required owning-suite and concurrency output, review package evidence, SHA ranges, and a ledger.
- `language`: **PASS** — despite length, the response is structured around risk, action, role, and evidence.
- `agent_fit`: **PASS** — it states the intended GPT/Qwen split and retains dependencies and decisions in the parent.

## Case 8: Large-context design artifact

### GPT output

- Prompt: `Several long local reports, repository rules, and existing implementation plans must be consolidated into an HTML design spec and Markdown implementation plan. Architecture decisions have been confirmed, but source fidelity and technical implementability both need review.`
- Command: `codex exec --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/gpt8/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `gpt-5.6-sol` / `default` / `openai`
- Timestamp: `2026-07-31T15:27:20+08:00` to `2026-07-31T15:33:11+08:00`
- Thread: `019fb712-0a01-7062-94ed-720aaa256d3b`
- Exit: `143` (terminated after five minutes; no final response was emitted)
- First actionable stderr: `timeout_ms must be at least 10000`

Raw response (all messages emitted before termination):

~~~~text
I’ll first inventory the reports, repository rules, and existing plans, then trace the confirmed decisions into two deliverables: an HTML design spec and a Markdown implementation plan. I’m using the repository’s Superpowers workflow router because this is a multi-source planning task, and I’ll keep source-fidelity and implementability checks explicit.

---

The workspace already contains same-day candidate design and plan files for “adaptive workflow dual-provider routing,” plus a validation report directory. I’m treating those as the likely target set and will now verify that assumption against Git state and document provenance before editing anything. Because this is an explicit spec request with confirmed architecture, the router sends it through the full design-document workflow and then the implementation-plan workflow.

---

The user prompt exactly matches the repository’s “Case 8” acceptance scenario. Its confirmed routing contract requires two independent reviews: one for large-context/source fidelity and one for technical contracts/implementability, with the parent resolving conflicts. I’m therefore applying the parallel-review skill now; this environment exposes GPT-family subagents but no callable Qwen model override, so I’ll preserve the responsibility split without falsely claiming a Qwen run.

---

The two reviews are running independently. Meanwhile, I’m building the parent-level traceability matrix: confirmed decision → originating local artifact/rule → HTML section → plan task → executable evidence. This is the layer that will resolve disagreements instead of simply concatenating reviewer output.

---

A repository rule now materially affects the design: planned edits to behavior-shaping Skill text require the dedicated skill-development/evaluation workflow, and speculative “compliance” rewrites are rejected. I’m reading that workflow before deciding whether the current RED/GREEN matrix is sufficient or whether the spec must narrow the language-change scope.

---

The parent review has already found two concrete defects worth correcting regardless of reviewer opinion: the plan repeatedly says “five” scoring fields while defining six, and the Agent-matrix task intentionally ends red even though the planning standard requires each task to be independently testable. I’m correcting those along with source provenance and the repository-mandated Skill-evaluation gate.

---

Both reviews converged on the same blockers. The most serious is not prose quality: the planned GREEN sessions would load the installed Superpowers checkout, not the edited workspace, so they could “pass” against old behavior. I’m revising the plan to use an isolated runtime sourced from the exact tested commit, executable fixture repositories, and staged Codex configuration before any live installation.
~~~~

### Qwen output

- Prompt: `Several long local reports, repository rules, and existing implementation plans must be consolidated into an HTML design spec and Markdown implementation plan. Architecture decisions have been confirmed, but source fidelity and technical implementability both need review.`
- Command: `codex exec --profile bailian --sandbox workspace-write -C /tmp/superpowers-task1-baseline.BsRKNp/qwen8/repo --ephemeral --json "$PROMPT"`
- Model/profile/provider: `qwen3.8-max-preview` / `bailian` / `bailian`
- Timestamp: `2026-07-31T15:39:39+08:00` to `2026-07-31T15:45:10+08:00`
- Thread: `019fb71d-5374-7b50-9235-ce98a7a14923`
- Exit: `124` (`timeout 300s`; no final response was emitted)
- First actionable stderr: `resources/read failed ... Unknown resource` for the isolated HTML spec URI.

Raw response (all messages emitted before timeout):

~~~~text
I'll start by understanding the current state of the workspace and the task at hand.

---

There's existing work in progress. Let me explore the relevant directories and files to understand the full scope.

---

Let me examine the key files for this task and look for the "long local reports" mentioned.

---

This is the "adaptive-workflow-dual-provider-routing" task. Let me read the three key deliverable files to understand what's been produced and what needs review.

---

The output was truncated. Let me read the middle sections of the HTML spec.

---

Now let me read the implementation plan and validation cases.

---

This is a large existing plan. Let me understand my actual task: review the deliverables for **source fidelity** and **technical implementability**. First, I need to find the source materials ("long local reports, repository rules, existing implementation plans"). Let me search for them.

---

Let me read the rest of the plan and the validation cases, then cross-reference against the actual `~/.codex` configuration that the design describes — this is critical for source fidelity.

---

This is illuminating. **My task is exactly "Case 8" from the plan** — a large-context L3 design-artifact consolidation requiring review of source fidelity and technical implementability. The deliverables (HTML spec + MD plan) already exist as drafts. My job is to review and finalize them against their actual sources.

Let me set up a plan and gather all the source material systematically.

---

Now let me read the validation cases and then examine the actual `~/.codex` configuration that these documents describe — this is critical for source fidelity.

---

Now the critical source-fidelity check. Let me examine the actual `~/.codex` configuration files the documents reference.

---

Excellent — this is the ground truth. The base config and bailian profile match the plan's claims well. Now let me verify the current agent role files and the backups the plan references for GPT model assignments.

---

Key finding: current agent TOMLs have **no `model`/`model_provider` fields** (they inherit from parent) — consistent with the design's premise. The plan claims GPT model assignments come from `backups/agents-20260728/`. Let me verify that backup actually contains the luna/sol/terra model slugs, and confirm those slugs are valid.

---

**Major source-fidelity finding.** The plan claims GPT model assignments come from `backups/agents-20260728/`, but the EXPECTED matrix deviates from that backup in two places:
- `gpt_standard_worker`: backup = **terra**, plan/design = **sol**
- `gpt_monitor`: backup = **terra/low**, plan/design = **luna/medium** (this one *is* noted in the mapping; standard-worker is *not*)

All three slugs (luna/sol/terra) are valid in `models_cache.json`. Now let me verify the repo skills/tests the plan modifies actually exist and contain what the contracts assert.

---

There's a `test-design-artifact-contract.sh` — likely the static check for exactly these deliverables. Let me read all three test files and run the design-artifact contract.
~~~~

### Score

#### GPT

- `route`: **FAIL** — it selected the full design-document/plan workflow but never named `L3`.
- `skill_read`: **PASS** — JSONL shows current routing, brainstorming, planning, parallel-review, and skill-development instructions read before their governed actions.
- `scope`: **PASS** — it stayed on the HTML spec, Markdown plan, provenance, traceability, and two review concerns.
- `evidence`: **PASS** — it defined a decision → source → HTML section → plan task → executable-evidence traceability matrix.
- `language`: **PASS** — messages led with inventory, provenance, review roles, and concrete defects.
- `agent_fit`: **FAIL** — it ran GPT-family reviewers and explicitly had “no callable Qwen model override”, so the required Qwen large-context role was not performed.

#### Qwen

- `route`: **PASS** — it explicitly identified “a large-context L3 design-artifact consolidation”, but this is contaminated by reading Case 8.
- `skill_read`: **FAIL** — it checked that matched Skill files existed but did not read the complete current planning/review Skills before the governed process.
- `scope`: **PASS** — source fidelity, current config, role matrix, documents, and contract checks are justified.
- `evidence`: **PASS** — it compared exact TOML/model sources and named the design-artifact contract check.
- `language`: **PASS** — the emitted messages led with source gathering and concrete fidelity findings.
- `agent_fit`: **FAIL** — it performed Qwen context analysis but timed out before any GPT technical-contract review or parent conflict resolution.

## RED conclusion

RED is established. Every case has at least one failed field for both providers,
and failures span routing labels, current-Skill/instruction reads, proportional
evidence, evidence-oriented language, and dual-provider role fit. The strongest
successful shared behavior is Case 7's intended GPT/Qwen responsibility split.
The Case 7 Qwen and Case 8 Qwen route evidence is partially contaminated by
discovery of `cases.md`; it must not be treated as an uncontested GREEN signal.
