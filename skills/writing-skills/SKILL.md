---
name: writing-skills
description: Use when creating, editing, or validating a reusable agent skill or its supporting guidance.
---

# Writing Skills

A skill is a reusable technique, workflow, or reference. Write clear, positive guidance that helps an agent achieve the target outcome, and validate it with checks proportional to its impact.

## 1. Define the Purpose and Scope

1. State the user-facing outcome, trigger conditions, and key operational trade-offs.
2. Check existing skills and references so each workflow has a single authoritative owner and links to related skills instead of duplicating them.
3. Choose a proportional validation method:
   - **Reference skill**: verify discovery metadata, relative links, examples, and command accuracy.
   - **Behavioral skill**: compare baseline and candidate behavior on realistic scenarios when feasible.
   - **Structural contract**: run targeted checks on frontmatter, routing identifiers, or helper scripts.

## 2. Structure the Skill

Keep `SKILL.md` concise and action-oriented:
- **Frontmatter**: `name` and a specific `description` in the skill's working language so the agent knows when to load it.
- **Core workflow**: Organize steps in the order the work actually happens (Goal → Action → Verification/Outcome).
- **One complete example**: Show a realistic positive path that illustrates the key judgment.
- **Progressive disclosure**: Put detailed CLI flags, platform adapters, or domain tables in `references/` or helper scripts.

Guide behavior through concrete actions, observable criteria, and trade-offs. Reserve explicit prohibitions for real safety, credential, data-loss, or external-publishing boundaries.

## 3. Validate and Refine

Run the narrowest structural or scenario check that verifies the change. If testing reveals a gap, refine the specific step that caused it and re-verify. Commit, deploy, or sync changes when the task scope includes those actions.

For scenario evaluation methods, see [testing-skills-with-subagents.md](testing-skills-with-subagents.md); for general authoring patterns, see [anthropic-best-practices.md](anthropic-best-practices.md) and [persuasion-principles.md](persuasion-principles.md).
