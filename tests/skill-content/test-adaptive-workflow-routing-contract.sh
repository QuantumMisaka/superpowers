#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROUTER="$REPO_ROOT/skills/using-superpowers/SKILL.md"
BRAINSTORM="$REPO_ROOT/skills/brainstorming/SKILL.md"
CODEX_TOOLS="$REPO_ROOT/skills/using-superpowers/references/codex-tools.md"
ROUTER_DESCRIPTION="$(sed -n 's/^description: //p' "$ROUTER")"

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
assert_literal "$ROUTER" '所有行动型请求开始时使用' 'actionable-task trigger'
if [[ "$ROUTER_DESCRIPTION" != *'bug 修复'* ]]; then
  printf '  [FAIL] router description must explicitly cover bug fixes\n'
  exit 1
fi
printf '  [PASS] bug-fix discovery trigger\n'
if [[ "$ROUTER_DESCRIPTION" != *'repository/Skill instructions'* ]]; then
  printf '  [FAIL] router description must explicitly cover repository/Skill instructions\n'
  exit 1
fi
printf '  [PASS] instruction-bearing task discovery trigger\n'
assert_literal "$ROUTER" '`工作流：L1/L2/L3`' 'observable route slot'
assert_literal "$ROUTER" \
  '多文件机械迁移若需要实施分解、可恢复检查点或仓库级验证，走 L3' \
  'mechanical migration planning route'
assert_literal "$ROUTER" '无需 `brainstorming`' 'mechanical migration design boundary'
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
assert_literal "$ROUTER" \
  '子代理直接执行父 Agent 给定的任务契约，无需重新做 L1/L2/L3 路由' \
  'child agent inherits the parent task contract'
assert_literal "$ROUTER" \
  '仍读取并遵循任务明确要求或匹配的 Skills、最近层级 `AGENTS.md` 和适用项目约定' \
  'child agent still follows scoped instructions'
assert_literal "$ROUTER" \
  '用户点名 Skill 时，先读取其当前完整版本再回答' \
  'named Skill is read for read-only requests'
assert_literal "$ROUTER" \
  '由主 Agent 直接完成，不生成 spec/plan' \
  'L1 direct parent-agent route'
assert_literal "$ROUTER" '运行最小充分验证' 'L1 sufficient verification'
assert_literal "$ROUTER" \
  '行为变化先建立能暴露缺失行为的回归或验收证据' \
  'L2 failing evidence before implementation'
assert_literal "$ROUTER" \
  '测试基础设施适用时用 TDD 完成 RED-GREEN' \
  'L2 TDD RED-GREEN route'
assert_literal "$ROUTER" \
  'L3α 设计未定' \
  'L3 unresolved-decision design route'
assert_literal "$ROUTER" \
  'L3β 决策已定' \
  'L3 settled complex-work planning route'
assert_literal "$ROUTER" \
  'Spec: none - requirements supplied directly' \
  'L3β decision-source annotation requirement'
assert_literal "$ROUTER" \
  '回退 L3α 的 Grill' \
  'L3 ambiguity falls back to Grill'
assert_literal "$ROUTER" \
  '完成判据必须是可执行检查' \
  'goal completion criterion must be executable'
assert_literal "$ROUTER" \
  '不得外包给子代理后直接批准' \
  'decision-phase artifacts stay with main agent'
assert_literal "$ROUTER" \
  '判断密度 × 上下文依赖' \
  'main/subagent division of labor principle'
assert_literal "$ROUTER" \
  '已有批准计划时进入执行流程' \
  'L3 approved-plan execution route'
assert_literal "$ROUTER" \
  '当前任务涉及子 Agent、并行工作、worktree/分支收尾或模型/Provider 路由时' \
  'load harness reference for orchestration and provider routing'
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

# 入口 skill 体积门禁（fork-added 2026-08-22）：路由器只放判据与指针，
# 细节必须下沉到目标 skill；触顶时一进一出，不堆叠。
ROUTER_LINES=$(wc -l < "$ROUTER" | tr -d ' ')
ROUTER_BYTES=$(wc -c < "$ROUTER" | tr -d ' ')
if [[ "$ROUTER_LINES" -gt 60 || "$ROUTER_BYTES" -gt 6144 ]]; then
  printf '  [FAIL] router size budget exceeded: %s lines / %s bytes (limit 60 lines / 6144 bytes)\n' "$ROUTER_LINES" "$ROUTER_BYTES"
  exit 1
fi
printf '  [PASS] router size budget (%s lines / %s bytes, limit 60/6144)\n' "$ROUTER_LINES" "$ROUTER_BYTES"

printf 'All adaptive workflow routing checks passed\n'
