# Writing Good Tests

**Load this reference when:** writing or changing tests, adding mocks, or
adding cleanup/helper methods for tests.

## Overview

A test exists to catch a specific break. Two principles govern everything
here:

```
1. Every test names the break it catches
2. Every test exercises real behavior at the narrowest stable boundary
```

Strict TDD produces both naturally: a test written first and watched failing
against real code has already proven it can fail. A mock earns its place only
when the real dependency proves slow or external.

## Principle 1: Name the Break

Before writing the test body, answer: **what production change should make
this test fail, and is that change a bug or a decision?** A test earns its
place by catching a wrong branch, missing side effect, wrong argument, boundary
case, or broken contract.

**Derive expectations independently.** Use literals and hand-checked fixtures;
table-driven tests with literal `want` values are the preferred shape. An
expectation computed by the code under test, or its helpers, passes no matter
what that code does:

```typescript
// BAD: the same builder computes both sides
const expected = buildSearchQuery({ tag: 'urgent' });
expect(buildSearchQuery({ tag: 'urgent' })).toBe(expected);

// GOOD: hand-derived literal
expect(buildSearchQuery({ tag: 'urgent' })).toBe('tag:"urgent"');
```

**No change detectors.** If only intentional decisions can fail a test, such
as a constant's value, exact message wording, or private structure, it fires on
redesign and sleeps through bugs. Test the behavior that depends on the
decision: not `expect(MAX_RETRIES).toBe(5)` but "a failing call is retried 5
times and the 6th attempt never happens."

**Behavior, not text.** Asserting that a script, skill, or config contains an
exact line proves only that the source is the source. Run scripts against
controlled inputs and assert outputs, side effects, or exit codes. Documents
that instruct agents are tested by the consuming agent's behavior
(`superpowers:writing-skills`); prose for humans earns no test at all.

**Your code, not the framework.** Test the contract your code makes at its
boundaries: the route you register, query you emit, or payload you produce.
Upstream mechanics are their maintainers' tests to write. When upstream
behavior genuinely surprised you, write one narrow characterization test
naming the assumption. The same boundary applies inside your code:
constructors, getters, constants, and trivial forwarding earn tests only when
they validate, normalize, default, derive, enforce, or cause side effects.

### Gate Function

```
BEFORE writing the test body:
  Name the production change that would make this test fail.

  Cannot name one            -> redesign around an observable behavior
  "The source text changed"  -> run the artifact and assert its effects
  Only intentional decisions -> test the behavior that depends on the decision

  Confirm the expected value is derived without the code under test.
  IF it reuses the code's logic or helpers:
    Replace it with a literal or hand-checked fixture.
```

## Principle 2: Exercise the Real Thing

**The mock earns no assertions.** A mock assertion passes when the mock is
present and fails when it is absent; it says nothing about the component.
Assert the real component's behavior. If the mock is what you are checking,
unmock it or delete the assertion.

```typescript
// GOOD: real behavior
expect(screen.getByRole('navigation')).toBeInTheDocument();

// BAD: mock existence
expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
```

**your human partner's correction:** "Are we testing the behavior of a mock?"

**Mock at the right level.** Learn every side effect of the real method before
replacing it. Mock the slow or external operation and keep what the test
depends on real. When unsure, run against the real implementation first.

```typescript
// BAD: swallows the config write that duplicate detection reads
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
}));

// GOOD: only slow server startup is mocked; config writes stay real
vi.mock('MCPServerManager');
```

**Make doubles specific.** When arguments, call counts, or ordering are part of
the contract, assert them. Give success, error, and malformed branches separate
fixtures so the wrong branch cannot satisfy the expectation.

**Mirror real data completely.** Mock the complete real structure, not just the
fields your test reads. Partial mocks hide downstream assumptions and let tests
pass while integration breaks.

**Production classes carry production methods only.** Cleanup that only tests
need lives in test utilities, never as a `destroy()` on the production class.
Ask: is this method called only from tests? Does this class own this resource's
lifecycle? Wrong answers mean test utility.

**Prefer real components over complex mocks.** When mock setup outgrows the
test logic or tests break when the mock changes, switch to an integration test
with real components.

### Gate Function

```
BEFORE adding a mock or test helper:
  List the real method's side effects; keep required effects real.
  Mock responses mirror the complete real structure.
  A method only tests call lives in test utilities, not production.
  About to assert on the mock itself? Unmock it or delete the assertion.
```

## Test Portfolio Maintenance

- Extend the nearest owning suite or table before creating a new test file.
- Consolidate cases with the same behavior, setup, and failure reason.
- Keep temporary probes only while learning; remove one-off scripts before commit.
- Promote a characterization test only when the behavior becomes a relied-on contract.
- Before deleting redundancy, mutate realistic production behavior and confirm
  the remaining suite catches the same breaks.

## Tests Ship With the Implementation

The TDD cycle, failing test, minimal implementation, refactor, is what
"complete" means. Ship the tests the behavior needs and only those: trivial
code and human prose earn none, and a test written only for process costs
maintenance forever.

## The Mutation Check

Before finishing, mentally mutate the production code. At least one test should
fail for each realistic mutation:

- Wrong constant or argument
- Wrong branch handler
- Missing state change or side effect
- Empty or default return
- Missing validation for zero, empty, nil, unauthorized, or malformed input

A mutation nothing catches marks the behavior as unprotected, or the test as
tautological.

## Quick Reference

| When you... | Do |
|-------------|-----|
| Write any test | Name the break it catches: a bug, not a decision |
| Build an expected value | Derive it by hand, never with the code under test |
| Test a script or document | Run it or pressure-test its consumer; never grep its text |
| Reach for a dependency test | Test your boundary contract, not their mechanics |
| Want to assert on a mocked element | Test the real component, or unmock it |
| Are about to mock a method | Learn its side effects; mock the slow/external level |
| Build a mock response | Mirror the real structure completely |
| Need cleanup only tests use | Put it in test utilities |
| Watch mock setup balloon | Switch to an integration test with real components |
| Finish a suite | Consolidate it, remove probes, then run the mutation check |

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
- Mock setup is more than half the test, or you cannot explain why it is needed
- A new test file duplicates the setup and behavior of an existing suite
