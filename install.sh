#!/bin/bash

# This script installs Moodle using plain variables for easy copy-paste from docker compose exec commands
# Check if Moodle is already installed and install Moodle
if [ ! -f /var/moodledata/.installed ]; then
  php /var/www/html/moodle/admin/cli/install.php \
    --wwwroot=http://127.0.0.1 \
    --lang=fr \
    --dataroot=/data/moodledata \
    --dbtype=pgsql \
    --dbhost=postgres \
    --dbname=moodle \
    --dbuser=moodleadmin \
    --dbpass=moodlepass \
    --adminuser=moodle \
    --adminpass=moodlepass \
    --agree-license \
    --supportemail=admin@example.com \
    --non-interactive \
    --fullname="FULLNAME" \
    --shortname="SHORTNAME"

# Mark Moodle as installed
  touch /data/moodledata/.installed

# Display a message indicating successful installation
  echo "Moodle has been installed successfully."

# Set permissions for the config.php file. As the install process is done after Docker build, it is necessary to set the permissions again.
  chown root:www-data /var/www/html/moodle/config.php && \
  chmod 0640 /var/www/html/moodle/config.php
fi