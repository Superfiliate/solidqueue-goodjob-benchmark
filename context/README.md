# Context Folder

This folder contains all decision documents, specifications, and domain knowledge for the benchmark project. It serves as the single source of truth for what we're building and how we're building it.

## Tool-Agnostic by Default

**Important**: Everything in `context/` is designed to work with **any AI agent or editor** (Cursor, Claude Code, OpenCode, etc.), not just Cursor-specific features. This ensures our documentation and workflows remain portable and version-controlled.

For example, commands in `context/commands/` are written as plain markdown prompts that can be used by any agent. The `.cursor/commands` symlink is just a Cursor-specific adapter - the canonical source is always `context/commands/`.

## When to Create New Files

Create a new decision document when you encounter:

- **A new assumption** that affects implementation
- **A decision point** that needs to be documented (feature or technical)
- **A new benchmark scenario** or workload to test
- **A methodology change** in how we measure or report results
- **A constraint or requirement** that wasn't previously documented

## How to Discover Context

**Always list files** in the relevant subfolders to discover what exists. Do not maintain an index file - the descriptive filenames should make it clear what each document contains.

Use commands like:
- `list_dir` on `context/features/`
- `list_dir` on `context/technical/`
- `list_dir` on `context/commands/`

Then read the files that seem most relevant to your current task.

## Filename Convention

- **Extremely descriptive**: The filename should clearly indicate what decision or topic the document covers
- **No dates**: We don't prefix filenames with dates
- **One decision per file**: Each file should focus on a single decision or topic
- **Use kebab-case**: Separate words with hyphens (e.g., `benchmark-scope-and-success-metrics.md`)

Examples of good filenames:
- `benchmark-scope-and-success-metrics.md`
- `rails-version-and-dependency-strategy.md`
- `job-workload-design-patterns.md`
- `database-schema-for-benchmark-jobs.md`

## Decision Document Template

Each decision document should follow an ADR (Architecture Decision Record) style format:

```markdown
# [Descriptive Title]

## Context

[Describe the situation, background, and constraints that led to this decision]

## Decision

[State the decision clearly and concisely]

## Alternatives Considered

[List other options that were evaluated and why they were rejected]

## Consequences

[Describe the positive and negative impacts of this decision]

## Open Questions / Follow-ups

[Any unresolved questions or future decisions that depend on this one]
```

## Subfolders

- **`features/`**: Decisions about **what** we're building - benchmark scenarios, success criteria, project scope, and feature requirements. Feature decisions answer questions like: What are we benchmarking? What scenarios should we test? What defines success? What is in scope vs out of scope?

- **`technical/`**: Decisions about **how** we're building it - implementation details, tools, architecture, methodology, and technical constraints. Technical decisions answer questions like: What tools and frameworks will we use? How will we measure performance? What is our testing methodology? How will we structure the code?

- **`commands/`**: Reusable prompts and workflows that can be used by AI agents (Cursor, Claude Code, OpenCode, etc.). These are stored as markdown files and are tool-agnostic by design. In Cursor, they're accessible via the `.cursor/commands` symlink, but the canonical source is `context/commands/` so they work with any agent or editor.
