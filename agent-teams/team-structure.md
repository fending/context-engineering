# Team Structure Template

Template for an AGENT_TEAMS.md file that lives in your project's `context/` directory. Defines team composition, ownership boundaries, integration contracts, and the prompt to start the build.

Copy the fenced content below and replace the `[bracketed]` values.

````markdown
# Agent Teams -- Development Plan

How we use Claude Code Agent Teams to build [project name].

---

## Development Phases

### Phase 0: Scaffolding (Single Session)

Not a team -- sequential prerequisite work in one focused session.

- [Initialize project with framework, language, styling]
- [Configure linting, formatting, path aliases]
- [Set up database client and auth]
- [Run initial database migration]
- [Configure environment variables]
- [Create base layout and theme]
- [Deploy skeleton to hosting platform]

**Output:** A working, deployed skeleton that teams can build on.

### Phase 1A: Parallel Build (Two Teams)

After scaffolding, two teams run in parallel against shared interfaces.

#### Team Experience (Frontend-heavy)

**Owns:** `[frontend directories]`

Teammates and their work:

- **[Role A]** -- [Scope: primary UI feature, interactions, visual states]
- **[Role B]** -- [Scope: secondary UI feature, navigation, management screens]
- **[Role C]** -- [Scope: auth UI, landing page, settings, base chrome]

#### Team Engine (Backend-heavy)

**Owns:** `[backend directories]`

Teammates and their work:

- **[Role D]** -- [Scope: database schema, policies, save/load API routes]
- **[Role E]** -- [Scope: core business logic, integrations, processing pipeline]
- **[Role F]** -- [Scope: output generation, export formats, rendering]

### Phase 1B: Integration (Single Session or Small Team)

- Wire frontend to real APIs (replace stubs/mocks)
- End-to-end testing of full flow
- Polish, error handling, edge cases

---

## Integration Contract

Teams build against shared interfaces. These are the handoff points.

### Data Interfaces

```typescript
// [Define your core data types here]
// These are consumed by both teams
interface [PrimaryEntity] {
  id: string;
  [fields relevant to your domain];
}
```

### API Route Contracts (Team Engine defines, Team Experience consumes)

```typescript
// POST /api/[resource]
// Creates a new [resource]
interface Create[Resource]Request {
  [fields];
}

// PUT /api/[resource]/[id]
// Updates [resource] state
interface Update[Resource]Request {
  [fields];
  version: number; // optimistic locking
}

// POST /api/[resource]/[id]/[action]
// Triggers [action] on [resource]
interface [Action]Request {
  [fields];
}

// GET /api/[resource]/[id]/[output]/[format]
// Returns [output] in requested format
```

These interfaces should be defined in `[shared types directory]` early in Phase 1A so both teams can build against them.

---

## Jira Integration

See `CLAUDE.md` for the full sync protocol. Summary:

- All tasks create corresponding [PROJECT_KEY] tickets
- Comments on Jira tickets for progress and feedback
- Labels: team labels + project label
- Work logging on task completion
- Teammates check Jira comments at checkpoints for owner feedback
- Dependencies tracked via Jira issue links

---

## Team Prompt Template

When starting the parallel build, use a prompt like:

```text
Create an agent team called "{project}-build" for Phase 1A development.

Read context/AGENT_TEAMS.md for the full team structure, integration
contracts, and Jira sync protocol. Read [product requirements doc] for
product requirements. Read CLAUDE.md for conventions and Jira integration.

Spawn two sub-teams:
- Team Experience (3 teammates): [Role A], [Role B], [Role C]
- Team Engine (3 teammates): [Role D], [Role E], [Role F]

Each teammate should:
1. Read their assigned scope from AGENT_TEAMS.md
2. Create Jira [PROJECT_KEY] tickets for their tasks with appropriate labels
3. Follow the Jira sync protocol in CLAUDE.md
4. Build against the shared interfaces
5. Team Experience builds with typed stubs where APIs don't exist yet
6. Team Engine builds against the decided schema

Require plan approval for all teammates before they start implementing.
Use delegate mode -- the lead coordinates, doesn't implement.
```

Replace `{project}` with the actual project name.
````

## Notes

**Why two teams, not six individual agents?** Ownership boundaries matter more than parallelism. Two teams with clear directory ownership (frontend vs. backend) prevents merge conflicts. Within each team, the lead coordinates work and resolves conflicts. Six independent agents touching the same files creates chaos.

**Why plan approval?** Without it, agents start implementing immediately based on their interpretation of the scope. Plan approval gives the team lead (and by extension, you) a checkpoint to catch misunderstandings before code is written. The cost is a few minutes of review; the benefit is avoiding rework.

**Why shared interfaces early?** The integration contract is the single most important artifact in a parallel build. If Team Experience builds against different assumptions than Team Engine, integration (Phase 1B) becomes a rewrite. Define the interfaces first, then both teams build toward them.

**Adapt the roles.** The `[Role A]` placeholders in the template are intentionally generic. Name roles after what they build, not generic titles. "Export Engineer" is clearer than "Backend Developer 3." Specific role names help agents understand their scope boundaries.

**Team naming is generic by design.** Use `team-experience` and `team-engine` (or your equivalents) as reusable labels, not product-specific names. This lets you run the same Jira project and label scheme across multiple engagements without reconfiguration.
