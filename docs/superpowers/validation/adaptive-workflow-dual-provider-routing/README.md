# Adaptive workflow and dual-provider routing evidence

Status: **IMPLEMENTED_AND_VERIFIED** on 2026-07-31 with Codex CLI 0.146.0.

## Current installed state

- OpenAI main: `gpt-5.6-sol`, medium, Multi-Agent V2, five `gpt_*` roles.
- Bailian main: `qwen3.8-max-preview`, xhigh, Multi-Agent V1, seven `qwen_*`
  roles plus the inherited five `gpt_*` roles.
- Maximum concurrent child Agents per session: 4.
- Native routes: GPT→GPT, Qwen→Qwen, and Qwen→GPT.
- Compatibility route: GPT→Qwen uses the repository-local review package.
- Role TOMLs live only under `agents/gpt/` and `agents/qwen/`.

The installed configuration and
`/home/james/.codex/tests/test_agent_matrix.py` are the executable source of
truth. The approved design is
`../../specs/2026-07-31-adaptive-workflow-dual-provider-routing-design.html`.

## Reading order

1. Read the approved SPEC for current architecture and decisions.
2. Read `runtime-smoke.md` for current runtime evidence and protocol limits.
3. Read the implementation plan only when investigating how the result was
   produced; superseded branches are historical, not current instructions.
4. Read the remaining validation files only for behavior-evaluation or audit
   work.

## Artifact roles

| File | Role | Status |
|---|---|---|
| `runtime-smoke.md` | Provider/model/protocol runtime evidence | Current evidence plus retained superseded probes |
| `cases.md` | Reusable GPT/Qwen workflow evaluation cases | Reusable test input |
| `baseline.md` | Pre-change RED behavior record | Historical |
| `after.md` | Post-change frozen-case evaluation and review history | Historical; its blocked gate does not mean the installed Agent matrix is blocked |

Historical V2 failures and the earlier main-only decision remain in place for
auditability. The later V1 compatibility sections and this index supersede
those conclusions for current operation.
