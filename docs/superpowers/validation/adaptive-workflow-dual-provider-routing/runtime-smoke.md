# Dual-provider Codex runtime smoke

Date: 2026-07-31

Runtime: `codex-cli 0.146.0`

Corrected probe root: `/tmp/codex-task6-corrected-20260731T094657Z`

Decision: `provider-per-session-main-only`

## Corrected method

The original probe set used an underspecified spawn instruction. GPT main
sessions selected an incompatible full-history fork, and `--ephemeral`
prevented inspection of child rollouts. Those results are superseded by the
corrected probes below. Their raw artifacts remain at
`/tmp/codex-task6-runtime-smoke-20260731T091909Z` for audit, but they are not
the basis for this decision.

The corrected run first extracted the pre-fallback snapshot into a new,
private temporary `CODEX_HOME`:

```text
/tmp/codex-task6-corrected-20260731T094657Z/home
```

The isolated home retained the pre-fallback twelve active registrations.
Authentication, local model catalog, and model cache were symlinked from the
real Codex home; no credential value was read or printed. The restored profile
hashes were:

```text
2bf77ee0b2328c15485de1a09d16169b103a893b9a292278b8199feac6c618d7  config.toml
f062cdb5b152e921dea91b32eb4886b6e3bd5ae4af8e4489c4ea4029e9d5e37c  bailian.config.toml
```

`tomllib` parsed both profiles. A read-only execution of the snapshot
validator's role, contract, registration, profile, and catalog checks reported
`native 12-registration mode valid`. The Qwen catalog check deliberately used
the installed absolute catalog path already declared by the unchanged role
files.

Four fresh sessions used independent work directories and persistent session
logging in the isolated home. Persistence was required to inspect child
rollout metadata rather than trusting parent JSONL or Agent-authored text.
Every command used `--json --skip-git-repo-check` and
`timeout --signal=TERM --kill-after=5s 540s`; no more than two probes ran
concurrently.

Each prompt explicitly required the corrected invocation:

```text
Call spawn_agent with agent_type="<role>", fork_turns="none" for one
read-only task. In the child task message, require it to return only <token>
and its configured role name. If spawn returns error stop and report it. Wait
on the exact returned child id. After it completes, report the exact spawn
result and child id/state without doing other work.
```

The exact command, profile, UTC timestamps, exit status, parent JSONL, stderr,
and final response are preserved in each probe directory. The four command
records are:

```text
/tmp/codex-task6-corrected-20260731T094657Z/probes/gpt-main-to-gpt-monitor/command.txt
/tmp/codex-task6-corrected-20260731T094657Z/probes/qwen-main-to-qwen-monitor/command.txt
/tmp/codex-task6-corrected-20260731T094657Z/probes/gpt-main-to-qwen-monitor/command.txt
/tmp/codex-task6-corrected-20260731T094657Z/probes/qwen-main-to-gpt-monitor/command.txt
```

## Backend evidence method

In `codex-cli 0.146.0`, parent `--json` emits a `wait` collaboration event
with an empty `receiver_thread_ids` list even when spawn succeeds. Therefore,
the corrected evidence uses the equivalent persisted child-session chain:

1. parent `events.jsonl` supplies the main `thread_id`;
2. a distinct rollout has `session_meta.thread_source="subagent"` and
   `session_meta.parent_thread_id` equal to that main thread;
3. the same `session_meta` supplies child `id`, `agent_path`, `agent_role`, and
   `model_provider`;
4. the child rollout's `turn_context.model` supplies the effective model; and
5. the child rollout records NEW_TASK delivery plus terminal
   `event_msg.task_complete` output or error.

This proves a real child thread and backend independently of the parent's final
text.

## Corrected results

| Main → requested child | UTC start → finish | Exit | Backend-grounded child | Task/result | Verdict |
|---|---|---:|---|---|---|
| GPT → `gpt_monitor` | `09:48:22` → `09:48:44` | 0 | Child `019fb793-49c7-7b43-844e-3a26bb0db74d`; parent `019fb793-2918-7a41-b048-a0a5fb07a681`; role `gpt_monitor`; Provider `openai`; model `gpt-5.6-luna`. | Child `task_complete` line 15: `ROLE_PROBE_OK gpt_monitor`, no error. | Pass. |
| Qwen → `qwen_monitor` | `09:48:22` → `09:51:29` | 0 | Child `019fb793-661c-7b62-9549-6831a1bb0297`; parent `019fb793-28e9-75f1-9c0a-8a3eefa153a5`; role `qwen_monitor`; Provider `bailian`; model `qwen3.8-max-preview`. | NEW_TASK body is stored only as `encrypted_content`. The Qwen child behaved as though the payload were empty and terminated with `No monitoring task received`, not `ROLE_PROBE_OK`. | Fail: same-provider spawn/backend works, but delegated task delivery is incompatible. |
| GPT → `qwen_monitor` | `09:51:56` → `09:54:24` | 0 | Child `019fb796-8d50-7690-b113-36b179f6c93f`; parent `019fb796-6c13-72a1-8e83-2f56ca9777d7`; role `qwen_monitor`; Provider `bailian`; model `qwen3.8-max-preview`. | NEW_TASK line 10 contains unresolved `gAAAA...` ciphertext. The child initially reported no task, then reconstructed the success criterion from the on-disk `command.txt` and returned explanatory text plus the token. | Fail: backend selected correctly, but the native parent→child task channel did not deliver readable instructions. Disk reconstruction is not a successful dispatch. |
| Qwen → `gpt_monitor` | `09:51:56` → `09:52:58` | 0 | Child `019fb796-b5b8-7722-a1d6-81bd8281a726`; parent `019fb796-6c11-7261-9968-b260d0da2423`; role `gpt_monitor`; Provider `openai`; model `gpt-5.6-luna`. | The GPT child received the probe task, but `task_complete` line 23 has no final message and errors: `Encrypted function output content could not be decrypted or decoded.` | Fail: child backend selected correctly, but the native child→parent response channel failed. |

All corrected probes finished within 187 seconds, below the ten-minute bound.

### Child rollout files and hashes

| Probe | Child rollout | SHA-256 |
|---|---|---|
| GPT → GPT | `rollout-2026-07-31T17-48-31-019fb793-49c7-7b43-844e-3a26bb0db74d.jsonl` | `df37bc32ecbc1cb2868f9671684872fecee538674b7f10198333d6f7f9bf6e89` |
| Qwen → Qwen | `rollout-2026-07-31T17-48-38-019fb793-661c-7b62-9549-6831a1bb0297.jsonl` | `177c046c3a0a0e55cb0517999f4650ed473f98ba5c6a5bfe214277ea7fed89e0` |
| GPT → Qwen | `rollout-2026-07-31T17-52-04-019fb796-8d50-7690-b113-36b179f6c93f.jsonl` | `e8859065ed1b03a96a3190374b9eda203c03071f55ef5a505c7f3a6c31a59dc2` |
| Qwen → GPT | `rollout-2026-07-31T17-52-15-019fb796-b5b8-7722-a1d6-81bd8281a726.jsonl` | `c792db579e4a4cf0ced5ff3f1f8807847b646a2adf8667b93fe29c3c13f03a59` |

Parent event hashes are:

```text
58658ebffa1c7045aa72a6ae406fd0d61896142ea9a8419114d68d20dbae1c80  gpt-main-to-gpt-monitor/events.jsonl
76811f4eee1b452354db66138dfdfc29496acce0928b40e3fb75789644074bc3  qwen-main-to-qwen-monitor/events.jsonl
2abe92b40ef9e56f34111861e7ce099cc23b18e625a4ceb638daa640a70e03df  gpt-main-to-qwen-monitor/events.jsonl
2fb0ef1d04087e6ea84534b0314fb2afda2396c901ea1ab9f116c2fefefec121  qwen-main-to-gpt-monitor/events.jsonl
```

## Decision

Mode: provider-per-session-main-only

Correct invocation proves that Codex creates the requested child roles on the
configured backends, including both cross-provider directions. It also proves
that the installed runtime cannot reliably carry delegated messages across
the Qwen/GPT boundary: GPT→Qwen instructions remain encrypted, while
Qwen→GPT output cannot be decrypted. The Qwen same-provider probe additionally
shows that an `encrypted_content` NEW_TASK is not surfaced to that child model.
The native gate therefore fails, including for Qwen same-provider delegation.

The default profile keeps five active GPT generic roles. The Bailian profile
keeps its Qwen main model, `xhigh` effort, and local catalog, but explicitly
sets `features.multi_agent=false` and
`features.multi_agent_v2.enabled=false`. It has no active Agent registration
overrides. Qwen work runs in an independent Bailian main session and consumes
a file-based review package; it never starts nested `codex exec` orchestration.

All twelve provider-specific role TOMLs remain installed, validated, and
inactive as capability templates and future retry evidence. Active routing is:

| Slot | Default profile | Bailian profile |
|---|---|---|
| `routine_worker` | `agents/gpt/routine-worker.toml` | not registered; main session only |
| `standard_worker` | `agents/gpt/standard-worker.toml` | not registered; main session only |
| `task_reviewer` | `agents/gpt/task-reviewer.toml` | not registered; main session only |
| `final_reviewer` | `agents/gpt/final-reviewer.toml` | not registered; main session only |
| `monitor` | `agents/gpt/monitor.toml` | not registered; main session only |

## Bailian main-only smoke

Fresh smoke root:

```text
/tmp/codex-task6-main-only-20260731T100741Z
```

The real installed Bailian profile ran this bounded probe without shell use or
nested Codex orchestration:

```text
timeout --signal=TERM --kill-after=5s 300s codex exec --profile bailian
  --json --skip-git-repo-check
  -C /tmp/codex-task6-main-only-20260731T100741Z/work
  --output-last-message /tmp/codex-task6-main-only-20260731T100741Z/final.txt
  <capability-probe prompt>
```

It exited 0 and completed in 11.334 seconds with
`BAILIAN_MAIN_ONLY_OK AGENT_TOOL_UNAVAILABLE`. Persisted rollout evidence is:

| Field | Evidence |
|---|---|
| Session | `019fb7a5-065a-7db3-8ba7-34df55978b44` |
| `session_meta.model_provider` | `bailian` |
| `turn_context.model` / effort | `qwen3.8-max-preview` / `xhigh` |
| `turn_context.multi_agent_version` | `disabled` |
| Tool behavior | zero `function_call` or `custom_tool_call` response items |
| Rollout SHA-256 | `6d460ce70c0c3f4ec30a5bf2fbb5a089a366da09911452f4899794f28fac4fad` |
| Final-message SHA-256 | `a45b271220224a9f6ac2ce6baf49a500c39116c2a0cb91b25fd8f66f3667d6cb` |

The rollout is
`/home/james/.codex/sessions/2026/07/31/rollout-2026-07-31T18-07-53-019fb7a5-065a-7db3-8ba7-34df55978b44.jsonl`.
The CLI also repeatedly warned that five inherited base role definitions were
malformed. This is retained as runtime noise rather than hidden; the effective
turn still reports multi-agent disabled and exposes no collaboration call.

## Upstream corroboration

The decision rests on the local rollouts above. Three open upstream reports
independently describe adjacent failures: [`codex exec` multi-agent output
decryption](https://github.com/openai/codex/issues/33267), [native subagents
with non-OpenAI custom providers](https://github.com/openai/codex/issues/17598),
and [provider-specific encrypted content surviving a model/provider
switch](https://github.com/openai/codex/issues/17541). They corroborate the
failure class but are not substitutes for the local gate.

## Snapshot and fallback verification

The fresh snapshot taken before the main-only correction is:

```text
/home/james/.codex/backups/pre-bailian-main-only-fallback-20260731T100525Z.tar.gz
SHA-256 86a860e72f47b3f17e224b1834b00076202488b91793ff397e5906975c2878b1
```

The archive contains both profiles, the matrix test and validator, and all
twelve provider-specific role files, plus the Task 6 runtime record/report and
untracked plan/spec. The current fallback validator and test continue to
preserve all twelve role-file checks.

Final local verification:

```text
python -m unittest -v tests.test_agent_matrix
Ran 15 tests
OK
```

```text
python /home/james/.codex/scripts/validate_agent_matrix.py
Agent matrix valid: 12 roles, 3 shared contracts, 4 information roles; active mode provider-per-session-main-only
```

`tomllib` also parses both active profiles and all twelve provider-specific
role files, 14 TOML files total. Current global artifact hashes are:

```text
d4d25a037c53969c50b49816c61122b09eefd1568692b63059e28d085754deaf  config.toml
cdc1851e0565bf10dc24123bde3a9cbdec276911f8ef93bd069e581e7d3badd1  bailian.config.toml
c24f6be54a363453399eb9b15bf6a8b780b8118cbcbd66ca1c12e59c68600519  tests/test_agent_matrix.py
3794160d4833b595790eb1160bb6db67568521abbe5091b0123499b70d44e8db  scripts/validate_agent_matrix.py
```

## Remaining concerns

- Parent `--json` does not expose successful spawn receiver IDs in this CLI
  build; persisted child rollouts are required for backend-grounded evidence.
- The temporary-home runs warn that PATH helper aliases are not created under
  `/tmp`. The probes still launch through the existing `codex` executable and
  record complete parent and child rollouts.
- Native mode should be reconsidered only after a Codex runtime change and a
  new gate that proves readable task delivery and readable child output for
  Qwen same-provider and both cross-provider directions, not merely correct
  backend selection. The twelve inactive TOMLs preserve the retry inputs.
- Both corrected and superseded raw probe trees remain preserved through final
  review.
