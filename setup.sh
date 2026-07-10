#!/bin/bash
set -e

# Set permissions for the Moodle directory
chown -R root:www-data /var/www/html/moodle/ && \
chmod 0770 /var/www/html/moodle/

# Create Moodle data directory with proper permissions
# root owns the directory, www-data/Apache group has write access, good for maintenance
mkdir -p /data/moodledata && \
chown -R root:www-data /data/moodledata && \
chmod -R 0770 /data/moodledata

# Configure Apache to use 'localhost' as ServerName
echo ServerName localhost >> /etc/apache2/apache2.conf

# Remove any existing symlink to moodle_listeners.conf
rm -f /etc/apache2/sites-enabled/moodle_listeners.conf

# Entrypoint script for Moodle container

echo "Installing Moodle..."

php /var/www/html/moodle/admin/cli/install.php \
  --wwwroot="http://${MOODLE_ROOT:-127.0.0.1}" \
  --lang="${MOODLE_LANG:-fr}" \
  --dataroot="/data/moodledata" \
  --dbtype="${MOODLE_DBTYPE:-pgsql}" \
  --dbhost="${MOODLE_DBHOST:-postgres}" \
  --dbname="${MOODLE_DBNAME:-moodle}" \
  --dbuser="${MOODLE_DBUSER:-moodleadmin}" \
  --dbpass="${MOODLE_DBPASS:-moodlepass}" \
  --adminuser="${MOODLE_ADMIN_USER:-moodle}" \
  --adminpass="${MOODLE_ADMIN_PASS:-moodlepass}" \
  --adminemail="${MOODLE_ADMIN_EMAIL:-admin@moodle.com}" \
  --supportemail="${MOODLE_SUPPORT_EMAIL:-support@moodle.com}" \
  --agree-license \
  --non-interactive \
  --fullname="${MOODLE_FULLNAME:-Moodle}" \
  --shortname="${MOODLE_SHORTNAME:-Moodle}"

  # Set proper permissions for config.php
  chown root:www-data /var/www/html/moodle/config.php && \
  chmod 0640 /var/www/html/moodle/config.php

  echo "Moodle installed successfully!"

  # --------------- CRON & CRON-LOGS ---------------
  mkdir -p /var/log/moodle
  touch /var/log/moodle/cron.log
  chown www-data:www-data /var/log/moodle/cron.log

  # Write once (overwrite) to /etc/cron.d/moodle - cron.php + adhoc_task.php
  cat > /etc/cron.d/moodle << 'EOF'
* * * * * www-data /usr/local/bin/php /var/www/html/moodle/admin/cli/cron.php >> /var/log/moodle/cron.log 2>&1
* * * * * www-data /usr/local/bin/php /var/www/html/moodle/admin/cli/cron.php >> /var/log/moodle/cron.log 2>&1
* * * * * www-data /usr/local/bin/php /var/www/html/moodle/admin/cli/cron.php >> /var/log/moodle/cron.log 2>&1
* * * * * www-data /usr/local/bin/php /var/www/html/moodle/admin/cli/adhoc_task.php --execute --keep-alive=59 >> /var/log/moodle/cron.log 2>&1
* * * * * www-data /usr/local/bin/php /var/www/html/moodle/admin/cli/adhoc_task.php --execute --keep-alive=59 >> /var/log/moodle/cron.log 2>&1
* * * * * www-data /usr/local/bin/php /var/www/html/moodle/admin/cli/adhoc_task.php --execute --keep-alive=59 >> /var/log/moodle/cron.log 2>&1

EOF


# Start cron in the background
cron &

# Start Apache in foreground
exec "$@"