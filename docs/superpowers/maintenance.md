# Superpowers fork 维护与分发

协作者接入以[README](../../README.md)为入口；维护原则与文件所有权以[AGENTS](../../AGENTS.md)为准。本页集中维护源布局、验证、上游纳入和发布步骤。

## 源与消费关系

| 资产 | 维护位置与消费方式 |
| --- | --- |
| 工程方法 | `skills/*/`；`using-superpowers` 是入口，按任务加载支撑技能 |
| 通用角色正文 | `skills/using-superpowers/references/roles/`，唯一可编辑源 |
| 角色简介与权限类别 | `skills/using-superpowers/assets/subagents/roles.toml` |
| GPT／DeepSeek 默认路由 | `skills/using-superpowers/assets/subagents/presets/` |
| Codex 公共安装器 | `skills/using-superpowers/scripts/codex-subagents.py`；维护受管角色和注册区块 |
| harness 工具适配 | `skills/using-superpowers/references/*-tools.md`；公共方法与模型/provider 配置分开 |
| 设计与证据 | 本目录下 `specs/`、`plans/`、`reports/`、`validation/` |

维护者的个人检出位于 personal 仓的 `codex-sync/superpowers/` 子模块，由父仓 `sync-superpowers.sh --mount` 挂载到 `~/.codex/skills/` 与 `~/.agents/skills/`。personal 消费共享角色加私有模型路由，生成自己的兼容快照；协作者使用 README 中的独立安装，不依赖该父仓脚本。

修改角色时先改本仓源，再生成和检查消费方；维护者个人渠道差异留在个人覆盖配置。公共角色和配置安装的能力与限制见[子代理说明](../../skills/using-superpowers/references/subagent-install.md)。

## 选择验证

按实际变更选择检查：

```bash
bash tests/skill-content/run-tests.sh
python3 -m unittest discover -s tests/codex -p 'test_subagent_installer.py'
bash tests/codex/test-package-codex-plugin.sh
```

第一项覆盖技能结构和部分适配契约；第二项覆盖安装、冲突与配置保留；第三项覆盖已提交源码的插件归档。文档调整核对链接和命令；涉及挂载步骤时，用临时目录验证首次安装、重复执行和同名冲突。结构通过不代表模型已正确执行工作流。

行为变化采用有界真实任务验证，分别报告配置发现、实际角色调用、模型路由和权限效果。最近的[共享角色验收](validation/shared-subagents-2026-11-17.md)记录了原生/通用派发及 Codex V2 沙箱继承边界；[早期路由验证](validation/subagent-routing-2026-09-13.md)保留其原时点证据。

## 上游纳入

按上游版本人工纳入，保留 `sync(upstream-vX)` 合并历史：查询上游版本与 SHA，对比上次合入点，审阅相关差异，在有实际隔离需要的工作区处理合并并验证，再在任务授权内发布 fork、更新消费仓 gitlink。文件所有权与合并判断遵循 AGENTS。

当前选择性基线为上游 v7.0.0；Codex fork 清单版本 `7.0.0-qm.2` 包含共享角色和可选安装，其他 harness 清单按各自发布维护。该版本不表示所有上游平台实现已完整纳入；依据见[选择性合入记录](reports/2026-10-18-upstream-v7-selective.md)。

父仓 `sync-superpowers.sh` 默认同步 fork 与 origin，`--mount` 只更新本机软链；两者都不执行 obra 的版本合并。上游是否更新，以成功的远端查询与 Git 比较为准。

## 发布与跨机更新

1. 确认本轮变更范围、工作区状态与相关验证，提交可审阅源码。
2. 按授权发布到 QuantumMisaka fork 的实际分发远端；发布前核对身份、仓库权限和目标引用，发布后回读提交。既有上游 marketplace 同步脚本有自己的目标仓库，不作为本 fork 的默认发布入口。
3. 个人消费仓更新 submodule pin，重新生成兼容快照并验证；公共源先可达，消费仓再引用该提交。
4. 协作者更新已选源码或插件；源码挂载新增技能、原生角色重新 apply/check 的操作，以 README 与子代理说明为准。

Codex 插件打包入口为 `scripts/package-codex-plugin.sh`，从 Git ref 提取运行资源，并需要已有包提供的技能元数据。`README.md` 与 `skills/` 随包发布；`AGENTS.md` 等维护入口、`docs/` 和测试不随运行包发布。修改资源引用时同时检查源码与包内的相对路径。插件清单应准确标明 fork 来源及上游归属。

## 设计与历史入口

[设计哲学](fork-design-philosophy.md)解释维护判据。已确认的[消融设计](specs/2026-09-14-taste-carrier-ablation-design.html)、[实施记录](plans/2026-09-14-taste-carrier-ablation.md)与[状态审查](reports/2026-09-14-skill-status-review.md)保留各自时点的决策和验证；后续维护不把历史状态当作当前运行结论。
