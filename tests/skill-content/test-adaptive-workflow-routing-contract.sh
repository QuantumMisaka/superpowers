#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROUTER="$REPO_ROOT/skills/using-superpowers/SKILL.md"
BRAINSTORM="$REPO_ROOT/skills/brainstorming/SKILL.md"
CODEX_TOOLS="$REPO_ROOT/skills/using-superpowers/references/codex-tools.md"

assert_literal() {
  local file="$1"
  local needle="$2"
  local label="$3"
  grep -Fq -- "$needle" "$file"
  printf '  [PASS] %s\n' "$label"
}

assert_literal "$ROUTER" 'L1 敏捷修改' 'L1 route'
assert_literal "$ROUTER" 'L2 有界行为开发' 'L2 route'
assert_literal "$ROUTER" 'L3 计划化开发' 'L3 route'
assert_literal "$ROUTER" \
  '不改变公共接口、数据或架构；无高风险外部副作用' \
  'L1 architecture and external-side-effect boundary'
assert_literal "$ROUTER" \
  '公共 API/schema/持久化数据/架构/安全姿态变化或高风险外部副作用' \
  'L3 architecture and external-side-effect escalation'
assert_literal "$ROUTER" '歧义、行为风险、跨模块协调和返工成本' 'risk-based escalation'
assert_literal "$ROUTER" '读取当前完整版本' 'fresh skill read'
assert_literal "$ROUTER" '用户直接要求' 'user priority'
assert_literal "$ROUTER" '最近层级' 'nearest repository instructions'
assert_literal "$ROUTER" '说明证据并升级' 'evidence-backed escalation'
assert_literal "$BRAINSTORM" '仅处理 L3' 'brainstorming scope'
assert_literal "$BRAINSTORM" '多文件机械迁移' 'mechanical-plan distinction'
assert_literal "$CODEX_TOOLS" 'GPT engineering group' 'GPT engineering default'
assert_literal "$CODEX_TOOLS" 'Qwen information group' 'Qwen information default'
assert_literal "$CODEX_TOOLS" 'local routing hypothesis' 'versioned empirical routing'
assert_literal "$CODEX_TOOLS" 'Inputs:' 'Qwen bounded input list'
assert_literal "$CODEX_TOOLS" 'Output contract:' 'Qwen output contract'
assert_literal "$CODEX_TOOLS" \
  'an HTML/Markdown draft grounded in approved decisions' \
  'Qwen approved-decision drafting boundary'
assert_literal "$CODEX_TOOLS" 'Stop condition:' 'Qwen stop condition'

if rg -n '1% chance|没有选择|不能通过.*绕开|rationaliz' "$ROUTER" "$BRAINSTORM"; then
  printf '  [FAIL] router and brainstorming contain generalized coercive language\n'
  exit 1
fi

printf 'All adaptive workflow routing checks passed\n'
