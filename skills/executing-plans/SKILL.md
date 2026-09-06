---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

Use the execution mode already selected. Availability of subagents alone does
not require SDD: direct execution is appropriate when its coordination cost is
lower. Delegate independent bounded work when useful and authorized; use SDD
when the plan benefits from its per-task implementation and review cycle.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. If present, read its `**Spec:**` file and the sections cited by tasks
3. Review critically - identify any questions or concerns about the plan
4. Resolve concerns from code or within the approved scope using Rulings below.
   Ask through brainstorming's Grill only for a missing decision or authorization
   that prevents reliable execution. Preserve prior authorization; do not ask
   again merely because this is a new execution step.
5. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

Exit condition — all three must hold: every task marked complete; every
acceptance condition supported by current revision-bound execution evidence (see
verification-before-completion); and every ruling you made listed in the
final message under "Rulings I made", each with what it costs if wrong.

After all tasks complete and verified, report results, evidence and the retained
branch/workspace. If integration or cleanup is requested, use
**superpowers:finishing-a-development-branch** for that operation and honor the
already authorized choice. Implementation-only delivery does not open a menu.

## Rulings, Not Stalls

A running plan does not wait on a human. Blockers, unclear instructions,
plan gaps, a failed verification you can diagnose — decide them. The spec is
the binding authority, the plan is its argument, and your judgment settles
what neither answers. Record every decision as `Ruling: <what you decided>
— <why> — <what it costs if wrong>` and keep going; the ruling list in your
final message is where your human partner reviews and reworks them.

Pause for missing authorization for irreversible/destructive operations,
security-sensitive actions or external side effects (merge, push, publish),
or when the plan leaves no reliable path forward. Existing authorization
persists within its scope; harness permission checks still apply. Ask only for
the missing decision, after resolving what the codebase can answer.

<!-- fork-added begin · 元认知条款（2026-08-22 QuantumMisaka fork；依据 AutoResearchEval/arXiv:2608.14905 ARFT） -->
## 元认知条款（fork）

计划执行期间，以下三条与 Rulings 机制同等生效：

1. **诊断-行动绑定**：执行中写下任何"这里有问题"的判断，必须同轮转化为处置——修复、按停止条件上报、或记入 Ruling 并写明代价。禁止"记录在案然后继续走"（ARFT F.4：82.5% 的轨迹已诊断却未修正）。
2. **目标重锚**：周期性对照计划的验收条件问"当前动作在服务验收吗"；发现跑偏先停再调，不带着偏差冲刺（ARFT 案例 c：正确诊断主导负分项后预算错配到已获胜实例）。
3. **自审不算证据**：任务完成只认 verification 命令的实时输出与 diff；自检清单打勾、解释性文字不计入验收。
<!-- fork-added end -->

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through missing evidence** — diagnose and repair within scope;
report incomplete when no reliable path remains.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - Ensures isolated workspace (creates one or verifies existing)
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - When integration or cleanup is requested
