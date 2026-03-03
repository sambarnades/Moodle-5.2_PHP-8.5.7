FROM php:8.5.3-apache
COPY . /var/www/html/
WORKDIR /var/www/html/
CMD [ "bash", "./setup_server.sh" ]
EXPOSE 80