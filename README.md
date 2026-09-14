# Superpowers — QuantumMisaka 个人定制 Fork

本仓是 [obra/superpowers](https://github.com/obra/superpowers) 的个人定制 fork，承载本人当前的开发品味，为模型提供可借用的工程方法和必要的协作边界。在已确认的目标、设计与授权内，保留模型选择实现和工作方法的空间。

是否保留某项指导，以其对真实交付的作用判断。随着模型、工具和本人需求变化，已有指导可以缩小、替换或退役。具体维护判据见 [AGENTS.md](AGENTS.md)，演进依据见[设计哲学](docs/superpowers/fork-design-philosophy.md)。上游安装说明不直接代表本 fork 的消费方式。

## 消费与结构

- `skills/`：可组合的工程方法；按任务需要加载。
- 本人的源仓位于 `codex-sync/superpowers/` 子模块，通过父仓 `sync-superpowers.sh --mount` 链接到 `~/.codex/skills/` 与 `~/.agents/skills/`。Codex 是主要消费入口；具体角色与模型选择归现行配置。
- `skills/using-superpowers/references/` 保存具体工具适配；公共技能不固定模型、Provider 或某个 harness 的调用语法。
- `docs/superpowers/` 保存设计、计划、验证与审查报告；[2026-09-14 消融设计](docs/superpowers/specs/2026-09-14-taste-carrier-ablation-design.html) 已确认，本地技能消融已实施。验证、分发边界和剩余优化见[实施记录](docs/superpowers/plans/2026-09-14-taste-carrier-ablation.md)与[状态审查报告](docs/superpowers/reports/2026-09-14-skill-status-review.md)。

## 上游纳入与分发

按上游版本人工纳入，保留 `sync(upstream-vX)` 合并历史：查询上游版本与 SHA，对比上次合入点，审阅相关差异，在隔离分支处理合并并验证受影响部分，再在实际授权内发布 fork、更新消费仓 gitlink。

`AGENTS.md` / `README.md` / `CLAUDE.md` / `GEMINI.md` 为 fork-owned 文件，冲突保留本地所有权。`skills/`、`hooks/`、`tests/` 的上游变更同样按本 fork 设计审阅；无文本冲突不等于应恢复已消融的流程。fork 定制不提交上游。

父仓 `sync-superpowers.sh` 的默认模式同步 fork 与 origin，`--mount` 只负责本机链接；两者都不执行 obra 的版本合并。上游是否有更新以成功的远端查询与 Git 比较为准，不能把查询失败当作零差异。2026-09-14 的已核实基线与现有脚本限制见上述 SPEC。

## 验证入口

`bash tests/skill-content/run-tests.sh` 检查技能元数据、链接、部分结构与适配契约；`tests/codex/*.sh` 覆盖打包和 manifest。按实际变更选择相关检查；结构通过不代表模型已正确执行工作流。

[2026-09-13 子代理路由验证](docs/superpowers/validation/subagent-routing-2026-09-13.md) 记录了预置角色、线程复用与 dirty 审查包的已有证据及局限。后续效果判断结合真实任务，不以文档、测试或代理数量为目标。

## 致谢与许可

上游项目：[obra/superpowers](https://github.com/obra/superpowers)（Jesse Vincent / Primeradiant），MIT 许可。本 fork 沿用 MIT（见 `LICENSE`）；借鉴与原创背景见设计哲学。
