---
name: onboard
description: Walks through the project's context structure, summarizes what exists at each level, and flags anything that looks stale. Run at session start or when joining a project.
---

# Onboard

Discover and summarize the project's context structure so you can orient quickly.

## What This Skill Does

1. **Discover context files** at all levels:
   - Global (`~/.claude/CLAUDE.md` or equivalent)
   - Project root (`AGENTS.md`, `CLAUDE.md`, symlinks)
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

Report findings conversationally. This is orientation, not an audit -- surface what matters for starting work, not an exhaustive inventory.

## When to Use

- At the start of a new session on an unfamiliar project
- When a new contributor (human or AI) joins the project
- After major refactoring that may have changed project structure
- When you're unsure what context files exist or how they relate

## Example Output

> This project has three layers of context:
>
> **Global** (`~/.claude/CLAUDE.md`, modified 2 weeks ago): Sets TypeScript preference, 2-space indentation, conventional commits.
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

## Notes

This skill is read-only orientation. It discovers and summarizes what exists but doesn't create or modify context files. A future `/context-setup` skill would handle scaffolding new context structures.

Modification dates matter because context files rot. A file modified 6 months ago in an actively developed project is worth flagging -- not because it's necessarily wrong, but because it hasn't been reviewed alongside the code it describes.

Staleness checks are heuristic, not exhaustive. The skill checks for obvious mismatches (missing directories, absent packages) but can't verify whether architectural descriptions still match the actual implementation. That's a human judgment call.
