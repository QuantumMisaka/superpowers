---
name: receiving-code-review
description: Use when evaluating code review feedback before changing a worktree, especially when a finding may be unclear, risky, or inconsistent with the current contract.
---

# Receiving Code Review

Verify review feedback against the current implementation, requirements, and callers before modifying the worktree.

## 1. Evaluate Each Finding

1. Read the complete comment and identify the specific behavior, caller, or edge case it raises.
2. Check the current code, approved requirements, compatibility expectations, and existing tests.
3. Classify the item as an actionable fix, an out-of-scope suggestion, or a question needing clarification.
4. Apply valid fixes in a coherent order, running focused checks and inspecting the diff as you go.

If one item requires a product or architectural decision, isolate that item and continue fixing the independent findings that are clear.

## 2. Check Real Callers and Trade-offs

- Confirm whether a suggested abstraction or feature has actual callers in the codebase and justifies its maintenance cost.
- Check platform and version compatibility where relevant.
- Prioritize Critical and Important correctness, security, or regression issues; note Minor suggestions for later when they are outside the current scope.

## 3. Explain Decisions with Code and Evidence

Summarize how each finding was handled using the resulting code and verification output:
- Fixed items: state the change location and passing check. Request another review only if the repair creates a new risk that needs independent judgment.
- Declined or deferred items: state the technical reason (for example, "Legacy callers still pass `null` on this path, so the guard remains; covered by `test_legacy_input`").
