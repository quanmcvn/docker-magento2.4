# Use PHP-FPM as base image
FROM php:8.1-fpm

# Install system dependencies and PHP extensions required for Magento 2
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libxslt1-dev \
    libicu-dev libzip-dev git unzip curl libcurl4-openssl-dev \
    libssl-dev libmcrypt-dev libpng-dev libjpeg-dev libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install simplexml gd intl pdo pdo_mysql zip soap xsl bcmath sockets \
    && apt-get clean

# Install Composer (dependency manager for PHP)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Magento 2 code into the container
COPY ./magento2/ /var/www/html/magento2/

WORKDIR /var/www/html/magento2
# Install Magento 2 dependencies using Composer
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install

# Configure Nginx to serve Magento 2
RUN rm /etc/nginx/sites-enabled/default

COPY ./nginx/default.conf /etc/nginx/sites-enabled/

# Expose port 80 for the web server
EXPOSE 80

# Start PHP-FPM and Nginx
# CMD php-fpm
CMD service nginx start && php-fpm
# CMD service nginx start
