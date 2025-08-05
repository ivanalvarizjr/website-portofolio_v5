# Gunakan image siap pakai yang sudah include PHP-FPM + NGINX
FROM webdevops/php-nginx:8.2-alpine

# Set direktori kerja
WORKDIR /app

# Copy semua file project Laravel ke container
COPY . .

# Install dependency sistem & ekstensi PHP yang dibutuhkan Laravel
RUN apk add --no-cache \
    zip unzip curl git libzip-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    oniguruma-dev bash \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring zip gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install dependency Laravel (non-dev, optimize)
RUN composer install --no-dev --optimize-autoloader

# Generate app key dan cache konfigurasi Laravel
RUN php artisan key:generate --ansi || true \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Set permission storage & cache
RUN chown -R application:application storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Railway hanya expose port 8080
EXPOSE 8080
