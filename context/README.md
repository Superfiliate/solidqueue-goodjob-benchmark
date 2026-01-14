# Context Folder

This folder contains all decision documents, specifications, and domain knowledge for the benchmark project. It serves as the single source of truth for what we're building and how we're building it.

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

- **`features/`**: Decisions about what features to build, benchmark scenarios, success criteria, and project scope
- **`technical/`**: Decisions about implementation details, tools, architecture, methodology, and technical constraints
