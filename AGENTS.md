# AI Agent Instructions

When working on this project, always follow these steps:

1. **Read the root [`README.md`](README.md) first** - This contains the project overview, goals, and design approach.

2. **ALWAYS update the root [`README.md`](README.md) as needed** - When the project evolves:
   - Update the "Current Status" section to reflect what exists
   - Add new sections or update existing ones when goals, metrics, or approach change
   - Keep it accurate and current - the README is the entry point for understanding the project
   - **Do not let the README become outdated** - it should always reflect the current state of the project
 - **Keep the root README high-level**: it should be the project vision + quick “how to run/fork” guidance. Detailed implementation notes belong in `context/` and should be linked from the README instead of copied in.
   - Examples of details that should live in `context/`: model/schema specifics (e.g. `BenchmarkRun` fields), instrumentation/measuring approach, deployment rationale, benchmark harness architecture, workload definitions.

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
