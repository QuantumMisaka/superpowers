# 入口指针

本仓是 obra/superpowers 的 QuantumMisaka 个人定制 fork。唯一开发入口见 `AGENTS.md`（开发纪律与仓库地图）与 `README.md`（fork 说明）；设计思想见 `docs/superpowers/fork-design-philosophy.md`。

## 开发品味红线（2026-08-26 本人确认）

依据：外部 AI Coding 常见失效模式反馈（语义漂移、屎山、测试绑源码字符串/文件 hash、过度检查），蒸馏为开发本仓（含 skills、测试与文档）的判据。细则见 `skills/test-driven-development/writing-good-tests.md` 与评审模板。

- **意图锚定**：需求与验收判据落在持久载体（spec/plan/判据）上，不随会话漂移。
- **最小变更**：单一职责，diff 保持可审阅，不顺手重构无关代码。
- **断言行为**：测试断言行为与效果，不绑源码字符串、不绑文件 hash/快照；只会在有意变更时失败的是 change detector，不是测试。
- **验证最小充分**：运行产物看输出，不为安全感堆冗余检查；绿勾 ≠ 正确。
