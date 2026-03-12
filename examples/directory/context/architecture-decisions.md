# Architecture Decisions

This file records significant technical decisions and their current status. It serves two purposes: helping AI assistants understand *why* the system is shaped this way, and giving human developers a decision log they can reference.

## What Belongs Here

- Decisions that constrain how code is written (ORM choice, auth model, API versioning)
- Trade-offs that were consciously made (and might be revisited)
- Decisions that are final vs. open for reconsideration
- Context that would otherwise live only in someone's head

## Format

Each decision follows a lightweight ADR (Architecture Decision Record) format. Keep them short -- the goal is to capture the decision and its implications, not to write a whitepaper.

## Example Content

---

### ADR-001: Multi-Tenant Data Isolation

**Status:** Active
**Date:** [date]

**Decision:** Tenant isolation via row-level filtering on `org_id` column, enforced at the repository layer.

**Context:** Needed multi-tenancy. Options were: separate databases per tenant, separate schemas, or row-level filtering. Separate databases provide the strongest isolation but increase operational complexity. Row-level filtering is simpler and sufficient for our threat model.

**Implications:**

- Every table with tenant-scoped data must include `org_id`
- All repository methods must accept and filter by `org_id`
- New queries must be reviewed for missing tenant filters
- Integration tests must verify cross-tenant data isolation

---

### ADR-002: Server Components as Default

**Status:** Active
**Date:** [date]

**Decision:** React Server Components are the default. Client Components (`"use client"`) require justification.

**Context:** Server Components reduce client bundle size and simplify data fetching. Client Components are needed for interactivity (forms, modals, real-time updates) but not for data display.

**Implications:**

- Data fetching happens in Server Components; client components receive data as props
- Interactive features use Client Components with clear boundaries
- `"use client"` directive must be as deep in the component tree as possible
- Client-side state management (SWR, React Query) only for truly dynamic data

---

### ADR-003: [Your Decision Title]

**Status:** Active | Superseded | Deprecated
**Date:** [date]

**Decision:** [What you decided]

**Context:** [Why this decision was needed, what alternatives were considered]

**Implications:** [What this means for how code is written going forward]

---

## Why This File Exists Separately

Architecture decisions are the most stable context in a project. They change when you make major technical choices -- every few months at most. Mixing them into a single file with code standards and API conventions (which change more frequently) creates unnecessary noise in diffs and makes it harder to review what actually changed.

This file also serves as a decision log. When someone asks "why do we use X instead of Y," the answer is here, not buried in a Slack thread from eight months ago.
