# QA Browser - Manual Testing Workflow

Perform manual QA testing of the application by starting the development server, opening the browser, and walking through the impacted user flows.

## Context Analysis

First, determine what needs to be QA'd by analyzing:
- **Current chat thread context**: What features or changes have been discussed?
- **Current branch diff**: What files have been modified compared to the main branch?

Identify the specific user flows, pages, or features that have been touched and need manual verification.

## Setup and Start Services

1. **Ensure PostgreSQL is running**:
   ```bash
   make db-up
   ```
   If the database is already running, this will be a no-op.

2. **Start the Rails development server**:
   ```bash
   make dev
   ```
   The server runs on `http://localhost:31500` by default (see `Makefile` for port configuration).

   **Note**: If the server is already running, detect this and proceed without starting a duplicate instance.

## Open Browser

Open the application in a browser:
- **Preferred**: Use Cursor's built-in browser tooling if available
- **Fallback**: Use system command `open http://localhost:31500` (macOS) or equivalent for other platforms

## Manual Testing

Walk through the impacted user flow(s) identified in the context analysis:

1. **Navigate to the relevant pages** (homepage, benchmark runs, etc.)
2. **Test the specific features** that were modified
3. **Verify expected behavior** matches the intended changes
4. **Check for regressions** - ensure existing functionality still works
5. **Look for errors** - check browser console, Rails logs, and any error states

## Document Findings

After completing the manual QA:

1. **Summarize what was tested** - list the flows and features verified
2. **Report any issues found** - bugs, regressions, or unexpected behavior
3. **Note any observations** - performance, UI/UX concerns, or edge cases
4. **Recommend next steps** - fixes needed, additional testing required, or approval to proceed

## Example Workflow

If testing benchmark run creation:
- Navigate to homepage (`http://localhost:31500`)
- Click a benchmark run button (e.g., "Create SolidQueue 1k run")
- Verify the BenchmarkRun record is created in the database
- Check that the UI provides appropriate feedback
- Verify no errors appear in browser console or Rails logs
- Test multiple button clicks and verify idempotency/duplicate handling
