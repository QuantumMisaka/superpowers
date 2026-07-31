#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TDD="$REPO_ROOT/skills/test-driven-development/SKILL.md"
VERIFY="$REPO_ROOT/skills/verification-before-completion/SKILL.md"

for needle in 'RED' 'GREEN' 'REFACTOR' 'expected failure' 'minimal implementation'; do
  grep -Fq -- "$needle" "$TDD"
done

for needle in 'fresh evidence' 'exact command' 'exit code' 'actual status'; do
  grep -Fq -- "$needle" "$VERIFY"
done

if rg -ni 'dishonest|dishonesty|lying|rationalization|you.ll be replaced|no exceptions|non-negotiable' \
  "$TDD" "$VERIFY"; then
  printf '  [FAIL] evidence skills contain moralized or generalized coercive language\n'
  exit 1
fi

printf 'All positive evidence language checks passed\n'
