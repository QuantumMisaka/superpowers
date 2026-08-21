#!/usr/bin/env bash
# Validate the Kimi Code harness reference. Upstream ships the base tool
# mapping inside .kimi-plugin/plugin.json's skillInstructions (covered by
# tests/kimi/); this contract guards the fork-owned reference that extends it
# with orchestration concerns: Agent subagent_type routing, resume-based fix
# rounds, AgentSwarm for same-shape parallel work, and the no-model-field
# routing boundary.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MAPPING="$REPO_ROOT/skills/using-superpowers/references/kimi-code-tools.md"
SKILL="$REPO_ROOT/skills/using-superpowers/SKILL.md"
PLUGIN="$REPO_ROOT/.kimi-plugin/plugin.json"

fail() { echo "FAIL: $*" >&2; exit 1; }

assert_literal() {
  local file="$1" needle="$2" label="$3"
  grep -Fq -- "$needle" "$file" || fail "$label (missing $needle in $file)"
  printf '  [PASS] %s\n' "$label"
}

echo "test-kimi-code-tools-contract: checking Kimi Code tool mapping"

[ -f "$MAPPING" ] || fail "tool mapping missing at $MAPPING"
[ -f "$PLUGIN" ] || fail "upstream plugin manifest missing at $PLUGIN"

# --- Core dispatch surface ---------------------------------------------------
assert_literal "$MAPPING" '`Agent`' 'Agent dispatch tool'
assert_literal "$MAPPING" '`AgentSwarm`' 'AgentSwarm batch dispatch tool'
assert_literal "$MAPPING" 'subagent_type' 'subagent_type routing field'
assert_literal "$MAPPING" '`coder`' 'coder subagent type'
assert_literal "$MAPPING" '`explore`' 'explore subagent type'
assert_literal "$MAPPING" '`plan`' 'plan subagent type'

# --- Fork orchestration concerns ---------------------------------------------
assert_literal "$MAPPING" '`resume`' 'resume-based fix rounds'
assert_literal "$MAPPING" 'at least 2 `items`' 'swarm minimum items constraint'
assert_literal "$MAPPING" \
  'schema exposes **no `model` or effort field**' \
  'no-model-field routing boundary'
assert_literal "$MAPPING" \
  'Never dispatch implementation subagents in parallel' \
  'SDD serial-implementer red line'

# --- Consistency with upstream plugin manifest mapping -----------------------
for token in AskUserQuestion TodoList Read Write Edit Bash Grep Glob FetchURL WebSearch; do
  assert_literal "$MAPPING" "$token" "base tool mapping covers $token"
done

# --- Entry router loads harness references -----------------------------------
grep -Fq 'references/*-tools.md' "$SKILL" \
  || grep -q 'kimi-code-tools.md' "$SKILL" \
  || fail "SKILL.md does not reference the harness tool mapping"
printf '  [PASS] %s\n' 'SKILL.md loads harness tool mapping'

echo "PASS: Kimi Code tool mapping valid"
