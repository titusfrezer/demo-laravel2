# Use Ubuntu base image with PHP 8.1
FROM ubuntu:latest

ARG GEOGRAPHIC_AREA=Africa

# Install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y \
    curl \
    nginx \
    supervisor \
    php8.1 \
    php8.1-cli \
    php8.1-common \
    php8.1-curl \
    php8.1-fpm \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-mysql \
    php8.1-xml \
    php8.1-zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get install nano

# Set workdir
WORKDIR /var/www/html

# Copy application code
COPY . /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Copy configuration files
RUN rm /etc/nginx/sites-available/default
COPY docker/nginx.conf /etc/nginx/sites-available/default
COPY docker/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/www.conf /etc/php/8.1/fpm/pool.d/www.conf

RUN mkdir -p /run/php/ && chmod 755 /run/php/

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

RUN php artisan migrate

# Expose ports
EXPOSE 80

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]