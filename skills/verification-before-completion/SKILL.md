---
name: verification-before-completion
description: Use before claiming work complete, fixed or passing, accepting delegated results, committing or requesting integration; match each claim to current-workstate evidence.
---

# Verification Before Completion

Ground every completion claim in direct, current evidence.

## 1. Match the Claim to Evidence

Verify that the command output, exit status, and produced artifacts cover the claimed requirement on the **current work state** (including staged, unstaged, and untracked changes):

| Claim | Minimum Sufficient Evidence |
| :--- | :--- |
| **Tests pass** | Test output showing 0 failures on the relevant scope |
| **Build succeeds** | Clean build output and resulting artifact |
| **Bug fixed** | Original symptom resolved and regression check passing |
| **Requirements met** | Inspected behavior and artifacts matching the specification |
| **Delegated work complete** | Coordinator inspection of the actual diff and raw verification output |

- **Proportionality & Reuse**: Use the narrowest check that proves the claim. Reuse valid evidence when the underlying code, inputs, and environment have not changed; run targeted checks for modified or doubtful areas.
- **Contextual Conditions**: When a check covers local unit/integration behavior rather than full platform operation or external data, state that condition alongside the corresponding result.

## 2. Outcome-First Delivery

Report the completed outcome and key evidence directly, closing naturally once the goal is met:

- Lead with what was delivered or fixed and its current usable state.
- Cite the key verification results and modified files or artifact paths.
- State any condition that affects usage or requires a user decision right next to the relevant result, without padding simple deliveries with empty limitation or next-step sections.
- When verification fails or a blocker remains, state the actual status, the specific failure evidence, and the concrete next action.
