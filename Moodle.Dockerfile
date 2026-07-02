# Use the official PHP 8.5.3 Apache image as the base
FROM php:8.5.7-apache

# Set the working directory inside the container
WORKDIR /var/www/html/

# Copy Apache configuration files for Moodle
COPY ./moodle_listener.conf /etc/apache2/moodle_listener.conf
COPY ./moodle_listeners.conf /etc/apache2/sites-available/000-default.conf

# Install system dependencies required for Moodle and PHP extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      unzip \
      libzip-dev \
      libjpeg-dev \
      libpng-dev \
      libfreetype6-dev \
      libpq-dev \
      libicu-dev \
      libxml2-dev \
      libonig-dev \
      nano \
      cron && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) zip gd pgsql pdo_pgsql intl soap

    # Set PHP settings for Moodle: max_input_vars and OPcache
RUN echo "max_input_vars=5000" >> /usr/local/etc/php/conf.d/docker-php-moodle.ini && \
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.revalidate_freq=60" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \

    # Change post_max_size; upload_max_filesize ; max_execution_time
    echo "post_max_size=100M" >> /usr/local/etc/php/conf.d/docker-php-filsize.ini && \
    echo "upload_max_filesize=100M" >> /usr/local/etc/php/conf.d/docker-php-filsize.ini && \
    echo "max_execution_time=300" >> /usr/local/etc/php/conf.d/docker-php-filsize.ini

# PRODUCTION: Use the official Moodle release tarball for stability and security
# Clone Moodle 5.2 stable directly into the moodle directory
RUN mkdir -p /var/www/html/moodle && \
    git clone -b MOODLE_502_STABLE git://git.moodle.org/moodle.git /var/www/html/moodle

# Set permissions for the Moodle directory
RUN chown -R root:www-data /var/www/html/moodle/ && \
    chmod 0770 /var/www/html/moodle/

# Create Moodle data directory with proper permissions
# root owns the directory, www-data/Apache group has write access, good for maintenance
RUN mkdir -p /data/moodledata && \
    chown -R root:www-data /data/moodledata && \
    chmod -R 0770 /data/moodledata

# Create a symlink for the Moodle data directory
# RUN ln -s /var/www/html/moodle /var/www/html/moodle_public

# Configure Apache to use 'localhost' as ServerName
RUN echo ServerName localhost >> /etc/apache2/apache2.conf

# Remove any existing symlink to moodle_listeners.conf
RUN rm -f /etc/apache2/sites-enabled/moodle_listeners.conf

# Copy the custom Apache configuration
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/apache2-foreground"]

# Expose port 80 for HTTP traffic
EXPOSE 80