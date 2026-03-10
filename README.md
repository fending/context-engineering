# Context Engineering

Reusable patterns for structuring the context that AI coding assistants consume. Copy a template, fill in your specifics, ship better code with less re-explaining. Claude Code users can install the [context-setup plugin](plugins/context-setup/) to generate, audit, align, and upgrade these files automatically.

What you get: four levels of context architecture (single file, context directory, cascading files, agents & agent teams with optional Jira sync) with working templates at each level. Every file is designed to be copied and adapted, and generic placeholders describe the *kind* of content that belongs there rather than inventing fictional examples.

## Start Here

**New to context engineering?** Start with [single-file-examples/minimal.md](single-file-examples/minimal.md) -- a 40-line template that eliminates the two most common failure modes in AI-assisted development.

**Already have a context file but outgrowing it?** Read [Which Approach Should You Use](#which-approach-should-you-use) to decide whether to move to a context directory, cascading files, or agents.

**Working across multiple projects?** The [cascading pattern](cascading-files-examples/) gives you consistent defaults with project-specific overrides.

**Running multi-agent workflows?** See [agents/](agents/) for structured workflows and [agent-teams/](agent-teams/) for parallel coordination with optional Jira integration.

**Want to automate and enforce your context files?** Copy `.claude-example/` for working skills and hooks. See [.claude-example/README.md](.claude-example/README.md). Claude Code users can also install the [context-setup plugin](plugins/context-setup/) to scaffold, audit, align, and upgrade context files from project analysis.

## What's Here

```text
context-engineering/
├── AGENTS.md                      # Context file for this repo (CLAUDE.md symlinked)
├── single-file-examples/          # Single-file approach (AGENTS.md / CLAUDE.md)
│   ├── README.md                  # When and why to use this pattern
│   ├── minimal.md                 # Bare minimum that's still useful
│   ├── saas-app.md                # SaaS product example
│   ├── api-service.md             # Backend API example
│   └── cli-tool.md                # CLI tool example
├── directory-example/             # Multi-file context directory approach
│   ├── README.md                  # When and why to use this pattern
│   └── context/                   # Full working example
│       ├── system-overview.md
│       ├── architecture-decisions.md
│       ├── technical-requirements.md
│       ├── api-documentation.md
│       ├── business-requirements.md
│       └── working-style-guide.md
├── cascading-files-examples/            # Cascading context (global > project > subdirectory)
│   ├── README.md
│   ├── global-example-agents.md   # Example: user-level defaults
│   ├── project-example-agents.md  # Example: project-level context
│   └── subdirectory-example-agents.md  # Example: subdirectory override
├── agents/                        # Agent-as-workflow pattern
│   ├── README.md
│   ├── shared-config.json         # Cross-agent settings (services, directories, dependencies)
│   ├── deploy/                    # Deploy agent example
│   │   ├── agent.md
│   │   ├── config.json
│   │   └── state.json
│   └── content-pipeline/          # Content pipeline agent example
│       ├── agent.md
│       ├── config.json
│       └── state.json
├── agent-teams/                   # Multi-agent teams (with optional Jira integration)
│   ├── README.md                  # Activation, team structure, phases, optional Jira sync
│   ├── jira-setup.md              # One-time Jira configuration (optional)
│   ├── agents-md-jira-section.md  # AGENTS.md template for Jira sync protocol (optional)
│   └── team-structure.md          # AGENT_TEAMS.md template for team composition
├── .claude-example/                    # Working Claude Code config (copy to .claude/)
│   ├── README.md                       # Setup, skills overview, hook documentation
│   ├── skills/                         # SKILL.md examples (vendor-neutral standard)
│   │   ├── onboard/SKILL.md           # Context structure discovery
│   │   ├── context-align/SKILL.md     # Drift detection across context sources
│   │   └── scope-check/SKILL.md       # Pre-task boundary validation
│   ├── hooks/
│   │   ├── boundary-guard.sh          # Pre-tool file protection script
│   │   └── lint-markdown.sh           # Post-tool markdown linting
│   └── settings.json                  # Hook configurations
├── plugins/                            # Installable plugin (generates and maintains context)
│   └── context-setup/                  # Scaffold, audit, align, usage, and upgrade context files
│       ├── README.md
│       ├── CHANGELOG.md
│       └── skills/
│           ├── context-scaffold/SKILL.md   # Generate context files from project analysis
│           ├── context-audit/SKILL.md      # Evaluate structure and completeness
│           ├── context-align/SKILL.md      # Drift detection against actual codebase
│           ├── context-mcp/SKILL.md        # MCP server detection and optimization guidance
│           ├── context-usage/SKILL.md      # Session-level context consumption diagnostic
│           └── context-upgrade/SKILL.md    # Transition between complexity levels
└── evolution.md                   # How context engineering evolved since June 2025
```

## Which Approach Should You Use

This isn't a spectrum with a right answer. It's a function of your project's complexity and how many people (human and AI) need to consume the context.

**Start with a single file** if you're working alone or in a small team on a bounded project. A well-structured AGENTS.md handles most scenarios. Zero setup cost, immediate value.

**Move to a context directory** when the single file grows past the point where you can hold its structure in your head, when multiple people are editing different sections, or when different parts of your context change at different rates. Architecture decisions are stable for months; prompt patterns change weekly.

**Use cascading context** when you work across multiple projects and want consistent defaults (coding style, error handling patterns, tool preferences) without repeating yourself. Global settings cascade down; project-level files override; subdirectory files specialize further.

**Add agents** when you have recurring multi-step workflows that benefit from structured instructions, persistent state, and shared configuration. Agents aren't just prompts -- they're workflow definitions with their own config and runtime state.

**Use agent teams** when the work is large enough to split across parallel tracks. Agent teams build on the same foundation as individual agents but add multi-agent coordination: ownership boundaries, shared interface contracts, and phased development. Optionally, sync agent progress to Jira for external visibility and bidirectional feedback.

**Add skills and hooks** when you want to automate workflows that consume your context files and enforce the boundaries they declare. Skills are user-invoked (discover context structure, check for drift, validate boundaries before starting). Hooks run automatically (block edits to protected files, verify symlink integrity). SKILL.md is a vendor-neutral standard, like AGENTS.md. See [.claude-example/](.claude-example/) for a ready-to-copy configuration.

## Key Principles

These patterns work regardless of which AI coding tool you use. They emerged from daily use across a productivity workspace, multiple side projects, consulting engagements, and a job search.

**Context is for both humans and AI.** If only the AI reads it, it'll drift from reality. If only humans read it, you'll spend time re-explaining things every session. Write for both audiences -- and you'll catch drift faster because humans review the same file.

**Boundaries matter more than instructions.** Telling an AI what NOT to do (don't modify templates without approval, don't push to main, don't add features beyond what was asked) prevents more problems than telling it what to do. Hard-won lessons belong in context files -- each boundary is a bug you won't hit again. Enforced boundaries matter even more. A pre-tool hook can actually block edits to files your AGENTS.md marks as protected. See [.claude-example/](.claude-example/) for how declarative and imperative layers work together.

**State is not context.** Context files describe *how* to work. State files describe *where you are*. Keep them separate. An agent's workflow instructions (`agent.md`) shouldn't contain today's pipeline status (`state.json`). Mixing them means every session update pollutes your process documentation.

**Review your context files.** They rot. Architecture decisions change, team norms evolve, tools get replaced. If your context file references a library you deprecated six months ago, it's actively misleading every AI session that reads it. Run `/context-align` after dependency upgrades, major refactors, or monthly as a hygiene check. It cross-references your context files against your actual codebase and flags what's drifted.

**Reduce output before it enters context.** AI coding tools consume tokens from every command output and tool response. Command Output Notes document concise CLI invocations (flags, pipes, format options) that return only what's needed. MCP Tool Notes do the same for MCP server calls (parameter knobs like `maxResults`, `fields`, query filters). Both sections go in your AGENTS.md and apply regardless of which structural approach you use. A 100-line AGENTS.md is roughly 300-400 tokens -- well within budget. At 150+ lines you're spending 500+ tokens on context before any task-specific content loads. Cascading files let the tool load only the relevant subset.

**Hybrid is the natural end state.** Most mature setups end up with a combination: an AGENTS.md for quick orientation, a context directory for depth, cascading files for cross-project consistency, and agents for recurring workflows. Start simple, add layers when the pain justifies them.

## Maintaining Context Files

Context files drift. Dependencies get upgraded, directories get renamed, conventions evolve. These triggers should prompt a review:

- **After dependency upgrades** -- run `/context-align` to catch stale version references and removed packages
- **After major refactoring** -- directory references, command names, and architecture descriptions may need updating
- **After adding or removing MCP servers** -- run `/context-mcp` to update MCP Tool Notes
- **Monthly or per-sprint** -- a lightweight hygiene check catches gradual drift before it accumulates

Review workflow:

1. `/context-align` -- fix any drift findings
2. `/context-audit` -- check structural completeness
3. Review bracket placeholders -- fill in any that are still generic
4. Commit the updates

### Keeping Context Files Lean

Not every section of an AGENTS.md is relevant to every task. When your file grows past ~100 lines, consider which sections need to load at session start versus which can live in a `context/` directory and be read on demand:

- **Always-load** (keep in root AGENTS.md): Tech Stack, Commands, Code Standards, Do NOT -- these apply to every task regardless of scope
- **Task-dependent** (move to `context/` when file gets large): Architecture, Auth, Data Model, API Conventions, Integration Map -- these matter for some tasks but not others
- **Session-dependent** (keep in root but understand the trade-off): Command Output Notes, MCP Tool Notes -- only relevant when those tools are used, but small enough that pre-loading is fine

A 100-line root AGENTS.md is ~300 tokens. Task-dependent detail in `context/` files only loads when the agent reads those files. Run `/context-setup:context-upgrade` when your single file outgrows this structure.

## Using These Examples

Every file in this repo is designed to be copied and adapted. Where examples need specifics, they use generic placeholders and describe the *kind* of content that belongs there rather than inventing fictional companies or products. The structures and patterns are drawn from real use.

1. Pick the approach that matches your current project complexity
2. Copy the relevant files into your project -- or if you use Claude Code, run `/context-setup:context-scaffold` to generate them pre-populated from your project's dependencies, directory structure, and config files
3. Replace the placeholder content with your own
4. Iterate -- context engineering is ongoing, not a one-time setup

## Tool Compatibility

These templates use AGENTS.md as the primary filename, following the vendor-neutral standard adopted by 60,000+ projects and stewarded by AAIF/Linux Foundation. AGENTS.md works with any compatible AI coding tool.

**For Claude Code users:** Claude Code reads `CLAUDE.md` by default. Use a symlink so both names resolve to the same file:

```bash
ln -s AGENTS.md CLAUDE.md
```

This repo uses the same convention -- `CLAUDE.md` is a symlink to `AGENTS.md`.

To install the context-setup plugin (scaffold, audit, align, and upgrade context files from project analysis):

```bash
/plugin marketplace add fending/context-engineering
/plugin install context-setup@context-engineering
```

To add the remaining operational skills and hooks (onboard, scope-check, boundary-guard):

```bash
cp -r .claude-example/ .claude/
```

**For other tools:** Check your tool's documentation for its context file convention. If it reads a different filename, symlink from AGENTS.md to that name. One source of truth, multiple entry points.

**Skills and hooks:** The `.claude-example/` directory demonstrates skills (SKILL.md, a vendor-neutral standard) and hooks (Claude Code configuration). The skill patterns and hook logic transfer to any tool with equivalent features. File paths and `settings.json` format are Claude Code-specific.

## Background

This repository is a companion to [Rethinking Team Topologies for AI-Augmented Development](https://brianfending.substack.com/p/rethinking-team-topologies-for-ai), which explored how teams organize context for AI collaboration. That article ended with a note: *"If interested in what I put into each such file, contact me!"* -- this repo is that answer, plus everything that's evolved since.

See [evolution.md](evolution.md) for how the landscape has changed since June 2025: cascading files became standard, AGENTS.md emerged as a vendor-neutral convention, hooks and skills formalized enforcement and reuse, and agent teams enabled parallel AI development.

## License

MIT. See [LICENSE](LICENSE).

## Author

Brian Fending -- [brianfending.com](https://www.brianfending.com) | [Substack](https://brianfending.substack.com)
