---
name: context-align
description: Checks AGENTS.md and SKILL.md files against the actual codebase for drift. Surfaces references to packages, directories, commands, or patterns that no longer match reality.
---

# Context Align

Cross-reference your context files against the actual codebase to find drift before it misleads an AI session.

## What This Skill Does

Reads all context sources and checks them against the filesystem and project configuration. Checks are ordered by impact:

1. **Tech stack references vs dependencies:**
   - Package names in AGENTS.md vs `package.json` / `requirements.txt` / `go.mod` / `Cargo.toml`
   - Version claims vs actual installed versions
   - Framework references (e.g., "React 18" when `package.json` shows React 19)

2. **Directory and file references vs filesystem:**
   - Paths mentioned in context files that don't exist
   - Directory structures described that don't match reality
   - References to files that have been moved or renamed

3. **Build/test commands vs actual scripts:**
   - Commands in context files vs `package.json` scripts / `Makefile` targets / CI configs
   - "Run `npm run test`" when the actual script is `npm test` or `pnpm test`

4. **Skill relevance:**
   - Skill descriptions referencing technologies not in this project's stack
   - Skills that reference tools or workflows that no longer exist

5. **Cascading contradictions:**
   - Rules in a subdirectory AGENTS.md that conflict with the project root AGENTS.md
   - Global preferences that override project-level boundaries (or vice versa)
   - Inconsistent technology references across levels

Report each finding with the specific file, line reference, what it says, and what the codebase actually shows. Suggest fixes where the correct answer is clear.

## When to Use

- Periodically (monthly or after sprints) as a hygiene check
- After dependency upgrades (`npm update`, major version bumps)
- After major refactoring that changes directory structure or removes features
- Before onboarding new contributors who will rely on context files for orientation
- When AI sessions produce unexpected results that suggest stale context

## Example Output

> Checked 4 context files against codebase. Found 3 drift issues:
>
> **AGENTS.md:12** -- References "React 18" but `package.json` shows `react@19.0.0`. Update the stack description.
>
> **context/architecture-decisions.md:45** -- References `src/lib/auth/` directory. This directory doesn't exist; auth code is in `src/middleware/auth.ts`. Likely moved during the auth refactor.
>
> **src/api/AGENTS.md:8** -- Says "run `npm run test:api`" but `package.json` has no `test:api` script. Available test scripts: `test`, `test:unit`, `test:integration`.
>
> No cascading contradictions found. All skill descriptions match current stack.

## Notes

This skill operationalizes the "they rot" principle from Key Principles. Context files that reference outdated dependencies, missing directories, or renamed commands actively mislead AI sessions. Regular alignment checks catch drift before it causes implementation errors.

Context-align checks *references* (does this file/package/command exist?), not *accuracy* (is this architectural description still true?). The latter requires human judgment. This skill handles the mechanical checks so humans can focus on the substantive ones.

Cascading contradictions are a specific failure mode of multi-level context. A project AGENTS.md might say "use Vitest for testing" while a subdirectory AGENTS.md says "use Jest for this module." Both might be intentional (legacy module with different tooling) or accidental (subdirectory file wasn't updated). The skill surfaces the contradiction; the human decides which is correct.
