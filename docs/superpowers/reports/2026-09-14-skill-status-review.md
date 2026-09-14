# Superpowers Skill 状态审查报告

**日期：** 2026-09-14

**审查对象：** `superpowers` Skill 库与相关文档

**审查基线：** `7c33eae13ca8e348b5ff6d50a9b9b7af7604cce5`

**工作流：** L2 只读审查加现有检查复核

**依据：** [2026-09-14 消融设计](../specs/2026-09-14-taste-carrier-ablation-design.html)、[实施记录](../plans/2026-09-14-taste-carrier-ablation.md)、当前 Git/挂载状态与仓库测试。

## 结论

按已确认的“品味载体消融”目标衡量，核心 Skill 改造已经达到本轮设计交付标准：入口路由、Brainstorming、系统调试、TDD、SDD、验证和计划执行不再把标准步骤当作每项任务的固定手续，而是按目标、风险、证据和协调收益选择方法。

整个 Skill 库仍不是“无需继续优化”的终态。剩余工作主要是外围一致性、分发收尾和后续针对性消融，不需要推倒重做，也不应再启动一轮大规模治理审查。

## 当前交付状态

| 项 | 状态 |
| --- | --- |
| 消融主提交 | `538b18e` (`docs: ablate skill governance and open workflow methods`) |
| 子模块打包修复 | `7c33eae` (`fix: support submodule checkouts in plugin packaging`) |
| 本地工作区 | 审查基线为 clean，HEAD 为 `7c33eae`；本报告落档本身产生文档改动 |
| Codeup `main` | 已更新到 `7c33eae` |
| GitHub `origin/main` | 仍在 `ac35b3c`，本地 main ahead 2 |
| 父仓消费 gitlink | `codex-sync/superpowers` 有 `ac35b3c -> 7c33eae` 的未提交变化 |
| 本机技能挂载 | `~/.codex/skills/using-superpowers` 与 `~/.agents/skills/using-superpowers` 均链接到本仓技能目录，已消费当前版本 |

这不等于正式插件版本发布。GitHub 推送、父仓 gitlink 收束和消费端 pin 更新仍需按实际授权执行。

## 核心核对结果

| 工作面 | 结论 | 依据 |
| --- | --- | --- |
| 入口路由 | 达到设计目标；L2 可局部澄清，公共 API、多文件、机械迁移等字样不再自动升级 L3。入口 34 行 / 3569 字节，低于 60 行 / 6144 字节预算。 | `skills/using-superpowers/SKILL.md` |
| Brainstorming | 已解除“澄清即 L3 / SPEC / PLAN”的自动链条；问题解决后按剩余工作退出。 | `skills/brainstorming/SKILL.md` |
| Systematic debugging | 已删除固定四阶段和三次失败强停；按证据更新假设，只有改变已批准产品/架构决策才回到用户。 | `skills/systematic-debugging/SKILL.md` 及引用 |
| TDD 与验证 | 按保护价值选择 RED/GREEN、baseline/candidate、直接检查、替身或观测；不为流程感制造无效测试。证据 freshness 集中在 completion skill。 | `skills/test-driven-development/SKILL.md`、`skills/verification-before-completion/SKILL.md` |
| SDD | 可用子代理不再是触发条件；计划文件列表不是 hunk 配额；独立审查按风险选择；等价实现可通过。 | `skills/subagent-driven-development/SKILL.md` 及模板 |
| 文档与维护准则 | README、AGENTS/CLAUDE 入口和设计哲学已与“结果约束 + 方法自主”一致，不再复述旧的至多三问、固定模型分工或 prose mutation 执法承诺。 | `README.md`、`CLAUDE.md`、`docs/superpowers/fork-design-philosophy.md` |

## 已关闭的问题

### 子模块打包误判

打包脚本曾用 `[[ -d "$REPO_ROOT/.git" ]]` 判断 Git checkout，在 submodule 的 `.git` 文件布局下误报：

```text
ERROR: repo root is not a git checkout
```

`7c33eae` 改用 `git rev-parse --is-inside-work-tree` 后，当前源仓和标准 clone 的打包测试均通过。该问题已关闭。

## 验证记录

在审查基线上执行：

```bash
bash tests/skill-content/run-tests.sh
bash tests/codex/test-marketplace-manifest.sh
bash tests/codex/test-package-codex-plugin.sh
bash tests/codex-plugin-sync/test-sync-to-codex-plugin.sh
bash -n scripts/package-codex-plugin.sh
git diff --check
```

结果均通过。入口大小检查为 34 行 / 3569 字节。

限制：

- `scripts/lint-shell.sh` 未完整执行，因为当前 PATH 缺少 `shellcheck`；这是环境限制，不是脚本失败证据。
- 结构测试只覆盖元数据、链接、部分结构和 adapter 契约，不证明所有模型或 harness 都会按语义执行。
- 语义场景评估是有限样本，不能外推为成本、返工率或跨模型行为结论。

## 剩余优化建议

按优先级排序：

1. **完成分发链路收尾。** 在授权下推送 GitHub `origin/main`，并在父仓单独提交 `superpowers` gitlink，避免把父仓其他并发改动混入。
2. **收敛 `dispatching-parallel-agents` 的触发。** 将“2+ 独立任务”和“3+ 失败测试文件”改为先判断并行收益、上下文隔离需求、写集/共享状态和协调成本；保留并行方法，但不再把独立数量本身当充分触发。
3. **弱化 `executing-plans` 的无条件技能链。** `writing-plans` 只在计划需要修订时使用；worktree 应按隔离需求与项目约定选择；finishing 只在集成或清理被请求时使用。
4. **澄清 Codex V1 生命周期措辞。** 将“任务 review 通过后关闭 implementer”改为“控制者验收且任何已选择 review 完成后关闭”，避免读出每个任务必有独立 review 的旧语义。
5. **结合真实任务观察效果。** 关注误升 L3、无效提问、无意义分派、等价实现误报和重复命令；不新增全模型矩阵、周期审计或治理台账。

不建议为了行数继续压缩 `finishing-a-development-branch` 或 `using-git-worktrees`。它们较长主要因为覆盖真实的 Git、子模块、清理和不可逆操作风险，不属于本轮应删除的流程仪式。
