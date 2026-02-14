---
name: context-upgrade
description: Guides transition from your current context level to the next one -- minimal to full, full to cascading, or adding skills and hooks layers. Preserves existing content.
---

# Context Upgrade

Guide a transition from your current context level to the next one without losing existing content.

## What This Skill Does

1. **Detect current level** by reading existing context files:
   - No context files found -- equivalent to running scaffold
   - Single AGENTS.md under ~60 lines -- minimal level
   - Single AGENTS.md over ~60 lines -- full level
   - AGENTS.md + context/ directory or multiple AGENTS.md files -- cascading level
   - Check for `.claude/skills/` and `.claude/settings.json` hooks to assess skills/hooks layers

2. **Identify the appropriate upgrade path** based on current level and project signals.

3. **Execute the upgrade** with the user's confirmation, preserving all existing content.

## Upgrade Paths

### No Context to Minimal

Equivalent to running `/context-setup:scaffold` at the minimal level. Generate AGENTS.md from project analysis with sections: project description, tech stack, commands, code standards, Do NOT. Create CLAUDE.md symlink.

### Minimal to Full Single File

Read the existing AGENTS.md. Identify which full-level sections are missing. The full level adds these sections beyond minimal:

- **Project Structure** -- directory layout with descriptions. Generate from filesystem scan.
- **Architecture** -- application layers and data flow. Populate what's inferable from framework and directory conventions; bracket-placeholder the rest.
- **Auth and Permissions** -- auth mechanism, session handling, roles. Populate from detected auth packages; bracket-placeholder specifics.
- **Data Model** -- core models and relationships. Populate from schema files if present (Prisma, SQLAlchemy models, etc.); bracket-placeholder otherwise.
- **API Conventions** -- URL structure, request/response format, error handling. Populate from detected route structure; bracket-placeholder conventions.

Insert missing sections into the existing file after the current content, preserving everything already written. Do not rewrite or reorder existing sections.

**Trigger signals** (when minimal is no longer enough):

- Project has multiple layers (frontend + backend, or API + workers)
- Auth packages present but not documented
- Database/ORM present but data model not documented
- API routes exist but conventions not documented

### Full Single File to Cascading + Context Directory

Read the existing AGENTS.md. Extract sections into separate context/ files:

1. **Rewrite AGENTS.md** as the project-level entry point:
   - Keep: project description, tech stack summary, commands, code standards, Do NOT
   - Add: a note pointing to `context/` for architectural detail
   - Target: under 60 lines

2. **Create context/ directory** with files extracted from the existing AGENTS.md:
   - `system-overview.md` -- extracted from project description + any business context
   - `architecture-decisions.md` -- extracted from Architecture section, restructured as decisions with rationale
   - `technical-requirements.md` -- extracted from any performance, security, or compliance notes (may need bracket placeholders if this wasn't in the original)
   - `api-documentation.md` -- extracted from API Conventions section
   - `working-style-guide.md` -- extracted from any contribution or workflow notes (may need bracket placeholders)

3. **Create subdirectory AGENTS.md files** where the project has clearly distinct areas. Common candidates:
   - API layer (error handling patterns, response formats, middleware conventions)
   - UI/component layer (component patterns, state management, styling conventions)
   - Test directory (testing conventions, fixture patterns, mocking approach)

   Only create subdirectory files where there are genuinely different patterns. A subdirectory file that would just say "follow the root conventions" should not exist.

4. **Verify no content was lost** by comparing section coverage before and after.

**Trigger signals** (when a single file is no longer enough):

- AGENTS.md exceeds ~150 lines
- Multiple contributors need different sections at different times
- Multi-project workspace or monorepo
- Conversations regularly hit context budget from loading the entire file

### Add Skills Layer

Check whether `.claude/skills/` exists and what skills are present.

Describe the three operational skills that complement context files:

- **onboard** -- Discovers and summarizes the project's context structure. Run at session start or when joining a project. Read-only orientation.
- **context-align** -- Cross-references context files against the codebase for drift. Checks tech stack, directory references, commands, and cascading contradictions. Run periodically or after upgrades.
- **scope-check** -- Validates planned tasks against AGENTS.md boundary rules before starting work. Three-level assessment: clear, warning, blocked. Run before tasks in protected areas.

These skills consume the same AGENTS.md files that the project already has. They add operational automation on top of the declarative context layer.

Note: The distribution mechanism for skills may vary. The `context-engineering` repo provides working examples in `.claude-example/skills/`. How you install them depends on your tool and workflow.

**Trigger signals** (when to add skills):

- Using context files regularly and wanting proactive validation
- Onboarding new contributors frequently
- Context files have drifted from codebase in the past
- Working in areas with declared boundaries

### Add Hooks Layer

Check whether `.claude/settings.json` has hook configurations.

Describe the hooks that enforce what AGENTS.md declares:

- **boundary-guard** (PreToolUse) -- Runs before every file edit. Finds the nearest AGENTS.md, extracts boundary rules from "Do NOT" and "Boundaries" sections, and blocks edits to restricted files. The rule moves from guidance to enforcement.
- **lint-markdown** (PostToolUse) -- Runs after file edits to `.md` files. Runs markdownlint and blocks if violations are found. Enforces consistent markdown formatting.
- **symlink-check** (PostToolUse) -- Verifies CLAUDE.md is a symlink after file operations. Notification only, never blocks.

Explain the three-layer defense model:

1. **AGENTS.md is declarative** -- says what to do and not do. Advisory.
2. **Hooks are imperative** -- enforce rules at execution time. Blocking.
3. **Skills are operational** -- validate at planning time and check for drift. Proactive.

All three layers read the same AGENTS.md files. The context file is the single source of truth; skills and hooks are the operational enforcement layer.

Note: Hook registration (settings.json format, event types) is Claude Code-specific. The hook scripts themselves are portable shell scripts. The `context-engineering` repo provides working examples in `.claude-example/`.

**Trigger signals** (when to add hooks):

- Need enforcement, not just guidance
- Boundary violations have happened despite context files
- Want automated markdown quality checks
- Multiple AI agents working in the same codebase

## When to Use

- After `/context-setup:audit` recommends upgrading to a higher level
- When your AGENTS.md is getting too long for a single file
- When adding contributors (human or AI) who need better context coverage
- When moving from solo development to team development
- When you want to add operational enforcement on top of declarative context

## Example Output

> **Current level: Full single file**
> AGENTS.md is 142 lines with 7 sections. No context directory. No subdirectory AGENTS.md files. No skills or hooks detected.
>
> **Recommended upgrade: Cascading + context directory**
> Your AGENTS.md is approaching the ~150 line threshold, and the project has 3 distinct areas (API routes, React components, database migrations) that would benefit from their own conventions.
>
> **Upgrade plan:**
>
> 1. Rewrite AGENTS.md as a 55-line entry point (keep: description, stack, commands, standards, Do NOT)
> 2. Create context/ directory with 4 files extracted from current content
> 3. Create subdirectory AGENTS.md for src/api/ (distinct error handling and response patterns)
> 4. Create CLAUDE.md symlink (currently missing)
>
> No content will be lost -- existing sections move to context/ files. Want to proceed?

## Notes

Upgrades are additive. Each level builds on the previous one rather than replacing it. Minimal sections (tech stack, commands, standards, Do NOT) persist at every level -- they just move to the project-root AGENTS.md as the canonical quick-reference while detailed content moves to context/ files.

The trigger signals are guidelines, not thresholds. A 140-line AGENTS.md that's well-organized and covers a straightforward project doesn't need to be split into cascading files just because it's near 150 lines. Upgrade when the structure becomes a bottleneck, not when an arbitrary metric is hit.

Content extraction during the full-to-cascading upgrade requires care. Sections don't always map 1:1 to context/ files. An "Architecture" section might contain both architectural decisions (goes to architecture-decisions.md) and business context (goes to system-overview.md). Read the content, don't just move headings.

The skills and hooks layers are described but not installed by this skill. Installation mechanisms vary by tool and may change over time. This skill explains what each layer does, when it's valuable, and what trigger signals suggest it's time. The user decides how and when to install.
