---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents. The quality of its work will be significantly higher if run on a platform with subagent support (Claude Code, Codex CLI, Codex App, Copilot CLI, and Gemini CLI all qualify; see the per-platform tool refs in `../using-superpowers/references/`). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. If present, read its `**Spec:**` file and the sections cited by tasks
3. Review critically - identify any questions or concerns about the plan
4. If concerns: raise them via the brainstorming §1 Grill protocol — at most 3 blocking questions, each with a recommended answer and an acceptance signal; resolve what the codebase can answer before asking. Concerns answerable by
   reading the code are resolved by reading, not raised.
5. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

Exit condition — all three must hold: every task marked complete; every
verification the plan names run fresh with passing output (see
verification-before-completion); and every ruling you made listed in the
final message under "Rulings I made", each with what it costs if wrong.

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## Rulings, Not Stalls

A running plan does not wait on a human. Blockers, unclear instructions,
plan gaps, a failed verification you can diagnose — decide them. The spec is
the binding authority, the plan is its argument, and your judgment settles
what neither answers. Record every decision as `Ruling: <what you decided>
— <why> — <what it costs if wrong>` and keep going; the ruling list in your
final message is where your human partner reviews and reworks them.

Four things stop you, and only these: an irreversible or destructive
operation; a security-sensitive action; a side effect outside this workspace
that norms say you ask about first (a merge, a push to a shared branch, a
publish); and a plan so broken that every path forward is a guess. For those,
stop and ask — via the brainstorming §1 Grill protocol — at most 3 blocking questions, each with a recommended answer and an acceptance signal; resolve what the codebase can answer before asking.

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

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
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
