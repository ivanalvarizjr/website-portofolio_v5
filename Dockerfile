# Multi-stage build untuk Railway
FROM node:18-alpine AS node_build

# Set working directory untuk Node build
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci --include=dev

# Copy source code
COPY . .

# Build assets dengan Vite
RUN npm run build

# PHP stage
FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    zip \
    libzip-dev \
    curl \
    nginx

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files first (for better caching)
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Copy application code
COPY . .

# Copy built assets from node_build stage
COPY --from=node_build /app/public/build ./public/build

# Set proper permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache \
    && chmod -R 775 /app/storage /app/bootstrap/cache

# Cache Laravel config untuk production
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose port untuk Railway
EXPOSE 8000

# Start command untuk Railway
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]