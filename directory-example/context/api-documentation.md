# API Documentation

This file defines the conventions and patterns for the project's API layer. Its primary consumers are AI assistants generating new endpoints and developers reviewing generated code.

## What Belongs Here

- URL patterns and versioning
- Request/response format conventions
- Authentication and authorization patterns
- Error handling standards
- Pagination, filtering, sorting approaches
- Rate limiting

This is not a full API reference (that's auto-generated from code or OpenAPI specs). This is the *conventions* that make the API consistent.

## Example Content

---

### URL Conventions

```text
Base: /api/v1

Resources:
  GET    /api/v1/{resources}          # List (paginated)
  POST   /api/v1/{resources}          # Create
  GET    /api/v1/{resources}/{id}     # Get by ID
  PUT    /api/v1/{resources}/{id}     # Full update
  PATCH  /api/v1/{resources}/{id}     # Partial update
  DELETE /api/v1/{resources}/{id}     # Delete

Nested:
  GET    /api/v1/{parents}/{id}/{children}    # List children
```

- Resource names are plural, kebab-case
- IDs are UUIDs
- No verbs in URLs -- use HTTP methods

### Response Format

**Success:**

```json
{
  "data": { },
  "meta": {
    "page": 1,
    "per_page": 25,
    "total": 142
  }
}
```

**Error:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ]
  }
}
```

### HTTP Status Codes

| Code | Usage |
| ---- | ----- |
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Validation error, malformed request |
| 401 | Missing or invalid authentication |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state mismatch) |
| 429 | Rate limited |
| 500 | Unhandled server error |

### Authentication

[How callers authenticate and how new endpoints should enforce it.]

- [Token type and header format]
- [Middleware or decorator used for auth enforcement]
- [Public vs. authenticated endpoint conventions]

### Pagination

- Default: `?page=1&per_page=25`
- Maximum per_page: 100
- Response includes `meta.total` for total count
- [Or: cursor-based pagination with `?cursor=` and `meta.next_cursor`]

### Rate Limiting

- [Limits per endpoint tier or global]
- [How limits are communicated -- headers, error response]
- [What happens when rate limited]

---

## Why This File Exists Separately

API conventions change when you add new endpoint patterns, update your auth mechanism, or standardize a new response format. These changes don't overlap with architecture decisions (which are about system structure) or code standards (which are about how individual files are written).

An AI generating a new endpoint needs this file. It probably doesn't need the business requirements or the system overview at the same time. Separate files mean the AI loads only the context it needs.
