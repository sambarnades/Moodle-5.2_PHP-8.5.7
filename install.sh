#!/bin/bash

# Source the .env file to load environment variables
if [ -f .env ]; then
  source .env
fi

# Check if Moodle is already installed and install Moodle
if [ ! -f /var/moodledata/.installed ]; then
  php /var/www/html/moodle/admin/cli/install.php \
    --wwwroot=${MOODLE_WWWROOT:-http://127.0.0.1} \
    --lang=${MOODLE_LANG:-fr} \
    --dataroot=${MOODLE_DATAROOT:-/data/moodledata} \
    --dbtype=${MOODLE_DBTYPE:-pgsql} \
    --dbhost=${MOODLE_DBHOST:-postgres} \
    --dbname=${MOODLE_DBNAME:-moodle} \
    --dbuser=${MOODLE_DBUSER:-moodleadmin} \
    --dbpass=${MOODLE_DBPASS:-moodlepass} \
    --adminuser=${MOODLE_ADMIN_USER:-moodle} \
    --adminpass=${MOODLE_ADMIN_PASS:-moodlepass} \
    --agree-license \
    --supportemail=${MOODLE_SUPPORT_EMAIL:-admin@example.com} \
    --non-interactive \
    --fullname=${MOODLE_FULLNAME:-"FULLNAME"} \
    --shortname=${MOODLE_SHORTNAME:-"SHORTNAME"}

# Mark Moodle as installed
  touch /data/moodledata/.installed

# Display a message indicating successful installation
  echo "Moodle has been installed successfully."

# Set permissions for the config.php file. As the install process is done after Docker build, it is necessary to set the permissions again.
  chown root:www-data /var/www/html/moodle/config.php && \
  chmod 0640 /var/www/html/moodle/config.php
fi