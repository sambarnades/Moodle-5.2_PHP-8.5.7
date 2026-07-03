# Moodle 5.2 Docker Compose Makefile
# Usage: make <target>

.PHONY: help up up-dev up-prod up-full up-web up-db up-cache down rebuild logs shell db-shell db-dump db-restore clean ps

# Default target
help:
	@echo "Moodle 5.2 Docker Compose Commands"
	@echo "==================================="
	@echo ""
	@echo "Available targets:"
	@echo "  up              - Start all services (default: dev profile)"
	@echo "  down            - Stop and remove containers"
	@echo "  rebuild         - Rebuild and restart containers"
	@echo "  rebuild-dev     - Rebuild and restart (dev profile)"
	@echo "  rebuild-prod    - Rebuild and restart (prod profile)"
	@echo "  restart         - Restart all services"
	@echo "  logs            - View logs for all services"
	@echo "  logs-moodle     - View Moodle logs only"
	@echo "  logs-postgres   - View PostgreSQL logs only"
	@echo "  shell           - Open shell in Moodle container"
	@echo "  db-shell        - Open PostgreSQL shell"
	@echo "  db-dump         - Dump database to backup.sql"
	@echo "  db-restore      - Restore database from backup.sql"
	@echo "  clean           - Stop containers and remove volumes"
	@echo "  ps              - List running containers"
	@echo "  cron-run        - Manually run Moodle cron"
	@echo ""

# Start services (default: dev profile)
up:
	docker compose up -d

# Stop services
stop:

	docker compose stop

# Stop & Remove services
down:
	docker compose down

# Rebuild and restart
rebuild:
	docker compose up -d --build

# Restart services
restart:
	docker compose restart

# View all logs
logs:
	docker compose logs -f

# View Moodle logs
logs-moodle:
	docker compose logs -f moodle

# View PostgreSQL logs
logs-postgres:
	docker compose logs -f postgres

# Open shell in Moodle container
shell:
	docker compose exec moodle bash

# Open PostgreSQL shell
db-shell:
	docker compose exec postgres psql -U $$(grep POSTGRES_USER .env | cut -d= -f2) -d $$(grep POSTGRES_DB .env | cut -d= -f2)

# Dump database
db-dump:
	docker compose exec postgres pg_dump -U $$(grep POSTGRES_USER .env | cut -d= -f2) $$(grep POSTGRES_DB .env | cut -d= -f2) > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "Database dumped to backup_$(date +%Y%m%d_%H%M%S).sql"

# Restore database (usage: make db-restore FILE=backup.sql)
db-restore:
	@if [ -z "$$(FILE)" ]; then \
		echo "Error: Please specify backup file with FILE=backup.sql"; \
		exit 1; \
	fi
	cat $$(FILE) | docker compose exec -i postgres psql -U $$(grep POSTGRES_USER .env | cut -d= -f2) -d $$(grep POSTGRES_DB .env | cut -d= -f2)
	@echo "Database restored from $$(FILE)"

# Clean everything (containers + volumes)
clean:
	docker compose down -v

# List containers
ps:
	docker compose ps

# Run Moodle cron manually
cron-run:
	docker compose exec moodle /usr/local/bin/php /var/www/html/moodle/admin/cli/cron.php
