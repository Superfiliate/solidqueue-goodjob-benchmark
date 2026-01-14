# SolidQueue vs GoodJob Performance Benchmark

## Purpose

This project performs a comprehensive performance benchmark comparing [SolidQueue](https://github.com/rails/solid_queue) and [GoodJob](https://github.com/bensheldon/good_job) gems on a Rails application.

## Current Status

**Basic Rails application scaffold** - A vanilla Rails application has been set up at the repository root with PostgreSQL and Fly.io deployment configuration. The app is ready for local development and can be deployed to Fly.io.

**BenchmarkRun persistence** - A `BenchmarkRun` model exists to store benchmark run metadata (gem type, job count, timestamps). The homepage provides a UI with buttons to create benchmark runs for SolidQueue and GoodJob at different job counts (1k, 10k, 100k, 1M). Currently, creating a run only persists the record - it does not trigger any background job execution yet.

**Still pending** - Benchmark-specific gem integration (GoodJob gem not installed yet, SolidQueue is in Gemfile but not integrated) and instrumentation have not been added yet.

This project follows a spec-driven, domain-driven design approach where decisions and specifications are documented in the `context/` folder before implementation begins.

## Benchmark Goals

The benchmark aims to answer:

- Which gem performs better under various workload conditions?
- What are the trade-offs between SolidQueue and GoodJob?
- How do they compare in terms of latency, throughput, resource usage, and scalability?
- Which gem is more suitable for different use cases?

## Metrics

Initial metrics to measure (subject to refinement via decision documents):

- **Latency**: Job execution time (p50, p95, p99)
- **Throughput**: Jobs processed per second
- **Resource Usage**: CPU, memory consumption
- **Database Load**: Query patterns, connection pool usage, lock contention
- **Queue Depth**: Number of pending jobs over time
- **Tail Latencies**: Extreme percentiles (p99.9, p99.99)
- **Error Rates**: Failed job rates under load

## Workloads

High-level workload scenarios to simulate (detailed specifications in `context/`):

- Different job types (CPU-bound, I/O-bound, mixed)
- Various concurrency levels
- Burst vs steady-state traffic patterns
- Different queue priorities and scheduling strategies

## Design Approach

This project follows **spec-driven development** and **domain-driven design** principles:

- **Decisions are documented first** in the `context/` folder before implementation
- **Feature decisions** capture what we're building and why
- **Technical decisions** capture how we're building it
- All assumptions and constraints are explicit and discoverable

## Using the Context Folder

The `context/` folder contains all decision documents, specifications, and reusable workflows. To discover relevant context:

1. **List files** in `context/features/`, `context/technical/`, and `context/commands/`
2. **Read relevant files** based on descriptive filenames
3. **Create new files** when making new decisions (see `context/README.md` for format)

**Important**: There is no index file. Always list the directory to discover what exists.

**Note**: Commands in `context/commands/` are tool-agnostic and work with any AI agent or editor. In Cursor, they're accessible via the `.cursor/commands` symlink.

## Prerequisites

### Fly.io CLI

To deploy this application to Fly.io, you'll need the Fly CLI (`flyctl`) installed. Installation instructions are available at:

**https://fly.io/docs/flyctl/install/**

Quick install for macOS (with Homebrew):
```bash
brew install flyctl
```

For other platforms, see the [official installation guide](https://fly.io/docs/flyctl/install/).

### Local Development

This project uses Docker Compose to run PostgreSQL locally for development. The Rails server runs on port **31500** and PostgreSQL on port **31501** to avoid conflicts with other applications.

**Prerequisites:**
- Docker and Docker Compose installed
- Ruby 4.0.1 (managed via `mise` or your preferred Ruby version manager)

**Quick Start:**

1. **Start PostgreSQL**:
   ```bash
   make db-up
   ```

2. **Setup the application** (install dependencies and prepare database):
   ```bash
   make setup
   ```

3. **Start the Rails development server**:
   ```bash
   make dev
   ```

4. **Visit the application**:
   Open `http://localhost:31500` in your browser.

**Other useful commands:**

- `make db-down` - Stop PostgreSQL container
- `make db-nuke` - Stop and remove PostgreSQL container and volume (destructive)
- `make db-logs` - View PostgreSQL logs
- `make psql` - Open psql shell in PostgreSQL container

**Note:** The Makefile uses custom ports (Rails: 31500, Postgres: 31501) to avoid conflicts with other applications. These can be overridden via environment variables if needed.

## Deploying to Fly.io

After installing `flyctl` and creating a Fly.io account, you can deploy this application:

1. **Login to Fly.io**:
   ```bash
   fly auth login
   ```

2. **Create and deploy the app** (choose one approach):

   **Option A - Using fly launch (recommended for first-time Fly users)**:
   ```bash
   fly launch --org=<your-org-name>
   ```
   Follow the wizard to select your organization and region. The wizard will detect the existing `Dockerfile` and `fly.toml` configuration. You can accept the defaults or customize as needed. **Note**: The `fly.toml` file already has an app name configured (`solidqueue-goodjob-benchmark`), but you can change it during the wizard if desired.

   **Option B - Manual app creation**:
   ```bash
   fly apps create <your-app-name>
   fly deploy
   ```
   If using this option, you may want to update the `app` name in `fly.toml` to match your chosen app name.

4. **Provision PostgreSQL database** (required for this project):
   ```bash
   fly postgres create --name <your-db-name>
   fly postgres attach --app <your-app-name> <your-db-name>
   ```
   This will automatically set the `DATABASE_URL` environment variable for your app. Replace `<your-app-name>` with the actual name of your Fly app.

5. **Deploy** (if you used Option B, or to redeploy after attaching the database):
   ```bash
   fly deploy
   ```

6. **Open your app**:
   ```bash
   fly apps open
   ```

## Troubleshooting

### Fly deploy fails with `listen tcp :80: bind: permission denied`

This app’s production container starts via Thruster (`bin/thrust`). Thruster defaults to listening on port 80, which is a privileged port and will fail when the container runs as a non-root user.

Fix: ensure Thruster listens on Fly’s `internal_port` (8080). This repo’s `fly.toml` sets `HTTP_PORT=8080`.

## Next Steps

1. Review and refine decision documents in `context/`
2. Document benchmark scenarios and success criteria
3. Design the benchmark harness and instrumentation
4. Add SolidQueue and GoodJob gems for benchmarking
5. Implement benchmark suite
