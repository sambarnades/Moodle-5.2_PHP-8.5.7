# Moodle 5.2 / PHP 8.5.3 Docker Stack

A Docker Compose stack for running **Moodle 5.2** with PostgreSQL, Redis, and pgAdmin.

## 🚀 Quick Start

```bash
# 1. Clone & enter directory
cd moodle-5.2/compose

# 2. Configure environment
# Copy template and edit with your values
cp .env.example .env
# Then edit .env with your database credentials and settings

# 3. Start all services for development (all tools exposed)
docker compose --profile dev up -d

# Or start production mode (Moodle only, databases internal)
docker compose --profile prod up -d

# 4. Access Moodle
# Open http://localhost or http://127.0.0.1 in your browser
```

> 💡 **Tip**: Use `make help` to see all available commands

---

## 📋 Services

| Service | Default Port | Description | Profile |
|---------|--------------|-------------|---------|
| **Moodle** | `0.0.0.0:80` | Main Moodle application (Apache + PHP) | web, dev, prod |
| **PostgreSQL** | `127.0.0.1:5432` | Database server | db, dev, full |
| **pgAdmin** | `127.0.0.1:8081` | Database management UI | db, dev, full |
| **Redis** | `127.0.0.1:6379` | Caching layer | cache, dev, full |
| **RedisInsight** | `127.0.0.1:5540` | Redis management UI | cache, dev, full |

---

## 🔧 Configuration

### Environment Variables (`.env`)

| Variable | Description | Default |
|----------|-------------|---------|
| `MOODLE_LANG` | Moodle language | `fr` |
| `MOODLE_ROOT` | **Site URL** - Must be valid hostname, NOT 0.0.0.0 | `127.0.0.1` |
| `MOODLE_DBTYPE` | Database type | `pgsql` |
| `MOODLE_DBHOST` | Database host (Docker service name) | `postgres` |
| `MOODLE_DBNAME` | Database name | `moodle` |
| `MOODLE_DBUSER` | Database user | `moodleadmin` |
| `MOODLE_DBPASS` | Database password | - |
| `MOODLE_ADMIN_USER` | Admin username | `admin` |
| `MOODLE_ADMIN_PASS` | Admin password | - |
| `MOODLE_ADMIN_EMAIL` | Admin email | `admin@moodle.com` |
| `MOODLE_SUPPORT_EMAIL` | Support email | `support@moodle.com` |
| `MOODLE_FULLNAME` | Site full name | `Moodle` |
| `MOODLE_SHORTNAME` | Site short name | `Moodle` |

### Port Configuration
| Variable | Description | Default | Bind Address |
|----------|-------------|---------|---------------|
| `MOODLE_HOST` | Moodle bind address | `0.0.0.0` | All interfaces |
| `MOODLE_PORT` | Moodle port | `80` | - |
| `POSTGRES_HOST` | PostgreSQL bind address | `127.0.0.1` | Localhost only |
| `POSTGRES_PORT` | PostgreSQL port | `5432` | - |
| `PGADMIN_HOST` | pgAdmin bind address | `127.0.0.1` | Localhost only |
| `PGADMIN_PORT` | pgAdmin port | `8081` | - |
| `REDIS_HOST` | Redis bind address | `127.0.0.1` | Localhost only |
| `REDIS_PORT` | Redis port | `6379` | - |
| `REDISINSIGHT_HOST` | RedisInsight bind address | `127.0.0.1` | Localhost only |
| `REDISINSIGHT_PORT` | RedisInsight port | `5540` | - |

> ⚠️ **Note**: Variables referencing others (e.g., `MOODLE_DBNAME=${POSTGRES_DB}`) are resolved by Docker Compose. **Always set sensitive values in `.env` before deployment.**
> 
> 💡 **Important**: `MOODLE_ROOT` must be a URL like `127.0.0.1`, `localhost`, or `yourdomain.com` - **never `0.0.0.0`** (which is a bind address, not a URL).

> ⚠️ **Note**: Variables referencing others (e.g., `MOODLE_DBNAME=${POSTGRES_DB}`) are resolved by Docker Compose. **Always set sensitive values in `.env` before deployment.**

### Apache Configuration

- **`moodle_listener.conf`**: Handles Moodle sites served from sub-folders (e.g., `/moodle/public`)
- **`moodle_listeners.conf`**: Includes the listener config in the virtual host
- **DocumentRoot**: `/var/www/html/moodle/public` (update if needed)

---

## 📁 Project Structure

```
compose/
├── .env                    # Environment variables (NOT in git)
├── .env.example            # Template for environment variables
├── .gitignore              # Git ignore rules
├── .dockerignore           # Docker build ignore rules
├── Makefile                # Common Docker commands
├── compose.yaml            # Docker Compose configuration
├── Moodle.Dockerfile       # Moodle container image
├── entrypoint.sh           # Container entrypoint (installs Moodle, starts Apache, sets up cron)
├── moodle_listener.conf    # Apache rewrite rules for Moodle
├── moodle_listeners.conf   # Apache virtual host include
├── moodle/                 # Moodle source code
├── postgres/               # PostgreSQL data (volume mount, NOT in git)
├── redis/                  # Redis data (volume mount, NOT in git)
├── redisinsight/           # RedisInsight data (volume mount, NOT in git)
└── servers.json            # pgAdmin servers config (NOT in git)
```

---

## ⚙️ Entrypoint Details

The `entrypoint.sh` script:

1. **Installs Moodle** (if `/data/moodledata/.installed` marker is missing):
   - Uses CLI installer with `.env` variables
   - Creates `config.php` with proper permissions

2. **Configures Cron**:
   - Runs `cron.php` and `adhoc_task.php` every minute
   - Logs to `/var/log/moodle/cron.log`

3. **Starts Apache** in foreground mode (`exec "$@"`)

> 💡 PHP path for CLI tasks: **`/usr/local/bin/php`** (used in cron and Moodle CLI)

---

## 🔄 Development Workflow

```bash
# Rebuild Moodle container (after code changes)
docker compose build moodle

# Restart services
docker compose up -d

# View logs
docker compose logs -f moodle

# Run Moodle CLI commands
docker compose exec moodle /usr/local/bin/php /var/www/html/moodle/admin/cli/cron.php
```

---

## 🛡️ Security

- **Never commit `.env`** to version control (it's in `.gitignore`)
- **Change all default passwords** in `.env` before production use
- Use HTTPS in production (add a reverse proxy like Nginx, Traefik, or Caddy)
- Consider using Docker secrets for sensitive data in production
- The Moodle admin password (`MOODLE_ADMIN_PASS`) should be strong and unique
- **For production**: Use `--profile prod` to avoid exposing database and admin tool ports
- **For security**: Database ports (PostgreSQL, Redis) are bound to `127.0.0.1` by default

---

## 💾 Backup & Restore

### Backup Database
```bash
# Manual backup
docker compose exec postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > moodle_backup_$(date +%Y%m%d_%H%M%S).sql

# Or use Makefile
make db-dump
```

### Restore Database
```bash
# Manual restore
cat moodle_backup.sql | docker compose exec -i postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Or use Makefile
make db-restore FILE=moodle_backup.sql
```

> ⚠️ **Note**: Backups are saved to the host machine (outside containers). Store them securely.

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| **PostgreSQL connection fails** | Check `docker compose logs postgres` |
| **Moodle install hangs** | Verify `MOODLE_DB*` variables in `.env` are correct |
| **Apache won't start** | Check `docker compose logs moodle` for errors |
| **Port already in use** | Run `docker compose down` then `docker compose up -d` |
| **Cron not running** | Check `/var/log/moodle/cron.log` inside the Moodle container |

### Common Commands
```bash
# Check container status
docker compose ps

# View resource usage
docker stats

# Inspect Moodle container
docker compose exec moodle bash

# Test database connection
docker compose exec postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```
