# Codex Routing Role Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the standalone Codex routing kit and Superpowers with one capability-based five-role contract without coupling Superpowers to concrete models.

**Spec:** `none - requirements supplied directly and approved in the 2026-07-14 routing review`

**Architecture:** Superpowers owns workflow semantics and selects abstract capabilities. The standalone routing kit owns Codex role identifiers, concrete models, reasoning effort, sandboxing, and optional standalone scheduling guidance.

**Tech Stack:** Markdown skills, TOML Codex configuration, CommonJS adapter, Node test runner, Bash content checks

## Global Constraints

- Codex-only optimization; do not add Claude-specific behavior.
- Superpowers skill text must remain model-family and routing-kit independent.
- Concrete role matrix: Luna high routine worker, Terra high standard worker, Terra high task reviewer, Sol high final reviewer, Terra low monitor.
- Controller, architecture decisions, and escalation remain in the parent.
- `fork_turns` is used only when the active schema exposes it.
- Do not modify `~/.codex` until repository and live-probe verification pass.

---

### Task 1: Standalone Routing Kit Contract

**Files:**
- Modify: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/test/superpowers-adapter.test.js`
- Modify: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/adapters/superpowers.js`
- Modify: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/config.toml.snippet`
- Replace: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/agents/*.toml`
- Modify: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/README.md`
- Modify: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/INSTALL.md`
- Modify: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/AGENTS.routing.md`
- Modify: `/home/james/work/QuantumMisaka/toys/codex-routing-kit/wrapper/spawn-agent-schema.ts`

**Test strategy:** Extend the existing adapter/config suite. It must fail on the old role matrix, then pass only when routing, validation order, concrete role files, parent-default preservation, and Superpowers installation boundaries agree.

**Interfaces:**
- Consumes: `{ mode, role, complexity?, review_scope?, parallel_safe? }`
- Produces: `{ dispatch, agent_type?, fork_turns? }`

- [x] Write and run failing Node tests for the five semantic routes and configuration.
- [x] Implement the minimal adapter, role overlays, and configuration changes.
- [x] Update standalone and Superpowers-aware installation guidance without adding runtime coupling.
- [x] Run `node --test test/superpowers-adapter.test.js`; expect all tests to pass.

### Task 2: Superpowers Abstract Routing Contract

**Files:**
- Modify: `skills/using-superpowers/references/codex-tools.md`
- Modify: `skills/subagent-driven-development/SKILL.md`
- Modify: `skills/dispatching-parallel-agents/SKILL.md`
- Modify: `skills/requesting-code-review/SKILL.md`
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `skills/requesting-code-review/code-reviewer.md`
- Modify: `tests/skill-content/test-codex-subagent-routing-contract.sh`

**Test strategy:** Extend the existing skill-content contract and supplement it with live Codex pressure probes. Static tests own durable text invariants; live probes own actual role selection and effective model evidence.

**Interfaces:**
- Consumes: active `spawn_agent` schema and advertised role descriptions
- Produces: routine implementer, standard implementer, task reviewer, final reviewer, and monitor capability requests

- [x] Update the shell contract so the old two-tier taxonomy fails.
- [x] Define the five abstract roles without concrete model or kit identifiers.
- [x] Align SDD selection, blocked-task escalation, reviewer scope, and prompt headings.
- [x] Run `bash tests/skill-content/test-codex-subagent-routing-contract.sh`; expect pass.
- [x] Run `bash tests/skill-content/run-tests.sh`; expect pass.

### Task 3: Runtime And Installation Verification

**Files:**
- Temporary probes: isolated `CODEX_HOME` and `/tmp` session artifacts only; remove or leave outside both repositories

**Test strategy:** Load the exact routing-kit config in a fresh Codex session, list the five roles, spawn harmless read-only task/final reviewer or monitor probes, and inspect recorded effective model/effort.

**Interfaces:**
- Consumes: routing-kit role files and Codex MultiAgent V2 schema
- Produces: evidence that named roles resolve to the approved concrete model matrix

- [x] Run config parsing and named-role discovery in an isolated `CODEX_HOME`.
- [x] Run read-only live probes and inspect their rollout metadata.
- [x] Review both diffs and confirm actual repositories are clean except intended changes.
- [x] Commit the Superpowers branch only after all verification passes.
- [x] Assess global installation; do not install without a separate explicit action.
