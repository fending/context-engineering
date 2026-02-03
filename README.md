# Context Engineering

Working examples of context file structures for AI-augmented development.

This repository is a companion to [Rethinking Team Topologies for AI-Augmented Development](https://brianfending.substack.com/p/rethinking-team-topologies-for-ai), which explored how teams organize context for AI collaboration. That article ended with a note: *"If interested in what I put into each such file, contact me!"* -- this repo is that answer, plus everything that's evolved since June 2025.

## What's Here

```text
context-engineering/
├── CLAUDE.md                       # Context file for this repo (yes, it has one)
├── claude-md-single-file/          # Single-file approach (CLAUDE.md / AGENTS.md)
│   ├── minimal.md                  # Bare minimum that's still useful
│   ├── saas-app.md                 # SaaS product example
│   ├── api-service.md              # Backend API example
│   └── cli-tool.md                 # CLI tool example
├── context-directory/              # Multi-file context directory approach
│   ├── README.md                   # When and why to use this pattern
│   └── context/                    # Full working example
│       ├── system-overview.md
│       ├── architecture-decisions.md
│       ├── technical-requirements.md
│       ├── api-documentation.md
│       ├── business-requirements.md
│       └── working-style-guide.md
├── claude-md-cascading-files/      # Cascading context (global > project > subdirectory)
│   ├── README.md
│   ├── global-claude.md            # User-level defaults (~/.claude/CLAUDE.md)
│   ├── project-claude.md           # Project-level (repo root CLAUDE.md)
│   └── subdirectory-claude.md      # Subdirectory override
├── agents/                         # Agent-as-workflow pattern
│   ├── README.md
│   ├── shared-config.json          # Cross-agent settings (services, directories, dependencies)
│   ├── deploy/                     # Deploy agent example
│   │   ├── agent.md
│   │   ├── config.json
│   │   └── state.json
│   └── content-pipeline/           # Content pipeline agent example
│       ├── agent.md
│       ├── config.json
│       └── state.json
└── evolution.md                    # What changed since June 2025
```

## Which Approach Should You Use

This isn't a spectrum with a right answer. It's a function of your project's complexity and how many people (human and AI) need to consume the context.

**Start with a single file** if you're working alone or in a small team on a bounded project. A well-structured CLAUDE.md or AGENTS.md handles most scenarios. Zero setup cost, immediate value.

**Move to a context directory** when the single file grows past the point where you can hold its structure in your head, when multiple people are editing different sections, or when different parts of your context change at different rates. Architecture decisions are stable for months; prompt patterns change weekly.

**Use cascading context** when you work across multiple projects and want consistent defaults (coding style, error handling patterns, tool preferences) without repeating yourself. Global settings cascade down; project-level files override; subdirectory files specialize further.

**Add agents** when you have recurring multi-step workflows that benefit from structured instructions, persistent state, and shared configuration. Agents aren't just prompts -- they're workflow definitions with their own config and runtime state.

## Key Principles

These patterns emerged from daily use across a productivity workspace, multiple side projects, consulting engagements, and a job search. Some things that matter:

**Context is for both humans and AI.** If only the AI reads it, it'll drift from reality. If only humans read it, you'll spend time re-explaining things every session. Write for both audiences.

**Boundaries matter more than instructions.** Telling an AI what NOT to do (don't modify templates without approval, don't push to main, don't add features beyond what was asked) prevents more problems than telling it what to do. Hard-won lessons belong in context files.

**State is not context.** Context files describe *how* to work. State files describe *where you are*. Keep them separate. An agent's workflow instructions (`agent.md`) shouldn't contain today's pipeline status (`state.json`).

**Review your context files.** They rot. Architecture decisions change, team norms evolve, tools get replaced. If your context file references a library you deprecated six months ago, it's doing more harm than good.

**Hybrid is the natural end state.** Most mature setups end up with a combination: a CLAUDE.md for quick orientation, a context directory for depth, cascading files for cross-project consistency, and agents for recurring workflows. The article predicted this; it's now standard practice.

## Evolution Since June 2025

The original article framed single-file vs. context-directory as two competing approaches. In practice, the single-file approach won... but then evolved. Cascading CLAUDE.md files (the article's "hierarchical override system") became the de facto standard, and most of the other developments build on top of that foundation.

- **Cascading CLAUDE.md** is now the default pattern for multi-project work (global > project > subdirectory). The article described this as a feature of the single-file approach; it's now the primary organizing principle for most context engineering setups.
- **Hooks** introduced event-driven automation (pre-commit checks, post-tool actions)
- **Skills** formalized reusable, invocable capabilities within context systems
- **MCP servers** connected AI assistants to external services (Jira, Gmail, APIs) natively
- **Agent-as-workflow** pattern emerged: `agent.md` + `config.json` + `state.json` for structured, stateful operations
- **Hybrid approaches** moved from theoretical to default -- most production setups combine multiple patterns

See [evolution.md](evolution.md) for details on each of these developments.

## Using These Examples

Every file in this repo is designed to be copied and adapted. Where examples need specifics, they use generic placeholders and describe the *kind* of content that belongs there rather than inventing fictional companies or products. The structures and patterns are drawn from real use.

1. Pick the approach that matches your current project complexity
2. Copy the relevant files into your project
3. Replace the placeholder content with your own
4. Iterate -- context engineering is ongoing, not a one-time setup

## License

MIT. See [LICENSE](LICENSE).

## Author

Brian Fending -- [brianfending.com](https://www.brianfending.com) | [Substack](https://brianfending.substack.com)
