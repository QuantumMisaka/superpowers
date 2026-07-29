---
name: using-superpowers
description: 会话开始时选择最轻的工作流路由。子代理执行特定任务时忽略本 skill。
---

# Using Superpowers

分类请求，然后行动。例行工作不走仪式。

**子代理规则：** 如果你是作为子代理被分派执行特定任务的，忽略本 skill，直接执行任务。

## 路由表

| 请求类型 | 路由 |
|---|---|
| 提问、解释、查询、查看命令输出（无变更） | **直接回答** |
| 小而明确的变更，验收标准已知 | **轻量交付：** 检查相关代码，行为变更用 `test-driven-development`，完成前用 `verification-before-completion`。无需 brainstorming 或 plan 文件。 |
| Bug、测试失败、flaky、未解释症状 | **调查：** 先 `systematic-debugging`，再走轻量交付。 |
| 新行为 + 产品/UX/架构/跨系统决策；验收标准不清；或显式设计请求 | **完整设计：** `brainstorming` → 设计确认后 `writing-plans`。 |

安全姿态、公共 API/schema/持久化数据、依赖变更和破坏性操作，除非已有批准的 spec 固定了决策，否则走完整设计。

明确的多步任务可直接用 `writing-plans`（无需重复 brainstorming）。有界歧义先查事实再问阻塞问题，不自动升级为完整设计。

**【强制】** 路由选定 skill 后，先调用该 skill 再执行它管辖的动作。选定的 skill 指令是必须遵循的。路由本身保持轻量。

显式指定的 skill 优先（除非用户在问它是否适用）。用户和仓库指令优先于 skill 默认值。

## 顺序

多个 skill 适用时：

1. 选路由
2. 执行流程 skill（`brainstorming` 或 `systematic-debugging`）
3. 执行实现 skill（如 `test-driven-development`）
4. 成功声明前用 `verification-before-completion`

`references/` 下的文件仅在当前 harness 需要工具替代时读取。
