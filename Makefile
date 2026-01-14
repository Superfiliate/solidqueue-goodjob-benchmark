.PHONY: db-up db-down db-nuke db-logs psql setup bootstrap dev dev-web dev-solidqueue dev-goodjob dev-stop kill

# Default ports
RAILS_PORT ?= 31500
DB_PORT ?= 31501
DB_HOST ?= localhost
DB_USER ?= postgres
DB_PASSWORD ?= postgres

# Database connection URL for development
DATABASE_URL = postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/solidqueue_goodjob_benchmark_development

# Start PostgreSQL container
db-up:
	@echo "Starting PostgreSQL on port $(DB_PORT)..."
	docker compose up -d postgres
	@echo "Waiting for PostgreSQL to be ready..."
	@ruby -rtimeout -e 'Timeout.timeout(60) do; loop do; exit 0 if system("docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1"); sleep 1; end; end' || (echo "PostgreSQL failed to start" && docker compose ps postgres && docker compose logs --tail=200 postgres && exit 1)
	@echo "PostgreSQL is ready!"

# Stop PostgreSQL container
db-down:
	@echo "Stopping PostgreSQL..."
	docker compose stop postgres

# Stop and remove PostgreSQL container and volume (destructive)
db-nuke:
	@echo "Stopping and removing PostgreSQL container and volume..."
	docker compose down -v postgres
	@echo "PostgreSQL container and volume removed."

# View PostgreSQL logs
db-logs:
	docker compose logs -f postgres

# Open psql shell in PostgreSQL container
psql:
	docker compose exec postgres psql -U postgres -d solidqueue_goodjob_benchmark_development

# Bootstrap development tools (macOS/Homebrew)
bootstrap:
	@echo "Checking for Homebrew..."
	@command -v brew >/dev/null 2>&1 || { \
		echo "Error: Homebrew is not installed."; \
		echo "Please install Homebrew first: https://brew.sh/"; \
		exit 1; \
	}
	@echo "Installing development tools (flyctl, overmind, tmux)..."
	@brew install flyctl overmind tmux
	@echo "Bootstrap complete! Tools installed: flyctl, overmind, tmux"

# Setup development environment (install dependencies and prepare database)
setup:
	@echo "Installing dependencies..."
	bundle install
	@echo "Preparing database..."
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) bin/rails db:prepare
	@echo "Setup complete!"

# Run all development processes (web, solidqueue, goodjob) via Overmind
dev: dev-stop
	@echo "Ensuring PostgreSQL is running..."
	@docker compose ps postgres | grep -q "Up" || make db-up
	@echo "Preparing databases (primary + queue)..."
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) bin/rails db:prepare
	@echo "Starting all development processes (web, solidqueue, goodjob) via Overmind..."
	@command -v overmind >/dev/null 2>&1 || { \
		echo "Error: Overmind is not installed. Run 'make bootstrap' first."; \
		exit 1; \
	}
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) PORT=$(RAILS_PORT) overmind start -f Procfile.dev

# Run Rails development server only
dev-web:
	@echo "Starting Rails server on port $(RAILS_PORT)..."
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) PORT=$(RAILS_PORT) bin/rails server

# Run SolidQueue worker only
dev-solidqueue:
	@echo "Starting SolidQueue worker..."
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) bin/jobs start --mode=async

# Run GoodJob worker only
dev-goodjob:
	@echo "Starting GoodJob worker..."
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) bundle exec good_job start

# Stop all development processes (Overmind and any stray processes)
dev-stop:
	@echo "Stopping all development processes..."
	@# If Overmind is running, stop it. If not, clean up stale socket files so `make dev` recovers.
	@if [ -S .overmind.sock ] || [ -f .overmind.sock ]; then \
		overmind status >/dev/null 2>&1 && overmind stop || true; \
		rm -f .overmind.sock; \
	fi
	@# Some Overmind setups may leave PID files around; remove them if present.
	@rm -f .overmind.pid .overmind.port 2>/dev/null || true
	@echo "Killing any processes on port $(RAILS_PORT)..."
	@PID=$$(lsof -ti:$(RAILS_PORT) 2>/dev/null || true); \
	if [ -n "$$PID" ]; then \
		kill $$PID 2>/dev/null || true; \
		echo "Killed process on port $(RAILS_PORT)"; \
	fi
	@if [ -f tmp/pids/server.pid ]; then \
		kill `cat tmp/pids/server.pid` 2>/dev/null || true; \
		rm -f tmp/pids/server.pid; \
		echo "Removed stale PID file"; \
	fi
	@echo "All development processes stopped."

# Stop both PostgreSQL and development processes
kill: dev-stop
	@echo "Stopping PostgreSQL..."
	@docker compose stop postgres 2>/dev/null || true
	@echo "All services stopped."
