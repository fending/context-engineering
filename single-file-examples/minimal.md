# AGENTS.md (Minimal)

The smallest useful context file. If your tool uses `CLAUDE.md`, symlink it: `ln -s AGENTS.md CLAUDE.md`. Copy this, fill in the blanks, and you're operational.

---

````markdown
# AGENTS.md

## What This Project Does

[One paragraph. What does this thing do, who uses it, why does it exist.]

## Tech Stack

- Language: [e.g., TypeScript]
- Framework: [e.g., Next.js 14, App Router]
- Database: [e.g., PostgreSQL via Prisma]
- Hosting: [e.g., Vercel]

## Commands

- `npm run dev` -- start local dev server
- `npm test` -- run test suite
- `npm run build` -- production build

## Code Standards

- [Indentation preference]
- [Import style]
- [Naming conventions]
- [Test expectations]

## Do NOT

- [Hard boundaries -- things the AI should never do]
- [Learned-the-hard-way rules go here]
````

---

## Why This Works

Even this minimal file eliminates the two most common failure modes in AI-assisted development:

1. **Wrong assumptions about the stack.** Without context, an AI will guess your framework, your testing library, your deployment target. It'll suggest Express when you're using Hono, Jest when you're using Vitest, `require` when you use ES modules. A few lines fix this permanently.

2. **Unbounded scope.** Without explicit boundaries, AI assistants will refactor code you didn't ask about, add error handling for scenarios that can't happen, and create abstractions for one-time operations. The "Do NOT" section is where hard-won lessons live.

## When to Graduate

Move to a fuller single file (see the other examples) or a context directory when:

- The file exceeds ~100 lines and becomes hard to scan
- You need to document architecture decisions or business context
- Multiple people are contributing to the project
- You have recurring workflows that need structured instructions
