# Cascading Context

The cascading context file pattern applies the same concept as cascading stylesheets: global defaults, project-level overrides, and subdirectory-level specializations. More specific files take precedence over more general ones.

This pattern was described in the original article as a feature of the single-file approach. It has since become the de facto standard for organizing context across multiple projects and workspaces.

## Precedence

```text
~/.claude/CLAUDE.md              # Global: user preferences, environment, defaults
  └── project/AGENTS.md          # Project: stack, structure, architecture, boundaries
        └── project/src/api/AGENTS.md   # Subdirectory: specialized rules for this area
```

More specific files override more general ones. If the global file says "2-space indentation" but a project file says "4-space indentation," the project file wins for that project.

## What Goes Where

### Global (~/.claude/CLAUDE.md)

Things that are true across all your projects:

- Editor and environment preferences (macOS, VS Code, terminal)
- Language and framework defaults (TypeScript, ES modules)
- Code style defaults (indentation, import style, naming)
- Error handling philosophy
- Commit message format
- Communication preferences (concise, no emojis, no meta-commentary)

See [global-claude.md](global-claude.md) for a working example.

### Project (repo root AGENTS.md)

Things that are true for this specific project:

- What the project does and who it's for
- Tech stack and project structure
- Build, test, and deploy commands
- Architecture decisions
- Project-specific boundaries and "Do NOT" rules
- References to context directory if using one

See [project-claude.md](project-claude.md) for a working example.

### Subdirectory (e.g., src/api/AGENTS.md)

Things that are true only within this part of the codebase:

- Specialized coding patterns for this layer (API conventions, component patterns)
- Testing expectations specific to this area
- Dependencies or conventions that don't apply elsewhere
- Overrides to project-level rules when this area has different needs

See [subdirectory-claude.md](subdirectory-claude.md) for a working example.

## When to Use Each Level

| Level | Update frequency | Owned by | Examples |
| ----- | --------------- | -------- | -------- |
| Global | Rarely | Individual developer | "I use TypeScript, 2-space indentation, ES modules" |
| Project | When architecture changes | Tech lead / team | "This is a Next.js app, here's the structure" |
| Subdirectory | When patterns diverge | Area owner | "API handlers follow this pattern" |

## Common Mistakes

**Too much in global.** Your global file should be lightweight -- preferences and defaults. If it's describing architecture or business context, that belongs at the project level.

**Contradictions without intent.** If your global says "always use TypeScript" but a project uses Python, that's fine -- the project file overrides. But document the override explicitly rather than hoping precedence handles it silently.

**Subdirectory files that duplicate the project file.** Only create subdirectory context when that area genuinely has different rules. If `src/api/AGENTS.md` just repeats the project-level coding standards, delete it.
