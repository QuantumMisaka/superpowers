---
name: receiving-code-review
description: Use when evaluating code review feedback before changing a worktree, especially when a finding may be unclear, risky, or inconsistent with the current contract.
---

# Receiving Code Review

Review feedback is input to verify, not an instruction to obey blindly.

## For each finding

1. Read the complete comment and restate the concrete behavior it concerns.
2. Check the current code, requirements, compatibility constraints, and tests.
3. Decide whether it is valid, out of scope, or needs clarification.
4. Apply valid independent fixes in an order that keeps the worktree coherent;
   test each behavior-changing group and inspect the diff.
5. Record a short technical response or ruling, including evidence when
   declining a finding.

If one item is unclear, isolate that item. Continue with other findings whose
scope and intended behavior are clear when they do not depend on the unclear
decision. Pause only the dependent work or a change that could affect security,
data, public compatibility, or authorization.

## Technical checks

- Check whether the suggested feature has real callers before adding it.
- Check behavior on supported platforms and versions when compatibility is at
  issue.
- Keep safety, authorization, and user-requested boundaries intact.
- Treat Critical/Important correctness or security findings as gates; a Minor
  can be recorded for later when it does not affect acceptance.

Useful responses are factual: “The caller still relies on the legacy path, so
that compatibility branch remains”; “The endpoint has no caller; removing it
keeps the public surface unchanged”; or “This item depends on the unresolved
migration choice and is held while the independent test fix proceeds.”

Do not use performative agreement or copy a reviewer's rationale as proof. The
current code, focused checks, and the approved requirement decide the result.
