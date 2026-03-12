# Working Style Guide

This file covers how code is written, reviewed, and shipped. It's the most frequently updated file in the context directory because team norms evolve as tools and practices change.

## What Belongs Here

- Code style and formatting rules
- Import and module conventions
- Testing expectations
- Git workflow and commit conventions
- PR and review process
- Tool-specific configuration
- Boundary rules ("Do NOT" items)

## Example Content

---

### Code Style

**General:**

- [Indentation: 2 spaces, 4 spaces, tabs]
- [Line length limit if enforced]
- [Trailing commas: always, never, multiline only]
- [Semicolons if applicable]

**Naming:**

- Files: [kebab-case, camelCase, PascalCase]
- Variables/functions: [camelCase]
- Types/interfaces: [PascalCase]
- Constants: [SCREAMING_SNAKE_CASE or camelCase]
- Database columns: [snake_case]

**Imports:**

- [Module system: ES modules, CommonJS]
- [Import order: stdlib, external, internal, relative]
- [Destructuring preference]
- [Barrel exports: yes/no]

### Component Patterns

[If applicable -- React, Vue, Svelte, etc.]

- [Functional components only / class components allowed when]
- [Server vs. Client Component defaults]
- [State management approach]
- [Styling approach -- Tailwind, CSS modules, styled-components]

### Testing

- [Unit test expectations -- what must be tested]
- [Integration test expectations]
- [Test file naming and location -- colocated or separate directory]
- [Coverage targets if enforced]
- [Mocking conventions -- what to mock, what to test with real implementations]

### Git Workflow

- [Branch naming: feature/, fix/, chore/]
- [Commit format: conventional commits, free-form]
- [PR requirements: review count, CI passing, labels]
- [Merge strategy: squash, merge commit, rebase]

### Review Checklist

[What reviewers look for. Also useful for AI-generated code self-review.]

- [ ] Tests cover the change
- [ ] No unnecessary scope creep beyond the task
- [ ] Auth/permission checks present on new endpoints
- [ ] Migrations are reversible
- [ ] Error handling present for failure modes
- [ ] No hardcoded values that should be config

### Tooling

[Tool-specific notes that affect development.]

- **Linter:** [tool and config location]
- **Formatter:** [tool and config location]
- **Type checker:** [strict mode, suppression rules]
- **CI:** [what runs, in what order, how to run locally]

### Boundaries

[The "Do NOT" section. Specific, experience-driven rules. Every item here traces back to a real incident or repeated friction.]

- [e.g., Do not modify shared configuration files without team review]
- [e.g., Do not add dependencies without checking bundle size impact]
- [e.g., Do not use `any` type -- use `unknown` and narrow]
- [e.g., Do not add `eslint-disable` without a comment explaining why]
- [e.g., Do not create abstraction layers for one-time operations]

---

## Why This File Exists Separately

Style and workflow conventions change more frequently than any other context. New tools get adopted, team agreements shift, post-mortems produce new rules. This file should be the easiest to update because it's updated the most.

Keeping it separate also makes ownership clear. Architecture decisions might be made by a lead or architect. Business requirements come from product. The working style guide is a team agreement -- anyone can propose changes, and the team agrees on them.
