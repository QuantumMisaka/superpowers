---
name: using-superpowers
description: Use at session start to choose the lightest workflow that safely fits the request
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

# Using Superpowers

Classify the request before acting. Do not turn routine work into ceremony.

## Routes

| Request | Route |
| --- | --- |
| Question, explanation, lookup, or command output with no change requested | **Direct:** answer or inspect directly. |
| Small, clear change with known acceptance criteria | **Lightweight delivery:** inspect the relevant code, use `test-driven-development` for behavior changes, then `verification-before-completion`. Do not require brainstorming or a written plan. |
| Bug, failing test, flaky behavior, or unexplained symptom | **Investigation:** use `systematic-debugging` before choosing a fix, then the lightweight delivery route. |
| New behavior with meaningful product, UX, architecture, or cross-system decisions; unclear success criteria; or an explicit design request | **Full design:** use `brainstorming`; after design approval, use `writing-plans` for multi-step implementation. |

Security posture, public API/schema/persisted-data, dependency, and destructive
changes are never lightweight unless an approved spec already fixes the decision.

A clear multi-step task may use `writing-plans` without repeating
`brainstorming`. For a bounded ambiguity, inspect available facts and ask only
the blocking question; do not promote it to full design automatically.

<EXTREMELY-IMPORTANT>
Once a route selects a skill, invoke that skill before taking the action it
governs. Selected skill instructions are mandatory. Routing itself must remain
lightweight.
</EXTREMELY-IMPORTANT>

An explicitly named skill takes priority unless the user is asking whether it
applies. User and repository instructions take precedence over skill defaults.

## Order

When several skills apply:

1. Choose the route.
2. Apply its process skill (`brainstorming` or `systematic-debugging`).
3. Apply implementation skills such as `test-driven-development`.
4. Use `verification-before-completion` before success claims.

Read a matching file under `references/` only when tool substitutions for the
current harness are needed.
