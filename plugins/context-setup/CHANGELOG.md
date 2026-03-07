# Changelog

## 1.1.0

- Add `/context-setup:context-mcp` skill -- detects connected MCP servers, matches against known optimization templates (Atlassian, Gmail, Google Calendar, Web, GitHub, Supabase, Vercel), generates MCP Tool Notes for AGENTS.md, and interactively discovers optimization opportunities for unknown servers
- Add `/context-setup:context-usage` skill -- reports on token consumption from Bash tool calls in the current session, flags verbose and repeated commands, estimates recoverable tokens
- Add MCP Tool Notes cross-reference to `/context-setup:context-audit` (category 6) -- detects MCP configs without corresponding MCP Tool Notes section
- Fix skill invocation names across all files -- use full namespaced form (`/context-setup:context-scaffold` not `/context-setup:scaffold`) for consistency and to avoid ambiguity with other plugins
- Document short-form invocation behavior in README (`/context-scaffold` works when no namespace conflict exists)

## 1.0.0

- Initial release with 4 skills: context-scaffold, context-audit, context-align, context-upgrade
