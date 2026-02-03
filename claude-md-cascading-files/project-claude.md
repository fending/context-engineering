# Project CLAUDE.md Example

This file lives at the repository root and describes everything specific to this project.

---

````markdown
# CLAUDE.md

## Repository Purpose

[What this project does and who it's for. One paragraph.]

## Tech Stack

- **Frontend:** [framework, language]
- **Backend:** [framework, language]
- **Database:** [engine]
- **Auth:** [provider]
- **Hosting:** [platform]
- **CI:** [service]

## Project Structure

[Actual directory tree with annotations]

## Commands

```bash
npm run dev          # Start dev server
npm test             # Run tests
npm run build        # Production build
npm run lint         # Lint and format check
```

## Architecture Decisions

- **[Decision]:** [What it means for implementation]
- **[Decision]:** [What it means for implementation]

## Context

Detailed project context is in the `context/` directory:

- System architecture: `context/system-overview.md`
- Architecture decisions: `context/architecture-decisions.md`
- Code standards: `context/working-style-guide.md`
- API conventions: `context/api-documentation.md`

## Boundaries

Do NOT:

- Modify [critical files] without explicit approval
- Add new dependencies without checking [criteria]
- Push directly to main
- Skip migrations when modifying data models
- Add features, refactoring, or "improvements" beyond what was asked
````

---

## Notes

**This file works with or without a context directory.** If the project is small enough that everything fits in this one file, include the code standards and architecture decisions here. If it's grown past that point, keep this file as a map that points to the context directory.

**The "Boundaries" section is the most important part.** Specific rules about what not to do prevent more problems than general guidance about what to do. Every item in this section should trace back to something that actually went wrong or that's genuinely fragile.

**Reference to context directory is optional.** The article discussed single-file vs. context-directory as separate approaches. In practice, the project CLAUDE.md often serves as the entry point that references deeper context when it exists. This is the hybrid approach the article predicted.
