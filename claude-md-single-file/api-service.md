# CLAUDE.md (API Service)

A single-file context for a backend API. API services have specific context needs: endpoint conventions, auth middleware, data validation patterns, and integration points.

---

````markdown
# CLAUDE.md

## Service Overview

[What this API does, what consumes it (frontend apps, mobile clients, third-party integrations), what external services it depends on. Scale context: request volume, data volume, latency requirements.]

## Tech Stack

- **Runtime:** [Language and version]
- **Framework:** [Web framework]
- **Database:** [Primary datastore]
- **Cache:** [If applicable]
- **Queue/Jobs:** [Background processing approach]
- **Auth:** [Token validation, API keys, OAuth -- how callers authenticate]

## Project Structure

```text
service/
├── src/
│   ├── routes/           # HTTP route handlers
│   ├── middleware/        # Auth, logging, rate limiting
│   ├── services/         # Business logic
│   ├── repositories/     # Data access layer
│   ├── models/           # Data models / schemas
│   ├── jobs/             # Background job definitions
│   └── utils/            # Shared utilities
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── migrations/
└── scripts/              # Operational scripts
```

## Commands

```bash
[dev server]
[test -- unit, integration, or both]
[migration commands]
[linting]
[build / compile if applicable]
```

## API Design Conventions

### URL Patterns

- [Versioning approach: /api/v1/, header-based, etc.]
- [Resource naming: plural nouns, kebab-case]
- [Nested resources: /parents/{id}/children or flat]

### Request/Response Format

- [Content type -- JSON, accept headers]
- [Response envelope -- { data, meta, errors } or flat]
- [Pagination -- cursor vs. offset, parameter names]
- [Filtering/sorting conventions]

### Error Handling

- [Standard error response shape]
- [Error code conventions -- HTTP status mapping, internal codes]
- [Validation error format -- field-level errors, how they're structured]

### Auth

- [How callers authenticate -- Bearer tokens, API keys, both]
- [Where auth is enforced -- middleware, per-route, decorator]
- [Scopes/permissions model if applicable]
- [Rate limiting -- per-key, per-endpoint, global]

## Data Layer

### Models

[Key models/tables and their relationships. Focus on the ones that matter for understanding data flow, not every junction table.]

### Migration Rules

- [Migration tool and workflow]
- [Rules about destructive migrations -- never drop columns without deprecation period, etc.]
- [Testing requirements for migrations]

### Query Patterns

- [ORM vs. raw SQL conventions]
- [Where queries live -- repository layer, not in route handlers]
- [N+1 prevention approach]
- [Transaction boundaries]

## Integration Points

[External services this API calls or depends on. Include expected failure modes.]

| Service | Purpose | Failure Mode |
| ------- | ------- | ------------ |
| [service] | [what it does] | [what happens when it's down] |
| [service] | [what it does] | [what happens when it's down] |

## Environment and Config

- [How config is loaded -- env vars, config files, secrets manager]
- [Required env vars and what they control]
- [Environment differences -- dev vs. staging vs. prod]

## Do NOT

- [Endpoint creation rules -- always add schema validation, always document]
- [Database rules -- no raw SQL in handlers, no schema changes without migrations]
- [Auth rules -- never skip middleware, never trust client-side tokens alone]
- [Deployment rules -- no direct pushes, feature flags for new endpoints]
- [Integration rules -- never call external services synchronously in hot paths]
````

---

## Notes

**API services need more context about conventions than application code.** An AI generating a new endpoint needs to know your URL patterns, response format, error handling approach, and auth model. Without this, every generated endpoint will be slightly different from the rest.

**Integration points and failure modes are often missing from context files.** If your API depends on a payment processor that occasionally times out, the AI needs to know that. Otherwise it'll generate code that treats the happy path as the only path.

**The data layer section prevents the most common API bugs.** Wrong query patterns (N+1), missing auth checks on new endpoints, and destructive migrations are all preventable with explicit context.
