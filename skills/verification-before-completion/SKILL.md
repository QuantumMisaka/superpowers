---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Claim Contract

Before reporting a work-state claim:

1. Name the exact command or observation that can support the claim.
2. Run it fresh and read the complete relevant output and exit code.
3. Compare the result with the claim.
4. If they match, report the claim with fresh evidence.
5. If they do not match, report the actual status, failing check, and next
   actionable step.

Use the narrowest sufficient verification for the claim. A focused test can
prove the changed behavior; a full build claim requires the full build command.

## Claim-to-Evidence Mapping

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

Match the scope and freshness of the evidence to the claim. A previous run
describes a previous work state; a partial check supports only the boundary it
exercised; an agent report becomes evidence after inspecting the resulting
artifacts and running their verification.

## Evidence Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
Evidence gap: "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
Evidence gap: "I've written a regression test" without red-green verification
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
- the narrower statement the evidence supports;
- the next actionable step.

This preserves the boundary between observed results and work still required.

## When to Apply

Apply the claim contract before:

- reporting success, completion, correctness, or passing checks;
- committing, creating a PR, or moving to the next task;
- accepting delegated work as complete;
- reporting satisfaction with a work state.

## Completion Record

For every final work-state claim, name the matching fresh evidence and its
result. Where evidence and claim differ, report the actual status and retain the
failure as the next work item.
