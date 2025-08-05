FROM php:8.2-fpm-alpine

# Install dependencies
RUN apk add --no-cache \
    zip unzip curl git libzip-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    oniguruma-dev bash

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring zip gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy app files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set correct permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Laravel cache
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan key:generate --ansi || true

EXPOSE 9000

CMD ["php-fpm"]
