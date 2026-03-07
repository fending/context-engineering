---
name: context-usage
description: Reports on token consumption from Bash tool calls in the current session. Estimates tokens used, tokens recoverable, and points to context-audit for specific optimization recommendations.
---

# Context Usage

Quick diagnostic of how tool calls in the current session are consuming context. Run mid-session when responses feel slow or you suspect token waste.

## What This Skill Does

Review visible conversation history and report on Bash tool calls from the current session. This is a lightweight observation -- no file changes, no recommendations, just a summary of what happened and where context went. Focuses on Bash calls because they produce the most variable output; Read/Grep/Glob calls are generally predictable in size.

### 1. Session Tool Call Summary

Count visible Bash tool calls and estimate token consumption:

- Total Bash calls in visible history
- Estimated total tokens consumed by Bash output (approximate at ~3 tokens per line of output)
- Commands that produced more than ~50 lines of output (flag as verbose)
- Commands that were run more than once with the same or similar invocation (flag as repeated)
- Commands that already use concise flags or pipes (acknowledge as concise)

### 2. Verbose Command Report

For each command that produced notably verbose output, report:

- The command that was run
- Approximate output size (line count from what's visible)
- Whether a concise variant is known (based on common tools: vitest, pytest, eslint, cargo, ruff, tsc, docker compose)

Do not suggest the concise variant here -- just flag the command and note that a variant may exist. The goal is awareness, not prescription.

### 3. Repetition Report

For commands run more than once with similar invocations:

- The command pattern
- How many times it appeared
- Whether the output was similarly verbose each time

Repeated verbose commands are the highest-value optimization target -- they compound token cost.

### 4. Estimated Savings

For verbose commands where a concise variant is known, estimate the token reduction:

- Current: approximate tokens consumed by the verbose output
- Projected: approximate tokens if the concise variant had been used (e.g., `tail -5` produces ~5 lines vs. 180)
- Delta: estimated tokens recoverable

Use ~3 tokens per line as the rough conversion. This is an approximation -- actual token counts depend on line length, formatting, and encoding. The estimate is directionally useful for deciding whether optimization is worth pursuing.

This is distinct from the built-in `/usage` command, which shows your account quota consumption. `/context-setup:context-usage` estimates how much of the context *window* is consumed by tool output within the current session.

### 5. Handoff

If any verbose or repeated commands were identified, close with:

> Optimization opportunities found. Run `/context-setup:context-audit` for specific recommendations on concise command variants for your project's toolchain.

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
> 14 Bash calls in visible history. Estimated ~1,800 tokens consumed by Bash output.
>
> **Verbose commands (4):**
>
> - `npm test` -- ~180 lines (~540 tokens). Concise variant may exist (vitest detected).
> - `npm test` -- ~180 lines (~540 tokens). Repeat of above.
> - `npx eslint .` -- ~65 lines (~195 tokens). Concise variant may exist (eslint detected).
> - `bundle exec rspec` -- ~120 lines (~360 tokens). No known concise variant.
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
> **Estimated savings:** ~1,260 tokens recoverable if concise variants were used for `npm test` (2x ~540 -> 2x ~15) and `eslint .` (~195 -> ~90). Run `/context-setup:context-audit` for specific recommendations.

## How This Differs from Context Audit

`/context-setup:context-usage` observes the current session and reports what it sees. It does not read project files, check dependencies, or generate recommendations. It answers: "what happened in this session?"

`/context-setup:context-audit` (category 6) reads your project's dependency manifest, checks for missing Command Output Notes sections, and generates specific concise command recommendations. It answers: "what should you change?"

Use `/context-setup:context-usage` as the quick check. If it finds something, `/context-setup:context-audit` tells you what to do about it.

## Notes

This skill only works with conversation history that hasn't been compressed. After compression, prior Bash calls and their outputs are summarized or removed, making accurate observation impossible. The skill detects this and tells you to run it earlier next time.

Token estimates use ~3 tokens per line as a rough conversion. Actual token counts depend on line length, formatting, and encoding -- a line of JSON is more tokens than a line of plain text. The estimates are directionally useful ("that command cost ~540 tokens and could cost ~15") even if not exact. This is distinct from the built-in `/usage` command, which shows account quota consumption. `/context-setup:context-usage` estimates context *window* utilization from tool output within the current session.
