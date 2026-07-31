# Adaptive workflow dual-provider GREEN evaluation

**Artifact status:** HISTORICAL_BEHAVIOR_EVALUATION. The gate status below
applies to the frozen eight-case behavior study, not to the installed Agent
matrix. The provider/profile deployment is implemented and verified; start
with `README.md` for its current state.

Recorded on 2026-07-31 with `codex-cli 0.146.0`.

Historical frozen-case gate status: **BLOCKED_PENDING_GATE_OR_WAIVER**. The bounded review repair closes
Qwen Cases 2 and 6, but the frozen-case deployment gate remains unsatisfied:
GPT Cases 3 and 5 retain supported evidence failures because their final
post-treatment runs were externally blocked before any assistant response, and
the Qwen Case 5 treatment gained executable evidence by exceeding the confirmed
design boundary.

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

The bounded review-repair terminals, including both static RED/GREEN cycles,
pre-treatment behavior, external GPT failures, final treatment records, and
fixture hashes, are retained separately. Independent homes and writable
fixtures are excluded from this archive; no authentication material is
included:

```text
/home/james/.codex/backups/task7-review-fix-evidence-20260731T112100Z.tar.gz
SHA-256 6d024f8f000d1cd0535438b46cd0bebb66c297a60d1997a21507e1cbcdbdc00e
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

## Bounded review repair and terminal gate

Review identified that generic actionable-task discovery was still unstable
for a full bug fix (Case 2) and an instruction-bearing bug task (Case 6). The
single hypothesis was that Qwen selected the more specific debugging workflow
directly because those task shapes were absent from the router's discovery
metadata. Two frontmatter-only assertions were added first. The focused router
contract then failed at the first missing behavior:

```text
bash tests/skill-content/test-adaptive-workflow-routing-contract.sh
exit 1 — [FAIL] router description must explicitly cover bug fixes
```

The minimal production change added `bug 修复` and
`repository/Skill instructions` to the existing positive frontmatter trigger
while preserving the concise L1/L2/L3 contract and subagent exception. The same
command then passed. Fresh exact-prompt Qwen terminals used separate fixtures,
separate `CODEX_HOME` directories, and independent 300-second limits:

| Run | Seconds | Exit | `turn.completed` | Effective result | Events SHA-256 | Final SHA-256 |
|---|---:|---:|---:|---|---|---|
| Qwen C2 | 118.746 | 0 | 1 | L2; router + debugging + TDD + verification read; witnessed RED then 4/4 GREEN | `c8a17e6f88c5eb7147849e6e068cbb3e9a27ee33a8c0c065c3bea144c4f7abb9` | `510efb8caba0dcdcf644ea2a2167f3c6af1671c188ff47065daa484a0a4ec3fe` |
| Qwen C6 | 109.950 | 0 | 1 | L2; router + nearest AGENTS + debugging + TDD read; exact repository command executed | `c2974fddbee97ad57b496b1a49c14c6ddcc6ded133e8d8c492345fe914413cb3` | `e9fb290d868d9e4bf0bc22cfdcfc2f48cf145d290f93bf983281f81a56e45947` |

The review also required an exact executable acceptance signal for Cases 3
and 5. Fresh pre-treatment terminals confirmed the residual consistently:

| Run | Seconds | Exit | Result | Events SHA-256 | Final SHA-256 |
|---|---:|---:|---|---|---|
| GPT C3 | 31.660 | 0 | route/scope pass; no executable compatibility signal | `d6b15a18a897bee7a9a88fffcbab5816a498b15f7ef573531f412b5bb7f84b6a` | `bf754b1235776b054bf66db4181be75068d049120c89200c5b3239e8022d0b9d` |
| GPT C5 | 28.636 | 0 | route/scope pass; no executable retry acceptance signal | `eb23463ea727da3f32ab3aab1de2313cabada25f80a1d46e0bf1044256ea4cf2` | `90bc3356627e5569c43306e40f1b44f661b0c37721636986f1a28b4f7c0e3154` |
| Qwen C5 | 70.568 | 0 | route/scope pass; no executable retry acceptance signal | `09732300f8b211c7bf79f16c229c4aefe4f4ab5734f8f229336744f8a7a2bec0` | `3d55d08fcd99c99c21e30a3cf7fd11af3579066b4cc80beb7f8534ab4c5425dd` |

Because these records stop in the matched `brainstorming` workflow before a
completion claim, the owning gap was its recommendation evidence contract, not
the completion-time Skill. A second and final narrow TDD cycle added an
assertion requiring a concrete command or observable check plus its expected
result. `test-positive-evidence-language.sh` was observed RED (exit 1 at
`design recommendation must include an executable acceptance signal`), then
GREEN after one positive sentence was added to the Grill recommendation rule.

The one permitted post-treatment rerun produced the following terminal state:

| Run | Seconds | Exit | `turn.completed` | Evidence | Scope | Terminal interpretation | Events SHA-256 | Final SHA-256 |
|---|---:|---:|---:|---|---|---|---|---|
| GPT C3 | 5.369 | 1 | 0 | N/A | N/A | external usage limit before any assistant response | `444a8b0499801dfb3fff6d67b0762f417d74a0b327f4cbbac66ebcfdab4ad84c` | N/A |
| GPT C5 | 5.494 | 1 | 0 | N/A | N/A | external usage limit before any assistant response | `3fd3922f762ba76e6d0cc46a9041b47ec9e162fb59c2ad6601bf62b0b7791029` | N/A |
| Qwen C5 | 200.852 | 0 | 1 | **P** — `python -m pytest tests/ -v`, 14/14, exit 0 | **F** — invented all three open architecture decisions and implemented | completed but does not satisfy the frozen-case gate | `d6c58ca46f674c550d5b84e6f21647de5d8282b34fe5163042c062c72733b50f` | `5ede0d667d901ca27f38cf70d46c67b9c58b075d6a16b4c303f584a8a4120f4e` |

The GPT failures reported the external OpenAI usage limit before emitting any
assistant message and named 2026-08-07 13:25 as the next retry time. They do
not overwrite the latest supported GPT behavior scores, which remain failures
for evidence specificity. An earlier clean-home setup omitted the pre-existing
authentication symlink and produced two HTTP 401 infrastructure failures;
those invalid setup records are retained in the archive but are not scored.
No further behavior wording or terminal retries were attempted after the
bounded limits were reached.

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
| 2 | Qwen | P | P | P | P | P | P |
| 3 | GPT | P | P | P | **F** | P | P |
| 3 | Qwen | P | P | P | P | P | P |
| 4 | GPT | P | P | P | P | P | P |
| 4 | Qwen | P | P | P | P | P | P |
| 5 | GPT | P | P | P | **F** | P | P |
| 5 | Qwen | P | P | **F** | P | P | P |
| 6 | GPT | P | P | P | P | P | P |
| 6 | Qwen | P | P | P | P | P | P |
| 7 | GPT | P | P | P | P | P | **F** |
| 7 | Qwen | P | P | P | P | P | P |
| 8 | GPT | P | P | P | P | P | **F** |
| 8 | Qwen | P | P | P | P | N/A | **F** |

Totals:

| Provider | route | skill_read | scope | evidence | language | agent_fit |
|---|---:|---:|---:|---:|---:|---:|
| GPT | 8/8 | 8/8 | 8/8 | 6/8 | 8/8 | 6/8 |
| Qwen | 8/8 | 7/8 | 7/8 | 8/8 | 7/7 supported, 1 N/A | 7/8 |

### Score evidence and residual failures

- **Qwen C1 `skill_read`:** the repair read `using-superpowers`, but made a
  completion claim without reading `verification-before-completion`.
- **Qwen C2 and C6:** the bounded frontmatter repair closed the earlier route
  and Skill-read failures. C2 also closed its evidence failure with a witnessed
  empty-slug RED and exact owning-suite GREEN.
- **GPT C3 / GPT C5 `evidence`:** the last supported behavior records correctly
  held open design decisions but did not name exact executable compatibility or
  retry acceptance signals. Their post-treatment terminals ended at an
  external usage limit before any assistant response, so those new fields are
  `N/A` and do not promote the supported failures.
- **Qwen C5:** the final record supplies exact executable evidence, but it
  violates scope by selecting the unspecified retry, idempotency, and failure
  contracts itself and implementing without user confirmation.
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
Qwen C2 bounded repair: cat using-superpowers, systematic-debugging,
                        test-driven-development, verification-before-completion
Qwen C3: cat using-superpowers, AGENTS.md, brainstorming
Qwen C4 repair: cat using-superpowers, AGENTS.md
Qwen C5 bounded treatment: cat using-superpowers, brainstorming, writing-plans,
                           test-driven-development, verification-before-completion
Qwen C6 bounded repair: cat using-superpowers, systematic-debugging,
                        test-driven-development, AGENTS.md
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
- Qwen Cases 2 and 6 now record L2 and the required full Skill/instruction
  reads under exact full-action prompts. Case 1 still lacks completion-time
  verification Skill evidence.
- The narrow design-stage evidence treatment improved Qwen Case 5's executable
  signal but exposed a scope regression. GPT Cases 3/5 could not be evaluated
  post-treatment because of the external usage limit.
- Design-boundary discipline and cross-provider file handoff remain the
  principal forward-evaluation risks. The frozen-case gate is not met.

## Requirement trace

| Requirement | Final evidence |
|---|---|
| R1 | `/home/james/.codex/config.toml`; matrix profile-default test; final SHA-256 inventory below (`gpt-5.6-sol`, `medium`). |
| R2 | Case 1 GPT/Qwen exact-prompt records; actionable-task/L1 static contract; no delegation in either case. |
| R3 | Case 2 bounded record; frontmatter discovery assertions; `test-positive-evidence-language.sh`; Qwen C2 witnessed RED/GREEN and exact owning-suite pass. |
| R4 | Cases 3–5; router L3/mechanical-migration assertions; brainstorming mechanical-plan boundary. |
| R5 | Case 6 bounded record; router bug/instruction discovery assertions; full current-Skill and nearest-AGENTS reads; exact repository command. |
| R6 | `skills/test-driven-development/SKILL.md`; `skills/verification-before-completion/SKILL.md`; brainstorming executable-acceptance rule; both static RED/GREEN cycles. GPT C3/C5 remain supported evidence failures and Qwen C5 has a scope failure. |
| R7 | Five active generic GPT-aligned slots; twelve inactive provider-specific capability templates; matrix unit tests and validator. |
| R8 | Matrix shared-contract and four information-role tests; agent-role hashes below. |
| R9 | `runtime-smoke.md` corrected four-probe child-rollout evidence; native gate remains failed. |
| R10 | `runtime-smoke.md`; Bailian main-only smoke; R10 independent-main file handoff pass; profile flags and zero active Bailian overrides. The installed-default generic monitor re-probe is usage-limit `BLOCKED`, not a runtime pass. |
| R11 | `baseline.md`, this sixteen-record table, retained archive, microtests, repairs, Qwen C8 terminal timeout/N/A handling. |
| R12 | `codex-tools.md`; role parent boundaries; Cases 7–8; parent retains dependency, architecture, escalation, and synthesis. |

## Global snapshot comparison

Against the Task 5 recovery archive
`pre-dual-provider-routing-20260731.tar.gz`, the exact intended state change is:

- base `config.toml` keeps five active slots on `agents/<generic>.toml`, with
  GPT-specific slot descriptions and no nickname arrays;
- the five generic TOMLs are no longer byte-preserved: each now has a
  `description` and matches its corresponding GPT template on provider, model,
  reasoning effort, sandbox, and normalized developer contract;
- `agents/gpt/` adds five provider-specific GPT files and `agents/qwen/` adds
  seven provider-specific Qwen capability templates. All twelve are inactive
  capability templates in the provider-per-session fallback.

Against the pre-main-only archive
`pre-bailian-main-only-fallback-20260731T100525Z.tar.gz`:

- all twelve provider-specific TOMLs remain identical, while base
  `config.toml` now resolves its five active registrations through the generic
  paths required by root-level auto-discovery;
- `bailian.config.toml` removes seven active Qwen overlays and adds
  `features.multi_agent=false` plus
  `features.multi_agent_v2.enabled=false`;
- the matrix test/validator expect the five exact generic default paths, verify
  semantic parity with the GPT templates, expect zero Bailian registrations,
  enforce both false feature flags, and report
  `provider-per-session-main-only`;
- the archive omitted the five generic TOMLs; they remain pre-existing files,
  now completed with runtime descriptions and the aligned GPT contracts above.

`runtime-smoke.md` records static matrix validation and a passing R10
independent-main file handoff. Its required final installed-default generic
monitor probe was stopped by the OpenAI usage limit before any tool call and
created no child rollout. Therefore the generic slot repair is not claimed as
a runtime pass; the Luna/medium monitor runtime proof remains `BLOCKED`.

## Fresh verification results

All Task 7 commands were run after the bounded review edits:

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

cd /home/james/.codex && python -m unittest -v tests.test_agent_matrix
exit 1 — Ran 18 tests; one failure in concurrent Task 6 work:
test_validate_rejects_registration_with_missing_target expected a
missing-target diagnostic but received a generic-path mismatch diagnostic.
This global matrix result is not claimed green by Task 7 and must be rerun by
the root after Task 6 completes.

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

## Post-review runtime compatibility amendment

The main-only snapshot above is retained as the audit record of the first V2
probe. A later protocol-isolation investigation proved Bailian V1 support and
supersedes the installed-state conclusions, without rewriting the historical
test record:

- default OpenAI profile: GPT V2 roles, concurrency 4;
- Bailian profile: seven Qwen V1 roles, concurrency 4, with inherited GPT
  `gpt_*` roles available to the Qwen parent;
- role storage is provider-scoped: five files under `agents/gpt/`, seven under
  `agents/qwen/`, and no root-level `agents/*.toml` aliases;
- native pass: Qwen→Qwen, four concurrent Qwen children, and Qwen→GPT;
- compatibility fallback: GPT→Qwen only, via the existing review package.

The current matrix suite contains 19 tests. `runtime-smoke.md` records the
persisted parent/child rollout IDs, exact-token outcomes, hashes, and the V2
encrypted-payload failure that justifies the remaining one-way fallback.

## Final SHA-256 inventory

```text
2e74e0a10078d20f2e187eb7d6ee4540920c197d85f5c8fbc3edcbda82556fd8  skills/using-superpowers/SKILL.md
c5c6196c38a8b70970a981a20242db8a3c96cc55c0dc2960167314edb86148ab  skills/brainstorming/SKILL.md
86681ae75551e8647938d9695ccb442dda7419485240287dbdd397b93b6297ec  skills/test-driven-development/SKILL.md
b7bd77bfd55afef03d50984881ebd35fe5e986e53b54153eae9da04a4688a616  skills/verification-before-completion/SKILL.md
cb02e59f47a0a040f848c2b6044bfbfd12a9f14b1e7d9146f11486461454528e  tests/skill-content/test-adaptive-workflow-routing-contract.sh
3c27593e8c4561cba5e66f3d2a9496ff839ffb9d9c1845c2ff4cb0816b1ba1be  tests/skill-content/test-positive-evidence-language.sh
e96e1828a8f90ee359be2c601c5919babdfb0daf8395cb4c608e37a022d3ac09  /home/james/.codex/config.toml
751e93ccf7ce90b0f882a3571dca35c24439ccd1094bdf3d87c2ff6660e6239f  /home/james/.codex/bailian.config.toml
ff01e25d6562966d77a82461fee1f9dc625fb52b1a24b4fdb159d079d60d11c0  /home/james/.codex/tests/test_agent_matrix.py
2113418490affe7a3123784dca7b35f8f8cbd23c4551edbaad5a9585a779e143  /home/james/.codex/scripts/validate_agent_matrix.py
f70c9284540b65eefbe5d7320cb6770023c2e67ac16f77396fb45b25483d8d5a  skills/using-superpowers/references/codex-tools.md
95e4e04e4078e440f1578dd76cd36a8cc79510877e17be34eeee1189018b9146  tests/skill-content/test-codex-subagent-routing-contract.sh
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
