# 按所需成果选择角色

L1/L2/L3 决定组织粒度，角色承接具体成果。主代理统筹意图、范围、决定与整合；子任务可独立交付且分工收益高于协调成本时，才启用委派。

角色职责见下表，按需读取。优先用已注册原生角色；只有通用子代理时，把角色正文与任务说明一并传入（模型沿用当前配置）；无子代理工具时，主代理借用角色方法并说明执行方式。Codex 原生 GPT/DeepSeek 角色见[安装说明](subagent-install.md)按需选装；读写约束由工具权限与沙箱落实。

| 所需成果 | 角色 | 派发时须交代清楚 |
| --- | --- | --- |
| 发现可推动项目的能力与工作机会 | [`capability-advisor`](roles/capability-advisor.md) | 项目目标、当前状态、已有任务与本次可用能力 |
| 查清事实、根因或设计历史 | [`context-analyst`](roles/context-analyst.md) | 待回答的问题、一手来源与证据范围 |
| 比较候选方案并给出推荐 | [`design-analyst`](roles/design-analyst.md) | 期望结果、现实约束、既有决定与核心取舍 |
| 完成局部实现或行为复现 | [`routine-worker`](roles/routine-worker.md) | 目标行为、可写文件与核验方式 |
| 完成跨文件实现或集成修复 | [`standard-worker`](roles/standard-worker.md) | 接口契约、关联调用方、写集与完成标准 |
| 核验工作包或整体交付 | [`task-reviewer`](roles/task-reviewer.md) / [`final-reviewer`](roles/final-reviewer.md) | 实际变更、验收目标、已有证据与重点疑点 |
| 形成文稿或审阅表达 | [`document-writer`](roles/document-writer.md) / [`document-reviewer`](roles/document-reviewer.md) | 主读者、文档用途、核心来源与已定取舍 |
| 分析科学证据或撰写论文 | [`paper-analyst`](roles/paper-analyst.md) / [`paper-writer`](roles/paper-writer.md) | 研究问题、核心主张、证据与目标体裁 |
| 判断是否达成目标、下一步做什么 | [`progress-reviewer`](roles/progress-reviewer.md) | 当前目标、现有产物与完成标准 |
| 跟踪长任务与关键日志 | [`monitor`](roles/monitor.md) | 运行标识、观察入口与需回报的事件 |

## 能力发现与机会识别

用户问“还能让 Agent 帮什么忙”，或项目新阶段要定投入优先级时，可委派 `capability-advisor`。它基于现状推荐少量切入点，写清角色、产物与最小启动范围，核对既有任务与能力可用性；主代理收束范围并执行。明确局部任务直接派发；提醒由当前会话主代理触发。

## 典型场景组合

- **故障排查与修复**：根因不明时先调查再动手，紧耦合问题由同一名 worker 连续闭环。
- **技术方案设计**：主代理结合用户偏好对齐目标，需独立多方案对比时委派 `design-analyst`；关键判断成型后，可交 reviewer 做独立把关。
- **历史债务与重构**：先由 `context-analyst` 摸清历史动机与现役调用方，再交 `design-analyst` 权衡调整方案，最后由 worker 落地实现。
- **瓶颈定位与阶段复盘**：先锚定指标与时间范围，由 `context-analyst` 串起事件与证据链，必要时交 `design-analyst` 拟定改进方案，并由 `progress-reviewer` 评估收口条件（详见[复盘指南](retrospective.md)）。

例如，当缓存方案尚未定型时，先让 `context-analyst` 摸清真实耗时分布，待证据足以支撑对比后，再交 `design-analyst` 权衡缓存、批处理与队列调整；简单清晰的小问题由主代理一次完成即可。

每次派发均须交代清晰的问题定义、预期成果、一手依据与读写范围。角色名与实际权限以当前 harness 注册状态为准；需查阅平台调用细节时，按需打开对应适配器：[Codex](codex-tools.md)、[OpenCode](opencode-tools.md)、[dsh](dsh-tools.md) 或 [Kimi Code](kimi-code-tools.md)。
