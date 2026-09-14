---
name: executing-plans
description: Use when executing an existing implementation plan directly; ordinary unplanned L1/L2 work does not need this skill
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

Use the execution mode already selected. Availability of subagents alone does
not require SDD: direct execution is appropriate when its coordination cost is
lower. Delegate independent bounded work when useful and authorized; use SDD
when the plan benefits from isolated implementers and reviewable work-package
checkpoints.

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

For each work package (one or more plan tasks):
1. Mark as in_progress
2. Follow the relevant plan steps, resolving ordinary implementation choices
   from the plan and repository context
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

Exit condition — all planned work packages are complete, acceptance conditions
are supported by current revision-bound execution evidence (see
verification-before-completion), and material decisions, deviations, and
uncertainty are retained in the plan ledger or report. The final message should
surface the decisions that affect scope, safety, or acceptance and link the
durable record; it need not repeat every ordinary implementation choice.

After all tasks complete and verified, report results, evidence and the retained
branch/workspace. If integration or cleanup is requested, use
**superpowers:finishing-a-development-branch** for that operation and honor the
already authorized choice. Implementation-only delivery does not open a menu.

## Rulings, Not Stalls

A running plan does not wait on a human for ordinary implementation choices.
Blockers, unclear instructions, plan gaps, and failed verification that you can
diagnose should be resolved within scope. The spec is the binding authority,
the plan is its argument, and your judgment settles what neither answers.
Record material decisions or deviations as `Ruling: <what you decided> — <why>
— <what it costs if wrong>` and keep going; link the record in the final
message.

Return an implementation-changing product or architecture decision to the user;
a Ruling cannot revise the approved design or expand scope. Pause for missing
authorization for irreversible/destructive operations,
security-sensitive actions or external side effects (merge, push, publish),
or when the plan leaves no reliable path forward. Existing authorization
persists within its scope; harness permission checks still apply. Ask only for
the missing decision, after resolving what the codebase can answer.

## Keep work tied to acceptance

Use the plan to retain scope and recovery state. A file list or step order is
an implementation estimate unless the approved contract makes it binding.
Resolve equivalent implementation changes within scope; record material
tradeoffs in the existing plan or report. Address actual acceptance gaps,
while routing unrelated observations outside the current work package.
Completion evidence is owned by `verification-before-completion`; do not
create a second checklist or repeat unchanged checks here.


## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through missing evidence** — diagnose and repair within scope;
report incomplete when no reliable path remains.

## Remember
- Review plan critically first
- Follow the plan's acceptance intent and record justified deviations
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - Ensures isolated workspace (creates one or verifies existing)
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - When integration or cleanup is requested
