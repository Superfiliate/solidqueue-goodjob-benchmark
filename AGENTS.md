# AI Agent Instructions

When working on this project, always follow these steps:

1. **Read the root [`README.md`](README.md) first** - This contains the project overview, goals, and design approach.

2. **ALWAYS update the root [`README.md`](README.md) as needed** - When the project evolves:
   - Update the "Current Status" section to reflect what exists
   - Add new sections or update existing ones when goals, metrics, or approach change
   - Keep it accurate and current - the README is the entry point for understanding the project
   - **Do not let the README become outdated** - it should always reflect the current state of the project
   - **Keep the root README high-level (non-negotiable)**: it should be the project vision + quick “how to run/fork” guidance. If a detail is not necessary for someone to run the project today, it belongs in `context/` (and the README should link to it).

   **README.md allowed content**
   - Purpose / high-level goals (1–2 short sections)
   - Quick start commands (local dev) and minimal prerequisites
   - Minimal “Current Status” bullets (what exists, what’s missing) without internal mechanics
   - Pointers to canonical `context/` docs (links)

   **README.md forbidden content**
   - Model/table schema details (fields, enums, validations, indexes)
   - Internal flow descriptions (controllers/jobs callbacks, “last write wins”, transaction details, etc.)
   - Deep deployment mechanics (process groups, scaling recipes, port wiring, troubleshooting narratives)
   - Benchmark methodology/instrumentation specifics and long metric/workload enumerations

   **Rule of thumb**: If you’re writing more than ~2 sentences about “how it works internally”, stop and create/update a `context/` doc instead.

   **Documentation ownership (what goes where)**
   - `README.md`: vision + quick start + links (no internals)
   - `context/README.md`: how to use `context/` (rules, template, conventions)
   - `context/features/*`: “what/why” decisions (scope, success metrics, workloads)
   - `context/technical/*`: “how” decisions (architecture, instrumentation, deployment, ops/processes)
   - `AGENTS.md`: contributor/agent guardrails (how to work in this repo)
   - `TODO.md`: short, tactical punch-list only (no specs; link to `context/` instead)

3. **Consult the `context/` folder** - Before making any decisions or implementing features:
   - List files in `context/features/` and `context/technical/`
   - Read the most relevant decision documents for your current task
   - Follow the guidance and constraints documented there

4. **Create new decision documents when needed** - If you encounter:
   - A new assumption or decision point
   - Missing guidance for a feature or technical choice
   - A conflict between existing decisions

   Create a new file in the appropriate `context/` subfolder with a descriptive filename (see `context/README.md` for format).

5. **Never improvise without context** - If guidance is unclear or missing, document the decision first, then implement.
