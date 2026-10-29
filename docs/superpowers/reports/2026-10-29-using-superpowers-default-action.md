# using-superpowers 默认姿态优化记录

**日期：** 2026-10-29

**对象：** `skills/using-superpowers` 入口及其协作模式相关 skill。

**性质：** 设计与验证记录，不是新的流程门禁、台账或强制审查要求。

## 目的

针对 2026-10-22 至 10-29 实际会话中反复出现的六类摩擦：

- 过度锁定：每遇到问题就新增字段、角色、门禁、目录或检查；
- 擅自改范围：把“看起来更合理”当成已授权；
- 已授权还请示：重复确认并行化、push、集成等已授权动作；
- 验证替代交付：用测试数量、审查次数、日志量证明进展；
- 防御性表达：结论前后堆“不代表/不等于/不能证明”，读者先看到防御；
- 无依据回滚：不查决策记录就恢复已删除字段或推翻既有设计。

优化目标不是增加约束，而是把默认动作改成正向、可执行的行为：先交付最小闭环，已有授权不重复请示，普通实现自主推进，汇报先给结论，案例库按需参考而不是逐条对照。

## 设计

### 入口默认姿态

- 最小闭环优先；可逆实现自主推进，不把可逆操作变成审批。
- 已有同范围授权持续有效；先查会话、`AGENTS.md` 和既有 Ruling。
- 只在缺少不可逆/破坏性、安全敏感或外部动作授权，实质改变已批准目标、面向消费者的设计或交付物身份，或确无可靠路径时回到决策相。
- 不新增门禁解决行为问题；优先改默认动作、示例和汇报方式。
- 改既有设计前查决策记录；找不到依据就说“未找到”。
- 汇报先给结论、交付或冲突；测试数量、审查次数、日志是证据，不是进展。

### 行动前自检

1. 这是用户目标，还是从文档/惯例推出来的要求？
2. 授权是否已经存在？
3. 最小可交付闭环是什么？当前动作在闭环上，还是在加外围？
4. 改/删/回滚既有设计前，是否知道它为什么存在？

### 协作模式

- 项目默认直接集成 `main` 时，在当前 checkout 实现；不默认建分支、worktree 或 PR/MR。
- 需要隔离时使用 detached worktree；记录 base，提交后用 `refs/superpowers/work/<name>` 保护 work commit，集成与清理验证后再删除。
- 分支/PR 模式只在项目或用户明确要求时使用。
- 并行分派按收益、写集是否重叠、是否存在共享状态和 harness 容量判断，不以任务/失败数量本身触发。
- 完成声明按交付行为与验证范围报告，不以检查数量替代。

## 非目标

- 不重写 `brainstorming`、`writing-plans`、`systematic-debugging`、TDD、review、SDD 的方法论主干。
- 不新增 SPEC/PLAN 强制、审批门、台账、评分卡或固定审查轮次。
- 不把 `references/behavior-failure-modes.md` 当检查清单；它是按需案例参考。
- 不把本轮优化本身做成新的治理流程。

## 变更

- `skills/using-superpowers/SKILL.md`：默认姿态、行动前自检、汇报/纠错契约。
- `skills/using-superpowers/references/behavior-failure-modes.md`：失败模式与正例，按需参考。
- `skills/executing-plans/SKILL.md`、`skills/subagent-driven-development/SKILL.md`：按项目协作模式选择工作区；去掉无条件 skill 链。
- `skills/using-git-worktrees/SKILL.md`、`skills/finishing-a-development-branch/SKILL.md`：local-main 默认、detached worktree recovery、local-main 集成菜单。
- `skills/dispatching-parallel-agents/SKILL.md`：按 work package 收益/写集/共享状态触发；删除上游宣传段。
- `skills/verification-before-completion/SKILL.md`：报告交付行为与范围，而非检查数量。
- `tests/skill-content/workflow-consistency-scenarios.md`：V–AA 回放场景。
- `tests/skill-content/test-adaptive-workflow-routing-contract.sh`：入口预算与新 reference 链接检查。

提交：`3309191`、`3ee2aed`、`d5f4dbd`、`3ed7599`、`6f354e7`、`d35df2b`。

本记录在 `d35df2b` 之后单独提交；它记录设计与验证，不改变上述 skill 行为。

## 验证

- `bash tests/skill-content/run-tests.sh`：退出 0。
- `git diff --check`：通过。
- 入口：54 行 / 4,965 字节，低于 60 行 / 6,144 字节预算。
- 独立 DeepSeek reviewer：最终 `ACCEPT`；V/W/X/Y/Z/AA 场景回放在 `3309191` 上返回预期动作。
- GLM `glm-5.3`：`3309191` `REQUEST_CHANGES`；`3ee2aed`、`d5f4dbd`、`3ed7599` 均 `APPROVE`。`d35df2b` 是后续去锁定的删减，未再起新一轮审查。
- 审查包保存在本机 `~/.superpowers/review-packages/`；它们是外部证据，不写入仓库。

## 集成状态

- `codex-sync/superpowers` 本地 `main`：已包含优化提交与本记录，工作树干净。
- `origin/main` 与 `codeup/main`：已推送同一 `main`。
- 父仓 `personal` 的 `codex-sync/superpowers` gitlink：已记录该子仓 `main` 并推送父仓。
- 本机 `~/.codex/skills/using-superpowers` 与 `~/.agents/skills/using-superpowers`：符号链接到本仓，已即时生效。
- 父仓其余 `codex-sync` config 变更如经确认同步，属于独立的 config sync，不改变本优化范围。

远端推送、父仓 gitlink 收口和跨机 pin 更新按实际授权执行；本文不把它们变成合入门禁。
