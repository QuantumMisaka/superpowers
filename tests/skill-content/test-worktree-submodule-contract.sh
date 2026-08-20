#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL="$REPO_ROOT/skills/using-git-worktrees/SKILL.md"

assert_literal() {
  local needle="$1"
  local label="$2"

  grep -Fq -- "$needle" "$SKILL"
  printf '  [PASS] %s\n' "$label"
}

# Multi-line contract phrases: whitespace-flexible match across line wraps.
assert_phrase() {
  local pattern="$1"
  local label="$2"

  grep -Pzoq -- "$pattern" "$SKILL"
  printf '  [PASS] %s\n' "$label"
}

printf 'Worktree submodule contract\n'

test -f "$SKILL"
printf '  [PASS] skill exists\n'

assert_literal '`git worktree add` does not check out submodule' \
  'names the worktree submodule gap'
assert_literal '[ -f .gitmodules ]' 'guards on declared submodules'
assert_literal 'git submodule update --init --recursive' \
  'initializes submodules recursively'
assert_phrase '(?s)initialize them before any\s+dependency install or baseline test' \
  'orders init before setup and baseline'
assert_phrase '(?s)report the\s+exact failing submodule and stop' \
  'halts on failed init'
assert_literal '| Repo declares submodules | Initialize in new workspace before setup (Step 2) |' \
  'error table routes submodule repos to Step 2'

printf 'All worktree submodule contract checks passed\n'
