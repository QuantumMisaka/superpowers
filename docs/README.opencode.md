# Superpowers for OpenCode（Codex-first fork）

Codex 是默认开发入口，OpenCode 是第二生产入口和独立复核入口。
两端共享 Superpowers 的设计、计划、TDD、审查与验收规则；
工具分发、权限和会话恢复属于各自 harness，不构造嵌套 CLI 调度层。

## 安装与发现

优先复用已经挂载给 Codex 的 `~/.agents/skills`，或明确选择项目 pinned Skills。
操作见 [接入说明](../.opencode/INSTALL.md)。
OpenCode 原生发现这些目录，无需为了共享规则再安装另一份上游 plugin。

本机验证（2026-09-10）：OpenCode 1.18.30 在无外部插件模式下发现
using-superpowers、brainstorming、subagent-driven-development、test-driven-development；
其路径与 Codex 链接解析到同一份个人源码。版本和路径是本次观察，不是其它机器的保证。

```bash
opencode debug skill --pure
opencode debug agent misaka-safe --pure
```

`--pure` 验证原生发现，不证明另装插件时的行为；需要验证插件时应另做相应检查。
调试输出可能包含完整 Skills 或配置，只筛选所需的 name/location/permission，
不把原始配置、凭据或无关私有材料写入交付报告。

## 子代理

详见 [OpenCode 原生机制适配](../skills/using-superpowers/references/opencode-tools.md)；
Codex 对照见 [Codex adapter](../skills/using-superpowers/references/codex-tools.md)。
原生工具支持什么，以当前 agent 可见 schema 为准；子会话不意味着独立文件系统。

使用已配置的开发 primary，不新建一套模型或角色矩阵。若项目将 `task` 或
`skill` 禁用，接入不代表可以绕过禁用；确认该入口是不是受限产品 agent。
例如 app-tools 的旧 Adam 远程 build 配置有意收窄本地工具，不应为 SDD 改开。

## 全局指令与版本

全局 `AGENTS.md` 和项目入口负责要求加载 using-superpowers；Skill discovery 本身不
自动执行规则。Codex 与 OpenCode 应消费同一份已批准全局指令，避免 OpenCode
的旧同步副本重新引入已取消的治理硬门禁。

更新共享源后用新会话检查正文及 location。个人安装源与项目 pinned tree 的发布状态分别记录；
本地同步不是远端发布，也不自动推进父仓 gitlink。

## 可选插件

仓库仍保留 `.opencode/plugins/superpowers.js`，用于确实需要 message bootstrap 和
skills-path 注册的安装方式。它不是原生共享安装的前置，也不应与已有共享入口重复部署。
使用插件前核对所装版本的 hook 与 Skill 来源；不要按旧说明自动安装 obra 上游，
或递归删除已有安装与缓存。

## 依据与验证边界

- [OpenCode 原生 Skills](https://opencode.ai/docs/skills/)
- [OpenCode agents](https://opencode.ai/docs/agents/)
- 本机 `opencode debug skill --pure`、`debug agent --pure` 与实际软链解析

这些检查证明发现与配置解析，不证明模型已执行一次完整 SDD。
真实任务验证另行记录，不以工具名出现、字符串匹配或口头声称代替执行证据。
