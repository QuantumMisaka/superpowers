# Superpowers 接入 OpenCode

本 fork 以 Codex 为默认开发入口，OpenCode 为第二生产与独立复核入口。
共享同一份 Skills 核心，不要求 OpenCode 调用 Codex，也不改变 OpenCode 的模型供应商。

## 已有 Codex 安装：优先复用

OpenCode 原生扫描 `~/.agents/skills/*/SKILL.md`。
若 Codex 的 Skills 已挂载到这个目录，先检查实际发现结果：

```bash
opencode --version
opencode debug skill --pure
opencode debug agent misaka-safe --pure
```

最后一条使用本机已经配置的 primary 名称；没有 `misaka-safe` 时换为自己的开发 primary。
核对 using-superpowers、brainstorming、SDD、TDD 的 location 解析到预期源码，
以及 primary 的 skill/task 权限。发现目录不代表当前 agent 获准加载或分派。

共享全局或项目 `AGENTS.md` 保留行动前读取 using-superpowers 的入口。
原生发现只提供目录，不会自动执行所有 Skills；无需插件重复注入整段工作流。
本机 codex-sync 的 `sync-superpowers.sh --mount` 已把 Codex 和
`~/.agents/skills` 指向同一个个人 Superpowers 源；不要另装 obra 上游覆盖本 fork。

## 没有共享挂载时

可以在 OpenCode 的 `skills.paths` 指向所选 fork checkout 的 `skills` 目录。
先查重同名 Skill 并核对解析位置；项目 pinned tree 优先于个人旧副本，
不得靠同名多副本的扫描顺序猜测实际来源。保留既有配置和权限。

OpenCode 1.x 的工具映射与原生子代理机制见
[OpenCode adapter](../skills/using-superpowers/references/opencode-tools.md)。
其他版本按实际 schema 核查，不把 1.x 的 `task/permission` 字段套到 V2。

## 更新与验证

更新选定的 QuantumMisaka fork 源后重新启动会话，再核对 discovery 和正文。
本地 dirty candidate 与已发布 commit 分开报告；发布和父仓 gitlink 更新按所属仓库授权执行。
不为更新自动删除插件缓存、旧 checkout 或其它 harness 的安装目录。

插件路径仅在确实需要插件 bootstrap、且已检查与原生加载不重复时选用。
已有插件不自动移除；先核对其来源与职责，再决定迁移。

完整说明：[OpenCode 使用指南](../docs/README.opencode.md)。
