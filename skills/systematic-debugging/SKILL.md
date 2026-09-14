---
name: systematic-debugging
description: Use for non-trivial bugs, test failures or unexpected behavior whose cause is unclear. Obvious typos, syntax errors and known configuration fixes can be handled directly.
---

# Systematic Debugging

Investigate enough to explain the failure and choose a repair. Use observation,
a hypothesis and a discriminating check rather than stacking speculative fixes.
These are methods to combine as evidence permits, not four mandatory ceremonies.

## Investigate the failing boundary

Read the relevant error and trace, reproduce the symptom when practical, and
inspect recent changes and the inputs involved. Distinguish product failures
from environment or test-setup failures before changing production code.
For intermittent failures, collect bounded evidence at the uncertain boundary.

In a multi-layer system, trace the value or state from producer to consumer.
Inspect the first point where observed behavior differs from the expectation;
add temporary instrumentation there rather than logging every component.
Compare a working path when it helps identify a missing assumption.

Example: a request succeeds in a local call but fails through the launcher.
Check the actual arguments, working directory and environment crossing that
boundary before rewriting the request implementation.

## Test a useful hypothesis

State the likely cause and what observation would distinguish it from an
alternative. Run a small reversible experiment. Keep changes separable enough
to interpret the result; remove probes or fold useful checks into the owning
suite once they have served their purpose.

A failed experiment updates the hypothesis. Repeated attempts that add no
information call for a different strategy or a narrower investigation. There
is no fixed failure count that proves an architectural problem or forces a
human interruption. New evidence can justify another scoped repair.

## Repair and verify

Fix the identified cause within the approved scope. Use
`test-driven-development` for applicable behavior changes: a focused regression
should distinguish the failing baseline from the repaired behavior. Existing
consumer coverage or a relevant direct check may suffice for a trivial fix;
missing test infrastructure requires a suitable observation, not a fabricated
RED result. Verify the original symptom and the affected behavior, then report
only what the evidence supports under `verification-before-completion`.

If the repair would change an approved product or architecture decision, return
that choice to the user. Preserve existing authorization; seek only what is
missing for sensitive or external actions. If no reliable path remains, report
the evidence and unresolved gap rather than guessing or claiming success.

## Useful techniques

- [Root-cause tracing](root-cause-tracing.md): work back from a bad value to its source.
- [Condition-based waiting](condition-based-waiting.md): wait for an observable state instead of guessing a delay.
- [Defense in depth](defense-in-depth.md): consider additional validation only where a distinct boundary needs it.

Read a technique for a concrete diagnostic need. A reference does not by itself
expand this repair into system-wide hardening.
