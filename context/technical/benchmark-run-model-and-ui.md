# BenchmarkRun Persistence Model and UI Scaffold

## Context

We need a minimal way to record benchmark runs so we can:

- Track which adapter/gem (SolidQueue vs GoodJob) a run is using
- Track the intended workload size (job count)
- Track coarse lifecycle timestamps (e.g., when scheduling finished, when execution finished)
- Present a simple UI to create runs during early scaffolding (before the actual benchmark harness exists)

This document captures the current Rails scaffold’s persisted model + UI so the root `README.md` can stay focused on project vision + “how to run,” while implementation details live in `context/`.

## Decision

### `BenchmarkRun` model

We persist benchmark runs in a `benchmark_runs` table with:

- `gem` (string, required): `"solid_queue"` or `"good_job"`
- `jobs_count` (integer, required): requested job count (e.g., 1_000, 10_000, 100_000, 1_000_000)
- `scheduling_finished_at` (datetime, nullable): when enqueue/scheduling completed
- `run_finished_at` (datetime, nullable): when all jobs finished running
- Rails timestamps (`created_at`, `updated_at`)

The Rails model:

- Defines `enum :gem, { solid_queue: "solid_queue", good_job: "good_job" }, prefix: true`
- Validates presence of `gem`
- Validates `jobs_count` presence and `numericality: { greater_than: 0 }`

### Minimal UI + controller

The homepage (`HomeController#index`) displays:

- Two button groups to create a new run for each gem at preset job counts: 1k, 10k, 100k, 1M
- Two lists of runs (SolidQueue runs and GoodJob runs), ordered newest-first, showing:
  - jobs count
  - created timestamp
  - scheduling finished timestamp (or “Not finished”)
  - run finished timestamp (or “Not finished”)

Run creation is handled by `BenchmarkRunsController#create`:

- Accepts `benchmark_run[gem]` and `benchmark_run[jobs_count]`
- Persists the record
- Enqueues an adapter-specific scheduling job (`SolidQueueSchedulingJob` or `GoodJobSchedulingJob`) based on the run's `gem` value
- Redirects back to `/` with a flash message

The scheduling job:
- Receives the `BenchmarkRun` record as a parameter
- Reads `jobs_count` from the record
- Inside a transaction, enqueues `jobs_count` adapter-specific "Pretend" jobs (`SolidQueuePretendJob` or `GoodJobPretendJob`)
- Updates `scheduling_finished_at` with `Time.current` before closing the transaction

The Pretend jobs are placeholder jobs with no work inside `perform` - they exist solely for benchmarking the job queue systems.

## Alternatives Considered

- **No persistence until benchmark harness exists**: rejected; even early scaffolding benefits from a place to hang benchmark state and future metrics.
- **Separate models per adapter**: rejected; we want one unified “run” concept with a `gem` discriminator.
- **Storing full metrics on `BenchmarkRun`**: deferred; detailed metrics collection/storage design should be captured separately once instrumentation is implemented.

## Consequences

### Positive

- A single “run” record anchors future benchmark execution + reporting.
- UI scaffolding allows quick manual creation of runs during development.
- The model is intentionally minimal and adapter-agnostic.

### Negative

- The lifecycle timestamp `scheduling_finished_at` is now set automatically by the scheduling job, but `run_finished_at` remains a placeholder until the benchmark harness tracks job completion.

## Open Questions / Follow-ups

- Where should per-run metrics be stored (table schema vs time-series files vs external system)?
- Should we record benchmark configuration (concurrency, job type, payload size, etc.) on `BenchmarkRun` or via associated tables?
- What transitions define “scheduling finished” and “run finished” once job execution is implemented?
