# Moodle 5.2 Project Instructions

## 📚 Documentation & References
- **Moodle 5.2 Official Release Notes**: https://moodledev.io/general/releases/5.2
- **Moodle 5.2 Repository**: https://github.com/moodle/moodle/tree/MOODLE_502_STABLE
- **Official Docker Setup**: https://github.com/moodlehq/moodle-docker

## 🛠️ Environment
### Server Requirements (Moodle 5.2)
- **PHP**: 8.3.0+ minimum (PHP 8.4.x supported). Only 64-bit versions supported.
- **PHP Extension**: `sodium` is required
- **PHP Settings**: `max_input_vars` must be >= 5000
- **Web Server**: Apache/Nginx (via Docker recommended)

### Database Requirements
- **PostgreSQL**: 16+ (recommended for this project)
- **MySQL**: 8.4+
- **MariaDB**: 10.11.0+
- **Microsoft SQL Server**: 2019+
- **Aurora MySQL**: 8.0+ (MySQL compatibility version)
- **Oracle Database**: ❌ NOT SUPPORTED (since Moodle 5.0)

## ✅ Coding Standards
- Follow [Moodle Coding Style](https://moodledev.io/general/development/policies/codingstyle) (official)
- Defer to [PSR-12](https://www.php-fig.org/psr/psr-12/) and [PSR-1](https://www.php-fig.org/psr/psr-1/) where not specified
- 4-space indentation, **no tabs**
- All PHP files require PHPDoc blocks
- Use short array syntax (`[]`) for new code
- Namespaces **required** for all new classes
- Line length: aim for 132 characters, maximum 180
- Unix line endings (LF only), no trailing whitespace
- Use `moodle-php-lint` for validation
- Strings must be internationalized via `get_string()`

## 🚫 Constraints
- Never modify `vendor/` directory
- Do not edit core Moodle files unless patching a verified bug
- Prefix custom database tables with `local_` or plugin name
- Always use `$CFG->` for configuration access
- File permissions: 0644 for files, 0755 for directories
- Only 64-bit PHP versions supported

## 🧪 Testing
- **PHPUnit**: `php vendor/bin/phpunit`
- **Behat**: `php vendor/bin/behat`
- **PHP lint**: `php vendor/bin/moodle-php-lint`
- **Code checker**: `php vendor/bin/moodle-check`

## 📁 File Structure
- Plugins: `/moodle/local/` or `/moodle/[plugintype]/`
- Theme customizations: `/moodle/theme/`
- Configuration: `/moodle/config.php`
- Docker files: `/compose/`
- This project uses: PostgreSQL (configured in compose.yaml)
- **New files in `/compose/`**:
  - `Makefile` - Common Docker commands
  - `.env.example` - Environment template
  - `.dockerignore` - Docker build exclusions
  - `.gitignore` - Git exclusions (includes moodle/)

## 🐳 Docker Commands
### Official Moodle Docker (Recommended)
```bash
git clone https://github.com/moodlehq/moodle-docker.git
cd moodle-docker
export MOODLE_DOCKER_WWWROOT=./moodle
export MOODLE_DOCKER_DB=pgsql
bin/moodle-docker-compose up -d
```

### Project-Specific Commands
- **Start**: `make up` or `docker compose up -d`
- **Stop**: `make down` or `docker compose down`
- **Stop + remove volumes**: `make clean` or `docker compose down -v`
- **Rebuild**: `make rebuild` or `docker compose up -d --build`
- **Logs**: `make logs` or `docker compose logs -f`
- **Logs (Moodle only)**: `make logs-moodle`
- **Logs (PostgreSQL only)**: `make logs-postgres`
- **Shell access**: `make shell`
- **Database dump**: `make db-dump`
- **Database restore**: `make db-restore FILE=backup.sql`
- **Cron manual**: `make cron-run`
- **List all commands**: `make help`

## 🔧 Installation
- **Official**: Use [moodle-docker](https://github.com/moodlehq/moodle-docker) for standard setup
- **Project-specific**: Uses `/compose/entrypoint.sh` for automated setup (PostgreSQL + Redis)
- `config.php` is generated during installation
- Data directory: `/moodledata/` (mounted volume)
- **Note**: `moodle/` folder not tracked in git (see `.gitignore`)

## 💡 Project Notes
- This project uses **PostgreSQL 18** (configured in compose.yaml)
- Redis is included for caching/session storage
- pgAdmin available at port 8081 for database management
- RedisInsight available at port 5540 for Redis management

---

## 🚀 Project Improvements

### Healthchecks
- **Moodle**: HTTP check on port 80 (30s interval, 10s timeout, 3 retries, 60s start period)
- **PostgreSQL**: `pg_isready` check (5s interval, 5s timeout, 5 retries)
- **Redis**: `redis-cli ping` check (10s interval, 5s timeout, 3 retries)

### Security
- `.env` in `.gitignore` (never commit credentials)
- `moodle/` in `.gitignore` (downloaded in Dockerfile for production)
- Sensitive defaults removed from README.md

### Development Tools
- **Makefile**: Standardized commands for consistency
- **backup/restore**: Automated via `make db-dump` / `make db-restore`
- **.env.example**: Template for new contributors
