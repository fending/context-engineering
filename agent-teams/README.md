# Agent Teams (with optional Jira integration)

Agent teams coordinate multiple AI agents working in parallel on a shared codebase. Each teammate owns a scope, builds against shared contracts, and reports progress through the team's internal task system.

This guide covers activation, team structure, and development phases. It also includes an optional Jira integration for syncing agent progress to an external board -- something I find useful for visibility and bidirectional feedback, but not required to run agent teams.

## When to Use Agent Teams

Agent teams make sense when:

- The work can be split into parallel tracks with clear ownership boundaries (frontend/backend, feature A/feature B)
- You want visibility into agent progress without watching terminal output
- Multiple agents need to coordinate through shared interfaces rather than shared files
- The project is large enough that a single agent session would hit context limits

Agent teams are overkill when:

- The task is small enough for one agent session
- There's no natural parallelism in the work
- You don't need coordination between agents

## Activation

Agent teams require an environment variable. Add it to your Claude Code settings:

**Option 1: Global settings** (`~/.claude/settings.json`)

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Option 2: Project settings** (`.claude/settings.json` in repo root)

Same format, scoped to one project.

Verify it's active by starting a Claude Code session and asking it to create a test team. If it works, you'll see team and task directories created under `~/.claude/teams/` and `~/.claude/tasks/`. Delete the test team afterward.

## Team Structure

Teams split into groups with clear ownership boundaries. Each group owns a set of directories and builds against shared interfaces. The boundaries prevent merge conflicts and let agents work in parallel without coordination overhead.

See [team-structure.md](team-structure.md) for a complete template.

A typical two-team split for a full-stack application:

- **Team Experience** (frontend) -- Owns pages, components, and client-side logic
- **Team Engine** (backend) -- Owns API routes, database, integrations, and server-side logic

Teams build against shared TypeScript interfaces (or equivalent contracts in your stack). These interfaces are defined early and represent the handoff points between teams. Frontend builds against typed stubs where APIs don't exist yet; backend builds against the agreed schema.

## Development Phases

Agent teams work best when preceded by scaffolding and followed by integration:

### Phase 0: Scaffolding (Single Session)

Not a team. One focused session to create the skeleton that teams will build on: project initialization, authentication, database setup, base layout, initial deployment. Teams need something to build *on*.

### Phase 1: Parallel Build (Agent Teams)

Two or more teams work in parallel against shared contracts. Each teammate:

1. Reads their assigned scope
2. Creates tasks for their work
3. Builds against shared interfaces
4. Reports progress through comments and status transitions

Use plan approval mode (`plan_mode_required`) so teammates present their approach before implementing. The team lead coordinates but doesn't implement.

### Phase 2: Integration (Single Session or Small Team)

Wire the pieces together: replace stubs with real APIs, end-to-end testing, polish, error handling. This phase is smaller and benefits from one agent (or a small team) that can see the full picture.

## Optional: Jira Integration

Agent teams work without Jira -- the internal task system handles coordination between teammates. But if you want external visibility (for yourself, stakeholders, or just a persistent record), syncing agent tasks to Jira turns the team's work into a board you can filter, comment on, and direct.

I find this useful because agent tasks are essentially Jira tickets already: they have a summary, description, status, owner, and dependencies. The sync protocol makes that mapping explicit and adds a feedback loop -- you leave direction as Jira comments, agents pick it up at checkpoints.

### Setup

One-time Jira configuration: API token, custom fields, screen setup, and validation. See [jira-setup.md](jira-setup.md).

### The Sync Protocol

The sync protocol defines how agent teammates interact with Jira. It belongs in your project's CLAUDE.md so every agent reads it automatically.

See [claude-md-jira-section.md](claude-md-jira-section.md) for a complete template.

The protocol covers five operations:

1. **Task creation** -- When an agent claims a task, it creates a corresponding Jira ticket with labels, custom fields, and a description that includes the agent task ID for cross-referencing.

2. **Progress updates** -- Agents comment on their Jira ticket at natural checkpoints: starting work, completing milestones, finishing. Work is logged via the worklog API on task completion.

3. **Status sync** -- Agent task status transitions map directly to Jira: Pending to To Do, In Progress to In Progress, Completed to Done.

4. **Dependency tracking** -- When agent tasks have blockers, Jira issue links are created between the corresponding tickets. This surfaces the dependency graph in the Jira board.

5. **Feedback loop** -- Before starting work and at natural checkpoints, agents read the latest comments on their Jira ticket. The project owner can leave direction as Jira comments, which agents pick up without needing to be in the same terminal session.

The feedback loop is what makes this bidirectional. Agents push progress to Jira; the owner pushes direction back through Jira comments.

### Labels

Labels provide the filtering layer in Jira. Use two categories:

- **Team labels** -- `team-experience`, `team-engine` (or whatever your teams are called). These are generic and reusable across projects.
- **Project label** -- One label per project engagement (e.g., `dashboard`, `auth-migration`). This lets you filter a single project's work when the Jira board serves multiple efforts.

Keep team labels generic. Don't name them after the product -- name them after the role they play. This lets you reuse the same Jira project and label scheme across engagements.

## Files in This Directory

- **[jira-setup.md](jira-setup.md)** -- One-time Jira configuration: API token, custom fields, screen setup, validation.
- **[claude-md-jira-section.md](claude-md-jira-section.md)** -- Template for the Jira integration section of your CLAUDE.md. Copy into your project's CLAUDE.md and fill in the bracketed values.
- **[team-structure.md](team-structure.md)** -- Template for an AGENT_TEAMS.md file that defines team composition, ownership boundaries, integration contracts, and the prompt used to start the parallel build.
