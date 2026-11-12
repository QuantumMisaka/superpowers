# Positive Guidance Principles for Skill Design

> Historical note: Upstream Superpowers originally framed this file around Cialdini persuasion tactics (`YOU MUST`, `No exceptions`, mandatory announcements). In this fork, aggressive compliance language was found to trigger over-defensive stalling, rigid checklist filling, and unnecessary refusals. Current skills use **Goal → Action → Observable Outcome** shaping instead.

## 1. Clear Purpose Over Imperative Shouting

Agents follow instructions more reliably when they understand **what outcome is needed and why a trade-off matters**, rather than reading stacked `NEVER` or `YOU MUST` clauses.

```markdown
# Preferred (Goal → Action → Outcome)
For behavior changes, run the focused test before and after the edit so the test proves the fix addresses the root cause.

# Avoid (Defensive / Punitive)
YOU MUST write the test first! Write code before test? Delete it. Start over. No exceptions.
```

## 2. State-Keyed Decisions Over Repeated Negations

Instead of listing `When to Use`, `Don't use when`, `When NOT to Use`, and `Red Flags` for the same condition, place each decision once at the step where the agent actually makes it:

```markdown
# Preferred
- If the project develops on `main` directly, implement in the current checkout.
- If concurrent writers or risky migrations need isolation, create a detached worktree.
```

## 3. Proportional Verification Over Ritual Gates

Tie verification to the actual risk and behavior changed:
- Code and behavior changes use focused regression tests (`test-driven-development`).
- Equivalent refactors compare baseline and candidate checks.
- Documentation, configuration, or independent cleanup tasks verify links, syntax, or git absorption directly without running unrelated test suites.

## 4. Collaborative Autonomy

Frame main-agent and subagent prompts around professional responsibility and concrete deliverables:
- Specify the **goal, owned files, relevant context, and completion criteria**.
- Let the executor handle ordinary technical choices, and ask the coordinator or user only when a decision changes product behavior, architecture, or external authorization.
