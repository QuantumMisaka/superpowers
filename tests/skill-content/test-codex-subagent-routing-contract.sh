#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REFERENCE="$REPO_ROOT/skills/using-superpowers/references/codex-tools.md"

assert_literal() {
  local file="$1"
  local needle="$2"
  local label="$3"

  grep -Fq -- "$needle" "$file"
  printf '  [PASS] %s\n' "$label"
}

printf 'Codex subagent routing contract\n'

assert_literal "$REFERENCE" 'sequential-gated' 'sequential workflow mode'
assert_literal "$REFERENCE" 'independent-parallel' 'parallel workflow mode'
assert_literal "$REFERENCE" 'generic subagent' 'capability fallback'
assert_literal "$REFERENCE" 'fork_turns: "none"' 'isolated child context'

for skill in \
  subagent-driven-development \
  dispatching-parallel-agents \
  requesting-code-review; do
  assert_literal \
    "$REPO_ROOT/skills/$skill/SKILL.md" \
    'using-superpowers/references/codex-tools.md' \
    "$skill uses shared Codex routing"
done

if rg -n 'codex-routing-kit|luna_worker|luna_deep|luna_monitor|sol_reviewer|gpt-5\.6' \
  "$REPO_ROOT/skills"; then
  printf '  [FAIL] skills must not depend on one routing kit or model family\n'
  exit 1
fi
printf '  [PASS] no routing-kit or model identifiers in skills\n'

if grep -Fq -- 'Always specify the model explicitly' \
  "$REPO_ROOT/skills/subagent-driven-development/SKILL.md"; then
  printf '  [FAIL] routing must not require fields absent from the active schema\n'
  exit 1
fi
printf '  [PASS] no impossible model-field requirement\n'

if rg -n '\[MODEL|^[[:space:]]*model:' \
  "$REPO_ROOT/skills/subagent-driven-development/implementer-prompt.md" \
  "$REPO_ROOT/skills/subagent-driven-development/task-reviewer-prompt.md"; then
  printf '  [FAIL] SDD prompts must leave routing fields to the controller\n'
  exit 1
fi
printf '  [PASS] SDD prompts contain no routing-field placeholders\n'

printf 'All Codex subagent routing contract checks passed\n'
