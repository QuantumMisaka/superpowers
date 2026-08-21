# Kimi Code Tool Mapping

Skills speak in actions ("dispatch a subagent", "create a todo", "read a file"). On Kimi Code these resolve to the tools below. The upstream `.kimi-plugin/plugin.json` `skillInstructions` carries the base mapping; this reference extends it with the fork's orchestration concerns (multi-agent dispatch, resume, parallel swarm, model routing).

| Action skills request | Kimi Code equivalent |
|----------------------|----------------------|
| Read a file | `Read` |
| Create or replace a file | `Write` |
| Edit a file | `Edit` |
| Run a shell command | `Bash` (background via `run_in_background: true`) |
| Search file contents | `Grep` |
| Find files by name | `Glob` |
| Fetch a URL | `FetchURL` |
| Search the web | `WebSearch` |
| Invoke a skill | `Skill` |
| Ask the user a structured question | `AskUserQuestion` (1-4 questions, 2-4 options each, recommended option first with `(Recommended)`) |
| Task tracking ("create a todo", "mark complete") | `TodoList` (statuses: pending, in_progress, done) |
| Dispatch a subagent | `Agent` — see [Subagent support](#subagent-support) |
| Same-shape batch dispatch | `AgentSwarm` — see [Swarm dispatch](#swarm-dispatch) |

## Instructions file

When a skill mentions "your instructions file", on Kimi Code this is **`AGENTS.md`**. Kimi Code loads `AGENTS.md` hierarchically: project root and deeper directories, the deeper file winning on conflict.

## Personal skills directory

User-level skills live at **`~/.kimi-code/skills/`** or the cross-runtime alias **`~/.agents/skills/`** (shared with Codex and other harnesses). Each skill is a directory containing a `SKILL.md` with `name` and `description` frontmatter.

## Subagent support

Kimi Code dispatches subagents through the `Agent` tool: `prompt` (the complete task contract), a short `description`, and an optional `subagent_type`. A subagent starts with zero context — the prompt must be self-contained: state the goal, hand over known paths and specifics, and name the acceptance evidence.

| Subagent type | Use for |
|---|---|
| `coder` (default) | Implementation and review dispatches — the only type with file-editing tools. Filled superpowers templates (implementer, task-reviewer, code-reviewer) go here. |
| `explore` | Read-only codebase exploration that would take several searches |
| `plan` | Read-only implementation planning and architecture design |
| `agent` | General dispatch needing the full toolset (background shells, cron, nested subagents) |

Skills dispatch with `Subagent (…):` and either reference a `*-prompt.md` template or supply an inline prompt. On Kimi Code, fill every template placeholder and pass the result as `Agent`'s `prompt`; never pass a Claude-style `general-purpose` as `subagent_type`.

### Fix rounds: resume, don't respawn

`Agent` accepts a `resume` parameter with a prior agent's id: the resumed agent keeps its full context. Subagent-driven development's fix rounds 1-3 resume the original implementer this way — the harness supports it, so the "fresh implementer carrying the report file" fallback is not needed. Record the agent id from each dispatch result.

### Foreground and background

Default to a foreground dispatch when the next step needs the result — the result returns directly. Use `run_in_background: true` only when independent work can proceed meanwhile; the completion then arrives on its own as a later message. Never launch in the background and immediately poll for the result.

### Waiting on children

There is no `wait_agent` poll loop on Kimi Code. A background subagent's completion is pushed into the session automatically; `TaskOutput` gives a non-blocking snapshot for a deliberate progress check, and `TaskStop` cancels. Keep doing local work (ledger, review packaging) while children run; reconcile finished children from their delivered results, not from polling.

## Swarm dispatch

`AgentSwarm` fans out one prompt template over many inputs: write `prompt_template` with a `{{item}}` placeholder and pass `items`; each item becomes one subagent running the same task shape.

- Use it for `independent-parallel` work once the calling skill has established independent domains and disjoint writes — same-shape only. Differently-shaped independent tasks go to multiple `Agent` calls in one response instead.
- Constraints: at least 2 `items` (a single task uses `Agent`), at most 128, and the `AgentSwarm` call must be the only tool call in its response.
- `resume_agent_ids` continues existing subagents (failed or timed out) alongside or instead of new items.

The subagent-driven-development implement-review-fix cycle stays serial on Kimi Code: one foreground `Agent` per stage. Never dispatch implementation subagents in parallel, via swarm or otherwise.

## Model routing on spawns

Kimi Code's `Agent`/`AgentSwarm` schema exposes **no `model` or effort field**; every subagent inherits the session's model. Per the Model Selection rules, specify a model only when the dispatch schema exposes one — here it does not, so omit model routing entirely. `subagent_type` selects the toolset, not the model; choose it by the work's read-only vs. editing nature. Controller judgment, unresolved architecture decisions, and escalation stay in the parent.
