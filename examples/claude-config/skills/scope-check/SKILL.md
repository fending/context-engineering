---
name: scope-check
description: Validates a task against AGENTS.md boundary rules before starting work. Use when planning changes to protected files or areas with declared restrictions.
---

# Scope Check

Validate a planned task against AGENTS.md boundary rules before writing any code.

## What This Skill Does

1. **Build constraint list:** Read AGENTS.md boundary sections ("Do NOT", "Boundaries", "Restrictions") from all applicable levels -- project root and any relevant subdirectories for the files the task will touch.

2. **Compare task against constraints:** For each boundary rule, assess whether the planned task could conflict. Consider both direct conflicts (task explicitly does what a rule forbids) and indirect ones (task modifies a file in a protected area, task has side effects that touch restricted scope).

3. **Assess and report:**
   - **Clear** -- no boundary conflicts found. Proceed.
   - **Warning** -- task touches areas near boundaries. Specific rules quoted with the potential conflict explained. Proceed with awareness.
   - **Blocked** -- task directly violates one or more boundary rules. Rules quoted, conflict explained, alternatives suggested.

## When to Use

- Before starting any task that touches files or areas you know have restrictions
- When a task description feels like it might conflict with project boundaries
- When working in an unfamiliar part of the codebase where you haven't read the local AGENTS.md
- As a planning step before larger changes that span multiple directories

## Example Output

> Checking task "add rate limiting to auth middleware" against boundaries...
>
> **Warning:** AGENTS.md (project root) declares:
>
> > Do NOT modify auth middleware without explicit approval
>
> This task directly modifies auth middleware. The boundary doesn't prohibit the change -- it requires approval before proceeding. Confirm with the project owner before starting.
>
> **Clear on all other boundaries.** No subdirectory-level restrictions apply to `src/middleware/`.

## How It Pairs with boundary-guard

Scope-check and boundary-guard are complementary, not redundant:

- **Scope-check** runs at planning time, before work starts. It's proactive -- you invoke it to understand constraints before writing code.
- **boundary-guard** runs at execution time, on every file edit. It's reactive -- it catches violations the moment they happen, even if you didn't run scope-check first.

Together they provide defense in depth. Scope-check prevents wasted effort (don't spend 30 minutes implementing something that will be blocked). Boundary-guard catches anything that slips through (mid-task scope creep, forgotten restrictions, tasks that touch more files than planned).

## Notes

Checking before starting is cheaper than catching mid-implementation. A boundary violation discovered after writing code means discarding work and potentially undoing changes. A violation discovered during planning means adjusting the approach before any code is written.

Boundary rules compound across cascading AGENTS.md files. A project root might say "don't modify the database schema without migration files" while a subdirectory AGENTS.md adds "don't modify seed data without updating fixtures." Scope-check surfaces both when the task touches that subdirectory, so you see the full constraint picture.

The three-level assessment (clear/warning/blocked) reflects that not all boundary rules are absolute prohibitions. Some are "proceed with caution" rather than "stop." The skill distinguishes between rules that require awareness and rules that require permission or alternative approaches.
