.PHONY: db-up db-down db-nuke db-logs psql setup dev kill

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
	@timeout 30 bash -c 'until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do sleep 1; done' || (echo "PostgreSQL failed to start" && exit 1)
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

# Setup development environment (install dependencies and prepare database)
setup:
	@echo "Installing dependencies..."
	bundle install
	@echo "Preparing database..."
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) bin/rails db:prepare
	@echo "Setup complete!"

# Run Rails development server
dev:
	@echo "Starting Rails server on port $(RAILS_PORT)..."
	@DB_HOST=$(DB_HOST) DB_PORT=$(DB_PORT) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD) PORT=$(RAILS_PORT) bin/rails server

# Stop both PostgreSQL and Rails development server
kill:
	@echo "Stopping PostgreSQL..."
	@docker compose stop postgres 2>/dev/null || true
	@echo "Stopping Rails server..."
	@if [ -f tmp/pids/server.pid ]; then \
		kill `cat tmp/pids/server.pid` 2>/dev/null || true; \
		rm -f tmp/pids/server.pid; \
		echo "Rails server stopped (via PID file)"; \
	else \
		PID=$$(lsof -ti:$(RAILS_PORT) 2>/dev/null || true); \
		if [ -n "$$PID" ]; then \
			kill $$PID 2>/dev/null || true; \
			echo "Rails server stopped (via port $(RAILS_PORT))"; \
		else \
			echo "Rails server not running"; \
		fi; \
	fi
	@echo "All services stopped."
