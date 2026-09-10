# Writing Good Tests

**Load this reference when:** writing or changing tests, adding mocks, or
adding cleanup/helper methods for tests.

## Overview

A test exists to catch a specific break. Two principles govern everything
here:

```
1. Every test names the break it catches
2. Every test exercises the owning behavior at an appropriate boundary
```

Strict TDD produces both naturally: a test written first and watched
failing against the baseline has already proven it can detect the missing
behavior. Exercise real dependencies only when their side effects are
authorized and controlled; a faithful offline double is also valid when a
dependency is external, unavailable, slow, nondeterministic, or otherwise
unreasonable to run in the test.

## Principle 1: Name the Break

Before writing the test body, answer: **what production change should
make this test fail — and is that change a bug or a decision?** A test
earns its place by catching a wrong branch, missing side effect, wrong
argument, boundary case, or broken contract.

**Derive expectations independently.** Use literals and hand-checked
fixtures; table-driven tests with literal `want` values are the preferred
shape. An expectation computed by the code under test — or its helpers —
passes no matter what that code does:

```typescript
// ❌ Mirror assertion: the same builder computes both sides — always true
const expected = buildSearchQuery({ tag: 'urgent' });
expect(buildSearchQuery({ tag: 'urgent' })).toBe(expected);

// ✅ Hand-derived literal
expect(buildSearchQuery({ tag: 'urgent' })).toBe('tag:"urgent"');
```

**No change detectors.** If only intentional decisions can fail a test —
an incidental constant, private structure, or wording that is not a public
contract — it fires on redesign and sleeps through bugs. Test the behavior
that depends on the decision: not `expect(MAX_RETRIES).toBe(5)` but "a failing
call is retried 5 times and the 6th attempt never happens." Exact wording is a
valid assertion when it is a documented user-facing or serialized contract;
otherwise assert the observable outcome rather than incidental text.

**Behavior, not text.** Asserting that a script, skill, or config
contains an exact line proves only that the source is the source. Run
scripts against controlled inputs and assert outputs, side effects, or
exit codes. Documents that instruct agents are tested by the consuming
agent's behavior (superpowers:writing-skills); human prose alone usually needs
no automated test.

**Your code, not the framework.** Test the contract your code makes at
its boundaries — the route you register, the query you emit, the payload
you produce. Upstream mechanics are their maintainers' tests to write
(the classic: asserting your router invokes a registered handler — that
is the framework's test, not yours). When upstream behavior genuinely
surprised you, write one narrow characterization test naming the
assumption. The same boundary applies inside your code: constructors,
getters, constants, and trivial forwarding earn tests only when they
validate, normalize, default, derive, enforce, or cause side effects —
otherwise assert the first consumer-visible result that depends on them.

### Gate Function

```
BEFORE writing the test body:
  Name the production change that would make this test fail.

  Cannot name one            → redesign around an observable behavior
  "The source text changed"  → run the artifact and assert its effects
  Only intentional decisions → change detector; test the behavior
                               that depends on the decision

  Confirm the expected value is derived without the code under test.
  IF it reuses the code's logic or helpers:
    Replace it with a literal or hand-checked fixture
```

## Principle 2: Exercise the Owning Behavior

**A double is not the behavior under test.** An assertion that only proves a
mock is present says nothing about the component. Assert the owning component's
observable behavior; assertions about a double's arguments, calls, or ordering
are appropriate when that interaction is itself the contract.

```typescript
// ✅ Real behavior
expect(screen.getByRole('navigation')).toBeInTheDocument();

// ❌ Mock existence
expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
```

**your human partner's correction:** "Are we testing the behavior of a
mock?"

**Use a double at the right level.** Identify the side effects the test depends
on and keep those real where practical and within authorized, controlled
scope; isolate the slow, external, or unavailable operation at a suitable
boundary. An offline fake or stub is valid when it models the relevant
contract and the test still asserts the owning behavior. When the real
implementation is available and the boundary is unclear, inspect or exercise
it before choosing what to replace.

```typescript
// ❌ The mock swallows the config write that duplicate detection reads
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
}));

// ✅ Mock only the slow server startup; the config write stays real
vi.mock('MCPServerManager');
```

**Make doubles specific.** When arguments, call counts, or ordering are
part of the contract, assert them — a fake that accepts anything verifies
nothing. Give each branch (success, error, malformed) its own fixture or
spy, so the wrong branch cannot satisfy the expectation.

**Keep doubles realistic for the contract under test.** Include the fields and
semantics consumed by the code path, and use complete fixtures for boundary or
integration checks. A deliberately minimal double is fine when the test owns a
narrow interface and its assumptions are explicit; do not omit fields that
downstream behavior relies on.

**Production classes carry production methods only.** Cleanup that only
tests need lives in test utilities, never as a `destroy()` on the
production class. Ask: is this method called only from tests? Does this
class own this resource's lifecycle? Wrong answers → test utility.

**Prefer real components over complex doubles when practical.** When double
setup obscures the test logic, misses methods required by the contract, or
breaks whenever its shape changes, use an integration test with real
components or a smaller boundary double. **your human partner's question:**
"Do we need to be using a mock here?"

### Gate Function

```
BEFORE adding a mock or test helper:
  Identify the side effects the test depends on; keep those real where
  practical and within authorized, controlled scope; isolate a slow, external,
  or unavailable level below them.

  Double responses model the fields and semantics required by the contract.

  A method only tests call lives in test utilities, not production.

  About to assert on the mock itself?
    Unmock it or delete the assertion.
```

## Test Portfolio Maintenance

- Extend the nearest owning suite or table before creating a new test file.
- Consolidate cases with the same behavior, setup, and failure reason.
- Remove one-off probes before commit; keep characterization tests only for
  behavior the project relies on.
- When removing redundancy, confirm that the remaining suite covers the same
  contract and failure mode. Targeted mutation reasoning can help, but routine
  cleanup does not require exhaustive mutation proof.

## Tests Ship With the Implementation

For behavior changes, the TDD cycle — failing test, minimal implementation,
refactor — establishes evidence for the implementation. For
behavior-preserving refactors, use baseline/candidate checks instead of
manufacturing a failure. Overall task completion may require other applicable
review, integration, or release checks. Ship the tests the behavior needs and
only those: trivial code and human prose alone need no test, and a test written
only to satisfy process costs maintenance forever.

## Mutation Reasoning

When useful, mentally mutate the production code or run a targeted mutation
check to probe important break classes:

- Wrong constant or argument
- Wrong branch handler
- Missing state change or side effect
- Empty or default return
- Missing validation for zero, empty, nil, unauthorized, or malformed input

A mutation that no test catches is a useful signal to assess whether the
behavior is unprotected or the test is tautological. This is supporting design
evidence, not exhaustive proof for every test file or a prerequisite for
deleting a redundant test when the remaining contract coverage is clear.

## Quick Reference

| When you... | Do |
|-------------|-----|
| Write any test | Name the break it catches — a bug, not a decision |
| Build an expected value | Derive it by hand; never with the code under test |
| Test a script or document | Prefer execution or consumer checks; source assertions serve stable public text or machine-consumed structure, not incidental wording |
| Reach for a dependency test | Test your boundary contract, not their documented mechanics |
| Want to assert on a mocked element | Test the real component, or unmock it |
| Are about to use a double | Identify relevant side effects; choose a suitable boundary |
| Build a double response | Model the fields and semantics required by the contract |
| Need cleanup only tests use | Put it in test utilities |
| Watch mock setup balloon | Switch to an integration test with real components |
| Finish a test file | Review likely realistic mutations when useful |

## Warning Signs

- Setup and assertion share the same object, guaranteeing equality
- The test can fail only through a panic, crash, or missing selector
- The test fails on every intentional change, never on accidental breakage
- Expected values are hidden behind loops, builders, or helpers
- The test greps source text, or asserts a removed symbol stays removed
- The test would still matter if only the framework remained
- The test exists for coverage, checking no side effect or outcome
- An assertion checks a `*-mock` test ID, or fails if you remove the mock
- A method is called only from test files
- Double setup obscures the test, or you can't explain why the boundary is needed
- Mocking "just to be safe"
