# How Context Engineering Evolved

The original article ([Rethinking Team Topologies for AI-Augmented Development](https://brianfending.substack.com/p/rethinking-team-topologies-for-ai)) framed context engineering as a choice between two approaches: a single file (CLAUDE.md, AGENTS.md) vs. a context directory with separate documents for each concern.

Eight months later, the landscape looks different. The single-file approach won the adoption race, but it evolved in ways the article didn't anticipate -- cascading files became the organizing principle, a vendor-neutral standard emerged, and stateful agents changed what's possible. Here's what happened.

## Cascading Context Files Became the Standard

The article described hierarchical override as a feature of the single-file approach: root-level guidance provides defaults, subdirectory files offer overrides. This pattern has since become the dominant organizing principle for context engineering.

The three-level cascade is now standard:

1. **Global** (`~/.claude/CLAUDE.md`): Personal preferences, environment defaults, communication style
2. **Project** (repo root `AGENTS.md`): Stack, structure, architecture, boundaries
3. **Subdirectory** (e.g., `src/api/AGENTS.md`): Specialized rules for that area

This is the pattern most practitioners settle on. It's simple enough to understand immediately, flexible enough to handle multi-project workflows, and doesn't require any tooling to implement.

The article's prediction that hybrid approaches would emerge was correct, but the hybrid looks different than expected. Rather than "single file OR context directory," most mature setups use cascading context files as the backbone, with a context directory for depth when needed.

## AGENTS.md Emerged as the Vendor-Neutral Standard

As context engineering spread beyond Claude Code to Cursor, Windsurf, Copilot, and other tools, a fragmentation problem emerged: each tool read its own filename. Claude Code read `CLAUDE.md`, Cursor read `.cursorrules`, and so on. Projects that wanted to work with multiple tools needed duplicate files with identical content.

AGENTS.md solved this by establishing a single, vendor-neutral filename that any tool can adopt. The standard is stewarded by AAIF/Linux Foundation, and adoption crossed 60,000+ projects within months of its introduction. The convention is straightforward: author your context in `AGENTS.md`, then symlink tool-specific filenames to it.

```bash
ln -s AGENTS.md CLAUDE.md     # Claude Code
ln -s AGENTS.md .cursorrules  # Cursor (if needed)
```

One source of truth, multiple entry points. The content doesn't change -- only the filename that each tool looks for.

For this repository, all templates now output `AGENTS.md` as the primary filename. The symlink convention is documented in each template's intro text, and this repo's own context file follows the same pattern (`CLAUDE.md` symlinks to `AGENTS.md`).

## Hooks

Hooks introduced event-driven automation into the context engineering workflow. They're shell commands that execute in response to specific events:

- **Pre-tool hooks:** Run before a tool executes (e.g., validate before file edits)
- **Post-tool hooks:** Run after a tool completes (e.g., lint after code generation)
- **Notification hooks:** Surface information when specific conditions are met

Hooks fill a gap the article didn't address: enforcement. A CLAUDE.md can say "always run tests before committing," but a hook actually enforces it. The combination of declarative guidance (context files) and imperative enforcement (hooks) is more robust than either alone.

Common hook patterns:

- Pre-commit quality checks
- Auto-formatting after code generation
- Validation that generated code matches project conventions
- Notification when specific files are modified

## Skills

Skills formalized what were previously ad-hoc prompt patterns into reusable, invocable capabilities. A skill is a structured instruction set that can be triggered by name:

- `/commit` -- Create a git commit following project conventions
- `/review-pr` -- Review a pull request with project-specific criteria
- `/deploy` -- Run the deployment workflow

Skills differ from agents in scope and statefulness. A skill is a single operation (render this PDF, create this commit). An agent is a workflow with persistent state (track the content pipeline, manage the deployment process).

The practical impact is that recurring single-step tasks that used to require re-explaining the process each session can now be invoked by name with consistent behavior.

## MCP Servers

Model Context Protocol (MCP) servers gave AI assistants native access to external services:

- **Jira, Asana, Linear:** Read and create tickets without API scripting
- **Gmail, Calendar:** Search messages, check schedules
- **Databases:** Query data directly
- **Custom APIs:** Any service with an MCP adapter

Before MCP, integrating an AI assistant with external services meant writing wrapper scripts or manually copying data. MCP made these connections first-class, which changed the kind of workflows that agents could handle.

This is what made the agent-as-workflow pattern viable. A standup agent that needs to check Jira, scan email, and review the calendar can do so natively rather than through brittle shell scripts.

## Agent-as-Workflow Pattern

The article didn't discuss agents directly -- it focused on context for development teams. Since then, a clear pattern emerged for structuring AI-assisted workflows:

```text
agent.md     -- Workflow instructions (what to do, in what order, with what rules)
config.json  -- Static settings (thresholds, URLs, feature flags)
state.json   -- Runtime state (last run, current status, pipeline data)
```

The important separation is between these three concerns:

- **Instructions** change when processes change (quarterly, when workflows evolve)
- **Config** changes when settings change (new service, adjusted threshold)
- **State** changes every session (updated timestamps, new pipeline items)

Agents also introduced the concept of "autonomous actions" -- things the AI should do without asking permission. Rather than prompting for confirmation at every step, the agent.md explicitly lists actions that should execute immediately (update state files, run standard checks, open auth URLs). This removes friction from recurring workflows without sacrificing control over dangerous operations.

See the [agents/](agents/) directory for working examples.

## Agent Teams

The agent-as-workflow pattern handles one agent running one workflow. Agent teams extend this to multiple agents working in parallel on a shared codebase.

The pattern emerged from a practical observation: when a project is large enough to split into parallel tracks (frontend/backend, feature A/feature B), a single agent session either hits context limits or moves sequentially through work that could be concurrent. Agent teams formalize the coordination: each teammate owns a scope, builds against shared interface contracts, and the work follows a phased structure (scaffolding, parallel build, integration).

The key design decision is ownership boundaries. Two teams with clear directory ownership (one owns pages and components, the other owns API routes and database) can work in parallel without merge conflicts. Within each team, a lead coordinates and resolves conflicts. This matters more than raw parallelism -- six independent agents touching the same files creates chaos regardless of how fast they work.

Agent teams work without external tooling, but syncing tasks to Jira (or a similar tracker) adds external visibility and a feedback loop. Agent tasks already have the shape of tickets -- summary, description, status, owner, dependencies -- so the mapping is natural. The project owner can direct work through Jira comments without needing to be in the same terminal session.

See the [agent-teams/](agent-teams/) directory for activation, team structure patterns, and optional Jira integration.

## Hybrid Approaches as Default

The article's conclusion predicted hybrid approaches:

> "Some teams are beginning to combine approaches: Bootstrap with single file, evolve to context directories, generate the single agent file from context, maintain dual interfaces."

This prediction held, though the specific hybrid that emerged is simpler than anticipated:

1. **Cascading AGENTS.md** provides the backbone (global > project > subdirectory)
2. **Context directory** provides depth where needed (architecture decisions, business requirements)
3. **Agents** handle recurring workflows with persistent state
4. **Agent teams** coordinate parallel work across ownership boundaries
5. **Skills** handle recurring single-step operations
6. **Hooks** enforce rules that context files can only declare

Most practitioners don't use all of these. A solo developer might use only cascading context files. A team might add a context directory. An organization might add agents and hooks. The pattern scales with complexity rather than requiring full adoption up front.

## What the Article Missed

**The article framed single-file vs. context-directory as competing approaches.** In practice, they're complementary. The AGENTS.md is the entry point; the context directory provides depth. Most setups that started with one evolved to include the other.

**The article underestimated how quickly cascading files would become standard.** The hierarchical override pattern wasn't presented as the central organizing principle, but that's what it became. Global > project > subdirectory is now the first thing practitioners set up.

**The article didn't anticipate stateful agents.** The discussion focused on static context (documentation for AI to read). The emergence of agents with persistent state and autonomous actions was a meaningful evolution that changed what's possible with context engineering.

**The article didn't anticipate multi-agent coordination.** Individual agents were a step beyond context files; agent teams were a step beyond that. The idea that multiple AI agents could work in parallel with clear ownership boundaries, shared contracts, and phased development wasn't on the radar. Neither was the natural mapping between internal agent tasks and external project trackers like Jira.

## Key Takeaways

**Context organization is critical.** This was the article's thesis, and nothing since has challenged it. Teams that invest in context engineering get better results from AI collaboration.

**The PRD wall can be broken.** Embedding product context into development workflows has become a real practice, not just a theoretical benefit. Business requirements in context files are consumed by AI assistants during implementation.

**Different scales require different solutions.** The sophistication curve (experimentation > scaling > maturity > enterprise) described in the article maps to what practitioners actually experience as they grow their context engineering practice.
