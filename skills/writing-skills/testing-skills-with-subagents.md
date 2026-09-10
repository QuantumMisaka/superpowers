# Testing Skills With Scenarios

Use this reference when a skill's behavior is important enough to warrant an
agent scenario. It complements `test-driven-development`; it does not impose a
fixed sample count or deployment ceremony.

## Choose the check

- Reference material: verify that an agent can find and apply the relevant
  entry, link, example, or command.
- Behavioral guidance: give an agent a realistic task that exercises the
  intended decision, then compare the result with and without the guidance when
  that comparison is practical.
- Safety or authorization guidance: include the relevant boundary and a case
  that attempts to cross it; inspect both the action and the stated pause.

Use a small set of independent scenarios that covers the actual risk. Vary
pressure or context only when it could change the decision. One clear scenario
can be sufficient for a narrow reference; a high-consequence discipline may
deserve several. Treat the result as bounded evidence, not a statistical claim.

## Scenario record

Keep each scenario self-contained and record:

1. the candidate skill revision and inputs;
2. the task and relevant pressure or boundary;
3. the observed action/output and cited guidance;
4. the baseline comparison, if run;
5. the remaining uncertainty and the next focused check, if any.

Do not seed an evaluator with the expected answer. The author may assess the
result afterward against the user-facing outcome. Do not treat a quoted example,
keyword count, or exact sentence as behavioral evidence.

## Iteration

If a scenario exposes a real gap, change the smallest relevant section and
rerun that scenario. If it exposes only a hypothetical interpretation, record
the uncertainty without adding a new prohibition. Stop when the target boundary
is covered and the evidence is sufficient for the release decision.

This workflow supports independent review and honest limits; it does not
require endless counterexamples, a universal pressure recipe, or a push before
the surrounding task authorizes publication.
