# Dual-provider Codex runtime smoke

**Current verdict:** IMPLEMENTED_AND_VERIFIED. OpenAI uses V2 for GPT→GPT;
Bailian uses V1 for Qwen→Qwen and Qwen→GPT with up to four concurrent child
Agents; GPT→Qwen uses the file handoff. Only provider-scoped `gpt_*` and
`qwen_*` role TOMLs remain.

The initial decision and probe sections below are retained in chronological
order. Their `provider-per-session-main-only` conclusion is superseded by the
later V1 compatibility re-probe and provider-scoped layout refinement. See
`README.md` for the reading order.

Date: 2026-07-31

Runtime: `codex-cli 0.146.0`

Corrected probe root: `/tmp/codex-task6-corrected-20260731T094657Z`

Historical initial decision: `provider-per-session-main-only`

Final-review follow-up: R10 file handoff `PASS`; installed-default generic
monitor re-probe `BLOCKED` by an OpenAI usage limit after the structural fix.

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
| `routine_worker` | `agents/routine-worker.toml` | not registered; main session only |
| `standard_worker` | `agents/standard-worker.toml` | not registered; main session only |
| `task_reviewer` | `agents/task-reviewer.toml` | not registered; main session only |
| `final_reviewer` | `agents/final-reviewer.toml` | not registered; main session only |
| `monitor` | `agents/monitor.toml` | not registered; main session only |

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
At that time the CLI repeatedly warned that five inherited base role
definitions were malformed. The final-review investigation below resolves the
missing-description source, but a post-structural-fix OpenAI probe is blocked
by the account usage gate. The Bailian turn itself still reports multi-agent
disabled and exposes no collaboration call.

## Final-review generic-slot investigation

Artifact root:

```text
/tmp/codex-task6-final-review-20260731T111140Z
```

The initial installed-default probe called the advertised collaboration tool
with `agent_type="monitor"` and `fork_turns="none"`. Its parent rollout is
`019fb7df-b45b-7841-a3f4-156ba15fd084`, uses OpenAI
`gpt-5.6-sol`/`medium`, and records an `agents.spawn_agent` function call.
The router returned `unknown agent_type 'monitor'`; no child was created. The
parent events also contain ten malformed-role errors: each of the five legacy
generic TOMLs was rejected twice because it lacked `description`.

```text
b57d84081e2f996c6a8be4f86edf7a560f40488dc806935cc1564cf7d2e9955d  default-monitor/events.jsonl
c40e4692e0b8307dee676e7beb310e06d55331c884db498d3f7a78e7860ede3b  default-monitor/final.txt
bef0979e285e28ef52bd9b53654c38adf4b0c831b0f8295af52af56f29c7ab86  initial parent rollout
```

A description-only TDD fix made the generic role callable and removed all ten
warnings, proving that root-level auto-discovery owns the active generic name.
It also proved that the original `config_file = "agents/gpt/monitor.toml"`
mapping was not selecting the intended template: child
`019fb7e2-a95c-7f11-bc9b-63da214d2641` ran `gpt-5.6-sol`/`low`, not
Luna/medium, although its task/result channel was readable. This intermediate
result was rejected.

```text
696a1d53a1f35b7687ba977a3a8ea4408297a245fa05a5a5df90045b223329ab  default-monitor-after-fix/events.jsonl
532af9d6066dcf6973c3d5182413710ec0a99b4a1553d20f737eea457e639f15  default-monitor-after-fix/final.txt
5ad8bbe78f4450cbb0d3fb1ee6ba0b9333989c63f903867cd87bd5cf96e4321b  intermediate parent rollout
f736c7773964314c3126956e6cf6814818c713a6db58599698fd48246d0aa4ca  intermediate child rollout
```

The structural candidate now points all five base slots at their active
`agents/<generic>.toml` files. Those files retain generic names while matching
their GPT templates on Provider, model, effort, sandbox, and normalized
developer contract. Matrix RED failed on all three previous mismatches and the
same focused set then passed 4/4.

The required final installed-default monitor re-probe did not reach the tool
router. Root thread `019fb7e6-4238-71d1-9c18-568ffc0ba719` failed before any
function call with the OpenAI usage-limit response and produced no final file
or child rollout. Therefore the structural candidate is statically validated,
but its required Luna/medium runtime proof remains `BLOCKED`, not passed.

```text
8d7cff4e4d17442c785125f410a934c3f6e3d319d66ecc9cadc08e9ad6edafb1  default-monitor-structural-fix/events.jsonl
```

## R10 file-handoff smoke

Verdict: `PASS` for the provider-per-session main-only file protocol.

The stable package is:

```text
/tmp/codex-task6-final-review-20260731T111140Z/review-handoff/repo/.superpowers/review-packages/20260731T111140Z-runtime-contract/
```

It contains a request with bounded Inputs, Output, Stop condition, and parent
decision ownership; an independent Bailian main-session result; and a final
decision written by the already-running independent GPT parent session. The
production contract uses the same stable repository-local paths but never
launches one main session from the other with nested `codex exec`; the CLI was
used here only as a bounded Qwen runtime probe.

| Artifact | SHA-256 |
|---|---|
| Repo-root `review-input.md` | `bd3a8708b19cc004e722204884ebcab102d0c548683658ce560fb3e8271d60db` |
| `request.md` | `67e0053a77188813278706b70ca71f1ac1e45c94615028588a2ba2b352f19110` |
| Qwen `result.md` | `8201a58310d2a14852e0a0f1f3b25d951e73eba4c6ab72efaae21c036e584717` |
| GPT parent `decision.md` | `68cb41bc569e722ab63c25bb6377b3f6a7801b72ef0982240426cc132b16215e` |

Qwen session `019fb7e7-7477-7613-9a32-08df360bfa37` records Provider
`bailian`, model `qwen3.8-max-preview`, effort `xhigh`, and
`multi_agent_version="disabled"`. It read the request and named input, wrote
the required result sections, recommended `REJECT` because `beta` was
`pending`, returned `QWEN_HANDOFF_COMPLETE`, and never created `decision.md`.
Its rollout SHA-256 is
`86f762d72f68d7c7831e9404b68205b18e059f1f103f13075f71987f68d4f0f6`.
The first input read incorrectly treated a repository-relative path as
package-relative; a bounded filename lookup recovered it. The durable contract
now explicitly resolves every Input path from repository root.

A new default-profile CLI turn was unavailable because of the same usage
limit. Instead, the already-running GPT parent main session independently read
the request, repo-root source, and Qwen result, accepted the advisory analysis,
and wrote `decision.md` with the final `REJECT` judgment. This is transparent
runtime evidence for two independent main sessions, not a claim that the
blocked new GPT CLI session succeeded.

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

Before repairing the legacy generic registry, a second fresh snapshot captured
the five active generic TOMLs plus config, validator, and test:

```text
/home/james/.codex/backups/pre-legacy-generic-description-fix-20260731T111307Z.tar.gz
SHA-256 e2d743b64a09511920d0f49e57a8302e2b6bb81df37098b70c7ed7587da6d0d1
```

Task 1 baseline trust onboarding had also written twelve exact temporary
`[projects]` blocks into the global config. The Task 5 archive
`pre-dual-provider-routing-20260731.tar.gz` therefore contains that pollution.
The live config now removes only those exact baseline paths; real-project and
general `/tmp` trust remain. No exact block for the final-review smoke root was
present. `baseline.md` now states this global side effect explicitly.

Final local verification:

```text
python -m unittest -v tests.test_agent_matrix
Ran 18 tests
OK
```

```text
python /home/james/.codex/scripts/validate_agent_matrix.py
Agent matrix valid: 12 roles, 3 shared contracts, 4 information roles; active mode provider-per-session-main-only
```

`tomllib` also parses both active profiles, five active generic roles, and all
twelve provider-specific role templates, 19 TOML files total. Current global
artifact hashes are:

```text
8375c92d63649be07c37fb5656617a9e406932cc80f0b6293b3f9532e9278811  config.toml
cdc1851e0565bf10dc24123bde3a9cbdec276911f8ef93bd069e581e7d3badd1  bailian.config.toml
1022622afb34bc68b5ecfaa82621a1c980c3a0d9380caabc210606f4f34d7f4d  tests/test_agent_matrix.py
b51c7a41f5e75dd07964902190f221fb49da61cc803c1f3093931c5338e799e5  scripts/validate_agent_matrix.py
ad7245c9d468f321cce677ea5ffcc158bb282d98fb439bc118a8cb71333000c2  agents/routine-worker.toml
a0d58b6a94180f34e4c6c5ba48ca3e17dca118e2110c61daf7a77fdfa32f80b9  agents/standard-worker.toml
eb9587b4a57d5f62b85ec674101c0b23baf8a8cae15aa6d095afd42b01b9a0bb  agents/task-reviewer.toml
8871153d88b60acf42e89a7129798c770bc85f4742050b363708d7b1be5d3b55  agents/final-reviewer.toml
cb2da386578bc01e681346e98c5c5ffb2a5707be0cf3e118edbea110f9c812f0  agents/monitor.toml
```

## 2026-07-31 V1 compatibility re-probe

The earlier decision above was correct for Multi-Agent V2 but too broad for
the runtime as a whole. Protocol-isolation probes established this deployed
matrix:

| Parent route | Protocol | Result |
|---|---:|---|
| GPT → GPT | V2 | Supported by the default profile. |
| Qwen → Qwen | V1 | Pass, including four children spawned before the first wait. |
| Qwen → GPT | V1 | Pass; `monitor` resolved to OpenAI `gpt-5.6-luna`, medium. |
| GPT → Qwen | V2 | Fail; the Qwen child receives the task as unreadable `encrypted_content`. |

The final installed-config Bailian four-child parent session is
`019fb862-5635-7433-bc50-e5c3c55731d8`. It spawned `qwen_monitor`,
`qwen_progress_reviewer`, `qwen_document_reviewer`, and
`qwen_context_analyst` before waiting. Their persisted V1 child rollouts
returned `FINAL_QWEN_MONITOR_OK`, `FINAL_QWEN_PROGRESS_OK`,
`FINAL_QWEN_DOC_OK`, and `FINAL_QWEN_CONTEXT_OK`; all four passed and the
parent completed with exit 0.

The final installed-config Qwen→GPT parent session is
`019fb863-0e93-76e0-b013-64b056820672`. Child
`019fb863-28b3-75f3-9149-b7084b4d57c5` records Provider `openai`, model
`gpt-5.6-luna`, effort `medium`, `multi_agent_version="v1"`, a plaintext
`FINAL_QWEN_TO_GPT_OK` task, and the exact result.

| Runtime artifact | SHA-256 |
|---|---|
| Four-Qwen parent rollout | `2ba1b2c4bc66cada9e45256f1b16e04775023127474197e9004b0125215e4ebc` |
| Qwen monitor child | `06641871a186df202e527a464d59145acf3696516a0c2f56dd72b927eb550c77` |
| Qwen progress child | `16f97dac1c5ae7e6cc595d4360263b0bec1f2b94256d3a39a2b57b8847de61ca` |
| Qwen document child | `2c3f364d8296b2c6e5e9f5bc1aac17e989d5ef84a0af6c5826c6e2b14be027d3` |
| Qwen context child | `fdefdc5f99d237027eb5377c97612d66678c82854bf92ef4f112ed6431c405ed` |
| Qwen→GPT parent rollout | `bcfa6129c811d312660e68a3666bb3da32349d404d8ed6312e3962f434c6a1c3` |
| GPT Luna child rollout | `64ea562c1ddf92fd4552e35d16d57a235f2e04fe9c20e5240c9b826180e494dd` |

The installed compatibility policy therefore keeps OpenAI V2 and its five
`gpt_*` roles in the default profile, enables Bailian V1 with seven `qwen_*`
roles and four concurrent children, permits Qwen→GPT through inherited
`gpt_*` roles, and retains the file review package only for GPT→Qwen.

### Provider-scoped role-layout refinement

The final role layout removes the five duplicated `agents/*.toml` aliases.
Only `agents/gpt/*.toml` and `agents/qwen/*.toml` remain. Base `config.toml`
registers `gpt_routine_worker`, `gpt_standard_worker`, `gpt_task_reviewer`,
`gpt_final_reviewer`, and `gpt_monitor`; the Bailian overlay registers the
seven `qwen_*` roles and inherits the five GPT registrations.

Fresh Bailian parent `019fb891-bce9-7372-aa07-82743d79258b` spawned both
provider-specific role families before waiting. Child
`019fb891-e7f0-7b21-9c90-14f5039e2d4b` ran Bailian
`qwen3.8-max-preview`/medium/V1 as `qwen_routine_worker` and returned
`PROVIDER_QWEN_OK`. Child `019fb891-eaaa-7aa0-986f-3909048e4503` ran OpenAI
`gpt-5.6-luna`/medium/V1 as `gpt_routine_worker` and returned
`PROVIDER_GPT_OK`.

Fresh default-profile parent `019fb894-2620-78d3-9b42-cd89e5bc12cf`
also spawned `gpt_monitor`; child `019fb894-4caa-74a1-a1d4-1fa9aafbd672`
records OpenAI `gpt-5.6-luna`/medium/V2 and returned
`GPT_PROFILE_SCOPED_OK`. This confirms the provider-scoped GPT names work from
both the OpenAI parent and the inherited Bailian configuration.

| Provider-scoped smoke artifact | SHA-256 |
|---|---|
| Qwen parent | `30d58f2c6d1a6699ee3f0bf7100755d88598765cbcb64e82d21afc92823fd465` |
| Qwen routine child | `4304c476ce90f2d91d63093bcb2adda407442c307a755c74a82ea89affc3eda2` |
| GPT routine child | `962e87279e7a5feb321ce161ba6f1f62a155feb86cf0baa4fda37c084b7cdd09` |

## Remaining concerns

- Parent `--json` does not expose successful spawn receiver IDs in this CLI
  build; persisted child rollouts are required for backend-grounded evidence.
- The temporary-home runs warn that PATH helper aliases are not created under
  `/tmp`. The probes still launch through the existing `codex` executable and
  record complete parent and child rollouts.
- GPT→Qwen should be reconsidered after a Codex runtime change and a new V2
  gate that proves readable task delivery and child output, not merely correct
  backend selection. The Qwen TOMLs remain active in the Bailian profile and
  available as retry inputs.
- The installed-default generic monitor structural candidate still requires a
  fresh post-limit rollout proving `gpt-5.6-luna`/`medium`; static alignment
  and an earlier wrong-backend child do not substitute for that proof.
- Both corrected and superseded raw probe trees remain preserved through final
  review.
