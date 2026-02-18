---
name: onboard
description: Walks through the project's context structure, summarizes what exists at each level, and flags anything that looks stale. Run at session start or when joining a project.
---

# Onboard

Discover and summarize the project's context structure so you can orient quickly.

## What This Skill Does

1. **Discover context files** at all levels:
   - Global (user-level AGENTS.md or tool-specific equivalent like `~/.claude/CLAUDE.md`)
   - Project root (`AGENTS.md` as primary, check for `CLAUDE.md` symlink)
   - Subdirectories (any nested `AGENTS.md` files)
   - Context directory (`context/` or similar with multiple files)
   - Agent definitions (`agents/`, `agent-teams/`)
   - Skills (`.claude/skills/` or equivalent)
   - Hooks (`.claude/settings.json` hook configurations)

2. **Summarize each file** with a one-line description and last modification date. Focus on what each file tells the AI to do differently -- boundaries, conventions, workflow instructions.

3. **Flag potential staleness:**
   - References to packages not in `package.json` / `requirements.txt` / `go.mod`
   - References to directories that don't exist on the filesystem
   - Build or test commands that don't match actual scripts
   - Agent state files with timestamps older than 30 days

4. **Produce a context map** -- a navigation guide that tells agents which files to read depending on the task, without front-loading everything. Group discovered files by when they're relevant:

   - The root AGENTS.md covers boundaries, stack, and commands -- always applicable.
   - Subdirectory AGENTS.md files apply when working in the directories they govern.
   - Context directory files apply when investigating specific concerns (architecture, API surface, data model).
   - Agent definitions and state files apply only when running those specific workflows.

   The map is the last section of the output. It answers "what should I read before starting this task?" not just "what exists?"

Report findings conversationally. This is orientation, not an audit -- surface what matters for starting work, not an exhaustive inventory.

## When to Use

- At the start of a new session on an unfamiliar project
- When a new contributor (human or AI) joins the project
- After major refactoring that may have changed project structure
- When you're unsure what context files exist or how they relate

## Example Output

> This project has three layers of context:
>
> **Global** (user-level context, modified 2 weeks ago): Sets TypeScript preference, 2-space indentation, conventional commits.
>
> **Project root** (`AGENTS.md`, modified 3 days ago): Next.js 15 / React 19 stack. Key boundaries: don't modify auth middleware without approval, don't push to main. Context directory at `context/` has 4 files covering architecture, API docs, business requirements, and working style.
>
> **Subdirectory** (`src/api/AGENTS.md`, modified 1 month ago): API-specific conventions for error handling and response formats.
>
> **Agents**: Deploy agent (`agents/deploy/`) and content pipeline (`agents/content-pipeline/`). Content pipeline state was last updated 45 days ago -- may be stale.
>
> **Skills**: 3 skills available (`/onboard`, `/context-align`, `/scope-check`).
>
> **Hooks**: Pre-tool boundary guard on edits, post-tool markdown linting.
>
> No package reference issues found. The `context/api-documentation.md` references a `/v2/webhooks` endpoint -- verify this still exists.
>
> **Context map** -- read different files depending on the task:
>
> - Any task: `AGENTS.md` (boundaries, stack, commands)
> - Working in `src/api/`: also read `src/api/AGENTS.md` (error handling, response formats)
> - Investigating business requirements: `context/business-requirements.md` (product goals, user personas)
> - Investigating architecture: `context/architecture-decisions.md` (layer rationale, data flow)
> - Investigating the API surface: `context/api-documentation.md` (endpoints, auth requirements)
> - Running deploy or publish workflows: `agents/deploy/` or `agents/content-pipeline/`

## Notes

This skill is read-only orientation. It discovers and summarizes what exists but doesn't create or modify context files. For scaffolding new context structures, see the `context-setup` plugin (`/context-setup:scaffold`).

Modification dates matter because context files rot. A file modified 6 months ago in an actively developed project is worth flagging -- not because it's necessarily wrong, but because it hasn't been reviewed alongside the code it describes.

Staleness checks are heuristic, not exhaustive. The skill checks for obvious mismatches (missing directories, absent packages) but can't verify whether architectural descriptions still match the actual implementation. That's a human judgment call.
