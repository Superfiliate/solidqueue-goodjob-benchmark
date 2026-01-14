# Multi-Process Development and Production Setup

## Context

This benchmark project needs to run SolidQueue and GoodJob workers as separate processes from the Rails web server. This separation is essential for:

1. **Fair benchmarking**: Each adapter runs independently without interference
2. **Resource isolation**: CPU/memory usage can be measured per-process
3. **Scalability testing**: Workers can be scaled independently in production
4. **Development clarity**: Separate logs make it easier to debug and observe each component

## Decision

### Local Development: Overmind + Procfile.dev

We use [Overmind](https://github.com/DarthSim/overmind) for local process management because:

- **Visual separation**: Each process runs in its own tmux pane with clearly labeled logs
- **Easy process management**: Start/stop all processes with a single command
- **Individual process control**: Can still run processes individually via `make dev-web`, `make dev-solidqueue`, `make dev-goodjob`
- **No gem dependency**: Overmind is a standalone binary (installed via Homebrew)

**Setup:**
- `Procfile.dev` defines 3 processes: `web`, `solidqueue`, `goodjob`
- `make dev` runs `overmind start -f Procfile.dev` with database environment variables
- `make dev-stop` stops all processes cleanly
- Individual targets (`dev-web`, `dev-solidqueue`, `dev-goodjob`) allow running processes separately

**Bootstrap:**
- `make bootstrap` installs required tools: `flyctl`, `overmind`, `tmux` (macOS/Homebrew)
- Ensures all developers have the same tooling setup

### Production: Fly.io Process Groups

Fly.io supports multiple process groups within a single app, allowing independent scaling:

**Process groups defined in `fly.toml`:**
- `web` → `./bin/thrust ./bin/rails server` (routed via HTTP)
- `solidqueue` → `./bin/jobs start` (background worker)
- `goodjob` → `bundle exec good_job start` (background worker)

**HTTP routing:**
- Only the `web` process group is included in `[http_service].processes = ['web']`
- `solidqueue` and `goodjob` are background workers and do not receive HTTP traffic

**Scaling:**
- Scale independently: `fly scale count web=1 solidqueue=2 goodjob=2`
- Useful for benchmarking: scale workers up/down without affecting web server
- Each process group runs on separate machines (or can share machines with proper configuration)

### Database Configuration: Queue Database

SolidQueue and GoodJob use a separate **logical** `queue` connection, but in this benchmark it points at the **same physical database** as the primary app DB.

**Why a separate logical `queue` connection (even on one DB):**
- **Fair comparison**: Both adapters use the same connection + migration structure
- **Clear ownership**: It’s obvious which tables belong to job processing
- **Stable migrations**: We can track queue migrations separately (via a dedicated `schema_migrations` table) without risking version collisions

**Configuration:**
- `config/database.yml` defines a `queue` connection for development, test, and production
- The `queue` connection points to the same database as `primary`
- Migrations live in `db/queue_migrate/` (separate from `db/migrate/`)
- GoodJob uses `GoodJobRecord` model that `connects_to` the `:queue` connection
- SolidQueue is configured to use the `:queue` connection

**Local development:**
- Development uses a single database: `solidqueue_goodjob_benchmark_development`
- The same PostgreSQL instance (Docker Compose), one database name
- Migrations run via `bin/rails db:prepare` (prepares primary + queue)

## Alternatives Considered

### Foreman instead of Overmind
- **Considered**: Foreman is a Ruby gem, more familiar to Rails developers
- **Rejected**: Overmind provides better visual separation (tmux panes) and doesn't require adding a gem dependency

### Single process with embedded workers
- **Considered**: Run workers in the same process as Rails (e.g., GoodJob's `:async` mode)
- **Rejected**: Doesn't allow fair benchmarking or independent scaling; resource usage would be mixed

### Separate Fly.io apps
- **Considered**: Deploy web, solidqueue, goodjob as 3 separate Fly apps
- **Rejected**: More complex deployment, harder to manage, and process groups within one app provide the same isolation with simpler setup

### Primary database for job tables
- **Considered**: Store job tables in the primary application database
- **Chosen**: We use one physical DB for portability (managed DBs often don’t permit creating multiple databases), while keeping a separate logical `queue` connection for clarity and migration tracking

## Consequences

### Positive

- **Clear separation**: Each component runs independently with its own logs
- **Easy scaling**: Workers can be scaled independently in production
- **Fair benchmarking**: No interference between adapters during tests
- **Developer experience**: Overmind provides excellent visual feedback
- **Production-ready**: Fly.io process groups match real-world deployment patterns

### Negative

- **More complex setup**: Requires Overmind/tmux for local development
- **Multiple processes**: More processes to manage and monitor
- **Database complexity**: Multiple logical connections require additional configuration
- **Platform dependency**: `make bootstrap` assumes macOS/Homebrew (though tools can be installed manually on other platforms)

## Open Questions / Follow-ups

- Should we add process monitoring/health checks for workers in production? (Currently deferred)
- Do we need to configure resource limits per process group in Fly.io? (Can be added if needed)
- Should we document how to run processes individually without Overmind? (Currently available via individual make targets)
