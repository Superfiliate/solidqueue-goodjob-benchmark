# Local Development Postgres Docker Compose Setup

## Context

This benchmark project requires PostgreSQL for local development. To make it easy for developers to run the application locally without requiring them to install and configure PostgreSQL directly on their machines, we need a simple, consistent way to provide a PostgreSQL database.

The project already uses Docker for production deployment (see [flyio-deployment-and-docker-strategy.md](flyio-deployment-and-docker-strategy.md)), so using Docker Compose for local development aligns with existing infrastructure and provides consistency.

Additionally, developers may have multiple Rails applications running locally, each potentially using PostgreSQL on the default port 5432. To avoid port conflicts, we should use custom ports for both Rails and PostgreSQL.

## Decision

### Docker Compose for PostgreSQL

We use Docker Compose to run PostgreSQL locally with:
- **PostgreSQL 17** (latest stable version)
- **Host port 31501** mapped to container port 5432
- Named volume for data persistence (`postgres_data`)
- Healthcheck to ensure the database is ready before use
- Default credentials: `postgres/postgres` (suitable for local development only)

### Custom Ports

To avoid conflicts with other applications:
- **Rails development server**: Port **31500**
- **PostgreSQL host port**: Port **31501**

These ports are intentionally adjacent (31500/31501) to make it obvious they belong together.

### Makefile Workflow

A `Makefile` provides simple commands for common development tasks:
- `make db-up` - Start PostgreSQL container
- `make db-down` - Stop PostgreSQL container
- `make db-nuke` - Stop and remove container + volume (destructive)
- `make db-logs` - View PostgreSQL logs
- `make psql` - Open psql shell in container
- `make setup` - Install dependencies and prepare database
- `make dev` - Start Rails development server

The Makefile sets environment variables (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `PORT`) to ensure Rails connects to the correct database and runs on the correct port.

### Database Configuration

The `config/database.yml` file uses environment variables for development and test environments:
- `DB_HOST` (default: `localhost`)
- `DB_PORT` (default: `31501`)
- `DB_USER` (default: `postgres`)
- `DB_PASSWORD` (default: `postgres`)

This allows developers to override these values if needed while providing sensible defaults that match the Docker Compose setup.

### Development Server Port

The Rails development server port is configured via:
- `config/puma.rb` uses `ENV.fetch("PORT", 3000)` (Rails default)
- `config/environments/development.rb` mailer URLs use `ENV.fetch("PORT", 31500)` to match the custom port
- The Makefile sets `PORT=31500` when running `make dev`

## Alternatives Considered

### Installing PostgreSQL directly on the host
- **Rejected**: Requires platform-specific installation steps, version management, and configuration. Docker Compose provides a consistent experience across platforms.

### Using default ports (3000/5432)
- **Rejected**: High likelihood of conflicts with other applications developers may be running.

### Using different port ranges
- **Considered**: Various port combinations were considered
- **Chosen**: 31500/31501 for Rails/Postgres provides clear visual relationship and avoids common port ranges

### Using DATABASE_URL environment variable only
- **Considered**: Rails supports DATABASE_URL which would override database.yml
- **Chosen**: Using individual environment variables (DB_HOST, DB_PORT, etc.) provides more flexibility and clearer configuration in database.yml while still allowing DATABASE_URL override if needed

### Using Foreman/Overmind for process management
- **Considered**: Could manage both Rails and PostgreSQL together
- **Rejected**: Docker Compose is better suited for managing containers, and separating database management from application process management provides clearer separation of concerns

## Consequences

### Positive

- **Easy setup**: Developers can start PostgreSQL with a single command (`make db-up`)
- **Consistent environment**: Docker ensures the same PostgreSQL version across all developers
- **No conflicts**: Custom ports prevent conflicts with other applications
- **Simple workflow**: Makefile provides intuitive commands for common tasks
- **Data persistence**: Named volume preserves database data between container restarts
- **Platform agnostic**: Works the same way on macOS, Linux, and Windows (with Docker Desktop)

### Negative

- **Docker dependency**: Requires Docker and Docker Compose to be installed
- **Additional complexity**: Adds docker-compose.yml and Makefile to the repository
- **Port awareness**: Developers need to remember the custom ports (31500/31501) instead of defaults
- **Volume management**: Developers need to use `make db-nuke` if they want to start fresh (though this is documented)

## Open Questions / Follow-ups

- Should we add Redis via Docker Compose if needed for future features? (Currently deferred - not needed yet)
- Should we document how to connect external tools (like pgAdmin) to the Docker Postgres? (Could be added to README if requested)
- Should we add a `make test` command that sets up the test database? (Currently handled by `bin/rails test` directly)
