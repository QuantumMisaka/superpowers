---
name: test-driven-development
description: Use for applicable feature and bugfix behavior tests; use baseline/candidate evidence for behavior-preserving refactors. Choose checks by observable impact, not file type.
---

# Test-Driven Development

Protect the behavior the user needs at its nearest stable boundary. For a
feature or bugfix that can be tested reliably, test-first is the default:
observe the missing behavior, implement it, then verify the result. The point
is a test that catches a real error, not a RED record for every function or file.

## Choose the evidence path

- **Changed behavior:** add or extend a focused regression, observe the expected
  baseline failure, implement the change and observe the test pass.
- **Behavior-preserving refactor:** inspect relevant coverage and compare the
  existing baseline and candidate checks. Do not invent a failing test.
- **Prose, formatting or trivial forwarding:** use an appropriate direct check
  or existing consumer coverage. Add a test only for an independently meaningful
  validation, transformation, default, side effect or other behavior.
- **Configuration:** classify by effect. Runtime behavior changes need behavior
  evidence; metadata-only changes may need a parser or build check.
- **Agent instructions:** assess routing and semantics through review or bounded
  consumer scenarios; machine-consumed fields may need structure checks. Exact
  wording assertions do not establish that an agent follows the guidance.

For prototypes, generated artifacts, unavailable test infrastructure or costly
external dependencies, choose a suitable focused regression, integration check,
controlled double or observation for the task. Explain a material limitation;
do not use missing infrastructure to declare important behavior verified.
User or project requirements for a particular test strategy remain applicable.

When writing or reorganizing tests, use [writing-good-tests.md](writing-good-tests.md)
for boundary selection, doubles and test maintenance. Group related cases in
an existing owning suite; a new helper does not automatically need its own test.

## RED: establish that the test detects the gap

Derive expectations from the requested behavior, not the implementation under
test. Run the focused test against the baseline and inspect why it fails. A
setup, syntax or dependency problem is not evidence of the intended gap unless
that failure is itself the behavior being added or fixed.

If it passes, check whether existing tests already protect the behavior or the
new case fails to distinguish it. Refine the relevant case rather than adding
assertions just to obtain a red result.

If implementation already exists, an isolated prior revision or a safe targeted
mutation can establish test sensitivity. Do not overwrite shared/user work or
call retrospective baseline evidence historical test-first execution.

## GREEN: implement and verify

Make the smallest coherent change that satisfies the behavior, using existing
interfaces and patterns where suitable. Run the focused check and affected
owning checks; interpret failures before expanding scope. Unrelated third-party
warnings do not by themselves require repairs outside this task.

For example, a retry helper's test should check both the eventual returned
value and the attempt bound, rather than merely inspecting a retry constant:

```typescript
test('returns the successful result after two transient failures', async () => {
  let attempts = 0;
  const result = await retryOperation(async () => {
    attempts++;
    if (attempts < 3) throw new Error('temporary');
    return 'success';
  });
  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```

The callback is controlled input; real external calls are unnecessary here.
Other cases follow the contract actually being changed, such as exhaustion
when that boundary matters. One test is not proof of every retry policy.

## Refactor and finish

Clean up only when needed, keeping relevant checks green. Merge redundant
cases and remove development probes or fold them into the owning regression.
A named realistic failure helps judge a test's value; exhaustive mutation
proof is not a prerequisite for deleting clear duplication.

Report the selected evidence path honestly: observed RED/GREEN when present,
baseline/candidate for behavior preservation, or the direct check and its scope.
Use `verification-before-completion` for evidence freshness and completion
claims; do not repeat a valid unchanged suite solely for another checkpoint.
