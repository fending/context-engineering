# .claude-example

A working `.claude/` configuration you can copy into your project. Includes skills (SKILL.md, a vendor-neutral standard) and hooks (shell scripts enforced by settings.json) that automate and enforce the context patterns in the rest of this repo.

## Setup

Copy the directory into your project root:

```bash
cp -r .claude-example .claude
```

Or merge into an existing `.claude/` directory:

```bash
cp -r .claude-example/skills .claude/skills
cp -r .claude-example/hooks .claude/hooks
# Merge settings.json manually if you have existing hook configurations
```

Make hook scripts executable (preserved by git, but verify after copying):

```bash
chmod +x .claude/hooks/*.sh
```

## Two Open Standards

This directory builds on two open standards that work across AI coding tools:

**AGENTS.md** -- The context layer. Declares what the project is, how to work in it, and what not to do. Vendor-neutral, adopted by 60,000+ projects, stewarded by AAIF/Linux Foundation.

**SKILL.md** -- The capability layer. Defines reusable operations invoked as slash commands. Frontmatter (name, description) loads at startup for discovery; full content loads on invocation. This progressive disclosure means you can have many skills without consuming context budget.

Both standards work with Claude Code, Codex CLI, and ChatGPT. The root-level directories in this repo teach AGENTS.md patterns. This directory teaches SKILL.md patterns and operational enforcement.

## Skills

Skills are SKILL.md files in subdirectories of `.claude/skills/`. Each skill has YAML frontmatter (name, description) and markdown instructions. Invoke them as slash commands (`/onboard`, `/context-align`, `/scope-check`).

### /onboard

Discovers context files at all levels (global, project, subdirectory, context directory, agents, skills, hooks). Summarizes each with a one-line description and modification date. Flags staleness: missing packages, nonexistent directories, outdated references. Produces a context map that tells agents which files to read depending on the task, without front-loading everything.

Run at session start or when joining a project. Read-only orientation -- it discovers and summarizes but doesn't create or modify anything.

See `skills/onboard/SKILL.md` for full instructions.

### /context-align

Cross-references AGENTS.md and SKILL.md files against the actual codebase. Checks tech stack references vs dependencies, directory references vs filesystem, build commands vs actual scripts, skill relevance to current stack, and contradictions between cascading context files.

Run periodically, after dependency upgrades, or after major refactoring. This operationalizes the "they rot" principle -- catching mechanical drift so humans can focus on substantive accuracy.

See `skills/context-align/SKILL.md` for full instructions.

### /scope-check

Validates a planned task against AGENTS.md boundary rules before writing code. Reads "Do NOT" and "Boundaries" sections from all applicable levels, compares against the task, and assesses: clear (proceed), warning (boundaries nearby), or blocked (direct violation).

Run before starting tasks that touch protected areas. This is the planning-time complement to the boundary-guard hook -- catch conflicts before writing code rather than after.

See `skills/scope-check/SKILL.md` for full instructions.

## Hooks

Hooks are shell commands configured in `settings.json` that run automatically on tool events. They enforce what AGENTS.md can only declare.

### boundary-guard (PreToolUse)

**Script:** `hooks/boundary-guard.sh`

Runs before every file edit. Walks the full directory ancestry to collect AGENTS.md files at every level, extracts "Do NOT", "Boundaries", and "Restrictions" sections from each, and checks whether the target file matches any restricted path patterns. Rules compound across levels -- a subdirectory boundary adds to the root boundary, it doesn't replace it. Blocks the edit (exit 2) if any rule matches, with a message quoting the specific rule and its source file.

**How it works:**

1. Receives target file path from stdin JSON (`tool_input.file_path`)
2. Collects all AGENTS.md files from the file's directory up to the filesystem root
3. Extracts boundary rules from "Do NOT", "Boundaries", and "Restrictions" sections in each file
4. Pattern-matches the target file against path references in the rules, relative to each AGENTS.md's own directory
5. Blocks on first match (exit 2 with rule and source file quoted on stderr), silent on no match (exit 0)

**Design notes:** The hook extracts path patterns from boundary rules in two ways. Backtick-fenced paths (`` `src/auth/` ``, `` `.env` ``) are extracted exactly as written -- this is the reliable path. For rules written in plain text, the hook falls back to regex extraction of path-shaped tokens (anything with slashes or leading dots). The fallback handles common cases but is inherently best-effort on free-form English. For predictable enforcement, use backticks around file and directory references in your boundary rules. The transferable pattern is the hook contract: stdin JSON in, exit codes out, stderr for messaging.

**Pairs with /scope-check:** boundary-guard catches violations at execution time (reactive). `/scope-check` catches them at planning time (proactive). Together they provide defense in depth.

### lint-markdown (PostToolUse)

**Script:** `hooks/lint-markdown.sh`

Runs after every file edit. Filters to `.md` files only, runs markdownlint-cli2, and blocks (exit 2) if violations are found. Details appear on stderr so the AI can fix the issues.

This is the simplest useful hook -- a clean example of the PostToolUse contract. It enforces a standard that's already declared in your project (markdown conventions) rather than requiring AGENTS.md parsing. If you're new to hooks, start here.

**Requirements:** markdownlint-cli2 (`npx` handles installation on first run). Pairs with a `.markdownlint.jsonc` config in your project root.

### symlink-check (PostToolUse, inline)

Configured directly in `settings.json` (simple enough to not need a script). Checks whether `CLAUDE.md` at the repo root is a symlink after file operations. If it's not, prints a reminder to stderr. Notification only -- never blocks (always exits 0).

This enforces the AGENTS.md/CLAUDE.md symlink convention. If someone accidentally replaces the symlink with a regular file, the next edit surfaces it.

## The Three Layers

AGENTS.md, skills, and hooks work together because they address different moments in the workflow:

**AGENTS.md is declarative.** It says "don't modify auth middleware without approval." The AI reads this as guidance and usually follows it -- but it's advisory. Nothing prevents the edit from happening.

**Hooks are imperative.** The boundary-guard hook actually blocks the edit. The rule moves from "guidance the AI should follow" to "constraint the system enforces." The AI gets a clear error message quoting the rule and can adjust its approach.

**Skills are operational.** `/scope-check` lets you validate a task against boundaries before starting. `/onboard` discovers what context exists. `/context-align` checks whether context files still match reality. Skills consume the same AGENTS.md files that hooks enforce.

All three layers read the same AGENTS.md files. The context file is the single source of truth; skills and hooks are the operational layer on top of it.

## When This Is Overkill

Not every project needs skills and hooks. Skip this if:

- You're working solo on a small project with a single AGENTS.md
- Your codebase is simple enough that boundaries are obvious
- You don't have recurring workflows that consume context budget explaining the same thing each session
- You're still figuring out what belongs in your context files (get the content right first, then automate)

Start with AGENTS.md. Add skills when you find yourself repeating the same orientation or validation steps. Add hooks when you need enforcement, not just guidance.

## For Non-Claude-Code Users

The SKILL.md format is vendor-neutral -- it works with Claude Code, Codex CLI, and ChatGPT. If your tool supports skill discovery, these files should work as-is.

The hook logic (stdin JSON, exit codes, stderr messaging) is portable shell scripting. The hook *registration* (`settings.json` format, event types like PreToolUse/PostToolUse) is Claude Code-specific. Adapt the registration mechanism for your tool's equivalent:

- **Codex CLI:** Check your tool's hook configuration format
- **Cursor / Windsurf:** May use different event names or config locations
- **Custom setups:** The scripts work standalone -- call them from any pre/post hook system

## Relationship to Other Directories

The root-level directories in this repo (`single-file-examples/`, `directory-example/`, `cascading-files-examples/`, `agents/`, `agent-teams/`) are tool-agnostic patterns. They teach context structure through copyable templates with `[bracket]` placeholders.

This directory is the operational layer. It demonstrates how to automate discovery, detect drift, validate boundaries, and enforce rules -- using the same AGENTS.md files those patterns produce. Copy the patterns from the root directories. Copy this directory to make them load-bearing.
