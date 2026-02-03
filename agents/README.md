# Agent-as-Workflow Pattern

Agents aren't chat prompts. They're structured workflow definitions with their own configuration and persistent state. The pattern uses three files:

```text
agents/
├── shared-config.json       # Cross-agent settings (API tokens, directories, shared services)
├── deploy/
│   ├── agent.md             # Workflow instructions -- what the agent does and how
│   ├── config.json          # Agent-specific settings (thresholds, targets, feature flags)
│   └── state.json           # Runtime state (last run, current status, queued items)
└── content-pipeline/
    ├── agent.md
    ├── config.json
    └── state.json
```

## The Three Files

### agent.md -- Workflow Definition

This is the instruction set. It defines:

- **Capabilities:** What the agent can do, organized by trigger phrase
- **Workflows:** Step-by-step procedures for each capability
- **Autonomous actions:** Things the agent should do without asking permission
- **Boundaries:** What the agent must never do
- **Decision logic:** How the agent should handle ambiguous situations

Think of it as a runbook that an AI follows. It's not a prompt -- it's a process document.

### config.json -- Settings

Static configuration that changes infrequently:

- Thresholds and targets
- Service URLs and credentials references
- Directory paths
- Feature flags
- Mappings and lookup tables

Config is separate from the workflow because settings change at different times and for different reasons than procedures.

### state.json -- Runtime State

Mutable state that persists between sessions:

- Last run timestamp
- Current status of tracked items
- Queues and pipelines
- Metrics and counters
- Scheduled next actions

State is separate from config because it changes every session. Mixing runtime state into config makes it impossible to reset one without affecting the other.

## shared-config.json -- Cross-Agent Settings

When multiple agents use the same services, shared config prevents duplication:

```json
{
  "jira": {
    "instance": "yourteam.atlassian.net",
    "projects": {
      "ENG": "Engineering work",
      "CONTENT": "Content production"
    }
  },
  "directories": {
    "content": "content/",
    "standups": "standups/"
  },
  "agent_dependencies": {
    "standup": ["content-pipeline", "deploy"]
  }
}
```

## When to Use Agents

Agents are useful when:

- You have a recurring workflow with multiple steps (daily standup, content publishing, deployment)
- The workflow needs persistent state (tracking a pipeline, counting metrics)
- Multiple agents need to coordinate (standup agent reads state from content and deploy agents)
- The same workflow needs to work consistently across sessions

Agents are overkill when:

- The task is a one-off
- There's no persistent state to track
- The workflow fits in a CLAUDE.md section

## Examples

This directory contains a shared config and two example agents:

- **[deploy/](deploy/)** -- A deployment workflow agent that manages pre-flight checks, deployment steps, and rollback procedures
- **[content-pipeline/](content-pipeline/)** -- A content production agent that tracks drafts, review status, and publishing workflow

The [shared-config.json](shared-config.json) file shows the cross-agent settings pattern -- service credentials, directory paths, workspace references, and agent dependencies that multiple agents consume.

The agent examples are sanitized versions of real production agents. Copy the structure and adapt to your workflows.
