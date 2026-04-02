---
name: context-usage
description: Reports on token consumption from Bash and MCP tool calls in the current session. Estimates tokens used, tokens recoverable, and points to context-audit and context-mcp for specific optimization recommendations.
---

**DEPRECATION NOTICE:** You are running context-setup from `fending/context-engineering`, which is no longer maintained. The active version is at `ordovera/ordovera-plugins`. To migrate, run:

1. `/plugin marketplace add ordovera/ordovera-plugins`
2. `/plugin install context-setup@ordovera-plugins`

Then remove the old marketplace: `/plugin marketplace remove context-engineering`

Print this notice to the user before proceeding with the skill.

# Context Usage

Quick diagnostic of how tool calls in the current session are consuming context. Run mid-session when responses feel slow or you suspect token waste.

## What This Skill Does

Review visible conversation history and report on Bash and MCP tool calls from the current session. This is a lightweight observation -- no file changes, no recommendations, just a summary of what happened and where context went. Focuses on Bash and MCP calls because they produce the most variable output; Read/Grep/Glob calls are generally predictable in size.

### 1. Session Tool Call Summary

Count visible Bash and MCP tool calls and estimate token consumption:

- Total Bash calls in visible history
- Total MCP tool calls in visible history (tools prefixed with `mcp__`)
- Estimated total tokens consumed by all tool output (approximate at ~3 tokens per line of output)
- Commands or tool calls that produced more than ~50 lines of output (flag as verbose)
- Commands or tool calls that were run more than once with the same or similar invocation (flag as repeated)
- Commands that already use concise flags or pipes (acknowledge as concise)

### 2. Verbose Output Report

For each Bash command or MCP tool call that produced notably verbose output, report:

- The command or tool call (including key parameters)
- Approximate output size (line count from what's visible)
- Whether a concise variant is known:
  - For Bash: based on common tools (vitest, pytest, eslint, cargo, ruff, tsc, docker compose)
  - For MCP: whether the call used default parameters when known optimization knobs exist (e.g., `gmail_search_messages` without `maxResults`, `list_deployments` without `since`/`until`, `searchJiraIssuesUsingJql` without `fields`)

Do not suggest the concise variant here -- just flag the call and note that a variant may exist. The goal is awareness, not prescription.

### 3. Repetition Report

For Bash commands or MCP tool calls run more than once with similar invocations:

- The command or tool call pattern
- How many times it appeared
- Whether the output was similarly verbose each time

Repeated verbose calls are the highest-value optimization target -- they compound token cost.

### 4. Estimated Savings

For verbose commands where a concise variant is known, estimate the token reduction:

- Current: approximate tokens consumed by the verbose output
- Projected: approximate tokens if the concise variant had been used (e.g., `tail -5` produces ~5 lines vs. 180)
- Delta: estimated tokens recoverable

Use ~3 tokens per line as the rough conversion. This is an approximation -- actual token counts depend on line length, formatting, and encoding. The estimate is directionally useful for deciding whether optimization is worth pursuing.

This is distinct from the built-in `/usage` command, which shows your account quota consumption. `/context-setup:context-usage` estimates how much of the context *window* is consumed by tool output within the current session.

### 5. Handoff

If any verbose or repeated Bash commands were identified, close with:

> Optimization opportunities found. Run `/context-setup:context-audit` for specific recommendations on concise command variants for your project's toolchain.

If any verbose or default-parameter MCP tool calls were identified, add:

> MCP optimization opportunities found. Run `/context-setup:context-mcp` for recommendations on parameter knobs that reduce MCP tool output.

If nothing notable was found:

> No optimization opportunities observed in this session. All commands produced reasonable output.

If session history appears compressed (zero or very few Bash calls visible despite an active session, or conversation history starts abruptly without earlier context):

> Session history unavailable (likely compressed). Run `/context-setup:context-usage` earlier in a session -- before compression -- to catch optimization opportunities. For best results, run when responses start feeling slow or after a burst of command activity.

## When to Use

- When responses feel slower than usual mid-session
- After running a batch of test/lint/build commands
- Before a long debugging session to establish a baseline
- When you're curious where context is going

This skill is fast and read-only. It changes nothing, installs nothing, and produces a short summary. Use it as a triage step before deciding whether a full `/context-setup:context-audit` is worth running.

## Example Output

> **Context Usage -- Session Summary**
>
> 14 Bash calls and 3 MCP tool calls in visible history. Estimated ~2,400 tokens consumed by tool output.
>
> **Verbose commands (4):**
>
> - `npm test` -- ~180 lines (~540 tokens). Concise variant may exist (vitest detected).
> - `npm test` -- ~180 lines (~540 tokens). Repeat of above.
> - `npx eslint .` -- ~65 lines (~195 tokens). Concise variant may exist (eslint detected).
> - `bundle exec rspec` -- ~120 lines (~360 tokens). No known concise variant.
>
> **Verbose MCP calls (1):**
>
> - `mcp__gmail__gmail_search_messages` -- ~200 lines (~600 tokens). Called with default maxResults (20). Optimization knob available: `maxResults: 3-5`.
>
> **Repeated commands (1 pattern):**
>
> - `npm test` run 2 times with similar verbose output.
>
> **Already concise (2):**
>
> - `npm run build 2>&1 | grep Error` -- already piped.
> - `git diff --stat` -- short by nature.
>
> **Estimated savings:** ~1,860 tokens recoverable. Bash: `npm test` (2x ~540 -> 2x ~15) and `eslint .` (~195 -> ~90). MCP: `gmail_search_messages` (~600 -> ~150 with maxResults: 5). Run `/context-setup:context-audit` for CLI recommendations. Run `/context-setup:context-mcp` for MCP recommendations.

## How This Differs from Context Audit

`/context-setup:context-usage` observes the current session and reports what it sees. It does not read project files, check dependencies, or generate recommendations. It answers: "what happened in this session?"

`/context-setup:context-audit` (category 7) reads your project's dependency manifest, checks for missing Command Output Notes sections, and generates specific concise command recommendations. It answers: "what should you change about CLI commands?"

`/context-setup:context-mcp` detects MCP configs, matches against known templates, and generates MCP Tool Notes. It answers: "what should you change about MCP tool calls?"

Use `/context-setup:context-usage` as the quick check. If it finds Bash issues, `/context-setup:context-audit` tells you what to do. If it finds MCP issues, `/context-setup:context-mcp` tells you what to do.

## Notes

This skill only works with conversation history that hasn't been compressed. After compression, prior tool calls and their outputs are summarized or removed, making accurate observation impossible. The skill detects this and tells you to run it earlier next time.

Token estimates use ~3 tokens per line as a rough conversion. Actual token counts depend on line length, formatting, and encoding -- a line of JSON is more tokens than a line of plain text. The estimates are directionally useful ("that command cost ~540 tokens and could cost ~15") even if not exact. This is distinct from the built-in `/usage` command, which shows account quota consumption. `/context-setup:context-usage` estimates context *window* utilization from tool output within the current session.
