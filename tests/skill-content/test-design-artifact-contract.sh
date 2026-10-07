#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE="$REPO_ROOT/skills/brainstorming/design-template.html"

assert_literal() {
  local needle="$1"
  local label="$2"

  grep -Fq -- "$needle" "$TEMPLATE"
  printf '  [PASS] %s\n' "$label"
}

printf 'Legacy HTML template compatibility (not a new-spec schema)\n'

test -f "$TEMPLATE"
printf '  [PASS] template exists\n'

assert_literal '<!DOCTYPE html>' 'standalone HTML document'
assert_literal '<meta name="viewport"' 'responsive viewport'

if grep -Eqi '<script|https?://|@import' "$TEMPLATE"; then
  printf '  [FAIL] template must not load scripts or external resources\n'
  exit 1
fi

printf '  [PASS] no scripts or external resources\n'
printf 'All design artifact contract checks passed\n'
