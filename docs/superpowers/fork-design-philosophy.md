# Fork 设计哲学（QuantumMisaka/superpowers）

> 本 fork 关于"superpowers 如何构建、如何消费"的基本思考模式的聚合入口，从 2026-07 以来的 fork 实践中提取。维护本 fork（含 agent 会话）修改 skills、流程或文档前先读本文。
> 与上游的关系：obra/superpowers 是上游，本 fork 按版本同步（`sync(upstream-vX)` commits）；本文只描述与上游原始设计的不同点，来源诚实——借鉴与原创分别标注。

## 1. Grill 元规则：一个协议覆盖所有审批点（原创）

所有需要人类审批/澄清的位置——brainstorming 设计确认、writing-plans 计划审批、executing-plans 疑虑、SDD 硬停——复用同一个 Grill 协议：至多 3 个阻塞问题，每问附推荐答案与可执行验收信号；能从代码库查证的先查证再问。不发明新的审讯仪式。

由此 brainstorming 被简化为"Grill 快路径是默认，完整 spec 产出仅是升级路径"（§1/§2 结构）。仪式随任务缩放：有界任务一问一答即过，只有需要固化公共行为/架构边界/跨团队约定时才产出设计文档。

参考：`bff72f7`（integrate grill-me as default path）、`fa76b4d`（grill-spirit pass: protocol reuse）。注：上游 v6.3.0 在 #2063 独立收敛到"ceremony 随任务缩放"，本 fork 先行到达，方向一致。

## 2. 模型路由不绑 GPT：按任务能力选，不跟随主进程（原创）

Codex 多 Provider 现实（OpenAI V2 + bailian/deepseek/scnet V1）下，子代理路由按任务能力选择 Provider 与档位，不默认跟随主会话模型：普通实现可互换，工程判断与代码审查偏强档，大上下文归纳/进度/文档偏 Qwen。三条配套原则：

- **configuration-owned**：角色标识、模型、effort 归 Codex 配置（`~/.codex/agents/`），skill 只用抽象角色名，不在 skill 文本里写死模型名；
- **双轨**：V1/V2 多 agent 指导并存在 `skills/using-superpowers/references/codex-tools.md`，不把 V2-only 编排建议写成普适规则;
- **诚实边界**：分工是本地实践假设，不是模型能力定律；随 benchmark 与社区证据更新。

参考：fork 原创 spec `docs/superpowers/specs/2026-07-31-adaptive-workflow-dual-provider-routing-design.html`、commit 链 `32692c2 → 266b839 → c9ac1db`、validation/ 契约测试。

## 3. 优先抽象为 meta-rules，不写死规则（原创）

能用一条可推理的原则覆盖的，不枚举具体规则：

- 工作流路由是 meta-rule——"选择能可靠完成目标的最轻工作流，按歧义、行为风险、跨模块协调和返工成本升级"，L1/L2/L3 只是它的实例化；
- "Rulings, not stalls" 用判断纪律 + 四类硬停取代枚举 STOP 清单：计划执行不等人，冲突与歧义由执行者裁决并记账，只有不可逆/安全/跨工作区副作用/计划彻底损坏才停；
- 每个流程 skill 用三个元属性定义：触发范围（何时**不**加载与何时加载同等重要）、显式退出条件、最小产物。

判据：新增规则时先问"这是某条 meta-rule 的实例吗？"若是，写 meta-rule 不写实例；实例只进触发条件或示例。

## 4. 正向目标优先，窄禁止为例外（doctrine 借鉴上游，扩展原创）

doctrine 来自上游 `docs/superpowers/specs/2026-06-10-positive-instruction-redesign-design.md`（随 v6.x 合并带入，非 fork 原创）：组合型禁止在模型对输出有自己的议程时会反噬，正向配方（"你的产出应包含 (1)…(5)"）才被稳定采纳。

fork 的扩展：把它从 skill 文本技巧升格为设计规则——对输出形状和条件路由使用正向契约："当条件 X 成立，产出 Y，并用 Z 证明"。只有三类情况使用窄范围禁止：真实安全边界、不可逆外部动作、已被行为评估证明会被模型绕过的纪律问题。

执法：`tests/skill-content/test-positive-evidence-language.sh` mutation 测试保护正向证据契约（`5eebdce`、`bc83284`）。

## Fork 维护纪律（自 CLAUDE.md 迁入）

本 fork 为多 Provider Codex 使用定制，刻意比上游轻。修改 skills 时：

- 每个流程 skill 必须定义三件事：触发范围、显式退出条件、最小产物。
- 每个审批/提问点走 brainstorming §1 Grill 协议；不发明新的审讯仪式。
- 子代理 dispatch 必须携带验收证据（精确命令 + 期望输出）。
- 新增任何 per-turn/per-session 义务前，先移除或合并一个既有义务。权重预算零和。
- V1/V2 多 agent 指导双轨存于 `skills/using-superpowers/references/codex-tools.md`。

## 证据索引

| 模式 | 承载位置 |
|---|---|
| Grill 元规则 | brainstorming §1/§2 结构 · CLAUDE.md/AGENTS.md 指针 · commits bff72f7/fa76b4d |
| 多模型路由 | references/codex-tools.md · spec 2026-07-31 · docs/superpowers/validation/ |
| meta-rule 抽象 | using-superpowers L1/L2/L3 · executing-plans Rulings · 本文维护纪律 |
| 正向优先 | spec 2026-06-10（上游）· spec 2026-07-31 语言形式节（fork 扩展）· test-positive-evidence-language.sh |
