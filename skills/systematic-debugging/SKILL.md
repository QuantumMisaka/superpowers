---
name: systematic-debugging
description: Use for non-trivial bugs, test failures or unexpected behavior whose cause is unclear. Obvious typos, syntax errors and known configuration fixes can be handled directly.
---

# Systematic Debugging

Investigate enough to explain the failure and choose a repair. Combine observation, a specific hypothesis, and a discriminating check rather than stacking speculative fixes.

## 1. Observe the Failing Path

Read the error output and stack trace, reproduce the symptom when practical, and check recent changes and actual inputs. Distinguish product defects from environment or test-setup issues before modifying production code.

In a multi-layer system, trace the value or state from producer to consumer and inspect the first point where actual output diverges from expectation. Add temporary diagnostic logging at that transition rather than instrumenting every component, and compare against a working path when helpful.

Example: a request succeeds in a direct local call but fails through a launcher. Inspect the actual arguments, working directory, and environment variables passed across the launcher call before changing the request handler.

## 2. Test a Discriminating Hypothesis

State the likely cause and what observation would distinguish it from an alternative. Run a small, reversible check or experiment while keeping changes separable enough to interpret the result. Remove temporary probes once the cause is clear.

When an experiment disproves the hypothesis, use the new observation to narrow the next check or adjust the diagnostic approach.

## 3. Repair and Verify

Fix the identified cause within the task scope. For behavior changes, use `test-driven-development` so a focused regression test distinguishes the failing state from the repaired behavior; for trivial or non-code fixes, use a direct check that covers the symptom. Verify the original failure is resolved and related checks pass, then report the result with evidence (`verification-before-completion`).

If fixing the root cause requires changing a product or architectural decision, present the diagnosis and options to the user while continuing any independent work.

## Diagnostic References

- [Root-cause tracing](root-cause-tracing.md): trace a bad value backward from symptom to origin.
- [Condition-based waiting](condition-based-waiting.md): synchronize tests on observable states instead of arbitrary sleeps.
- [Defense in depth](defense-in-depth.md): place validation at distinct trust or caller boundaries where needed.
