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
- **Cascading contradictions:** Rules at different levels that disagree about the same concern without a comment explaining the exception. Check these categories across all AGENTS.md files in the tree: test runner, linter/formatter, package manager, framework version, import style, and overlapping "Do NOT" boundaries. A subdirectory saying "use Jest" while the root says "use Vitest" is fine if documented -- flag it when it isn't.
- **Missing coverage:** Directories with clearly distinct patterns (API layer, test directory, component library) that lack their own AGENTS.md when the project uses cascading.
- **Orphaned references:** Context files that reference other context files or directories that don't exist.

### 5. Content Quality

Check for common content problems:

- **Vague boundaries:** Do NOT entries that aren't actionable enough to enforce
- **Stale framework references:** Tech stack mentions that don't match installed dependencies
- **Missing symlink:** CLAUDE.md is a regular file instead of a symlink, or doesn't exist at all
- **Overly long root file:** Project-root AGENTS.md exceeding ~150 lines (candidate for cascading)
- **Missing integration map:** Project has 2+ distinct service client packages (e.g., Supabase + Jira client, Prisma + Stripe SDK) but no integration map or equivalent domain-to-service mapping. Without this, agents default to the dominant persistence layer for new work, ignoring TODO comments or type hints that indicate a different backing service.

### 6. MCP Tool Notes Cross-Reference

Check whether the project has MCP servers configured but no MCP Tool Notes section.

- Scan for MCP config files at project level: `.mcp.json`, `.codex/config.toml`, `.gemini/settings.json`, `.vscode/mcp.json`, `.cursor/mcp.json`
- If any MCP config is found and AGENTS.md has no MCP Tool Notes section: report as a finding with a pointer to `/context-setup:context-mcp`
- If MCP Tool Notes exists but is still bracket placeholders: flag as incomplete with the same pointer
- If no MCP configs are found: skip this check silently

This check does not inspect tool registries, generate templates, or make recommendations about specific MCP tools. That's `/context-setup:context-mcp`'s domain. This check only surfaces the gap.

### 7. Command Output Optimization

Check whether the project could benefit from a Command Output Notes section, and if session history is available, surface specific optimization opportunities.

**Structural check** (always runs):

- Commands section exists but no Command Output Notes section -- recommend adding one if the project is at full single-file level or higher (skip this recommendation for minimal-level context files under ~50 lines)
- Command Output Notes section exists but is still bracket placeholders -- flag as incomplete

**Dependency-aware recommendations** (always runs):

Read the project's dependency manifest and recommend concise variants for detected tools:

- vitest/jest detected: suggest `npx vitest run 2>&1 | tail -5` for quick checks, `npx vitest run 2>&1 | tail -40` for debugging (vitest puts failures at the bottom)
- pytest detected: suggest `pytest -q --no-header 2>&1 | tail -3` for quick checks, `pytest -q --tb=short` for debugging failures
- eslint detected: suggest `eslint --format compact .` for eslint 8, or `eslint . 2>&1 | head -30` for eslint 9+ (compact was removed from core)
- cargo/clippy detected: suggest `--message-format=short` for one-line diagnostics
- ruff detected: suggest `ruff check --output-format concise .`

Only recommend tools that are actually in the dependency tree. Do not suggest tools the project doesn't use.

**Session-observed recommendations** (opportunistic -- pre-compression only):

Review conversation history for Bash tool calls from the current session. If history is available (not yet compressed), identify:

- Commands that were run more than once with full verbose output -- suggest the concise variant
- Commands that returned more than ~50 lines where a flag or pipe would reduce output
- Patterns like bare `npm test`, `cargo test`, `pytest` without output-reducing flags

If conversation history has been compressed and prior tool calls are not visible, skip this tier and note: "Session history unavailable (compressed). Run `/context-setup:context-audit` earlier in a session or after noticing slow responses to surface command-specific optimization opportunities."

If no Bash commands were run in the visible session history, or all observed commands already use concise flags/pipes, skip this tier with a brief note ("No optimization opportunities observed in this session" or "All observed commands already use concise output").

**When to surface this check prominently:**

If you're experiencing slow responses or high token usage mid-session, running `/context-setup:context-audit` will catch optimization opportunities that have presented since your last compression event. The session-observed tier is most useful during active development sessions, not as a periodic hygiene check.

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

- After running `/context-setup:context-scaffold` to verify the generated structure
- Before onboarding new contributors to ensure context is complete
- Periodically as a hygiene check alongside `/context-align`
- When AI sessions produce unexpected results that might indicate context gaps
- After major project changes to check if context level is still appropriate
- Mid-session when responses feel slow or token usage seems high -- the session-observed tier catches optimization opportunities that have presented since your last compression event

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
> **MCP Tool Notes: Missing**
> `.mcp.json` found with 2 configured servers (atlassian, supabase). No MCP Tool Notes section in AGENTS.md. Run `/context-setup:context-mcp` for optimization recommendations.
>
> **Command Output Optimization: Partial**
> AGENTS.md has a Commands section but no Command Output Notes. Detected vitest and eslint in devDependencies.
> Suggested additions:
>
> - `npx vitest run 2>&1 | tail -5` for quick pass/fail checks
> - `eslint . 2>&1 | head -30` (eslint 9+ detected -- compact format removed from core)
>
> Session history available (3 Bash calls visible):
>
> - `npm test` was run twice with ~180 lines of output each time. Concise variant: `npx vitest run 2>&1 | tail -5`
> - `npx eslint .` returned 47 lines. Concise variant: `eslint . 2>&1 | head -30`
>
> **Priority Recommendations:**
>
> 1. Upgrade to full single file -- project complexity warrants expanded coverage (run `/context-setup:context-upgrade`)
> 2. Add Command Output Notes section -- vitest and eslint detected with concise variants available
> 3. Fix `src/api/AGENTS.md` duplication -- replace with API-specific content or delete

## How This Differs from Other Skills

- **context-audit** (this skill) checks structure and completeness -- is your context well-formed?
- **context-align** (this plugin) checks accuracy -- does your context match your code?
- **context-mcp** (this plugin) detects MCP servers and generates optimization guidance -- are your MCP tools documented?
- **context-usage** (this plugin) observes session tool calls -- where is context going?
- **onboard** (`.claude-example/` skill) discovers and summarizes -- what context exists?
- **scope-check** (`.claude-example/` skill) validates tasks against boundaries -- can I do this?

Context-audit and context-align are complementary. Audit checks whether the *structure* is right (correct sections, appropriate level, no duplication, concise commands that optimize output). Align checks whether the *content* is right (references match reality, commands work, versions are current). Run audit when you change your context structure. Run align when you change your codebase.

Context-usage and context-audit category 6 are complementary. Usage is the quick diagnostic -- run it mid-session to see what's happening. If it finds verbose or repeated commands, it points you to audit for specific recommendations. Usage observes; audit prescribes.

## Notes

The level appropriateness check uses heuristics, not rules. A project with 50 directories might legitimately need only a minimal AGENTS.md if it's a monorepo where each package is simple. The audit surfaces the mismatch; the human decides whether it's intentional.

Section completeness is checked against the standard templates from `/context-setup:context-scaffold`. If you've intentionally omitted a section (no API to document, no auth layer), the audit will flag it -- acknowledge and move on. The goal is awareness, not compliance.

The audit is structural, not semantic. It can check whether an "Architecture" section exists and has content, but it can't check whether that content accurately describes your architecture. That requires human review or the code-level checks that `/context-setup:context-align` provides.
