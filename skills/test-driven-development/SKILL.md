---
name: test-driven-development
description: Use for applicable feature and bugfix behavior tests; use baseline/candidate evidence for behavior-preserving refactors. Choose checks by observable impact, not file type.
---

# Test-Driven Development

Protect the behavior the user needs at its nearest stable interface. For features and bugfixes that can be tested reliably, observe the missing or failing behavior first, implement the change, and verify that the test passes.

## 1. Choose the Verification Path

Match the check to what actually changed:
- **Changed behavior**: Add or extend a focused regression test in the owning suite, observe the expected failure on the baseline, implement the change, and confirm the test passes.
- **Behavior-preserving refactor**: Compare baseline and candidate runs on the existing test suite so behavior equivalence is verified directly.
- **Documentation, prose, or formatting**: Check rendering, links, or formatting directly.
- **Configuration**: Verify runtime behavior when the config alters execution; run parser or schema validation when it updates metadata.
- **Agent instructions and skills**: Evaluate through structural checks, link validation, or realistic task scenarios (`writing-skills`).

When external services or heavy dependencies are involved, use a controlled test double or focused integration check and note any environment conditions alongside the result. For boundary selection and test maintenance, see [writing-good-tests.md](writing-good-tests.md).

## 2. Establish Sensitivity (RED)

Write the test around the requested behavior and interface rather than internal implementation details. Run the focused test to confirm it fails for the expected functional reason (or, if the code change was already drafted, verify against the prior revision or a targeted check that the test catches the regression).

## 3. Implement and Verify (GREEN & Refactor)

Implement the smallest coherent change that satisfies the requirement, following existing codebase conventions. Run the focused test and related suite to confirm everything passes, and fold any useful diagnostic checks into the test suite while removing temporary probes.

Example of a behavior-focused test covering both the return value and retry limit:

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

## 4. Report Evidence

Report the verification result under `verification-before-completion`: state the behavior verified, the command and outcome (RED/GREEN, baseline/candidate equivalence, or direct check), and any condition that affects how the result applies.
