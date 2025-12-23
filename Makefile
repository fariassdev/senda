# ============================================================================
# SENDA - Full Stack Development Makefile
# ============================================================================
# This Makefile orchestrates all services: CMS, API, Database, and TTS
# For project-specific commands, see individual service Makefiles:
#   - senda-api/Makefile  -> API-specific commands (tests, migrations, linting)
# ============================================================================

# ============================================================================
# DOCKER COMPOSE - Full Stack Commands
# ============================================================================

# Start all services (build if necessary)
up:
	@echo "Starting all Senda services..."
	docker compose up -d

# Start all services with build
up-build:
	@echo "Building and starting all Senda services..."
	docker compose up -d --build

# Stop all services
down:
	@echo "Stopping all Senda services..."
	docker compose down

# Stop all services and remove volumes (DESTRUCTIVE)
down-v:
	@echo "Stopping all services and removing volumes..."
	docker compose down -v

# Restart all services
restart:
	@echo "Restarting all Senda services..."
	docker compose stop
	docker compose up -d

# Rebuild and restart all services
rebuild:
	@echo "Rebuilding and restarting all Senda services..."
	docker compose down
	docker compose up -d --build

# View logs for all services
logs:
	docker compose logs --tail=100 -f

# View logs for a specific service (usage: make logs-api, logs-cms, logs-postgres, logs-kokoro)
logs-api:
	docker compose logs --tail=100 -f api

logs-cms:
	docker compose logs --tail=100 -f cms

logs-postgres:
	docker compose logs --tail=100 -f postgres

logs-kokoro:
	docker compose logs --tail=100 -f kokoro_tts

# Check status of all services
ps:
	docker compose ps

# ============================================================================
# DATABASE Commands
# ============================================================================

# Initialize database (create DBs if not exist)
db-init:
	@echo "Initializing database..."
	docker compose up -d postgres
	@echo "Waiting for Postgres readiness..."
	docker compose exec -T postgres bash -lc 'until pg_isready -U "$$POSTGRES_USER"; do sleep 1; done'
	@echo "Creating databases if missing..."
	docker compose exec -T postgres bash -lc '/docker-entrypoint-initdb.d/create_databases.sh'

# Run migrations (requires API to have access to DB)
migrate:
	@echo "Running database migrations..."
	cd senda-api && "$(MAKE)" migrate

# Seed database with initial data (only if database is empty)
db-seed:
	@echo "Seeding database..."
	$(MAKE) db-init
	$(MAKE) migrate
	docker compose up -d postgres
	@echo "Waiting for Postgres readiness..."
	docker compose exec -T postgres bash -lc 'until pg_isready -U "$$POSTGRES_USER"; do sleep 1; done'
	@echo "Checking if database already has data..."
	@docker compose exec -T postgres bash -lc '\
		COUNT=$$(psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -tAc "SELECT COUNT(*) FROM public.\"user\";"); \
		if [ "$$COUNT" -gt 0 ]; then \
			echo "Database already contains $$COUNT users. Skipping seed."; \
			exit 0; \
		else \
			echo "Database is empty. Running seed..."; \
			psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -f /docker-entrypoint-initdb.d/seed_db.sql; \
			echo "Seed completed successfully."; \
		fi'

# Connect to PostgreSQL shell
db-shell:
	docker compose exec postgres psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"

# ============================================================================
# INDIVIDUAL SERVICE Commands
# ============================================================================

# Build only API
build-api:
	docker compose build api

# Build only CMS
build-cms:
	docker compose build cms

# Restart only API
restart-api:
	docker compose restart api

# Restart only CMS
restart-cms:
	docker compose restart cms

# Shell into API container
shell-api:
	docker compose exec api /bin/bash

# Shell into CMS container
shell-cms:
	docker compose exec cms /bin/sh

# ============================================================================
# DEVELOPMENT SHORTCUTS
# ============================================================================

# Full setup: start everything and initialize DB
setup:
	@echo "Setting up Senda full stack development environment..."
	@echo "1. Starting all services..."
	$(MAKE) up-build
	@echo ""
	@echo "Senda full stack setup complete!"
	@echo "   - CMS:      http://localhost:3000"
	@echo "   - API:      http://localhost:8081"
	@echo "   - Postgres: localhost:5439"
	@echo "   - Kokoro:   http://localhost:8880"

# Quick status check
status:
	@echo "Senda Services Status:"
	@docker compose ps

# Clean up everything (DESTRUCTIVE)
clean:
	@echo "Cleaning up all containers, images, and volumes..."
	docker compose down -v --rmi local

# ============================================================================
# HELP
# ============================================================================

help:
	@echo ""
	@echo "Senda Full Stack Development Commands"
	@echo "======================================"
	@echo ""
	@echo "Docker Compose:"
	@echo "  up              - Start all services"
	@echo "  up-build        - Build and start all services"
	@echo "  down            - Stop all services"
	@echo "  down-v          - Stop and remove volumes (DESTRUCTIVE)"
	@echo "  restart         - Restart all services"
	@echo "  rebuild         - Rebuild and restart all services"
	@echo "  ps              - Show container status"
	@echo ""
	@echo "Logs:"
	@echo "  logs            - View all logs"
	@echo "  logs-api        - View API logs"
	@echo "  logs-cms        - View CMS logs"
	@echo "  logs-postgres   - View Postgres logs"
	@echo "  logs-kokoro     - View Kokoro TTS logs"
	@echo ""
	@echo "Database:"
	@echo "  db-init         - Initialize databases"
	@echo "  db-seed         - Seed database with sample data"
	@echo "  db-shell        - Connect to PostgreSQL shell"
	@echo "  migrate         - Run API migrations"
	@echo ""
	@echo "Individual Services:"
	@echo "  build-api       - Build API image"
	@echo "  build-cms       - Build CMS image"
	@echo "  restart-api     - Restart API service"
	@echo "  restart-cms     - Restart CMS service"
	@echo "  shell-api       - Shell into API container"
	@echo "  shell-cms       - Shell into CMS container"
	@echo ""
	@echo "Development:"
	@echo "  setup           - Full setup (build + db init + migrate)"
	@echo "  status          - Quick status check"
	@echo "  clean           - Remove all containers/volumes (DESTRUCTIVE)"
	@echo ""
	@echo "For API-specific commands (tests, linting), see:"
	@echo "  cd senda-api && make help"
	@echo ""

.PHONY: up up-build down down-v restart rebuild logs logs-api logs-cms logs-postgres logs-kokoro ps \
	db-init db-seed db-shell migrate \
	build-api build-cms restart-api restart-cms shell-api shell-cms \
	setup status clean help
