# 上游 v7.0.0 选择性合入（2026-10-18）

本次以 obra/superpowers `v7.0.0`（`bb92a777`）为审阅基线，保留 `sync(upstream-v7.0.0)` 双父合并历史。清单版本为 `7.0.0-qm.1`，表示本 fork 审阅并纳入了适用变更，不承诺与上游文件逐一相同。原有 L1–L3、双相协作、Markdown 规范源和 harness 适配由本 fork 继续维护。

## 纳入

- SDD 工作区记录 plan 路径，避免同名计划共用目录；已有无标记目录可继续使用，已有 `.superpowers/sdd/.gitignore` 不再被覆盖。
- SDD 审阅包拒绝空范围和不属于基线后代的 HEAD；`task-brief`、`review-package` 调用辅助脚本时兼容丢失可执行位的安装包。
- brainstorming 服务器按字面插入 HTML 片段，避免 `$&` 等替换符改写内容；测试失败时保留清理服务器的 `finally` 路径。
- 设计稿跨执行者交接且错误猜测会导致返工时，可选做一次「可开工检查」；只查会改变实施方案的真实缺口，不固定角色和轮数。
- Hermes 注册技能时携带 frontmatter 描述，供其原生技能目录选择；同时修正一项仍断言上游旧英文标题的本 fork 测试。
- 现有平台清单统一标示 fork 版本；未增加新平台市场包。

## 保留 fork 取舍

- 不导入上游整份 brainstorming、executing-plans、writing-plans：其触发和固定步骤与本 fork 的轻量路由不同。
- 不导入 `diagnosing-superpowers` 的固定七分析员流程；诊断按实际问题选择方法。
- 本机 OpenCode 为 1.18.30，沿用已验证的 V1 插件；上游 V2 注册实现待实际 V2 消费需求出现后单独验证。Muse、Antigravity、Windows hook 等平台功能不因版本号自动启用或扩展。本轮运行现有 OpenCode 与 hook 检查以确认保留路径。
- 上游文档、发布说明与市场包保持上游历史可追溯，但不覆盖本 fork 的 README、AGENTS.md、CLAUDE.md 和本地约定。

## 验证

- `bash tests/claude-code/test-sdd-workspace.sh`：同名计划、范围拒绝、忽略规则及原有场景通过。
- `node tests/brainstorm-server/server.test.js`：34 项通过，包含字面替换符。
- `bash tests/skill-content/run-tests.sh`：结构与引用检查通过；不据此声称模型行为已验收。
- `python3 -m pytest tests/hermes -q`：25 项通过；`bash tests/opencode/run-tests.sh`：2 项通过；`bash tests/hooks/test-session-start.sh`：现有 hook 场景通过。

本报告只记载本次子仓选择性合入。dsh 分级编排、完成通知与跨模型验收由父仓相应变更及验证记录说明。

边界：SDD 同名计划隔离已验证顺序初始化；工作区认领保留上游实现，并发首次认领不具备原子性。本轮控制器按计划串行初始化；若需要多控制器并发初始化，需另行加锁与验证。版本脚本依赖的 yq 本机未安装，本轮以 Python 核对九处版本清单一致，未声称该脚本通过。
