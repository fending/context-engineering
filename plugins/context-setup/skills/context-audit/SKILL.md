---
name: context-audit
description: Evaluates an existing context structure for completeness, level appropriateness, and best practices. Checks whether your context is well-formed, not whether it matches the codebase.
---

# Context Audit

Evaluate your context structure for structural completeness and best practices. This checks whether your context files are well-formed and appropriate for your project's complexity.

## What This Skill Does

Reads all context files and evaluates them against five categories. Reports findings as a structured audit with scores and prioritized recommendations.

### 1. Level Appropriateness

Assess whether the context complexity matches the project complexity.

**Under-documented indicators** (project is more complex than its context):

- Multiple distinct layers (frontend, backend, database, auth) but only a minimal AGENTS.md
- More than 10 top-level directories with no project structure section
- Auth packages present but no auth section
- Multiple package manager configs (monorepo) but no cascading files
- More than 3 contributors (check git log) but no working style documentation

**Over-engineered indicators** (context is more complex than the project):

- Context directory with 5+ files for a project with fewer than 20 source files
- Subdirectory AGENTS.md files in a project with a flat structure
- Cascading setup for a single-person, single-language project
- Multiple context files that mostly repeat the same information

### 2. Section Completeness

Check which required sections are present for the current context level.

**Minimal level requires:**

- Project description (what this is)
- Tech stack (languages, frameworks, key dependencies)
- Commands (dev, build, test, lint -- whichever apply)
- Code standards (formatting, naming, import conventions)
- Do NOT section (boundary rules)

**Full level adds:**

- Project structure (directory layout with descriptions)
- Architecture (layers, data flow, key patterns)
- Auth and permissions (if auth packages are present)
- Data model (if database/ORM packages are present)
- API conventions (if API routes or endpoints exist)
- Integration map (if 2+ distinct service client packages are present in dependencies)

**Cascading level requires:**

- Project-root AGENTS.md as entry point (under ~60 lines, references context/)
- Context directory files covering at least: system overview, architecture decisions
- Subdirectory AGENTS.md files only where areas have distinct patterns
- No content duplication between levels

### 3. Format and Conventions

Check adherence to context engineering conventions:

- `AGENTS.md` exists as the primary file (not just `CLAUDE.md` alone)
- `CLAUDE.md` exists as a symlink to `AGENTS.md` (not a duplicate with separate content)
- Do NOT section entries are specific and actionable:
  - Good: "Do not modify files in `src/auth/` without explicit approval"
  - Bad: "Be careful with security-sensitive code"
  - Bad: "Don't break things"
- Commands section entries match actual executable commands (cross-reference against `package.json` scripts, `Makefile` targets, or equivalent)
- No template placeholders left from scaffolding (bracket syntax `[like this]` remaining in non-template files)
- File uses markdown headings consistently (H2 for main sections)

### 4. Structural Issues

Check for common structural problems:

- **Duplicate subdirectory files:** Subdirectory AGENTS.md that just repeats the project root content. These add noise without value -- delete them or make them area-specific.
- **Empty context files:** Files in `context/` that are empty or contain only headings with no content. Better to not have the file than to have an empty one.
- **Cascading contradictions:** Rules at different levels that conflict without explicit override documentation. A subdirectory saying "use Jest" while the root says "use Vitest" needs a comment explaining why.
- **Missing coverage:** Directories with clearly distinct patterns (API layer, test directory, component library) that lack their own AGENTS.md when the project uses cascading.
- **Orphaned references:** Context files that reference other context files or directories that don't exist.

### 5. Content Quality

Check for common content problems:

- **Vague boundaries:** Do NOT entries that aren't actionable enough to enforce
- **Stale framework references:** Tech stack mentions that don't match installed dependencies
- **Missing symlink:** CLAUDE.md is a regular file instead of a symlink, or doesn't exist at all
- **Overly long root file:** Project-root AGENTS.md exceeding ~150 lines (candidate for cascading)
- **Missing integration map:** Project has 2+ distinct service client packages (e.g., Supabase + Jira client, Prisma + Stripe SDK) but no integration map or equivalent domain-to-service mapping. Without this, agents default to the dominant persistence layer for new work, ignoring TODO comments or type hints that indicate a different backing service.

## Report Format

Present findings grouped by category with a per-category score:

- **Complete** -- all checks pass for this category
- **Partial** -- some checks pass, specific issues identified
- **Missing** -- category has significant gaps

For each finding, include:

- The specific file and line reference where the issue is
- What the issue is (concise description)
- Why it matters (one sentence)
- Suggested fix (specific action)

Order recommendations by impact: structural issues and missing sections first, formatting conventions last.

## When to Use

- After running `/context-setup:scaffold` to verify the generated structure
- Before onboarding new contributors to ensure context is complete
- Periodically as a hygiene check alongside `/context-align`
- When AI sessions produce unexpected results that might indicate context gaps
- After major project changes to check if context level is still appropriate

## Example Output

> **Context Audit Results**
>
> **Level Appropriateness: Partial**
> Project has 4 layers (React frontend, Express API, Prisma ORM, PostgreSQL) and auth (Clerk), but context is a 35-line minimal AGENTS.md. Recommend upgrading to full single file to cover architecture, auth, data model, and API conventions.
>
> **Section Completeness: Partial**
> Present: project description, tech stack, commands, code standards, Do NOT.
> Missing: project structure, architecture, auth (Clerk detected in dependencies), data model (Prisma schema exists), API conventions (Express routes exist).
>
> **Format and Conventions: Complete**
> AGENTS.md is primary file. CLAUDE.md is a valid symlink. Do NOT entries are specific and actionable. Commands match package.json scripts.
>
> **Structural Issues: Partial**
> `src/api/AGENTS.md` duplicates 80% of root AGENTS.md content. Either delete it or replace with API-specific conventions only.
>
> **Content Quality: Complete**
> No stale references. Boundaries are specific. File length is appropriate for current level.
>
> **Priority Recommendations:**
>
> 1. Upgrade to full single file -- project complexity warrants expanded coverage (run `/context-setup:upgrade`)
> 2. Fix `src/api/AGENTS.md` duplication -- replace with API-specific content or delete

## How This Differs from Other Skills

- **context-audit** (this skill) checks structure and completeness -- is your context well-formed?
- **context-align** (this plugin) checks accuracy -- does your context match your code?
- **onboard** (`.claude-example/` skill) discovers and summarizes -- what context exists?
- **scope-check** (`.claude-example/` skill) validates tasks against boundaries -- can I do this?

Context-audit and context-align are complementary. Audit checks whether the *structure* is right (correct sections, appropriate level, no duplication). Align checks whether the *content* is right (references match reality, commands work, versions are current). Run audit when you change your context structure. Run align when you change your codebase.

## Notes

The level appropriateness check uses heuristics, not rules. A project with 50 directories might legitimately need only a minimal AGENTS.md if it's a monorepo where each package is simple. The audit surfaces the mismatch; the human decides whether it's intentional.

Section completeness is checked against the standard templates from `/context-setup:scaffold`. If you've intentionally omitted a section (no API to document, no auth layer), the audit will flag it -- acknowledge and move on. The goal is awareness, not compliance.

The audit is structural, not semantic. It can check whether an "Architecture" section exists and has content, but it can't check whether that content accurately describes your architecture. That requires human review or the code-level checks that `/context-align` provides.
