# Adaptive workflow dual-provider GREEN evaluation

Recorded on 2026-07-31 with `codex-cli 0.146.0`.

## Method and retained evidence

The eight frozen prompts were supplied as command arguments from outside the
fixtures. Each provider/case used a fresh fixture and a fresh `CODEX_HOME`.
Fixtures contained only the current installed Superpowers Skills, a nearest
`AGENTS.md`, and the minimum files needed by the premise. They did not contain
`cases.md`, any rubric or baseline/GREEN result, the approved adaptive spec or
plan, or an SDD task brief. Runs used `--ephemeral --json`,
`--sandbox workspace-write`, separate stdout/stderr/final-response files, and
no more than four concurrent sessions.

Cases 1–7 had a configured 300-second limit; Case 8 had 600 seconds. The Qwen
Case 8 wrapper sent `TERM` at the 600-second bound and returned exit 124 after
CLI termination cleanup, at 650.176 seconds wall time. It emitted no
`turn.completed` and no final response, so unsupported fields are `N/A`; its
action trace is not rewritten as a completed answer.

Raw prompts, JSONL, stderr, timestamps, exits, final messages, fixture
before/after hashes, wording microtests, and repair reruns are retained in:

```text
/home/james/.codex/backups/task7-green-evidence-20260731T182035.tar.gz
SHA-256 2448c2d25041d2c54c490b5412b34421a757e22cd12d90730cd6243b0dd1441b
```

The default profile resolved to OpenAI `gpt-5.6-sol` at `medium`; the Bailian
profile resolved to `qwen3.8-max-preview` at `xhigh` with Agent tooling
disabled. Installed catalogs declare context windows of 272000 at 95% for GPT
and 983616 at 95% for Qwen, yielding effective windows of `258400` and
`934435`. The larger Qwen window supports a local capability-routing
hypothesis for long-context/document work; specialization remains an empirical
local hypothesis, not a universal model claim.

## Initial sixteen terminal records

| Run | Start → end | Seconds | Exit | `turn.completed` | Final bytes | Events SHA-256 | Final SHA-256 |
|---|---|---:|---:|---:|---:|---|---|
| GPT C1 | `18:20:35` → `18:21:17` | 41.113 | 0 | 1 | 221 | `dc4b8eb4ff573195e4c15dc111518bb4b5d2b900dcdd7f0e6f41d7e397440f5c` | `fe20446abf5bbdcd93ae0d2908160ae472f7c398beccb9155157d6f38ed650a4` |
| GPT C2 | `18:20:35` → `18:22:23` | 107.724 | 0 | 1 | 496 | `90e3e2559d6a6a03510a41e40a29ce57e0d3d6cf70294c3808239325192a30a0` | `022d6961aea4b9af17dbbb1a8e72728c354abd0fc40f664cafcc61eab05f3553` |
| GPT C3 | `18:20:35` → `18:21:06` | 30.458 | 0 | 1 | 327 | `9bff244374a52d00a31cabf7939e542883c1007cfced741e7b5aa853e9e5f233` | `a8fdd54add8b2df2879e0a29d682ffe24c4f51d70cb6d327a01283b5900bf450` |
| GPT C4 | `18:20:36` → `18:20:49` | 13.964 | 0 | 1 | 90 | `2880386312f1d6834c5a3fa8f43b359130a255b16d3e1f6dc35d6d1634cc2622` | `095e3d093ca143d270e888664f991d70f350443986c5a70c4f2e255afe201d58` |
| GPT C5 | `18:22:27` → `18:22:53` | 26.062 | 0 | 1 | 404 | `747b95bfcd4479dbced72dbe78cc222427cfe631dfed1c8d9c21daa55072bcbe` | `2dcdc8996f82781081c311d98664d6524bc3c6925a29105641c61f0658df0875` |
| GPT C6 | `18:22:27` → `18:22:48` | 20.590 | 0 | 1 | 778 | `3d844ba0bed04cd9e2c61ebe8dca8863e4bc6b61a8b9f947dddcdb0bb8306bbf` | `3d7a14f2665739267a88553ee19fdbd90490dc869ed9ecf29eb1cbdc198df46c` |
| GPT C7 | `18:22:27` → `18:23:09` | 41.932 | 0 | 1 | 910 | `9ea75aecd9d100cef9b624e226407c49c9addcd7039af287b91beb4c7b48797c` | `a2aad3f24cdb924e0f711c1abff81a566fbc645c8e2536150c8ad4109fe83849` |
| GPT C8 | `18:23:05` → `18:25:50` | 165.405 | 0 | 1 | 959 | `deac374c2657dd6e2790104e9b5cd303b305d31931aa7f4a7babedb9ccfd3bac` | `5a824ac49c89595f7d08fbc16ac5b17152d2166adf16d3c181baf8ff6bd18894` |
| Qwen C1 | `18:23:05` → `18:24:42` | 97.130 | 0 | 1 | 865 | `e9c1cefa68f0e8b28f3eb8ecdba701e2a7cf1206f72c58d888b0724a6cdb977c` | `1f5e81d81158fce7068ef60d70c76179b0c5834515f464780016788528799b8c` |
| Qwen C2 | `18:24:22` → `18:26:22` | 120.057 | 0 | 1 | 1213 | `ebffb6a74ac1e182c4b1eb637eb56b18591b1ddebebed4272b2b7bd4b63d363e` | `7eb29e319b474c8ceac721237683a46e8496c176abf496dd1d9d68e85a5d132a` |
| Qwen C3 | `18:24:22` → `18:25:32` | 69.257 | 0 | 1 | 2214 | `bca5f4decd31cf794718825c2c8b2a4885799b961b624cb44e0dc4934e8b5838` | `f308d1faea9b2427844288e5ab7495153239106242d57e97c4a90f39cc131288` |
| Qwen C4 | `18:25:40` → `18:28:07` | 147.119 | 0 | 1 | 2017 | `75c7f48c4db232bad32663bc0b7e6f94483ba888169217caefd3d6633c056bac` | `550c3027a44b60c1fd368a1ac0c14a51f2af3411bbbe28aa0c5767b38120090b` |
| Qwen C5 | `18:25:40` → `18:26:31` | 50.486 | 0 | 1 | 1611 | `cf3a8029d7138958d8213c69a7b90cd507d2e42b213b36cbb2aecdf1ea25e41c` | `d6d4513de468cbfafdc0da8576b5114e8998e23d8589b5bf30a6c2d881012bfe` |
| Qwen C6 | `18:27:00` → `18:27:34` | 33.860 | 0 | 1 | 1672 | `b6f4ebb952069b03ee64549519fbc5cc2ea45a00ce5a39f3a21ea461831ee168` | `24c222418c2d3db87de4c01adabb1014a50528d9b17acec92c4c9a7415f08f32` |
| Qwen C7 | `18:27:00` → `18:31:01` | 241.587 | 0 | 1 | 4094 | `8f8aa901ba2466e18551892a1d0eed29d3ed6b2edfe5feaa11580ad77423787c` | `2b74632bae2af5b6c3dcca8e9bdddf5b846cd02529f352f97bd889882ec1b74e` |
| Qwen C8 | `18:27:00` → `18:37:50` | 650.176 | 124 | 0 | 0 | `d2ffa8915875d282761dc4a29595b216f2a098eaaaa6f72f3891bfa6f3edb4e8` | `N/A` |

## Observed failure, microtests, and minimal repair

The initial run exposed two related failures:

1. **Missing structural slot:** GPT often followed the correct workflow but did
   not explicitly record `L1`, `L2`, or `L3`; Qwen Cases 1/2/6 also skipped the
   router under full-action pressure.
2. **Wrong conditional route:** Qwen Case 4 classified a twelve-file mechanical
   migration as L1 because it prioritized private/local reversibility over the
   implementation-plan and repository-verification boundary.

Before editing production text, five fresh Qwen treatment microtests used the
candidate router wording and a separate no-guidance control used the current
text. All treatment runs exited 0 and selected the intended routes:

| Microtest | Intended | Observed | Router read | Result |
|---|---|---|---|---|
| Config value | L1 | `工作流：L1` | full `cat` | Pass |
| Parser bug | L2 | `工作流：L2` | full `cat` | Pass |
| Persisted schema | L3 | `Workflow: L3` | full `cat` | Pass |
| Twelve-file migration | L3 plan, no design | `工作流：L3 (writing-plans)` | full `cat` | Pass |
| Instruction precedence | L2 | `工作流：L2` | full `cat` | Pass |
| No-guidance control, migration | L3 | `L1 敏捷修改` | full `cat` | **Fail as expected** |

The candidate adds one observable route slot, strengthens the actionable-task
trigger, and maps multi-file mechanical migrations requiring decomposition,
checkpoints, or repository-wide verification to L3 `writing-plans` without
`brainstorming`. A static regression contract was added first and observed RED
(exit 1 at `actionable-task trigger`), then the identical candidate wording
turned it GREEN.

Exact-prompt full repair reruns were retained for every initial route failure.
All GPT repair runs selected the expected level. Qwen Cases 1 and 4 also did;
Qwen Cases 2 and 6 still skipped `using-superpowers` in the full-action prompt
despite passing routing-only microtests. This is retained as a residual
provider/prompt-pressure failure rather than prompting an unbounded rewrite.

| Repair | Seconds | Exit | Observable route | Events SHA-256 |
|---|---:|---:|---|---|
| GPT C1 | 38.227 | 0 | L1 | `7dd3fa5c03a7e67dcadbe4c3df7f2597c26b89b5226f2777babfebcc2b50c56a` |
| GPT C2 | 73.876 | 0 | L2 | `bca646e9625d97927b5b64d547a1b1627d6c289ce222a626114f1fbb542f9887` |
| GPT C3 | 26.569 | 0 | L3 | `8dedd2c5e6ff5fbc4d9a9894bb47294a71863030f5a37bd308d1bc0ca4a81fb2` |
| GPT C4 | 13.242 | 0 | L3 | `81b981b964ced70416248f4c0ab5aa85fb0b05a6c20c96dee401fad3c5ec9dfa` |
| GPT C5 | 24.561 | 0 | L3 | `7f03c32f59b750e6cd6c0e06d4ee066d0af53f80e5e475df162d6e4d473a852a` |
| GPT C6 | 17.064 | 0 | L2 | `772e822282d99d2c967d41a2bbfd3ccaa1cac42c7f12c5129a7f67d72b93a992` |
| GPT C7 | 55.513 | 0 | L3 | `e04ae4ca8e52c8c01d66387585a66a40d9cac26296603818de7d8fd2576f6695` |
| GPT C8 | 533.256 | 0 | L3 | `db7339d2772db07e08b91ff7184ac56768fd1dac976c9765361a1a9055ce8adf` |
| Qwen C1 | 60.067 | 0 | L1 | `47ac648cac11c2b0b425f8ef8d58813ab36517036d7bf8fafbd6dd1e1195c4fc` |
| Qwen C2 | 54.418 | 0 | none | `81431f43f7c9e07add980e8eb87feea166fb2327f52763c47013694706639aff` |
| Qwen C4 | 38.618 | 0 | L3 | `15235684a4fa66f9e5174285758fbe09f4da9814382ae78e38c25ebc969654b6` |
| Qwen C6 | 58.897 | 0 | none | `1a5923635ab5a630c9cd2c497de2e06ad7e77c8a6463823bd9ae2fbce2411d36` |

## Effective per-case scores

`P` = supported pass, `F` = supported failure, `N/A` = insufficient terminal
evidence. For repaired fields, the exact-prompt repair record supersedes the
initial field. Route judgments use observable assistant messages, never keyword
counts inside loaded Skill text.

| Case | Provider | route | skill_read | scope | evidence | language | agent_fit |
|---:|---|---|---|---|---|---|---|
| 1 | GPT | P | P | P | P | P | P |
| 1 | Qwen | P | **F** | P | P | P | P |
| 2 | GPT | P | P | P | P | P | P |
| 2 | Qwen | **F** | **F** | P | **F** | P | P |
| 3 | GPT | P | P | P | **F** | P | P |
| 3 | Qwen | P | P | P | P | P | P |
| 4 | GPT | P | P | P | P | P | P |
| 4 | Qwen | P | P | P | P | P | P |
| 5 | GPT | P | P | P | **F** | P | P |
| 5 | Qwen | P | P | P | **F** | P | P |
| 6 | GPT | P | P | P | P | P | P |
| 6 | Qwen | **F** | **F** | P | P | P | P |
| 7 | GPT | P | P | P | P | P | **F** |
| 7 | Qwen | P | P | P | P | P | P |
| 8 | GPT | P | P | P | P | P | **F** |
| 8 | Qwen | P | P | P | P | N/A | **F** |

Totals:

| Provider | route | skill_read | scope | evidence | language | agent_fit |
|---|---:|---:|---:|---:|---:|---:|
| GPT | 8/8 | 8/8 | 8/8 | 6/8 | 8/8 | 6/8 |
| Qwen | 6/8 | 5/8 | 8/8 | 6/8 | 7/7 supported, 1 N/A | 7/8 |

### Score evidence and residual failures

- **Qwen C1 `skill_read`:** the repair read `using-superpowers`, but made a
  completion claim without reading `verification-before-completion`.
- **Qwen C2:** no Skill-read command occurred in the full repair run; it did
  not record L2 and fixed the code without first adding/observing the requested
  empty-slug regression RED.
- **GPT C3 / GPT+Qwen C5 `evidence`:** the responses correctly held open design
  decisions, but did not name an exact executable compatibility/retry
  acceptance signal.
- **Qwen C6:** it read `systematic-debugging` and used the exact repository
  command, but skipped the session router and never recorded L2.
- **GPT C7 / GPT C8 / Qwen C8 `agent_fit`:** under
  provider-per-session-main-only, the score requires a named on-disk handoff to
  an independent other-provider main profile. These outputs did not complete
  that cross-provider handoff; no Qwen child was expected.
- **Qwen C8 `language`:** the timed-out record has useful action evidence but
  no complete user-facing response, so the field is `N/A`.

Representative complete-response evidence and all intermediate assistant
messages are in the retained archive. Relevant exact Skill-read commands
include:

```text
GPT C2: cat/sed using-superpowers, systematic-debugging, test-driven-development
GPT C6: cat AGENTS.md, using-superpowers, systematic-debugging
GPT C7: cat using-superpowers, executing-plans, subagent-driven-development
GPT C8: read using-superpowers, writing-plans, verification-before-completion
Qwen C2 repair: []
Qwen C3: cat using-superpowers, AGENTS.md, brainstorming
Qwen C4 repair: cat using-superpowers, AGENTS.md
Qwen C6 repair: cat systematic-debugging only
Qwen C7: cat using-superpowers, executing-plans,
         subagent-driven-development, dispatching-parallel-agents, AGENTS.md
Qwen C8: cat using-superpowers, AGENTS.md, writing-plans, brainstorming,
         verification-before-completion
```

## Baseline comparison

The RED baseline remains qualitative because several Task 1 fields were
contaminated and explicitly `INVALID/N/A`. Those fields are not promoted into
a numeric before/after delta. Clean comparable failure classes improved as
follows:

- GPT's missing explicit level improved from all eight initial forward runs
  lacking a level to all eight repairs recording the expected level.
- Qwen's mechanical-migration route improved from L1 to L3 with no design
  phase, matching the frozen Case 4 contract.
- Qwen Cases 1/2/6 still demonstrate unstable router invocation under full
  action; Case 1 records L1 after repair, while Cases 2/6 remain failures.
- Evidence specificity and cross-provider file handoff remain the principal
  forward-evaluation risks.

## Requirement trace

| Requirement | Final evidence |
|---|---|
| R1 | `/home/james/.codex/config.toml`; matrix profile-default test; final SHA-256 inventory below (`gpt-5.6-sol`, `medium`). |
| R2 | Case 1 GPT/Qwen exact-prompt records; actionable-task/L1 static contract; no delegation in either case. |
| R3 | Case 2 records; `test-positive-evidence-language.sh`; TDD RED/GREEN contract. Qwen C2 remains a disclosed behavior failure. |
| R4 | Cases 3–5; router L3/mechanical-migration assertions; brainstorming mechanical-plan boundary. |
| R5 | Case 6 records; router current-Skill and nearest-AGENTS assertions; Qwen C6 remains a disclosed behavior failure. |
| R6 | `skills/test-driven-development/SKILL.md`; `skills/verification-before-completion/SKILL.md`; positive-language contract. |
| R7 | Twelve provider-specific TOMLs; matrix unit tests and validator; five active GPT slots plus seven inactive Qwen templates in fallback mode. |
| R8 | Matrix shared-contract and four information-role tests; agent-role hashes below. |
| R9 | `runtime-smoke.md` corrected four-probe child-rollout evidence; native gate remains failed. |
| R10 | `runtime-smoke.md`; Bailian main-only smoke; profile flags and zero active Bailian overrides; validator reports provider-per-session-main-only. |
| R11 | `baseline.md`, this sixteen-record table, retained archive, microtests, repairs, Qwen C8 terminal timeout/N/A handling. |
| R12 | `codex-tools.md`; role parent boundaries; Cases 7–8; parent retains dependency, architecture, escalation, and synthesis. |

## Global snapshot comparison

Against the Task 5 recovery archive
`pre-dual-provider-routing-20260731.tar.gz`, the exact intended state change is:

- base `config.toml` still has five active slots, retargeted from the five
  unchanged generic TOMLs to `agents/gpt/*.toml`, with GPT-specific
  descriptions and no nickname arrays;
- the five legacy generic TOMLs are byte-preserved;
- `agents/gpt/` adds five provider-specific GPT files and `agents/qwen/` adds
  seven provider-specific Qwen capability templates.

Against the pre-main-only archive
`pre-bailian-main-only-fallback-20260731T100525Z.tar.gz`:

- base `config.toml` and all twelve provider-specific TOMLs are identical;
- `bailian.config.toml` removes seven active Qwen overlays and adds
  `features.multi_agent=false` plus
  `features.multi_agent_v2.enabled=false`;
- the matrix test/validator expect zero Bailian registrations, enforce both
  false feature flags, and report `provider-per-session-main-only`;
- the archive omitted the five legacy generic TOMLs; comparison with the Task
  5 archive proves they are preserved pre-existing files, not Task 6 additions.

## Fresh verification results

All Task 7 commands were run after the residual router/test edit:

```text
bash tests/skill-content/test-adaptive-workflow-routing-contract.sh
exit 0 — all adaptive workflow routing checks passed

bash tests/skill-content/test-positive-evidence-language.sh
exit 0 — all positive evidence language checks passed

bash tests/skill-content/test-codex-subagent-routing-contract.sh
exit 0 — all Codex subagent routing contract checks passed

bash tests/skill-content/run-tests.sh
exit 0 — design artifact, Codex routing, adaptive routing, and positive
evidence-language contracts passed

python -m unittest -v /home/james/.codex/tests/test_agent_matrix.py
exit 0 — Ran 15 tests; OK

python /home/james/.codex/scripts/validate_agent_matrix.py
exit 0 — Agent matrix valid: 12 roles, 3 shared contracts,
4 information roles; active mode provider-per-session-main-only
```

Additional final checks:

```text
git diff --check
exit 0

HTML/plan/after contract reader
exit 0 — 11 HTML ids, 11 internal links, R1-R12 present,
no forbidden placeholders

tomllib profile/role parse
exit 0 — 14 files

catalog effective-window calculation
gpt-5.6-sol: 272000 × 95% = 258400
qwen3.8-max-preview: 983616 × 95% = 934435
```

## Final SHA-256 inventory

```text
77ec2cad636472f11a7a48228381191e0a90d54fca27301dd1081f8005bb99dc  skills/using-superpowers/SKILL.md
192dc7fb82c4602369a5855aa01f5861cc5a2a531a47101a443cb9f03261f6e3  skills/brainstorming/SKILL.md
86681ae75551e8647938d9695ccb442dda7419485240287dbdd397b93b6297ec  skills/test-driven-development/SKILL.md
b7bd77bfd55afef03d50984881ebd35fe5e986e53b54153eae9da04a4688a616  skills/verification-before-completion/SKILL.md
d4d25a037c53969c50b49816c61122b09eefd1568692b63059e28d085754deaf  /home/james/.codex/config.toml
cdc1851e0565bf10dc24123bde3a9cbdec276911f8ef93bd069e581e7d3badd1  /home/james/.codex/bailian.config.toml
3794160d4833b595790eb1160bb6db67568521abbe5091b0123499b70d44e8db  /home/james/.codex/scripts/validate_agent_matrix.py
94f0d3d1e991a5a10de0954094c71efed7682206436b4a9ef9e2ccdfbe3fc69c  /home/james/.codex/agents/gpt/final-reviewer.toml
6a7178049d0617e11bb6c8db26eb07b9c5815cd292e7d9846b6cddbe0fe3476b  /home/james/.codex/agents/gpt/monitor.toml
ac107305e40aa5bfc0dce00e368cf1de0b651ced9d21e38c6aa0b2b03c906e8c  /home/james/.codex/agents/gpt/routine-worker.toml
4a7911e58902c0bad1e0a4604b1c402e0477c378022f69ea7629b68a2037fe29  /home/james/.codex/agents/gpt/standard-worker.toml
5e59fec8a87cdbd1b3012e3b8528d2ae4085396abbdab08d25391b38c1d9342c  /home/james/.codex/agents/gpt/task-reviewer.toml
aa1c11f6815d9ad07720bc6535cedd93647ee4b3d63c176809e7fd18249a166e  /home/james/.codex/agents/qwen/context-analyst.toml
ff2e4524df06c72c4d39146d4e79d1ad07a0de53b880de0174781317032d24d6  /home/james/.codex/agents/qwen/document-reviewer.toml
d46c6f4b98987b76fcd89ca8cb2625e506b5f9cc4eb64bc851c1d02c9ae8af8a  /home/james/.codex/agents/qwen/document-writer.toml
06298ed0cd8c98f9186c189a444ca3d6c18dc8c8a75acf8fbc7f0d34fc39848f  /home/james/.codex/agents/qwen/monitor.toml
67f37a5cd3f67afa19934bd7680638849545a10504d89041e6a33c1b03006593  /home/james/.codex/agents/qwen/progress-reviewer.toml
01d1e58e48a211b57527d3340976b95edb60ea1d76d6f699c9db1773c08f2097  /home/james/.codex/agents/qwen/routine-worker.toml
99a4e73fdc343346b7dd2985458d37d7ab517e9438a84171092514132afc97bb  /home/james/.codex/agents/qwen/standard-worker.toml
```
