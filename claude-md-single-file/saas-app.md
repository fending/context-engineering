# CLAUDE.md (SaaS Application)

A full single-file context for a SaaS product. Placeholder sections use `[brackets]` for content you'd replace with your own specifics.

---

````markdown
# CLAUDE.md

## Project Overview

[What the product does, who it serves, rough scale -- ARR, user count, team size. One paragraph. This orients every AI interaction toward the right level of complexity and caution.]

## Tech Stack

- **Frontend:** [Framework, language, CSS approach]
- **Backend:** [Framework, language, ORM]
- **Database:** [Engine, hosting provider]
- **Auth:** [Provider, multi-tenant approach if applicable]
- **Infra:** [Hosting for each layer, CI/CD]
- **Testing:** [Unit, integration, e2e tools]

## Project Structure

[Your actual directory tree. This is one of the highest-value sections -- it prevents the AI from guessing where files live or creating new files in wrong locations.]

```text
project/
├── apps/
│   ├── web/              # Frontend application
│   │   ├── app/          # Pages and layouts
│   │   ├── components/   # Shared UI components
│   │   ├── lib/          # Client utilities, hooks
│   │   └── tests/
│   └── api/              # Backend service
│       ├── routers/      # Route handlers
│       ├── models/       # Data models
│       ├── services/     # Business logic
│       └── tests/
├── packages/
│   └── shared/           # Cross-app shared code
└── e2e/                  # End-to-end tests
```

## Commands

```bash
# Frontend
[dev server command]
[test command]
[build command]
[lint command]

# Backend
[dev server command]
[test command]
[migration commands]
```

## Code Standards

### Frontend

- [Indentation, import style, module system]
- [Component patterns -- functional only, server-first, etc.]
- [Test colocation rules]
- [CSS/styling conventions]
- [Error handling patterns]

### Backend

- [Indentation, type annotation expectations]
- [Layering rules -- what goes where]
- [Query patterns -- repository layer, no raw SQL in handlers, etc.]
- [Async conventions]

### Both

- [Commit message format]
- [PR/review requirements]
- [Test requirements for new code]

## Architecture Decisions

[State what's true, not why you chose it. "Multi-tenant via org-scoped auth" tells the AI what to enforce. Save the reasoning for an ADR document if you need it.]

- **[Decision]:** [What it means in practice]
- **[Decision]:** [What it means in practice]
- **[Decision]:** [What it means in practice]
- **[Decision]:** [What it means in practice]

## Auth and Permissions

[How authentication works, what roles exist, where permissions are enforced. This section prevents the most dangerous class of AI-generated bugs -- data leaking across tenants or unauthorized access.]

- [Auth provider and mechanism]
- [Roles and what each can do]
- [Where enforcement happens -- middleware, decorators, etc.]
- [Client-side vs. server-side validation rules]

## Data Model (Key Tables)

[You don't need every table. List the ones that matter for understanding relationships and data access patterns.]

| Table | Purpose | Key Relationships |
| ----- | ------- | ----------------- |
| [table] | [purpose] | [relationships] |
| [table] | [purpose] | [relationships] |
| [table] | [purpose] | [relationships] |

## API Conventions

- [URL patterns and versioning]
- [Response envelope format]
- [Error response format]
- [Pagination approach]
- [Rate limiting]

## Do NOT

- [Specific, experience-driven boundaries]
- [Things that broke when someone (or an AI) did them wrong]
- [Fragile areas that need manual review]
- [Environment/config changes that have downstream effects]
- [Deployment or branch rules]
````

---

## Notes

**This is ~100-120 lines filled in.** That's the sweet spot for a single file. Beyond ~150 lines, consider a context directory for the sections that change independently.

**The "Do NOT" section is specific and experience-driven.** "Don't modify webhook handlers without reviewing the event flow" is better than "be careful with webhooks." Every item in this section should trace back to something that actually went wrong.

**Architecture decisions are stated, not argued.** The AI needs to know *what's true*, not why you considered alternatives. If the reasoning matters for future decisions, put it in a dedicated architecture decisions document.

**Auth and data model sections prevent the worst bugs.** An AI that doesn't understand your tenancy model will generate queries that leak data across organizations. An AI that doesn't understand your permission model will skip authorization checks. These sections are load-bearing.
