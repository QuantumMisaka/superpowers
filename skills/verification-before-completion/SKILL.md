---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires current-workstate execution evidence and confirmed output before making success claims; evidence before assertions always
---

# Verification Before Completion

## Claim Contract

Before reporting a work-state claim:

1. Name the exact command or observation that can support the claim.
2. Use evidence produced for the current workstate: the exact revision, or an
   identified dirty snapshot including staged, unstaged, and new files. "Fresh"
   means current-state execution evidence, not that every agent or reviewer
   must rerun the same command. Run it now when no valid retained evidence
   covers the claim.
3. Read the complete relevant raw output and exit code, and locate the
   produced artifact when the check has one.
4. Compare the result with the claim.
5. If they match, report the claim with fresh evidence.
6. If they do not match, report the actual status, failing check, and next
   actionable step.

Use the narrowest sufficient verification for the claim. A focused test can
prove the changed behavior; a full build claim requires the full build command.

## Claim-to-Evidence Mapping

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Unbound or stale run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff plus current-workstate-bound raw output, exit code, and artifacts | Agent reports "success" |
| Requirements met | Requirements mapped to inspected artifacts and relevant execution evidence | Checklist ticks or tests passing alone |

Match the scope and freshness of the evidence to the claim. Output from a
previous run is usable only when its relevant inputs match the current revision
or identified dirty snapshot; otherwise it describes a previous state. A partial check
supports only the boundary it exercised. An agent report becomes evidence
after the controller inspects the resulting artifacts and verifies its raw
command output, exit code, and acceptance coverage.

For delegated work, the controller binds acceptance to the revision or identified dirty snapshot,
retained raw command output, exit code, produced artifact, and the criterion it
covers. A status or success summary alone is not evidence. If this package is
complete and current, consume it without mechanically repeating the full
suite; if it is missing, stale, or raises a concrete doubt, run the smallest
focused check that resolves the gap.

## Evidence Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
Evidence gap: "Should pass now" / "Looks correct"
```

**Regression tests:**
```
✅ Test fails for the missing behavior on baseline → candidate passes the same test
For code already written, compare in an isolated baseline or use a safe targeted
mutation; do not revert shared/user changes or claim retroactive test-first work.
Behavior-preserving refactors use characterization checks on baseline and candidate.
Evidence gap: a passing test alone does not show that it detects the original defect.
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
Evidence gap: "Linter passed" for a build claim
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
Evidence gap: "Tests pass, phase complete" without a requirements comparison
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
Evidence gap: repeating the agent report without inspecting artifacts
```

## Failed Verification

A failing verification command supplies useful status evidence. Report:

- the claim you evaluated;
- the exact command or observation;
- the exit code and first actionable failure;
- the raw output and produced artifact relevant to the check;
- the narrower statement the evidence supports;
- the next actionable step.

This preserves the boundary between observed results and work still required.

## When to Apply

Apply the claim contract before:

- reporting success, completion, correctness, or passing checks;
- committing, creating a PR, or moving to the next task;
- accepting delegated work as complete;
- reporting a positive factual claim about work state.

## Completion Record

For every final work-state claim, name the matching current-workstate evidence
and its result. Where evidence and claim differ, report the actual status and
retain the failure as the next work item.
