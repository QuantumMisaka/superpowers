# Superpowers — QuantumMisaka 个人定制 Fork

本仓是 [obra/superpowers](https://github.com/obra/superpowers) 的个人定制 fork，是本人工程开发模式的承载模块：为多 Provider Codex 定制的 superpowers 方法论，刻意比上游轻。上游原版 README（各 harness 安装指引、商业服务等）不适用于本仓。

## 这个 fork 是什么

- **消费方式**：skills 本体在 `skills/`，经 `~/.codex/skills-repos/superpowers/skills/*` 符号链接进 `~/.codex/skills/`，以 `superpowers:*` 命名空间暴露给 Codex，会话开始自动触发入口路由。
- **与上游的差异**（完整思想见 [`docs/superpowers/fork-design-philosophy.md`](docs/superpowers/fork-design-philosophy.md)）：

| 方面 | 上游 | 本 fork |
|---|---|---|
| 设计确认 | 完整 brainstorming 仪式 | Grill 快路径为默认，spec 产出仅为升级路径 |
| 模型路由 | 单 provider 隐式 | 按任务能力 × 多 Provider（OpenAI V2 + bailian/deepseek/scnet V1 双轨） |
| 规则风格 | 枚举式规则为主 | meta-rule 优先 + 正向目标（窄禁止仅限安全/不可逆/已证可绕过三类） |
| 入口技能 | 英文 | 中文优先（`using-superpowers` / `brainstorming` 中文重写） |
| 计划执行 | STOP 清单停下询问 | Rulings-not-stalls 裁决纪律 + 四类硬停 + dispatch 验收证据 |
| TDD | 逐行为 RED-GREEN | 增补反点对点语料触发器（表驱动合并、文本契约结构化断言） |

## 与上游同步

- 按上游版本同步（`sync(upstream-vX)` merge commits）；上游承载行为的内容（`skills/`、`hooks/`、`tests/`）照常合并。
- `AGENTS.md` / `README.md` / `CLAUDE.md` / `GEMINI.md` 为 fork-owned 文件，冲突 resolve ours。
- fork 内容不提交上游。

## 结构与验证

- `skills/`：14 个 skill；`skills/using-superpowers/references/` 为 harness 专属 reference（`codex-tools.md` = 多 Provider 路由权威文本；`kimi-code-tools.md` = Kimi Code 编排映射，扩展上游 `.kimi-plugin/plugin.json` 的基础映射）。
- 契约测试：`bash tests/skill-content/run-tests.sh`（路由契约 / 正向证据 mutation / 设计产物 / worktree submodule）+ `tests/codex/*.sh`（打包与 manifest）。
- `docs/superpowers/`：设计哲学、specs、plans、validation 存档。

## 致谢与许可

上游项目：[obra/superpowers](https://github.com/obra/superpowers)（Jesse Vincent / Primeradiant），MIT 许可。本 fork 沿用 MIT（见 `LICENSE`），借鉴与原创边界在设计哲学文档中逐条标注。
