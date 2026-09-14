# Skill 消融实施

**Goal:** 在已确认契约内释放模型判断，消除 L3 自动升级与重复流程。
**Spec:** ../specs/2026-09-14-taste-carrier-ablation-design.html
**Authorization:** 本人已确认设计与开发准则，并明确要求“继续推进 SKILL 消融优化”。
**Architecture:** 复用当前技能与适配器，修改通用指导和被引用模板，不改变 helper API、模型配置、项目消费 pin 或发布状态。
**Verification:** 结构套件、链接与 diff 检查；独立基线/候选场景与终审，结果不冒充实际交付成本基准。

## 工作包

- [x] 入口与 brainstorming：允许 L2 有界澄清，澄清后直接退出；仅真正计划化工作 L3 保留 PLAN；直接执行不自动加载计划链。
- [x] 调试与测试：删除次数强停；按实际保护价值选择测试路径，保留真实 RED/GREEN、基线/候选和证据边界。
- [x] 执行与审查：精简 SDD 重复要求及模板形状锁定；开放等价实现，保留共享状态、独立审查与完成责任。
- [x] 验证、独立审阅，回填当前源仓并同步实施状态。

## 范围与裁决

Ruling: 在 ~/scratch/superpowers-ablation-20260914 隔离工作树执行，携带源仓已有3份开发文档和已批准SPEC；验证后仅回填本次文件并核对源状态，保留源仓原有改动。没有自动发布或修改外部项目。
本轮为自然语言行为契约变更，使用语义场景及结构检查，不写逐句源码断言或合成代码 RED。

## 验证与审阅记录

- 基线：ac35b3c 的 skills；独立 ablation_baseline 评估 P–T。观察到 Q（机械迁移）和 R（三次失败）有冲突，P 的退出路径不一致；S/T 已有合理解释，不能将其全部计作候选新增收益。
- 候选：隔离工作树当前未提交 diff；独立 ablation_candidate 未读基线、SPEC或作者预期，评估 P–U 与原场景5。P/Q 直接有界执行；R 基于新证据继续；S 区分预估文件与缺失公开行为；T 无额外手续；U 保留 L3 PLAN 和生产授权；场景5复用当前证据、变更后补相关检查。未观察到相反动作的文本冲突。
- 两个独立 evaluator 各一次自然语言评估，原始答复在本会话对应代理消息中；此处是摘要。不是重复试验、真实代码任务或成本基准。
- `bash tests/skill-content/run-tests.sh`：退出0，全部结构检查通过，原日志 `/home/james/scratch/superpowers-ablation-structure.log`。helper/API未修改，不重复其运行套件。
- 临时链接检查：15份变更技能/参考文件的9个Markdown本地目标存在；入口34行/3569字节。`git diff --check`通过。
- 独立终审 ablation_final_review：发现分派前dirty基线压缩过度，已恢复owned-path内容/完整diff含未跟踪文件，保留作者归属；根因追踪图无条件追加防御的残留也已修正。修后 `bash tests/skill-content/test-codex-subagent-routing-contract.sh` 与 `git diff --check`通过。
- Ruling: 调试参考中的“每层都验证”会恢复主文刚消融的加固，故收敛同一活跃引用与流程图；保留独立边界保护和历史案例。这是消除明确回流，不扩展一般安全加固。
- 范围外：没有修改上游同步脚本、其他项目规则/pin、模型配置，也没有平台/科学计算或跨harness模型驱动E2E。

终审增量复核通过，两项发现已关闭。通过源仓基线/先前文档内容比较后，将本次15份技能/参考文件、场景及实施状态回填当前源仓；保留隔离工作树与原开发文档改动，未commit/push。

## 后续状态（2026-09-14 17:26 CST）

上段保留回填时的原时点状态。随后源仓已提交 `538b18e`（本消融改动）与 `7c33eae`（submodule 打包修复），并推送 Codeup `main`。GitHub `origin/main` 仍在 `ac35b3c`；父仓 `codex-sync/superpowers` gitlink 的 `ac35b3c -> 7c33eae` 变化尚未提交。当前审查结论、验证命令和剩余建议见[状态审查报告](../reports/2026-09-14-skill-status-review.md)。
