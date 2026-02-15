# AGENTS.md

This is the context file for *this* repository -- the one about context engineering. `CLAUDE.md` is symlinked to this file for Claude Code compatibility. For usage notes and an overview of what's here, read the [README](README.md).

## What This Project Is

A public companion repo to [Rethinking Team Topologies for AI-Augmented Development](https://brianfending.substack.com/p/rethinking-team-topologies-for-ai). Working examples of context file structures (single-file, context directory, cascading, agents) plus an installable plugin that scaffolds, audits, aligns, and upgrades context files from project analysis. Patterns you understand, automation you install.

## Structure

- `single-file-examples/` -- Four single-file AGENTS.md examples at different complexity levels
- `directory-example/` -- Full context directory with six template files
- `cascading-files-examples/` -- Global, project, and subdirectory cascading examples
- `agents/` -- Agent-as-workflow pattern with two example agents and shared config
- `agent-teams/` -- Multi-agent teams with optional Jira integration (activation, team structure, phases, templates)
- `.claude-example/` -- Working skills and hooks configuration (copy to `.claude/`)
- `plugins/context-setup/` -- Installable Claude Code plugin (scaffold, audit, align, upgrade context files)
- `evolution.md` -- What changed since the June 2025 article

## Standards

- No emojis, no decorative symbols
- kebab-case filenames
- Direct, practitioner voice -- not academic, not marketing
- Conventional commits (feat/fix/docs/etc)
- All markdown must pass markdownlint (MD013 disabled for line length)
- Example files use `[bracket]` placeholders -- no fictional companies or products

## Navigation

Read different files depending on the task:

- Adding or editing examples: read the target directory's `README.md` first, then the existing examples for the pattern
- Understanding the repo's purpose and framing: `README.md`
- Understanding what changed since the article: `evolution.md`
- Understanding cross-agent coordination: `agents/README.md` and `agents/shared-config.json`
- Setting up agent teams with Jira: `agent-teams/README.md`
- Setting up skills and hooks via copy: `.claude-example/README.md`
- Installing skills via plugin: `plugins/context-setup/README.md` and the SKILL.md files in its `skills/` subdirectories

## File Format Convention

Every example file follows the same structure:

1. **Title and intro** -- what this example is, when to use it (2-3 sentences)
2. **Fenced template** -- the actual AGENTS.md content the reader would copy, wrapped in backtick fences
3. **Notes section** -- explains why the template is structured this way, when to graduate to something more complex

Files containing nested markdown code blocks use 4-backtick outer fences (`` ```` ``) to avoid parsing issues. Template content uses `[bracket]` placeholders describing the *kind* of content that belongs there.

## Do NOT

- Add fictional company names, product names, or branded examples
- Add application code -- this is a documentation-only repo
- Modify example templates without updating the corresponding README if structure changes
- Add new top-level sections without updating the root README file tree
