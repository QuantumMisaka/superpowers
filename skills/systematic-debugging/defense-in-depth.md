# Validation at Distinct Boundaries

Use additional validation when a separate caller, trust boundary or dangerous
side effect can bypass an existing check. Validation at every internal layer
is not a default repair strategy; repeated checks of the same unchanged fact
can add maintenance and execution cost without protecting another behavior.

## Select the boundary

Trace the bad input to its source and the operation that consumes it. Repair
the source where possible. Then ask whether another supported path can still
reach the operation with invalid state. A separate boundary can justify a
separate guard; otherwise reuse the existing validation.

- Entry validation protects callers at a public boundary.
- Operation-specific validation protects assumptions not established upstream.
- Environment restrictions can protect a dangerous side effect in test or
  deployment contexts.
- Temporary instrumentation explains a failure; it is not itself prevention
  and need not become permanent runtime work.

## Example

An empty working directory falls back to the process cwd, causing a Git command
to act on the source checkout. Correct the producer that supplied the empty
value and verify the failing behavior. If the Git executor also has independent
callers, a guard there protects those callers too. If the executor is reachable
only through an already validated path, duplicating that same validation at
every helper is not automatically useful.

Test the actual rejected/accepted behavior at the owning boundary. Validate
path containment by path semantics, not a textual prefix. Preserve authorization
and source data while reproducing the problem. Choose checks for the distinct
risk being changed rather than a quota of validation layers.

The original multi-layer debugging example is a historical case, not a mandate
that every repair add four guards or make a bug “impossible.” Additional
hardening outside the approved repair is a separate scope decision.
