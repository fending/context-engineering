# Business Requirements

This file captures product context that affects implementation decisions. The goal is to bridge the gap between what the product team intends and what the engineering team builds -- the "PRD wall" problem described in the companion article.

## What Belongs Here

- Product vision and current priorities
- User personas and what they need
- Success metrics and how features are measured
- Business rules that constrain implementation
- Current feature focus areas

This is not a full PRD or backlog. It's the persistent product context that an AI assistant (or a new developer) needs to make good implementation decisions.

## Example Content

---

### Product Vision

[2-3 sentences. What the product does, who it's for, what differentiates it. This is the lens through which feature decisions should be evaluated.]

### Current Priorities

[What the team is focused on right now. Update this when priorities shift.]

1. [Current priority -- what and why]
2. [Current priority -- what and why]
3. [Current priority -- what and why]

### User Personas

[The primary users of the system and what they care about. Keep it practical -- this informs feature decisions, not marketing.]

**[Persona 1 -- Role/Title]**

- Needs: [what they're trying to accomplish]
- Pain points: [what frustrates them today]
- Context: [how they use the product -- frequency, environment, expertise level]

**[Persona 2 -- Role/Title]**

- Needs: [what they're trying to accomplish]
- Pain points: [what frustrates them today]
- Context: [how they use the product -- frequency, environment, expertise level]

### Business Rules

[Rules that are non-negotiable from a business perspective and must be reflected in code.]

- [e.g., Free tier limited to X records / Y API calls]
- [e.g., Enterprise customers get isolated data processing]
- [e.g., Data retention: 90 days for free tier, unlimited for paid]
- [e.g., All exports must include audit trail]

### Success Metrics

[How the team measures whether features are working. AI assistants can validate implementations against these when they're concrete enough.]

| Feature Area | Metric | Target |
| ------------ | ------ | ------ |
| [area] | [what's measured] | [target value] |
| [area] | [what's measured] | [target value] |

---

## Why This File Exists Separately

Business requirements change at the cadence of product decisions -- sprint boundaries, quarterly planning, pivots. They're owned by product stakeholders, not engineers. Keeping them in a separate file lets product people update priorities without editing a file full of code standards and API conventions.

This is the file that breaks down the PRD wall. Instead of product context living in a Confluence doc that engineers never read, it's in the project root, version-controlled, and consumed by both humans and AI. When an AI generates a feature, it can check this file to understand whether the implementation serves the actual user need.
