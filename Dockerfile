FROM webdevops/php-nginx:8.2-alpine

# Set workdir
WORKDIR /app

# Copy Laravel project
COPY . .

# Install system dependencies
RUN apk add --no-cache \
    bash zip unzip curl libzip-dev oniguruma-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring zip gd

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate app key
RUN php artisan key:generate --ansi || true

# Laravel cache
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Set permissions
RUN chown -R application:application storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expose Railway-compatible port
EXPOSE 8080
