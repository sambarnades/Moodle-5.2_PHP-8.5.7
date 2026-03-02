# Update & install dependencies

apt-get clean
apt-get update -y
apt-get upgrade -y
apt-get install -y libfreetype-dev libjpeg62-turbo-dev libpng-dev git xmlrpc


# Install php extensions

docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j$(nproc) gd ctype curl dom iconv intl json mbstring pcre simplexml spl xml zip pgsql openssl sodium tokenizer opcache

# Create moodledata directory

mkdir ./moodledata
chmod 0777 ./moodledata

# Download Moodle 5.1

# Prod only --------------------------

# git clone git://git.moodle.org/moodle.git

# ------------------------------------

chown -R root ./moodle
chmod -R 0755 ./moodle

 cd moodle
 git branch --track MOODLE_501_STABLE origin/MOODLE_501_STABLE
 git checkout MOODLE_501_STABLE


find ./moodle -type f -exec chmod 0644 {} \;

chown -R www-data:www-data /var/www/
chmod -R 755 /var/www

# cp config-dist.php config.php