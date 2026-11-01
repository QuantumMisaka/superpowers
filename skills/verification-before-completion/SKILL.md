---
name: verification-before-completion
description: Use before claiming work complete, fixed or passing, accepting delegated results, committing or requesting integration; match each claim to current-workstate evidence.
---

# Verification Before Completion

Report what the work and its evidence establish. A confident explanation, a
checklist tick or an agent's success summary does not establish completion.

## Match the claim to evidence

Inspect the command or observation, relevant raw output and exit status, and
any produced artifact. Check that they cover the requirement being claimed and
the current work state: an exact revision, or an identifiable dirty scope
including staged, unstaged and new files. HEAD alone does not identify dirty
content. Use existing task records rather than manufacturing a separate ledger.

| Claim | Supporting evidence |
| --- | --- |
| Tests pass | Matching test output with no failures; report the selected scope |
| Build succeeds | Successful build output and the resulting artifact |
| Bug fixed | Original symptom and relevant regression verified on the repair |
| Regression detects the bug | Expected baseline failure and repaired result, not just a passing test |
| Requirements met | Inspected behavior/artifacts against requirements and relevant checks |
| Delegated work complete | Controller inspection of actual changes and the above evidence |

Use the narrowest sufficient check. A focused test does not establish a whole
build; local success does not establish platform operation or scientific
validity. Report material limitations rather than extending the claim.

## Reuse and follow up

Evidence is current when its relevant code, inputs and environment match the
work under review, not when every reviewer reruns the command. Reuse retained
valid evidence. Missing, changed or concretely doubtful inputs call for the
smallest check that resolves the question; changes in unrelated files do not
automatically invalidate it.

For delegated work, read the actual diff and relevant raw results. If a report
is truncated, locate its referenced evidence before assuming it is absent.
An accessible success summary still needs the underlying evidence inspected.

For a historical implementation, isolated baseline/candidate checks can prove
a regression's sensitivity, but cannot be relabeled as test-first execution.
Never revert shared/user changes to reconstruct RED. Behavior-preserving
refactors need relevant baseline/candidate evidence, not an invented failure.

## Report the result

When evidence supports the claim, state the result and the check's scope.
When it does not, report the actual status, first actionable failure or missing
observation, and next step. Retain raw evidence in the existing task context or
artifact when useful for review/recovery; the final answer can summarize it.

Report the delivered behavior and its scope, not the volume of checks. Test
counts, review counts and log size are supporting evidence, not progress.

### Delivery-first report shape

Use this shape unless the project defines a stricter one:

```text
结论：本轮交付了 X / 当前能不能用 / 需要你做什么
证据：最多 3 条，每条一行
未纳入本轮：一句话，不展开完整缺口清单
下一步：一个动作
附录：文件、日志、review 链接
```

Report the delivered increment before the remaining scope. A plan, review
report or handoff counts as delivery only when the user asked for it or the
task is blocked; otherwise it is a process artifact and must be replaced by
the next action. Do not make the reader reconstruct the result from a
workstream-by-workstream account.

Example: “The parser regression passes on this change; the full integration
suite was not run.” This is preferable to inferring system-wide success from a
focused test. An unresolved real acceptance gap stays incomplete even when
unrelated checks pass.
