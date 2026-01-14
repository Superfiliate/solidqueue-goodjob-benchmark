# SolidQueue vs GoodJob Performance Benchmark

## Purpose

This project performs a comprehensive performance benchmark comparing [SolidQueue](https://github.com/rails/solid_queue) and [GoodJob](https://github.com/bensheldon/good_job) gems on a Rails application.

## Quick Start (Local)

This project uses Docker Compose to run PostgreSQL locally. The Rails server runs on port **31500** and PostgreSQL on **31501**.

**Prerequisites:**
- Docker and Docker Compose installed
- Ruby 3.4.8 (managed via `mise` or your preferred Ruby version manager)
- macOS with Homebrew (for `make bootstrap`)

```bash
make bootstrap  # Install flyctl, overmind, tmux (macOS only)
make db-up
make setup
make dev
```

Then visit `http://localhost:31500`.

## Current Status

- **Rails scaffold**: PostgreSQL-backed Rails app at repo root, ready for local dev and Fly.io deployment.
- **Run tracking scaffold**: `BenchmarkRun` records can be created from the homepage UI; creation triggers adapter-specific fan-out scheduling jobs that enqueue placeholder "Pretend" jobs. The `scheduling_finished_at` timestamp is automatically set when scheduling completes, and Pretend jobs update `run_finished_at` so the last write wins. Details: [`context/technical/benchmark-run-model-and-ui.md`](context/technical/benchmark-run-model-and-ui.md).
- **Job adapters installed**: Both SolidQueue and GoodJob gems are installed and configured to use a separate logical `queue` connection (but the **same physical database**). Both run as separate processes (locally via Overmind, production via Fly.io process groups).
- **Benchmark harness partial**: Fan-out scheduling jobs are implemented for both adapters, but instrumentation and robust completion tracking are not yet implemented.

## Benchmark Goals

The benchmark aims to answer:

- Which gem performs better under various workload conditions?
- What are the trade-offs between SolidQueue and GoodJob?
- How do they compare in terms of latency, throughput, resource usage, and scalability?
- Which gem is more suitable for different use cases?

## Metrics

The canonical metrics list (and how we define them) lives in:

- [`context/features/benchmark-scope-and-success-metrics.md`](context/features/benchmark-scope-and-success-metrics.md)
- [`context/technical/benchmark-methodology-and-instrumentation.md`](context/technical/benchmark-methodology-and-instrumentation.md)

## Workloads

The canonical workload axes (and what’s in/out of scope) lives in:

- [`context/features/benchmark-scope-and-success-metrics.md`](context/features/benchmark-scope-and-success-metrics.md)

## Design Docs (Read These First)

This repo is intentionally **spec-driven**: decisions and detailed design live in `context/`.

- Scope / questions / success metrics / workloads: [`context/features/benchmark-scope-and-success-metrics.md`](context/features/benchmark-scope-and-success-metrics.md)
- Methodology + instrumentation approach: [`context/technical/benchmark-methodology-and-instrumentation.md`](context/technical/benchmark-methodology-and-instrumentation.md)
- Local dev PostgreSQL (Docker Compose + ports): [`context/technical/local-development-postgres-docker-compose.md`](context/technical/local-development-postgres-docker-compose.md)
- Fly.io + Docker strategy (optional): [`context/technical/flyio-deployment-and-docker-strategy.md`](context/technical/flyio-deployment-and-docker-strategy.md)
- Reusable agent workflows: [`context/commands/`](context/commands/) (see also [`context/README.md`](context/README.md))

## Local Development Notes

**Development processes:**

- `make dev` - Start all 3 processes (web, solidqueue, goodjob) via Overmind in separate tmux panes
- `make dev-web` - Start only the Rails web server
- `make dev-solidqueue` - Start only the SolidQueue worker
- `make dev-goodjob` - Start only the GoodJob worker
- `make dev-stop` - Stop all development processes (Overmind)

Note: `make dev-solidqueue` disables Bootsnap by default to avoid rare native crashes on macOS; set `DISABLE_BOOTSNAP=0` if you want it enabled.

**Other useful commands:**

- `make db-down` - Stop PostgreSQL container
- `make db-nuke` - Stop and remove PostgreSQL container and volume (destructive)
- `make db-logs` - View PostgreSQL logs
- `make psql` - Open psql shell in PostgreSQL container

**Note:** The Makefile uses custom ports (Rails: 31500, Postgres: 31501) to avoid conflicts with other applications. These can be overridden via environment variables if needed.

**Process management:** Local development uses [Overmind](https://github.com/DarthSim/overmind) (tmux-based) to run web, SolidQueue, and GoodJob workers as separate processes with visually separated logs. Overmind is installed via `make bootstrap`.

## Deploying to Fly.io

Deploy is optional and primarily exists to make it easy for others to reproduce the environment.

**Prerequisites:**
- Install `flyctl` (macOS): `make bootstrap` or `brew install flyctl` (see Fly docs: [`https://fly.io/docs/flyctl/install/`](https://fly.io/docs/flyctl/install/))
- Follow the canonical deployment notes in [`context/technical/flyio-deployment-and-docker-strategy.md`](context/technical/flyio-deployment-and-docker-strategy.md)

**Process groups:**

This app deploys 3 separate process groups on Fly.io (all within the same app):
- **`web`** - Rails web server (routed via HTTP, runs Thruster)
- **`solidqueue`** - SolidQueue worker process
- **`goodjob`** - GoodJob worker process

**Scaling:**

Scale processes independently for benchmarking:
```bash
fly scale count web=1 solidqueue=1 goodjob=1
```

For example, to scale only workers for a benchmark run:
```bash
fly scale count solidqueue=3 goodjob=3  # Keep web at 1, scale workers
```

Only the `web` process receives HTTP traffic; `solidqueue` and `goodjob` are background workers.

## Next Steps

1. Review and refine decision documents in `context/`
2. Document benchmark scenarios and success criteria
3. Design the benchmark harness and instrumentation
4. Implement benchmark suite and instrumentation
