---
name: context-mcp
description: Detects connected MCP servers, matches them against known optimization templates, and generates MCP Tool Notes for your AGENTS.md. For unknown servers, interactively discovers optimization opportunities from tool registries.
---

# Context MCP

Optimize MCP tool calls the same way Command Output Notes optimizes CLI commands. Detect what MCP servers are connected, match against known templates, and generate documentation that reduces token waste from default tool parameters.

## General Principle: CLI Over MCP for Reads

When a CLI tool and MCP server both cover the same operation, prefer CLI for read operations. CLI tools generally offer field selection (`--json field1,field2`), output piping (`| tail -5`), and documented, predictable behavior. MCP servers typically wrap raw APIs with no field filtering -- GitHub's MCP `get_issue` returns ~100 lines where `gh issue view --json title,state` returns 1. MCP is the right choice for write operations (creating issues, sending messages) where output size doesn't matter, and for services that have no CLI equivalent.

When generating MCP Tool Notes, flag cases where a CLI alternative exists and if superior in performance recommend CLI for reads alongside the MCP optimization guidance.

## What This Skill Does

Two tiers: known pattern recommendations (deterministic, config-based) and interactive discovery (user-in-the-loop, for unknown servers).

### 1. Detect MCP Configurations

Scan for MCP config files across platforms. Always ask before reading user-level configs outside the project directory.

**Project-level configs (read without asking):**

| Platform | Path | Format |
| -------- | ---- | ------ |
| Claude Code | `.mcp.json` | JSON |
| OpenAI Codex | `.codex/config.toml` | TOML |
| Gemini CLI | `.gemini/settings.json` | JSON |
| VS Code / GitHub Copilot | `.vscode/mcp.json` | JSON |
| Cursor | `.cursor/mcp.json` | JSON |

**User-level configs (ask before reading):**

| Platform | Path | Format |
| -------- | ---- | ------ |
| Claude Code | `~/.claude/settings.json` | JSON |
| OpenAI Codex | `~/.codex/config.toml` | TOML |
| Gemini CLI | `~/.gemini/settings.json` | JSON |
| Windsurf | `~/.codeium/windsurf/mcp_config.json` | JSON |

Report which platforms have MCP servers configured and what servers were found. If no configs are detected at the project level, ask whether to check user-level configs.

**TOML parsing note:** Codex uses TOML for MCP config. Use regex-based extraction for server names and connection details rather than requiring a TOML parser dependency. Note in the output if TOML parsing was approximate.

### 2. Known Pattern Recommendations

For MCP servers that match known templates, generate ready-to-use MCP Tool Notes content.

**Known server templates:**

#### Atlassian (Jira / Confluence)

- Jira search: use `searchJiraIssuesUsingJql` with `fields: ["summary", "status"]` and `maxResults: 3-5` for triage. Default fields include `description`, `issuetype`, `priority`, and `created` -- roughly 2x the payload per issue. Description fields on form-generated tickets can be hundreds of tokens each.
- Confluence search: use `searchConfluenceUsingCql` with narrow CQL and `limit: 5`. Avoid `expand` unless you need page body content.
- Prefer `getJiraIssue` with a known key over broad JQL searches when you have the ticket number.

#### Gmail

- Search: use `maxResults: 3-5` with specific `q` filters (`from:`, `after:`, `subject:`). Default is 20 results, each with headers, snippet, and metadata.
- Prefer `gmail_read_message` over `gmail_read_thread` when you need one message. Thread reads return every message in the conversation.
- For recent mail checks: `q: "is:unread after:2024/3/1"` with `maxResults: 3`.

#### Google Calendar

- List events with tight `timeMin`/`timeMax` bounds and `maxResults: 5-10`. Default is 50 results per page.
- Keep `condenseEventDetails: true` (the default). Setting it to `false` adds full attendee lists, attachments, and timestamps per event -- only use `false` when you need attendee details.
- Single event by ID when you have it -- don't search for what you can fetch directly.

#### Web (WebFetch / WebSearch)

- WebFetch: use a focused `prompt` parameter. "Extract the API rate limits" returns less than no guidance. There are no `maxResults` or `limit` parameters -- the prompt is the only knob controlling output size.
- WebSearch: use `allowed_domains` to narrow results when you know the source (e.g., `allowed_domains: ["docs.anthropic.com"]`). Result count is server-controlled with no limit parameter.
- Avoid chaining WebSearch into multiple WebFetch calls -- each fetch returns a full page. Search results alone are often sufficient.

#### GitHub

- Via CLI (preferred for output efficiency): `gh issue view <N> --json title,state` returns 1 line vs. 65 lines default. `gh pr view <N> --json title,state` returns 1 line vs. ~30 lines default. List commands are already compact -- `--limit` matters more than `--json` there.
- Via MCP: the GitHub MCP server wraps the raw REST API with no field filtering. `get_issue` returns ~100 lines (full body, user objects with 15+ URL fields, labels, reactions) vs. 1 line from CLI with `--json`. `list_issues` with `per_page: 2` returns ~200 lines. The only knob is `per_page`/`page` on list operations.
- When both are available, prefer CLI for read operations. MCP is useful for write operations (creating issues, PRs, comments) where output size doesn't matter.

#### Supabase

- `list_tables` with `verbose: false` (the default) returns ~1 line per table. `verbose: true` adds all columns, types, defaults, and constraints -- ~20x larger. Only use verbose when you need schema details for a specific table.
- Always `LIMIT` query results. `SELECT *` without LIMIT on a table with content columns returns full row payloads.
- Select specific columns: `SELECT id, status, created_at` returns ~6x less than `SELECT *` on a typical table with 16 columns.

#### Vercel

- `list_deployments` requires `projectId` (no cross-project flooding) but returns 20 items per page with verbose git metadata (~25 lines each). No `limit` parameter -- use `since`/`until` timestamps to narrow the time window.
- `get_deployment_build_logs` defaults to 100 lines. Use `limit: 10-20` for quick checks, full 100 only when debugging build failures.
- `get_runtime_logs` defaults to 50 entries (max 1000). Filter with `level: ["error"]`, `environment: "production"`, `source: ["serverless"]`, and tight `since`/`until` to avoid pulling all log levels across all environments.
- `list_projects` is already compact (~4 fields per project). `get_deployment` by ID is efficient for single deployment checks.

**Matching logic:**

1. Extract server names from detected MCP configs
2. Match against known templates by server name (case-insensitive, partial matching -- "atlassian" matches "claude_ai_Atlassian", "github" matches "github-mcp-server")
3. Check for existing MCP Tool Notes section in AGENTS.md
4. Report: what servers are configured, which have known templates, which are already documented

**Output for known servers:**

For each matched server not already documented, generate the MCP Tool Notes entry ready to paste into AGENTS.md. If an MCP Tool Notes section already exists, show only the missing entries.

### 3. Interactive Discovery

For MCP servers without known templates. This tier is interactive -- every step that could have side effects requires user confirmation.

**Step 1: Inspect tool registry.**

List the tools available from the connected server. Identify:

- Tools with output-controlling parameters (`limit`, `maxResults`, `fields`, `per_page`, `pageSize`, query filter parameters like `q`, `query`, `filter`, `search`)
- Tools with MCP annotations (`readOnlyHint`, `destructiveHint`, `idempotentHint`)
- Tools that are likely list/search operations (name contains "list", "search", "get_all", "find")

Report findings:

- "These tools have parameter knobs you can document: [list with parameter names and types]"
- "These tools return fixed payloads -- no parameter-based optimization available"
- "These tools have `readOnlyHint: true` -- safe for test calls"
- "These tools lack safety annotations -- test calls may have side effects"

**Step 2: Optional test calls.**

For tools the user wants to explore further, make a minimal test call to observe response size and structure. Confirmation required before every test call.

Full disclosure before any test call against a tool WITHOUT `readOnlyHint: true`:

> MCP servers are opaque by design. Tool annotations (`readOnlyHint`, `destructiveHint`) are hints, not guarantees -- servers may not include them, and those that do may not be accurate. Test calls against tools without `readOnlyHint: true` may have side effects (creating records, sending messages, modifying state). Proceed only if you understand and accept this risk for the specific server and tool.

Lighter disclosure for tools WITH `readOnlyHint: true`:

> This tool declares `readOnlyHint: true`. This is an annotation from the MCP server, not a guarantee. Proceeding with a minimal test call.

**Step 3: Generate draft entries.**

Based on tool registry inspection and any test call results, generate draft MCP Tool Notes entries for the server. Flag these as drafts that need human review -- unlike known templates, these are based on tool definitions and observation, not tested patterns.

### 4. Generate or Update MCP Tool Notes

After detection and matching:

- If AGENTS.md has no MCP Tool Notes section: generate the full section with entries for all detected known servers, plus placeholders for unknown servers
- If MCP Tool Notes exists but is missing entries for detected servers: show only the missing entries with instructions on where to add them
- If MCP Tool Notes exists and covers all detected servers: report that no changes are needed

Generated content follows the template format from the `single-file-examples/` -- bold server name, dash, concise guidance in brackets for templates or filled in for known servers.

## Report Format

Present findings in three sections:

**1. Detection Summary**

> Scanned [N] platform config locations. Found MCP servers in [platforms]:
>
> - [platform]: [server list]
> - [platform]: [server list]

**2. Template Coverage**

> [N] servers match known templates: [list]
> [N] servers have no known template: [list]
> [N] servers already documented in MCP Tool Notes: [list]

**3. Recommendations**

For known servers: the ready-to-use MCP Tool Notes content.
For unknown servers: findings from tool registry inspection, or a prompt to run interactive discovery.

## When to Use

- After installing a new MCP server to get optimization guidance
- When running `/context-setup:context-scaffold` flags MCP servers without documentation
- When `/context-setup:context-usage` reports high token consumption from MCP tool calls
- When you want to audit which MCP servers are configured across platforms
- After connecting to a new or unfamiliar MCP server

## Example Output

> **MCP Server Detection**
>
> Scanned 5 platform config locations. Found MCP servers in 2 platforms:
>
> - Claude Code (`.mcp.json`): atlassian, github-mcp-server, supabase
> - VS Code (`.vscode/mcp.json`): github-mcp-server
>
> **Template Coverage**
>
> 3 servers match known templates: Atlassian, GitHub, Supabase
> 0 servers have no known template
> 1 server already documented in MCP Tool Notes: GitHub
>
> **Missing MCP Tool Notes entries (2):**
>
> Add these to your MCP Tool Notes section in AGENTS.md:
>
> - **Atlassian (Jira)** -- use `searchJiraIssuesUsingJql` with specific JQL and `maxResults: 3-5` for triage; `getJiraIssue` returns all fields by default -- prefer it only for single-ticket lookups
> - **Atlassian (Confluence)** -- use `searchConfluenceUsingCql` with narrow CQL and `limit: 5` over `getPagesInConfluenceSpace`; `getConfluencePage` is fine for known page IDs
> - **Supabase** -- query with `.select('col1, col2')` to limit columns; avoid `select('*')` on wide tables; use `.limit()` and `.range()` for pagination

## How This Differs from Other Skills

- **context-mcp** (this skill) owns the entire MCP optimization surface -- detection, templates, interactive discovery, and documentation generation
- **context-audit** (this plugin) checks structural completeness, format conventions, and CLI command optimization. It does not check MCP configs or MCP Tool Notes. If it detects MCP servers configured but no MCP Tool Notes section, it adds a finding: "MCP servers detected but no MCP Tool Notes found -- run `/context-setup:context-mcp` for recommendations"
- **context-usage** (this plugin) observes session tool calls for token consumption. Future extension will include MCP tool calls alongside Bash calls
- **context-scaffold** (this plugin) generates context files from project analysis. Future extension will detect MCP configs during scaffolding and pre-populate MCP Tool Notes for known servers

`/context-setup:context-audit` stays focused on structural completeness and CLI optimization. `/context-setup:context-mcp` owns MCP. The two skills are peers, not parent-child.

## Notes

The known templates are based on tested patterns for seven MCP server families: Atlassian, Gmail, Google Calendar, Web, GitHub, Supabase, and Vercel. These cover the most common MCP integrations. For servers not in this list, interactive discovery inspects the tool registry and optionally makes test calls to build optimization guidance.

Interactive discovery is inherently less reliable than known templates. Tool registries describe parameters but not payload sizes. A tool with a `limit` parameter might still return large individual records. Test calls provide ground truth but carry risk for non-read-only tools. The full disclosure language exists because MCP annotations are untrusted hints -- servers define them, but the spec explicitly states clients must not rely on them for security decisions.

TOML parsing for Codex configs uses regex-based extraction rather than a full parser. This handles standard MCP config patterns but may miss edge cases with complex TOML structures. If TOML parsing produces unexpected results, the output notes this and suggests manual review.

The MCP Tool Notes section generated by this skill uses the same format as the template sections in `single-file-examples/`. This ensures consistency whether the section was hand-written from a template or generated by this skill. The generated content goes in your AGENTS.md, which is platform-agnostic -- every AI tool that reads AGENTS.md benefits, not just the platform where the MCP server runs.
