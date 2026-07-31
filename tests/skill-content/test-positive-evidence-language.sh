#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TDD="$REPO_ROOT/skills/test-driven-development/SKILL.md"
VERIFY="$REPO_ROOT/skills/verification-before-completion/SKILL.md"

fail() {
  printf '  [FAIL] %s\n' "$1" >&2
}

require_literal() {
  local file="$1"
  local needle="$2"
  local label="$3"

  if ! grep -Fq -- "$needle" "$file"; then
    fail "$label"
    return 1
  fi
}

require_ordered_literals() {
  local file="$1"
  local label="$2"
  shift 2
  local previous=0
  local needle match line

  for needle in "$@"; do
    if ! match="$(grep -nF -m1 -- "$needle" "$file")"; then
      fail "$label: missing $needle"
      return 1
    fi
    line="${match%%:*}"
    if (( line <= previous )); then
      fail "$label: $needle is out of order"
      return 1
    fi
    previous="$line"
  done
}

check_tdd_contract() {
  local file="$1"

  require_ordered_literals "$file" 'TDD phase evidence order' \
    '1. RED — add one focused behavior test and run it.' \
    '2. Confirm the expected failure is caused by the missing behavior.' \
    '3. GREEN — write the minimal implementation and run the owning test.' \
    '4. REFACTOR — improve structure while the owning suite stays green.' ||
    return 1

  require_literal "$file" \
    'temporary revert or an equivalent isolated baseline' \
    'TDD contract must establish RED for an existing implementation' ||
    return 1
  require_literal "$file" \
    'Route throwaway prototypes, generated' \
    'TDD scope must route prototypes and generated code before invocation' ||
    return 1
  require_literal "$file" \
    'code, configuration-only edits, and missing test infrastructure before invoking' \
    'TDD scope must route configuration-only work and absent test infrastructure before invocation' ||
    return 1

  require_ordered_literals "$file" 'TDD bug-fix RED/GREEN example' \
    '## Example: Bug Fix' \
    '**RED**' \
    '**Verify RED**' \
    '**GREEN**' \
    '**Verify GREEN**' \
    '**REFACTOR**' ||
    return 1
}

check_verification_contract() {
  local file="$1"

  require_literal "$file" 'fresh evidence' \
    'verification contract must require fresh evidence' ||
    return 1
  require_literal "$file" 'exact command' \
    'verification contract must name the exact command' ||
    return 1
  require_literal "$file" 'exit code' \
    'verification contract must inspect the exit code' ||
    return 1
  require_literal "$file" 'actual status' \
    'verification failure must report actual status' ||
    return 1
  require_literal "$file" '## Claim-to-Evidence Mapping' \
    'verification contract must retain the claim/evidence mapping table' ||
    return 1

  for row in \
    '| Tests pass | Test command output: 0 failures | Previous run, "should pass" |' \
    '| Build succeeds | Build command: exit 0 | Linter passing, logs look good |' \
    '| Regression test works | Red-green cycle verified | Test passes once |' \
    '| Requirements met | Line-by-line checklist | Tests passing |'; do
    require_literal "$file" "$row" \
      "verification mapping must retain key row: $row" ||
      return 1
  done

  require_ordered_literals "$file" 'verification regression RED/GREEN example' \
    '**Regression tests (TDD Red-Green):**' \
    '✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)' ||
    return 1

  require_literal "$file" \
    'reporting a positive factual claim about work state' \
    'verification scope must target positive factual work-state claims' ||
    return 1
  if grep -Fq -- 'reporting satisfaction with a work state' "$file"; then
    fail 'verification scope still targets subjective satisfaction'
    return 1
  fi
}

expect_rejected() {
  local label="$1"
  local checker="$2"
  local file="$3"

  if "$checker" "$file" >/dev/null 2>&1; then
    fail "mutation was not rejected: $label"
    return 1
  fi
  printf '  [PASS] mutation rejected: %s\n' "$label"
}

check_tdd_contract "$TDD"
check_verification_contract "$VERIFY"

if rg -ni 'dishonest|dishonesty|lying|rationalization|you.ll be replaced|no exceptions|non-negotiable' \
  "$TDD" "$VERIFY"; then
  fail 'evidence skills contain moralized or generalized coercive language'
  exit 1
fi

expect_rejected 'TDD phase order' check_tdd_contract <(
  awk '
    index($0, "2. Confirm the expected failure") { expected = $0; next }
    index($0, "3. GREEN —") { print; print expected; next }
    { print }
  ' "$TDD"
)
expect_rejected 'existing-implementation RED baseline' check_tdd_contract <(
  sed '/temporary revert or an equivalent isolated baseline/d' "$TDD"
)
expect_rejected 'pre-invocation routing' check_tdd_contract <(
  sed '/missing test infrastructure before invoking/d' "$TDD"
)
expect_rejected 'claim/evidence mapping row' check_verification_contract <(
  sed '/| Regression test works |/d' "$VERIFY"
)
expect_rejected 'regression RED/GREEN example' check_verification_contract <(
  sed '/Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)/d' "$VERIFY"
)

printf 'All positive evidence language checks passed\n'
