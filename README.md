# Superpowers — QuantumMisaka Fork

一套面向 Codex 协作者的工程 Skills：从需求与方案讨论，到实现、调试、审查和验证，按任务需要选择工作方法。基于 [obra/superpowers](https://github.com/obra/superpowers) 定制，强调目标清楚、授权内自主推进和以实际成果验收。

本 fork 同时提供 13 个[子代理角色](skills/using-superpowers/references/role-selection.md)。安装 Skills 后即可将角色正文用于通用子代理；需要固定模型分工时，可额外安装 GPT 或 DeepSeek 原生角色。协作者可以独立使用，无需访问维护者的个人配置仓。

## Codex 快速开始

以下源码安装适用于 Linux、macOS 和 WSL。需要已安装并配置好可用模型的 Codex、Git、Python 3.11+；原生角色已在 Codex CLI 0.169.0 验证。先确认本机入口：

```bash
codex --version
git --version
python3 --version
```

Codex 的账号或 provider 沿用你自己的配置。已有本 fork 源码安装时，按原位置更新，尚未配置工作入口的继续第 2 步；通过插件安装者直接从第 2 步开始，第 3 步使用插件内的实际技能路径。已有其他来源的同名技能时，先选择要保留的来源。下方默认使用一个独立源码目录。

### 1. 获取并挂载整套 Skills

```bash
mkdir -p ~/.local/share
git clone https://github.com/QuantumMisaka/superpowers.git ~/.local/share/quantummisaka-superpowers
```

执行下面的脚本，将整套技能逐个挂载到 Codex 可发现的 `~/.agents/skills/`。脚本会先检查所有同名路径；冲突时列出路径并停止，已有正确软链可重复使用。

```bash
python3 - <<'PY_INSTALL'
from pathlib import Path

source = Path.home() / ".local/share/quantummisaka-superpowers/skills"
target = Path.home() / ".agents/skills"
skills = sorted(p for p in source.iterdir() if (p / "SKILL.md").is_file())
if not skills:
    raise SystemExit(f"未找到 Skills：{source}")
conflicts = [target / p.name for p in skills
             if ((target / p.name).exists() or (target / p.name).is_symlink())
             and (target / p.name).resolve() != p.resolve()]
if conflicts:
    raise SystemExit("请先处理同名技能来源：\n" + "\n".join(map(str, conflicts)))
target.mkdir(parents=True, exist_ok=True)
for skill in skills:
    link = target / skill.name
    if not link.is_symlink():
        link.symlink_to(skill, target_is_directory=True)
print(f"已挂载 {len(skills)} 个 Skills；入口：{target / 'using-superpowers/SKILL.md'}")
PY_INSTALL
```

### 2. 配置工作入口

在需要使用这套方法的项目 `AGENTS.md` 中加入以下内容；希望所有项目采用时，加入自己的 `~/.codex/AGENTS.md`（自定义 `CODEX_HOME` 时使用该目录下的 `AGENTS.md`）。保留文件中的其他项目约定。

```markdown
行动型请求、开发治理和进度核对，先读取 using-superpowers Skill，按任务规模选择工作流。
对可独立交付且分工收益明确的工作，按角色定义主动委派；主代理负责协调、验收和完整交付。
```

挂载让 Codex 能发现技能，这段入口让工作请求能够触发使用。`using-superpowers` 会按需要引用其余 Skills，因此默认安装整套目录。

### 3. 选择子代理使用方式

默认可以沿用 Codex 已有的通用子代理模型，按需读取角色正文。要启用或核对原生子代理工具，先运行 `codex features list`；在已验证的 0.169.0 中，可用 `codex features enable multi_agent_v2` 启用 V2。其他版本按该版本实际提供的开关操作。

如需采用 GPT 的角色模型预设，执行：

```bash
cd ~/.local/share/quantummisaka-superpowers/skills/using-superpowers
python3 scripts/codex-subagents.py preview --family gpt --codex-home ~/.codex
```

先核对 preview 中的模型在你的账号可用。需要替换模型时，先按[子代理配置说明](skills/using-superpowers/references/subagent-install.md)准备本地覆盖文件；确认后再应用：

```bash
python3 scripts/codex-subagents.py apply --family gpt --codex-home ~/.codex
python3 scripts/codex-subagents.py check --family gpt --codex-home ~/.codex
```

使用独立 `CODEX_HOME` 时将 `--codex-home` 换成实际目录。DeepSeek 使用 `--family deepseek`，需要已有可用 provider。配置继承、冲突处理及权限边界见子代理配置说明。其中 Codex 0.169.0 V2 的角色只读设置未在实测中收窄父会话权限，需要强制只读时应使用只读父会话并核对权限。

### 4. 开启新会话并验证

重启 Codex，在自己的项目中先发送：

> 请读取 using-superpowers，说明实际读取路径，并根据当前项目列出适用的工作方法；暂不修改文件。

确认路径指向你选择的 fork，且能读取角色定义。若装了原生角色，再发送：

> 请让 gpt_context_analyst 只读查看项目入口并概述结构，等待它返回后总结。

DeepSeek 对应使用 `ds_context_analyst`。以实际子代理调用及返回结果验收；静态 check 通过只表示安装内容一致，模型调用还取决于你的账号、provider 和运行版本。

## 日常更新

源码安装者在安装目录执行：

```bash
git -C ~/.local/share/quantummisaka-superpowers pull --ff-only
```

软链会读取更新后的内容。若版本新增了技能目录，重新执行挂载脚本；若安装了原生角色，重新执行对应族的 apply/check，再开启新会话。本地模型覆盖会保留。通过插件安装者更新所选 QuantumMisaka fork 插件来源，并使用其实际技能路径；无需重复源码安装。

OpenCode 用户可复用同一套 Skills，入口见[OpenCode 接入说明](https://github.com/QuantumMisaka/superpowers/blob/main/.opencode/INSTALL.md)；当前公共原生角色安装器面向 Codex。

## 维护与许可

贡献与维护请从[AGENTS.md](https://github.com/QuantumMisaka/superpowers/blob/main/AGENTS.md)进入，源布局、验证、上游纳入与发布流程集中在[维护文档](https://github.com/QuantumMisaka/superpowers/blob/main/docs/superpowers/maintenance.md)。

上游作者 Jesse Vincent / Primeradiant；本 fork 沿用 [MIT 许可](LICENSE)。
