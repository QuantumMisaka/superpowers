# Codex 共享角色：安装与更新

本技能附带 13 个通用角色的[完整定义](role-selection.md)。加载技能后，可以将选定正文与具体任务一起交给通用子代理。下面的可选安装把它们注册为 Codex 原生 `gpt_*` 或 `ds_*` 角色，并配置模型、effort 与沙箱。需要 Python 3.11+；已在 Codex CLI 0.169.0 验证 GPT 原生角色发现与实际调用，两族安装均有隔离配置测试。DeepSeek 的账号连通性由使用者验证，其他 Codex 版本先检查其子代理配置接口。

## 1. 取得同一个 Superpowers 源

已有 QuantumMisaka fork 的使用者更新原安装来源即可。新使用者可以检出：

```bash
git clone https://github.com/QuantumMisaka/superpowers.git ~/.local/share/quantummisaka-superpowers
```

将该 checkout 的 `skills/` 按你的 Codex 技能发现方式挂载。使用 `~/.agents/skills/` 的环境，可以逐个创建同名技能软链；已有同名技能时先确定要使用哪个来源。保留项目中已有的技能入口，也可以加入一句：“行动型任务先读取 using-superpowers，按任务规模选择流程和角色。”插件安装者使用插件提供的技能路径，无需再检出第二份。

下文命令从 `skills/using-superpowers/` 目录执行。源码安装者可先运行：

```bash
cd ~/.local/share/quantummisaka-superpowers/skills/using-superpowers
```

## 2. 选择模型族并预览

```bash
python3 scripts/codex-subagents.py preview --family gpt --codex-home ~/.codex
```

GPT 预设使用此 fork 当前维护的模型分工。DeepSeek 使用 `--family deepseek`，要求有效配置已注册所选 provider；指定其他配置文件时，安装器会同时读取 Codex home 下的基础 `config.toml` 来检查继承的 provider。安装器不配置服务地址或认证。角色的模型必须对你的账号和渠道可用。

如需更换模型，创建自己的 TOML 覆盖文件。例如下例中的值应替换为你已验证可用的模型与 effort：

```toml
[defaults]
model = "your-supported-model"
model_reasoning_effort = "medium"

[roles."final-reviewer"]
model = "your-review-model"
model_reasoning_effort = "high"
```

通过 `--overrides /path/to/your-overrides.toml` 使用它。支持覆盖 `model`、`model_provider`、`model_reasoning_effort`；角色职责和读写类别由共享源维护。安装后更新时保留本地模型映射。

## 3. 应用与核对

```bash
python3 scripts/codex-subagents.py apply --family gpt --codex-home ~/.codex
python3 scripts/codex-subagents.py check --family gpt --codex-home ~/.codex
```

使用覆盖文件时，在首次 preview 和 apply 中都传入 `--overrides`。需要安装到另一个配置文件时，显式传入 `--config /path/to/target.config.toml`，并确保实际启动入口会加载它。一个目标配置管理一个所选族；其他族可以安装到另一配置入口。

安装器只管理其角色文件和注册区块。主模型、认证、MCP、项目设置与其他角色保留；同名非受管角色先报告冲突。修改配置前会备份。它不会在加载技能时自动运行。

检查通过说明配置与共享源一致。开启新 Codex 会话，确认对应 `gpt_*` 或 `ds_*` 出现在可用角色中，再执行一个有界任务，才能确认当前版本、账号和模型调用正常。子代理功能需由当前 Codex 入口启用；检查输出会提示运行配置要求。

**Codex 0.169.0 V2 的权限边界**：本次实测中，角色文件的 `sandbox_mode = "read-only"` 未将子线程权限收窄，子线程继承了父会话的 `workspace-write`，独立探针成功写入测试文件。因此，角色的只读正文与配置不能在该版本下充当强制隔离。需要强制只读审查时，从只读父会话执行，并核对实际权限；共享工作会话中的只读角色按职责约束工作。安装器的静态检查不验证沙箱执行效果。

## 4. 更新

更新所选 fork 的 checkout 或插件版本后，角色正文立即随技能可用。对已经安装的原生角色，再运行同一组 apply/check 命令，并开启新会话；本地模型覆盖继续生效。安装器会识别受管文件的人工改动，处理差异后再更新。

共享角色和模型预设属于该 fork 的同一版本；个人服务和账号配置由各使用者管理。贡献角色改动时修改 `references/roles/`；通用简介和权限在 `assets/subagents/roles.toml`，两族默认模型在 `assets/subagents/presets/`。详细调用规则见 [Codex adapter](codex-tools.md)。
