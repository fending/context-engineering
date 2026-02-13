# Global Context File Example

This file lives at `~/.claude/CLAUDE.md` (or `AGENTS.md` with `CLAUDE.md` symlinked to it). Your tool may have an equivalent path, and this applies to every project you open there.

---

````markdown
# Personal Preferences

## Communication Style

- Prefer concise, direct responses over verbose explanations
- When uncertain, ask 1-2 clarifying questions immediately
- Skip meta-commentary about what you're doing unless I ask
- No apologies for limitations -- just state what you can/can't do

## Environment

- macOS development environment
- VS Code as primary editor
- Node.js 18+ for all projects
- TypeScript preferred for all JavaScript projects

## Default Behaviors

- 2-space indentation for all code
- Use ES modules (import/export) not CommonJS (require)
- Destructure imports when possible
- Always include error handling in async functions

## Error Handling

- When an API request fails, diagnose and address the failure -- do not silently fall back to alternative data sources
- If authentication is required, surface that rather than working around it
- If an endpoint returns 404/401/403, investigate the correct endpoint or auth mechanism before proceeding

## Project Standards

- Documentation: No emojis, no decorative symbols
- File naming: kebab-case for all files
- Git: Conventional commits format (feat/fix/docs/etc)
````

---

## Notes

**This is short by design.** Global context covers personal working preferences -- things that are true regardless of what project you're in. It's not the place for architecture decisions, project structure, or business requirements.

**Communication style matters more than you'd think.** Without explicit preferences, AI assistants default to verbose, hedging, emoji-laden responses. If that's not your style, say so once in the global file rather than correcting it in every session.

**Error handling philosophy is global.** "Diagnose failures, don't silently fall back" is a working preference, not a project-specific rule. It applies whether you're building a CLI tool or a SaaS app.

**Project-level files override these defaults.** If a project uses Python with 4-space indentation, the project AGENTS.md (or CLAUDE.md) says so, and these global defaults yield for that project.
