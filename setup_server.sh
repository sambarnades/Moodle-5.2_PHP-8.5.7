# Update & install dependencies

apt-get update
apt-get install -y libfreetype-dev libjpeg62-turbo-dev libpng-dev git curl libicu-dev libzip-dev libpq-dev
apt-get clean

# Install php extensions

docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install gd intl zip pgsql opcache
# ------------------------ Already installed by default ------------------------
# dom ctype json mbstring pcre simplexml spl xml openssl sodium tokenizer
# ------------------------------------------------------------------------------

# Create moodledata directory

mkdir ./moodledata
chmod 0777 ./moodledata

# Download Moodle 5.1
# -------------------- Prod only --------------------------
# git clone git://git.moodle.org/moodle.git
# ---------------------------------------------------------

# Give permissions to moodle directory

chown -R root ./moodle
chmod -R 0755 ./moodle

# Checkout the 5.1 stable branch

 cd moodle
 git branch --track MOODLE_501_STABLE origin/MOODLE_501_STABLE
 git checkout MOODLE_501_STABLE

# Set the correct permissions for all files in the moodle directory
# This ensures that the web server can read all the files, but
# prevents it from modifying them. This is a security best practice.
find . -type f -exec chmod 0644 {} \;


# Set the correct permissions for all directories in the moodle directory
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www

echo "Server setup completed successfully."

# cp config-dist.php config.php