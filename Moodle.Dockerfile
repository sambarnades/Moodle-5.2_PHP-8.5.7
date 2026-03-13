# Use the official PHP 8.5.3 Apache image as the base
FROM php:8.5.3-apache

# Set the working directory inside the container
WORKDIR /var/www/public_html/

# Copy Apache configuration files for Moodle
# COPY ./moodle_listener.conf /etc/apache2/moodle_listener.conf
# COPY ./moodle_listeners.conf /etc/apache2/sites-available/000-default.conf

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
      libonig-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) zip gd pgsql pdo_pgsql intl soap

<<<<<<< HEAD:Moodle.Dockerfile
    # Set PHP settings for Moodle: max_input_vars and OPcache
RUN echo "max_input_vars=5000" >> /usr/local/etc/php/conf.d/docker-php-moodle.ini && \
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.revalidate_freq=60" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini

=======
>>>>>>> parent of 62b25d2 (- Need to find why the RUN echo in Moodle doesn't write opcache &  moodle .ini):Moodle
# Clone Moodle 5.1 stable branch and set up directory structure
RUN mkdir /var/www/moodle && \
    cd /var/www/moodle && \
    git clone -b MOODLE_501_STABLE git://git.moodle.org/moodle.git . && \
    chown -R root /var/www/moodle/ && \
    chmod -R 0755 /var/www/moodle/ && \
    cp -r /var/www/moodle/public /var/www/public_html/

# Create Moodle data directory with proper permissions
RUN mkdir -p /var/moodledata && \
    chmod -R 0750 /var/moodledata

# Create a symlink for the Moodle data directory
RUN ln -s /var/www/moodle /var/www/public_html/moodle_public

# Configure Apache to use 'localhost' as ServerName
RUN echo ServerName localhost >> /etc/apache2/apache2.conf

# Remove any existing symlink to moodle_listeners.conf
RUN rm -f /etc/apache2/sites-enabled/moodle_listeners.conf

# Command to run Apache in foreground mode
CMD ["apache2ctl", "-D", "FOREGROUND"]

# Expose port 80 for HTTP traffic
EXPOSE 80