## Queue Admin UIs

### Context

We want lightweight, local-facing admin pages to inspect queued and scheduled jobs
for each adapter during development and benchmarking.

### Decision

- Mount the GoodJob web UI at `/good_job` via `GoodJob::Engine`.
- Mount the SolidQueue admin UI at `/solid_queue` via Mission Control Jobs.
- No authentication is required for this toy app; add auth if this becomes public.

### Notes

- GoodJob ships its web UI as part of the gem.
- SolidQueue relies on the `mission_control-jobs` gem for its admin UI.
