# Fly.io Deployment and Docker Strategy

## Context

This benchmark project needs to be easily deployable to Fly.io so that anyone can clone the repository and deploy it to their own Fly.io account. While "production deployment considerations" are explicitly out of scope for the benchmark itself (see [benchmark-scope-and-success-metrics.md](../features/benchmark-scope-and-success-metrics.md)), having a working deployment setup serves several purposes:

1. **Reproducibility**: Containerized deployment ensures consistent environments across different developers' machines
2. **Accessibility**: Makes it easy for others to run and test the benchmark
3. **Future-proofing**: Sets up infrastructure for potential distributed benchmarking scenarios (though currently out of scope)

The benchmark methodology document ([benchmark-methodology-and-instrumentation.md](benchmark-methodology-and-instrumentation.md)) notes that containerization is an open question, but having a working Docker/Fly setup doesn't commit us to using it for the actual benchmark runs - it's just infrastructure for deployment.

## Decision

### Repository Layout

The Rails application lives at the repository root. This provides:
- Simplicity: All Rails files (Gemfile, app/, config/, etc.) are at the root level
- Standard Rails conventions: Matches typical Rails project structure
- Benchmark documentation: Decision documents in `context/` coexist with the Rails app

### Docker Configuration

We use Rails 8's built-in Dockerfile generation, which creates:
- `Dockerfile` - Multi-stage build optimized for production
- `bin/docker-entrypoint` - Entrypoint script that handles database preparation
- `.dockerignore` - Excludes unnecessary files from the build context
- `config/dockerfile.yml` - Tracks Dockerfile generation options

The Dockerfile:
- Uses Ruby 4.0.1 (pinned via `.ruby-version` and `.tool-versions`)
- Exposes port 8080 (Fly.io uses `internal_port` from `fly.toml` for routing)
- Includes jemalloc for reduced memory usage
- Runs as non-root user for security
- Uses Rails 8's Thruster server by default (configured to listen on port 8080 via `HTTP_PORT`)

### Fly.io Configuration

The `fly.toml` file uses Fly.io's recommended configuration for Rails applications:

- **`[http_service]` section**: Simpler than `[[services]]` for HTTP-only apps
- **`internal_port = 8080`**: Fly.io's recommended default port
- **`HTTP_PORT = "8080"` environment variable**: Ensures Thruster binds to the same port Fly routes to (Thruster defaults to 80, which is privileged and will fail when running as non-root)
- **`PORT`/`TARGET_PORT` behavior**: Thruster sets `PORT` for the underlying Puma process to `TARGET_PORT` (default 3000); Fly routing should target Thruster (`HTTP_PORT`), not Puma directly
- **`release_command = "bin/rails db:prepare"`**: Runs database migrations/preparation once per deploy in a temporary machine before the new release goes live
- **Health checks**: Configured to check `/up` endpoint (Rails' built-in health check route)
- **Auto-scaling**: Configured with `auto_stop_machines` and `auto_start_machines`, with `min_machines_running = 1` to keep one web machine warm

#### Process groups

This app defines multiple Fly process groups so the web process and each adapter’s worker can be scaled independently:

- `web`: Rails web server (routed via HTTP)
- `solidqueue`: SolidQueue worker process
- `goodjob`: GoodJob worker process

Only the `web` process receives HTTP traffic; the worker processes are background-only.

### Ruby Version Management

We use `mise` (formerly rtx) as the Ruby version manager, with:
- `.tool-versions` file at the root specifying Ruby 4.0.1
- `.ruby-version` file at the root (also 4.0.1) for compatibility with other tools (rbenv, rvm, etc.)

## Alternatives Considered

### Rails app in subdirectory
- **Considered**: Initially placed Rails app in `solidqueue_goodjob_benchmark/` subdirectory
- **Changed**: Moved to root for simplicity and to follow standard Rails conventions. The benchmark documentation in `context/` coexists with the Rails app files.

### Using `fly launch` to generate all config
- **Rejected**: Requires authentication and would create the Fly app, which we want users to do themselves. Instead, we generate the Dockerfile via Rails and create `fly.toml` manually based on Fly's documentation.

### Different port configuration
- **Considered**: Using port 3000 (Rails default) or 80 (Dockerfile EXPOSE)
- **Chosen**: Port 8080 (Fly.io's recommended default) for consistency with Fly.io best practices

### Using Buildpacks instead of Dockerfile
- **Rejected**: Rails 8's Dockerfile generation provides better control and is the recommended approach per Fly.io's Rails documentation

## Consequences

### Positive

- **Easy deployment**: Users can clone and deploy with minimal setup
- **Consistent environment**: Docker ensures the same Ruby/Rails versions across deployments
- **Standard structure**: Rails app at root follows typical Rails project conventions
- **Follows best practices**: Uses Fly.io's recommended Rails deployment patterns

### Negative

- **Additional complexity**: Adds Docker and Fly.io configuration files to maintain
- **Deployment dependency**: Requires Fly.io account and `flyctl` CLI for deployment (though not for local development)
- **Port configuration**: Need to ensure PORT environment variable matches `internal_port` in `fly.toml`

## Open Questions / Follow-ups

- Local Postgres uses Docker Compose; see `local-development-postgres-docker-compose.md`. If we add additional local dependencies (e.g., Redis), document them there or in a new local-dev decision.
- Should we configure Redis for future use? (Currently deferred - not needed for basic setup)
- Do we need to document alternative deployment targets (Heroku, Railway, etc.)? (Currently out of scope - Fly.io only)
