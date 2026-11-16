# 开发入口

本仓是 obra/superpowers 的 QuantumMisaka 定制 fork。[README.md](README.md) 面向协作者，提供完整安装、使用验证和更新路径；[维护文档](docs/superpowers/maintenance.md)集中源布局、检查、上游纳入和发布操作。跨项目品味沿用本人已提供的现行 USER_TASTE，不在本仓另存副本。

## 开发维护准则

依据：2026-08-26 开发品味判据及 2026-09-14 本人确认的[消融设计](docs/superpowers/specs/2026-09-14-taste-carrier-ablation-design.html)。

- **意图锚定**：复用已有需求、设计、计划或验收记录，保持目标与范围清楚，不为每次修改另建文档。
- **方法自主**：在已确认的目标、设计与授权内，自主选择实现和工作方法；实质改变这些边界时，只回到受影响的决策。
- **变更相称**：保持职责清楚、diff 可审阅，允许必要的内部调整与行为等价实现，不顺手扩展无关工作。
- **断言行为**：保护真实行为与效果，避免锁定偶然措辞、实现形状和历史快照；必要的科学来源、产物完整性与正式公共文本契约按其实际用途验证。
- **验证最小充分**：用当前有效证据支持交付声明，复用输入未变的检查；不为检查数量、覆盖率或流程完整感制造测试。方法参见 [writing-good-tests](skills/test-driven-development/writing-good-tests.md)。
- **指导可演进**：优先消融重复义务、过宽触发和实现锁定，保留有用方法与清晰退出路径。依据本人当前明确要求和任务证据调整，历史案例与模型表现不自动成为通用禁令。
- **入口按读者组织**：README 承担协作者从零接入；本文件维护贡献与治理约定；操作细节及历史证据进入文档系统。相同事实只维护一处，其他入口链接复用。
- **保留 fork 所有权**：`AGENTS.md`、`README.md`、`CLAUDE.md`、`GEMINI.md` 为 fork-owned 文件；上游冲突保留本地所有权。技能、hooks 和测试的上游差异也按本 fork 设计审阅，无文本冲突不代表恢复已消融流程。fork 定制不提交上游。
- **规范与阅读视图分开**：新建 spec / plan 以 Markdown 为唯一可编辑源，HTML 按需生成；历史 HTML 规范保留原地位。具体呈现见[指南](skills/brainstorming/references/presentation.md)。
