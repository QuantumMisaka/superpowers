---
name: requesting-code-review
description: Use when an implementation has enough risk, scope, or independent judgment value that another reviewer should inspect it before integration.
---

# Requesting Code Review

Review is a risk-control tool. Request it at a meaningful work-package
boundary when the change affects public behavior, security, data, architecture,
multiple owners, or an integration decision. A tiny low-risk mechanical change
may use self-review plus focused verification; policy text and configuration
can change behavior or permissions and are not automatically low risk.

For a plan with several small tasks, group them into a coherent review package;
do not create a review gate for every edit or checklist step. A final review is
appropriate before merge or another external integration when the change is
substantial or high risk.

## Review request

Give the reviewer a concise description, the settled requirements or relevant
plan sections, the exact review scope (revision range or identified dirty
snapshot), and the evidence already collected.
Use [code-reviewer.md](code-reviewer.md) for the prompt shape. The reviewer
should inspect the diff, check real behavior and security boundaries, and cite
findings with file and line references. Resolve the dispatch schema through the
applicable `references/*-tools.md` when the harness exposes one.

## Act on findings

- Fix a valid Critical/Important issue before claiming the package complete.
- Record a Minor for later when it does not affect the approved behavior.
- If evidence disproves a finding, record the reasoning instead of silently
  dropping it.
- Re-review a changed review surface when the fix can alter the original risk;
  a one-line typo or isolated documentation correction needs only its focused
  check.

Do not pre-judge findings or ask for a review merely to satisfy a fixed count.
The purpose is an independent, useful check at the point where it can change
the result.
