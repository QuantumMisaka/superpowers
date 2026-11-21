# Codex 共享角色：安装与更新

本技能内置 13 个通用角色的[完整定义](role-selection.md)。加载技能后，即可将选定角色正文与具体任务一并交由通用子代理执行；下方可选安装步骤可将其注册为 Codex 原生 `gpt_*` 或 `ds_*` 角色，并自动配置对应的模型、推理强度（effort）与沙箱模式。运行环境需 Python 3.11+；当前已在 Codex CLI 0.169.0 上完成 GPT 原生角色的发现与实跑验证，两族安装器均通过隔离配置测试。DeepSeek 账号连通性由使用者自测确认，使用其他 Codex 版本前建议先核对其子代理配置接口。

## 1. 进入已安装的技能目录

首次接入请先按仓库 [README 的 Codex 快速开始](../../../README.md#codex-快速开始)安装整套 Skills、配置 AGENTS 入口并确认子代理工具可用，随后按本页完成原生角色注册。

以下命令均从实际安装的 `skills/using-superpowers/` 目录执行。使用 README 默认源码安装路径时：

```bash
cd ~/.local/share/quantummisaka-superpowers/skills/using-superpowers
```

若使用其他检出路径或插件目录，切换至对应安装位置即可。

## 2. 选择模型族并预览配置

```bash
python3 scripts/codex-subagents.py preview --family gpt --codex-home ~/.codex
```

GPT 预设沿用当前 fork 维护的模型分工；DeepSeek 使用 `--family deepseek`，要求有效配置中已注册对应 provider（指定自定义配置文件时，安装器会同步读取 Codex home 下的基础 `config.toml` 以校验继承的 provider）。安装前确认所选模型对当前账号与渠道可用；服务地址与认证凭证由本地 Codex 配置管理。

如需自定义模型或推理强度，可新建本地 TOML 覆盖文件（将示例值替换为你账号下已验证可用的模型与 effort）：

```toml
[defaults]
model = "your-supported-model"
model_reasoning_effort = "medium"

[roles."final-reviewer"]
model = "your-review-model"
model_reasoning_effort = "high"
```

通过 `--overrides /path/to/your-overrides.toml` 传入覆盖文件。支持覆盖 `model`、`model_provider` 与 `model_reasoning_effort`，角色职责与读写分类继续由共享源统一维护；后续更新角色时会自动保留本地模型映射。

## 3. 应用配置与核验

```bash
python3 scripts/codex-subagents.py apply --family gpt --codex-home ~/.codex
python3 scripts/codex-subagents.py check --family gpt --codex-home ~/.codex
```

使用覆盖文件时，在 `preview` 与 `apply` 中均传入 `--overrides`。若需写入其他配置文件，显式传入 `--config /path/to/target.config.toml`，并确保对应启动入口会加载该文件；单个配置文件管理一个模型族，另一模型族可安装至独立的配置入口。

安装器采用显式手动触发，且只接管自身维护的角色文件与注册区块：主模型、认证、MCP、项目配置与其他自定义角色均原样保留；遇同名非受管角色时先报冲突，修改配置前自动创建备份。

`check` 通过表明本地配置已与共享源对齐。接下来重启新 Codex 会话，确认对应的 `gpt_*` 或 `ds_*` 角色已出现在可用列表中，并用一个边界清晰的小任务实跑一次，即可完整确认当前版本、账号与模型链路畅通（子代理开关须在当前 Codex 入口启用，检查输出会给出对应配置提示）。

**Codex 0.169.0 V2 权限注意事项**：实测发现，该版本中角色配置的 `sandbox_mode = "read-only"` 尚未收窄子线程写入权限，子线程会继承父会话的 `workspace-write`（独立探针实测可写入测试文件）。因此，若审查场景需要硬性只读隔离，应从只读父会话发起并复核实际权限；在共享可写会话中，只读角色依托职责约定自律执行。安装器的 `check` 命令用于静态核对配置一致性，沙箱隔离效果须按实际版本行为确认。

## 4. 后续更新

拉取新版本 fork 源码或更新插件后，最新角色正文即刻随技能生效。若已安装原生角色，重新执行一次 `apply` 与 `check` 并开启新会话即可同步更新（本地模型覆盖自动保留）；若受管文件存在人工修改，安装器会先提示差异以便合并处理。

共享角色定义与模型预设随该 fork 版本同步演进，个人服务地址与账号配置由使用者本地维护。贡献角色改动时：正文修改 `references/roles/`，通用简介与权限分类修改 `assets/subagents/roles.toml`，两族默认模型修改 `assets/subagents/presets/`。详细调用规范见 [Codex adapter](codex-tools.md)。
