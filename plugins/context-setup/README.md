# context-setup

A Claude Code plugin for scaffolding, auditing, and upgrading context engineering files. Generates AGENTS.md files, context directories, and cascading structures based on your project's actual stack and complexity.

## Install

```bash
/plugin marketplace add fending/context-engineering
/plugin install context-setup@context-engineering
```

## Skills

### /context-setup:scaffold

Analyze your project and generate the right context files pre-populated with discovered information. Detects tech stack, framework, directory structure, and existing context. Recommends a complexity level (minimal, full single file, or cascading with context directory) and generates the corresponding files.

### /context-setup:audit

Evaluate your existing context structure for completeness and best practices. Checks whether your context complexity matches your project complexity, whether required sections are present, whether format conventions are followed, and whether structural issues exist (duplicated subdirectory files, empty context directory files, cascading contradictions).

### /context-setup:upgrade

Guide a transition from your current context level to the next one. Preserves existing content while adding missing sections (minimal to full), extracting content into a context directory (full to cascading), or describing the skills and hooks layers you can add on top.

## How This Differs from .claude-example Skills

The `.claude-example/` directory in the parent repo provides operational skills that consume and enforce existing context files:

- `/onboard` discovers and summarizes what context exists
- `/context-align` checks whether context files match the codebase
- `/scope-check` validates tasks against boundary rules

This plugin creates and evaluates the context files themselves:

- `/context-setup:scaffold` generates context files from project analysis
- `/context-setup:audit` checks structural completeness and best practices
- `/context-setup:upgrade` guides transitions to higher complexity levels

Use this plugin to set up your context structure. Use the `.claude-example/` skills to operate within it day-to-day.

## Learning the Patterns

This plugin generates context files based on patterns documented in the [context-engineering](https://github.com/fending/context-engineering) repo. For the theory behind the structures, read the repo's examples and the companion article: [Rethinking Team Topologies for AI-Augmented Development](https://brianfending.substack.com/p/rethinking-team-topologies-for-ai).
