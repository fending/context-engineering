# Context Directory Approach

The context directory pattern separates concerns into individual files that can evolve independently. Each document serves a specific audience and changes at its own rate.

## When to Use This

- Your single context file has grown past ~150 lines and is hard to scan
- Different sections change at different rates (architecture: rarely; style guide: often)
- Multiple people contribute to different aspects of the context
- You need to serve both AI assistants and human stakeholders with different levels of detail
- You want to version-track changes to individual concerns

## Structure

```text
context/
├── system-overview.md            # What the system is, high-level architecture
├── architecture-decisions.md     # ADRs and current state of key decisions
├── technical-requirements.md     # Constraints, performance targets, compliance
├── api-documentation.md          # Endpoint patterns, auth, conventions
├── business-requirements.md      # Product context, success criteria, user needs
└── working-style-guide.md        # Code standards, review process, tooling
```

## How AI Assistants Consume This

Most AI coding assistants (Claude Code, Cursor, etc.) will read the project's root AGENTS.md (or CLAUDE.md for Claude Code). That file should reference the context directory:

```markdown
# AGENTS.md

## Context

Detailed project context is in the `context/` directory. Read the relevant files before making changes:

- System architecture: `context/system-overview.md`
- Architecture decisions: `context/architecture-decisions.md`
- Code standards: `context/working-style-guide.md`
- API conventions: `context/api-documentation.md`
```

This gives the AI a map without front-loading everything into a single file.

## Maintenance

Review each file on a cadence that matches its rate of change:

| File | Review Cadence | Typical Trigger |
| ---- | -------------- | --------------- |
| system-overview.md | Quarterly | Major architecture change, new service |
| architecture-decisions.md | When decisions are made | New ADR, reversed decision |
| technical-requirements.md | Quarterly | New compliance requirement, perf issue |
| api-documentation.md | With API changes | New endpoint pattern, auth change |
| business-requirements.md | Sprint/cycle boundary | New feature area, pivot |
| working-style-guide.md | As team norms evolve | New tool adoption, style consensus |

The files in this directory are working examples showing the kind of content that belongs in each.
