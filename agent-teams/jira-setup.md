# Jira Setup for Agent Teams

One-time configuration to sync agent team tasks with Jira Cloud. Complete these steps before starting your first agent team build.

## Prerequisites

- A Jira Cloud instance with REST API access
- An API token (generated at [id.atlassian.com](https://id.atlassian.com/manage-profile/security/api-tokens))
- A project for agent work (dedicated project recommended -- keeps agent tickets separate from human work)

## Environment Variables

Agents authenticate via Basic auth. Store credentials where your agents can source them:

```bash
JIRA_USERNAME=[your-email@example.com]
JIRA_API_TOKEN=[your-api-token]
```

These can live in a `.env.local` file that your CLAUDE.md references, or as shell environment variables.

## Issue Types and Statuses

Agent teams work best with a simple workflow. The minimum viable setup:

| Issue Type | Purpose |
| ---------- | ------- |
| Task | Primary work item (one per agent task) |
| Sub-task | Breakdown of larger tasks |

| Status | Category | Transition ID |
| ------ | -------- | ------------- |
| To Do | To Do | Discover yours (see below) |
| In Progress | In Progress | Discover yours |
| Done | Done | Discover yours |

Transition IDs vary by Jira instance. Discover yours by creating a ticket and querying its transitions:

```bash
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  "https://[instance].atlassian.net/rest/api/3/issue/[KEY-1]/transitions" \
  | python3 -c "
import sys, json
for t in json.load(sys.stdin)['transitions']:
    print(f\"{t['name']} (id: {t['id']}) -> {t['to']['name']}\")"
```

Document these IDs in your CLAUDE.md so agents don't have to discover them at runtime.

## Custom Fields

Two custom fields give you visibility beyond what labels and comments provide:

**Assigned Team Member** (text field) -- Which agent role owns this ticket. Agents aren't Jira users, so the standard Assignee field won't work. This text field holds the role name (e.g., "QA Engineer", "Data Architect").

**Tokens Used** (number field) -- LLM tokens consumed on this task. Optional, but useful for cost tracking.

Create them via API:

```bash
# Assigned Team Member
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X POST "https://[instance].atlassian.net/rest/api/3/field" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Assigned Team Member",
    "description": "Agent team member role name",
    "type": "com.atlassian.jira.plugin.system.customfieldtypes:textfield",
    "searcherKey": "com.atlassian.jira.plugin.system.customfieldtypes:textsearcher"
  }'

# Tokens Used
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X POST "https://[instance].atlassian.net/rest/api/3/field" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tokens Used",
    "description": "LLM tokens consumed by agent during this task",
    "type": "com.atlassian.jira.plugin.system.customfieldtypes:float",
    "searcherKey": "com.atlassian.jira.plugin.system.customfieldtypes:exactnumber"
  }'
```

Both commands return the field's `id` (e.g., `customfield_10157`). Save these -- you'll need them in your CLAUDE.md.

## Adding Fields to Screens

Creating a custom field doesn't make it visible on tickets. You need to add it to the project's screens.

Find your project's screens:

```bash
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  "https://[instance].atlassian.net/rest/api/3/screens" \
  | python3 -c "
import sys, json
for s in json.load(sys.stdin)['values']:
    if '[PROJECT]' in s['name']:
        print(f\"{s['name']} (id: {s['id']})\")"
```

You'll typically see two screens per project: a create screen and an edit/view screen. Get the tab ID for each, then add your fields:

```bash
# Get tab IDs
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  "https://[instance].atlassian.net/rest/api/3/screens/[screen-id]/tabs"

# Add field to screen tab
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X POST "https://[instance].atlassian.net/rest/api/3/screens/[screen-id]/tabs/[tab-id]/fields" \
  -H "Content-Type: application/json" \
  -d '{"fieldId": "[customfield_id]"}'
```

Repeat for both screens and both custom fields.

## Validation

Create a test ticket, exercise every operation, then delete it:

```bash
# Create
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X POST "https://[instance].atlassian.net/rest/api/3/issue" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "[PROJECT]"},
      "summary": "[TEST] Agent sync validation",
      "issuetype": {"name": "Task"},
      "labels": ["team-experience", "[project-label]"],
      "[customfield_assigned_team_member]": "QA Engineer",
      "[customfield_tokens_used]": 12500
    }
  }'

# Comment
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X POST "https://[instance].atlassian.net/rest/api/3/issue/[KEY-1]/comment" \
  -H "Content-Type: application/json" \
  -d '{"body": {"type": "doc", "version": 1, "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Test comment from agent sync validation."}]}]}}'

# Transition to In Progress
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X POST "https://[instance].atlassian.net/rest/api/3/issue/[KEY-1]/transitions" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "[in-progress-transition-id]"}}'

# Log work
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X POST "https://[instance].atlassian.net/rest/api/3/issue/[KEY-1]/worklog" \
  -H "Content-Type: application/json" \
  -d '{"timeSpent": "30m", "comment": {"type": "doc", "version": 1, "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Test worklog."}]}]}}'

# Verify all fields
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  "https://[instance].atlassian.net/rest/api/3/issue/[KEY-1]?fields=summary,status,labels,[customfield_assigned_team_member],[customfield_tokens_used],worklog,comment"

# Clean up
curl -s -u "$JIRA_USERNAME:$JIRA_API_TOKEN" \
  -X DELETE "https://[instance].atlassian.net/rest/api/3/issue/[KEY-1]"
```

If every step returns success (200/201/204), your setup is complete.

## Why Basic Auth Instead of MCP

Atlassian offers a [Remote MCP Server](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/) that provides native Jira access through OAuth 2.1. It's the official integration path and works well for interactive sessions in Claude Desktop or ChatGPT.

For agent teams, this guide uses Basic auth with API tokens instead. Agent teammates run long sessions with unpredictable timing -- an agent might not touch Jira for 20 minutes while it's writing code, then need to update a ticket. OAuth tokens expire mid-session, and the [community reports](https://community.atlassian.com/forums/Jira-questions/Claude-Code-Jira-MCP/qaq-p/3122551) needing to re-authenticate multiple times a day. Basic auth with an API token is stateless -- it works the same whether the last request was 5 seconds or 50 minutes ago.

If your sessions are short or you prefer the MCP approach, the official server works. For agent teams running parallel builds over hours, API tokens are more reliable.

## Resources

### Official Atlassian Documentation

- [Getting Started with the Atlassian Remote MCP Server](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/) -- Official setup guide for the OAuth-based MCP integration
- [Atlassian MCP Server GitHub Repository](https://github.com/atlassian/atlassian-mcp-server) -- Apache-licensed source and documentation for the remote MCP server

### Community Experiences

- [Claude MCP Integration with Jira](https://community.atlassian.com/forums/Jira-questions/Claude-Code-Jira-MCP/qaq-p/3122551) -- Community thread discussing MCP reliability issues and the shift to API tokens for agent workflows
- [Using the Atlassian Remote MCP Server Beta](https://community.atlassian.com/forums/Atlassian-Remote-MCP-Server/Using-the-Atlassian-Remote-MCP-Server-beta/ba-p/3005104) -- Early adopter experiences with the Remote MCP Server, including setup friction and client compatibility

### Claude and MCP Documentation

- [Anthropic: Remote MCP Servers](https://platform.claude.com/docs/en/agents-and-tools/remote-mcp-servers) -- How Claude supports remote MCP servers, including the connector API and third-party server listing
- [Composio: Atlassian + Claude Code Integration](https://composio.dev/toolkits/atlassian/framework/claude-code) -- Third-party MCP wrapper that handles OAuth token refresh automatically, alternative to direct API access
