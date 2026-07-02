# Moodle 5.2 Docker Stack

A Docker Compose stack for running **Moodle 5.2** with PostgreSQL 18, Redis 8.8, and pgAdmin.

> ✅ **Updated**: Project structure evolved with new configuration files, enhanced health checks, and improved tooling.

## 🚀 Quick Start

```bash
# 1. Navigate to compose directory
cd moodle-5.2/compose

# 2. Configure environment
# Copy template and edit with your values
cp .env.example .env
# Then edit .env with your database credentials and settings

# 3. Start all services for development
docker compose up -d

# Or use Make command
make up        # Start all services

# 4. Access Moodle
# Open http://127.0.0.1 in your browser
```

> 💡 **Tip**: Use `make help` to see all available commands

---

## 📋 Services

| Service | Default Port | Description | Profile |
|---------|--------------|-------------|---------|
| **Moodle** | `127.0.0.1:80` | Main Moodle application (Apache + PHP 8.5.3) |
| **PostgreSQL** | `127.0.0.1:5432` | Database server (v18.4) |
| **pgAdmin** | `127.0.0.1:8443` | Database management UI |
| **Redis** | `127.0.0.1:6379` | Caching layer (v8.8.0) |
| **RedisInsight** | `127.0.0.1:5540` | Redis management UI (v3.6) |

---

## 🔧 Configuration

### Environment Variables (`.env`)

See `.env.example` for the complete template with all available variables.

#### Moodle Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `MOODLE_LANG` | Moodle language | `fr` |
| `MOODLE_ROOT` | **Site URL** - Must be valid hostname | `127.0.0.1` |
| `MOODLE_DBTYPE` | Database type | `pgsql` |
| `MOODLE_DBHOST` | Database host (Docker service name) | `postgres` |
| `MOODLE_DBNAME` | Database name | `moodle` |
| `MOODLE_DBUSER` | Database user | `moodleadmin` |
| `MOODLE_DBPASS` | Database password | `change_me` |
| `MOODLE_ADMIN_USER` | Admin username | `admin` |
| `MOODLE_ADMIN_PASS` | Admin password | `change_me` |
| `MOODLE_ADMIN_EMAIL` | Admin email | `admin@example.com` |
| `MOODLE_SUPPORT_EMAIL` | Support email | `support@example.com` |
| `MOODLE_FULLNAME` | Site full name | `Moodle` |
| `MOODLE_SHORTNAME` | Site short name | `Moodle` |

#### Database Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_VERSION` | PostgreSQL version | `18.4` |
| `POSTGRES_USER` | PostgreSQL user | `moodleadmin` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `change_me` |
| `POSTGRES_DB` | PostgreSQL database name | `moodle` |
| `ALLOW_EMPTY_PASSWORD` | Allow empty password | `false` |
| `PGDATA` | PostgreSQL data directory | `/var/lib/postgresql/data/pgdata` |

#### Admin Tools Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `ADMIN_EMAIL` | pgAdmin default email | `admin@pgadmin.com` |
| `ADMIN_PASSWORD` | pgAdmin default password | `change_me` |

#### Cache Configuration
| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_VERSION` | Redis version | `8.8.0` |
| `REDISINSIGHT_VERSION` | RedisInsight version | `3.6` |
| `RI_APP_HOST` | RedisInsight bind address | `${WEB_ADRESS}` |

#### Network Configuration
| Variable | Description | Default | Bind Address |
|----------|-------------|---------|---------------|
| `WEB_ADRESS` | Global bind address for all services | `127.0.0.1` | - |

> ⚠️ **Important**: 
> - **Always set sensitive values** in `.env` before deployment (passwords, emails)
> - `MOODLE_ROOT` must be a hostname like `127.0.0.1`, `localhost`, or your domain
> - Variables referencing others (e.g., `MOODLE_DBNAME=${POSTGRES_DB}`) are resolved by Docker Compose
> - **Never commit `.env`** to version control (it's in `.gitignore`)

### Apache Configuration

- **`moodle_listener.conf`**: Handles Moodle sites served from sub-folders (e.g., `/var/www/html/moodle/public`)
- **`moodle_listeners.conf`**: Includes the listener config in the virtual host
- **DocumentRoot**: `/var/www/html/moodle/public` (Moodle web root)
- **Redis Configuration**: `redis.conf` for custom Redis settings

---

## 📁 Project Structure

```
compose/
├── .env                    # Environment variables (NOT in git)
├── .env.example            # Template for environment variables
├── .gitignore              # Git ignore rules
├── .dockerignore           # Docker build ignore rules
├── AGENTS.md               # Project instructions and coding standards
├── Makefile                # Common Docker commands
├── compose.yaml            # Docker Compose configuration (v3)
├── Moodle.Dockerfile       # Moodle container image (PHP 8.5.3)
├── entrypoint.sh           # Container entrypoint (install, cron, Apache)
├── moodle_listener.conf    # Apache rewrite rules for Moodle
├── moodle_listeners.conf   # Apache virtual host include
├── redis.conf              # Redis server configuration
├── moodle/                 # Moodle source code (NOT in git)
│   └── public/             # Moodle web root
├── moodle_postgres/        # PostgreSQL data (volume mount, NOT in git)
├── moodle_redisinsight/    # RedisInsight data (volume mount, NOT in git)
└── servers.json            # pgAdmin servers config (NOT in git)
```

> 📝 **Note**: 
> - `moodle/` directory is not tracked in git (see `.gitignore`)
> - Volume directories (`moodle_postgres/`, `moodle_redisinsight/`) are created at runtime
> - Moodle web root is `/var/www/html/moodle/public` inside the container

---

## ⚙️ Entrypoint Details

The `entrypoint.sh` script performs the following on container startup:

1. **Installs Moodle** (if `/data/moodledata/.installed` marker is missing):
   - Uses CLI installer with `.env` variables
   - Creates `config.php` with proper permissions (0640, root:www-data)
   - Sets up data directory at `/data/moodledata`

2. **Configures Cron**:
   - Runs `cron.php` every minute via www-data user
   - Runs `adhoc_task.php` every minute with keep-alive
   - Logs all output to `/var/log/moodle/cron.log`

3. **Starts Services**:
   - Launches cron daemon in background
   - Starts Apache in foreground mode (`exec "$@"`)

> 💡 **Key Paths**:
> - PHP CLI: `/usr/local/bin/php` (used in cron and Moodle CLI)
> - Moodle CLI: `/var/www/html/moodle/admin/cli/`
> - Install marker: `/data/moodledata/.installed`
> - Cron log: `/var/log/moodle/cron.log`

---

## 🔄 Development Workflow

### Using Docker Compose
```bash
# Rebuild Moodle container (after code changes)
docker compose build moodle

# Restart services
docker compose up -d

# View logs
docker compose logs -f moodle

# Run Moodle CLI commands
docker compose exec moodle /usr/local/bin/php /var/www/html/moodle/admin/cli/cron.php

# Access container shell
docker compose exec moodle bash
```

### Using Makefile (Recommended)
```bash
# Common commands
make help           # List all available commands
make up             # Start all services
make down           # Stop and remove containers
make rebuild        # Rebuild and restart containers
make restart        # Restart all services
make clean          # Stop containers and remove volumes
make ps             # List running containers

# Service-specific
make logs           # View all logs
make logs-moodle    # View Moodle logs only
make logs-postgres  # View PostgreSQL logs only
make shell          # Open shell in Moodle container
make db-shell       # Open PostgreSQL shell
make cron-run       # Manually run Moodle cron

# Database operations
make db-dump            # Dump database to backup_YYYYMMDD_HHMMSS.sql
make db-restore FILE=x  # Restore database from backup file
```

---

## 🛡️ Security

### 🔒 Security Best Practices
- **Never commit `.env`** to version control (it's in `.gitignore`)
- **Change all default passwords** in `.env` before production use
- Use HTTPS in production (add a reverse proxy like Nginx, Traefik, or Caddy)
- Consider using Docker secrets for sensitive data in production
- The Moodle admin password (`MOODLE_ADMIN_PASS`) should be strong and unique

### 🌐 Network Security
- **For production**: Use `--profile prod` to start Moodle only, excluding database and admin tool ports
- **For security**: All database ports (PostgreSQL, Redis) are bound to `127.0.0.1` by default
- All services use health checks to ensure proper startup sequencing
- PostgreSQL uses shared memory (`shm_size: 128mb`) for optimal performance

### 📋 Security Configuration
- `ALLOW_EMPTY_PASSWORD=false` by default
- All sensitive variables have `change_me` as default (must be overridden)
- Volume data is persisted outside containers for security

---

## 💾 Backup & Restore

### Backup Database
```bash
# Manual backup
docker compose exec postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > moodle_backup_$(date +%Y%m%d_%H%M%S).sql

# Or use Makefile (recommended)
make db-dump
# Creates backup_YYYYMMDD_HHMMSS.sql in current directory
```

### Restore Database
```bash
# Manual restore
cat moodle_backup.sql | docker compose exec -i postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Or use Makefile (recommended)
make db-restore FILE=moodle_backup.sql
# Restores from specified SQL file
```

### Volume Data Backup
```bash
# PostgreSQL data is stored in moodle_postgres/
# RedisInsight data is stored in moodle_redisinsight/
# These directories are on the host machine and persist between container restarts

# To backup all volumes:
tar -czvf moodle_volumes_backup_$(date +%Y%m%d).tar.gz moodle_postgres/ moodle_redisinsight/
```

> ⚠️ **Important**: 
> - Backups are saved to the host machine (outside containers)
> - Store backup files securely and encrypt sensitive data
> - Test restore procedures regularly

---

## 🐛 Troubleshooting

### Common Issues & Solutions
| Issue | Solution |
|-------|----------|
| **PostgreSQL connection fails** | Check `docker compose logs postgres` for startup errors |
| **Moodle install hangs** | Verify `MOODLE_DB*` and `POSTGRES_*` variables in `.env` match |
| **Apache won't start** | Check `docker compose logs moodle` for configuration errors |
| **Port already in use** | Run `docker compose down` then `docker compose up -d` |
| **Cron not running** | Check `/var/log/moodle/cron.log` inside the Moodle container |
| **Health checks failing** | Wait for dependencies to start (check service logs) |
| **Volume permission issues** | Ensure volume directories have proper permissions on host |

### Service Health Checks
All services include health checks:
- **Moodle**: HTTP check on port 80 (30s interval, 10s timeout, 3 retries)
- **PostgreSQL**: `pg_isready` check (5s interval, 5s timeout, 5 retries)
- **Redis**: `redis-cli ping` check (10s interval, 5s timeout, 3 retries)

### Common Commands
```bash
# Check container status and health
docker compose ps
make ps

# View resource usage
docker stats

# Inspect Moodle container
docker compose exec moodle bash
make shell

# Test database connection
docker compose exec postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
make db-shell

# View service logs
make logs        # All services
make logs-moodle # Moodle only
make logs-postgres # PostgreSQL only

# Check health check status
docker inspect --format='{{json .State.Health}}' $(docker ps -q)
```

### Debugging Tips
- Use `make shell` for interactive debugging in Moodle container
- Check `.env` file for typos in variable names
- Ensure all required volumes exist: `moodle_postgres/`, `moodle_redisinsight/`
- Verify port availability: `netstat -tlnp | grep -E '80|5432|6379|8443|5540'`

---

## 📚 Additional Resources

### Project Documentation
- **`AGENTS.md`**: Detailed project instructions, coding standards, and development guidelines
- **`Makefile`**: Complete list of available commands with `make help`
- **`.env.example`**: Environment variable template with all available options

### Moodle Resources
- **Moodle 5.2 Release Notes**: https://moodledev.io/general/releases/5.2
- **Moodle Official Documentation**: https://docs.moodle.org/
- **Moodle Developer Resources**: https://moodledev.io/

### Docker Resources
- **Official Moodle Docker**: https://github.com/moodlehq/moodle-docker (recommended for standard setups)
- **Docker Compose Documentation**: https://docs.docker.com/compose/

---

## 🎯 Project Evolution Summary

This README has been updated to reflect the evolved project structure:

✅ **New Files Added**:
- `AGENTS.md` - Project instructions and coding standards
- `redis.conf` - Redis server configuration

📁 **Directory Changes**:
- `postgres/` → `moodle_postgres/` (volume mount)
- `redisinsight/` → `moodle_redisinsight/` (volume mount)
- Moodle web root now in `moodle/public/`

🚀 **Enhanced Features**:
- Comprehensive health checks for all services
- Improved Makefile with 15+ commands
- Better organized environment variables
- Updated service versions (PostgreSQL 18.4, Redis 8.8.0, RedisInsight 3.6)
- Enhanced security defaults and documentation

🔧 **Improved Tooling**:
- Standardized development workflow
- Better troubleshooting guidance
- Complete backup and restore procedures
- Service-specific log viewing commands
