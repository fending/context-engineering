# AGENTS.md Jira Section Template

Template for the Jira integration section of your project's AGENTS.md (or CLAUDE.md). This gives agent teammates everything they need to sync with Jira without runtime discovery.

Copy the fenced content below into your AGENTS.md (or CLAUDE.md) and replace the `[bracketed]` values.

````markdown
## Jira Integration

Project: **[PROJECT_KEY]** at [instance].atlassian.net
Cloud ID: `[cloud-id]`

### Jira API Reference

Issue type: Task (`[task-type-id]`), Sub-task (`[subtask-type-id]`)

Transitions: To Do (`[todo-id]`), In Progress (`[in-progress-id]`), Done (`[done-id]`)

Custom fields:

- Assigned Team Member (`[customfield_id]`) -- text, agent role name
- Tokens Used (`[customfield_id]`) -- number, LLM tokens consumed

### Agent Team Jira Sync Protocol

When working as part of an agent team, all teammates must follow this protocol.

Use the Jira REST API v3 at `https://[instance].atlassian.net/rest/api/3/`. Authenticate with Basic auth using `JIRA_USERNAME` and `JIRA_API_TOKEN` from the env.

**Task creation:**

- When you create or claim a task, create a [PROJECT_KEY] ticket via `POST /rest/api/3/issue`
- Summary: match the task subject
- Description: include the full task description, acceptance criteria, and the agent task ID
- Issue type: Task (subtasks for smaller pieces if needed)
- Labels: your team label (`team-experience` or `team-engine`) + project label
- Set `[customfield_assigned_team_member]` (Assigned Team Member) to your role name
- Store the Jira ticket key (e.g., [PROJECT_KEY]-47) in the agent task metadata

**Progress updates:**

- Comment on your Jira ticket when starting work, completing milestones, and finishing
- Log work via `POST /rest/api/3/issue/{key}/worklog` when completing tasks
- Update `[customfield_tokens_used]` (Tokens Used) on task completion if available

**Status sync:**

- When you transition an agent task status, transition the Jira ticket to match
- `POST /rest/api/3/issue/{key}/transitions` with transition id: To Do (`[todo-id]`), In Progress (`[in-progress-id]`), Done (`[done-id]`)

**Dependency tracking:**

- When agent tasks have blockers/dependencies, create Jira issue links between the corresponding tickets

**Checking for feedback:**

- Before starting any task, read the latest comments on the corresponding Jira ticket
- At natural checkpoints (subtask completion, before marking done), re-read the ticket for new comments
- The project owner may leave feedback or direction as Jira comments

**Labels:**

- `team-experience` -- Frontend/UX work
- `team-engine` -- Backend/API work
- Project label -- All tasks for a given project (e.g., `[project-name]`). Set per engagement.
````

## Notes

**Why hardcode transition IDs?** Agents discovering their own transition IDs means an extra API call per ticket operation, plus parsing logic that can fail silently. Hardcoding removes a runtime dependency and makes the protocol deterministic.

**Why text field instead of Jira Assignee?** AI agents aren't Jira users. The Assignee field requires a valid Jira account ID. A text custom field holds the agent's role name without user management overhead.

**Why Basic auth instead of MCP?** See [jira-setup.md](jira-setup.md#why-basic-auth-instead-of-mcp) for the full reasoning and community references. (TL;DR: OAuth tokens expire mid-session, and agent teams run long enough for that to matter.)

**Adapt the labels.** `team-experience` and `team-engine` are generic defaults for a frontend/backend split. Rename them to match your team structure. The pattern is: one label per team, one label per project. Keep team labels role-based, not product-based, so they're reusable.
