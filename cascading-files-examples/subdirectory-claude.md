# Subdirectory AGENTS.md Example

This file lives inside a specific directory (e.g., `src/api/AGENTS.md`) and provides specialized context for that area of the codebase.

---

````markdown
# AGENTS.md (API Layer)

## Purpose

This directory contains the API route handlers, middleware, and request/response logic. Business logic lives in `../services/` -- handlers here should be thin.

## Conventions

### Handler Structure

Every route handler follows this pattern:

1. Validate input (via schema)
2. Call service layer
3. Format response
4. Handle errors

```python
@router.post("/resources")
async def create_resource(
    request: CreateResourceRequest,
    org_id: str = Depends(get_org_id),
    service: ResourceService = Depends(),
):
    result = await service.create(org_id, request)
    return {"data": result}
```

### Auth

- All endpoints require authentication unless explicitly listed in `PUBLIC_ENDPOINTS`
- Use `@require_role()` decorator for role-based access
- Always filter by `org_id` -- never return cross-tenant data

### Error Handling

- Let service-layer exceptions propagate -- the global error handler maps them to HTTP responses
- Do not catch generic `Exception` in handlers
- Validation errors are handled by the schema layer automatically

### Testing

- Handler tests use the test client, not direct function calls
- Each handler test must verify: happy path, auth failure, validation failure
- Use factory fixtures for test data, not hardcoded values

## Do NOT

- Put business logic in handlers -- it belongs in the service layer
- Use raw SQL -- go through the repository layer
- Return data without filtering by org_id
- Create endpoints without corresponding request/response schemas
````

---

## Notes

**Only create subdirectory context when the area has genuinely different rules.** If `src/api/` follows the same conventions as the rest of the project, a subdirectory AGENTS.md adds noise without value.

**Code examples are high-value here.** Showing the expected handler pattern (with a real code snippet) is more effective than describing it in prose. The AI will pattern-match on the example.

**These files should be small.** 30-50 lines is typical. If a subdirectory AGENTS.md is approaching the size of the project-level file, something is wrong -- either the project file is too sparse or the subdirectory file is duplicating content.
