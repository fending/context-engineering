# System Overview

This file describes the system at a level that lets someone (human or AI) understand what they're working with before touching code.

## What Belongs Here

- What the system does and who it serves
- High-level architecture (services, data flow, major components)
- How the pieces fit together
- External dependencies and integration points
- Scale context (users, request volume, data volume)

## Example Content

---

### Purpose

[One paragraph describing what this system does and why it exists. Include the user base and the core value proposition. This isn't marketing copy -- it's the information someone needs to understand the domain before writing code.]

### Architecture

[Describe the major components and how they interact. A text-based diagram is fine:]

```text
[Client] --> [API Gateway] --> [Service Layer] --> [Database]
                                    |
                                    +--> [Cache]
                                    +--> [Job Queue] --> [Workers]
                                    +--> [External APIs]
```

### Components

| Component | Technology | Purpose |
| --------- | ---------- | ------- |
| Frontend | [framework] | [what it renders, who uses it] |
| API | [framework] | [what it exposes, who consumes it] |
| Database | [engine] | [primary datastore for what] |
| Cache | [engine] | [what's cached and why] |
| Workers | [framework] | [what background work happens] |

### External Dependencies

| Service | Purpose | Failure Impact |
| ------- | ------- | -------------- |
| [Auth provider] | Authentication, session management | Users can't log in |
| [Payment processor] | Billing, subscriptions | New signups blocked, existing users unaffected |
| [Email service] | Transactional email | Notifications delayed |

### Scale Context

[Rough numbers that affect design decisions: daily active users, requests per second, database size, job queue depth. This helps an AI understand whether a solution needs to handle 100 users or 100,000.]

---

## Why This File Exists Separately

System overview changes infrequently -- when you add a new service, swap a major dependency, or change the architecture. It doesn't need to be in the same file as your coding standards (which change monthly) or your API conventions (which change with each new endpoint pattern).

An AI reading this file gets the mental model of the system. Combined with `architecture-decisions.md`, it understands not just what the system looks like but why it looks that way.
