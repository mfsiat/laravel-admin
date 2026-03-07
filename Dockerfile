FROM php:8.1-cli

# 1. Install system dependencies
RUN apt-get update -y && apt-get install -y \
    openssl \
    zip \
    unzip \
    git \
    libonig-dev \
    libzip-dev \
    libpng-dev

# 2. Install PHP extensions (Required for Laravel)
RUN docker-php-ext-install pdo_mysql mbstring zip gd

# 3. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Set working directory
WORKDIR /app

# 5. Optimization: Install dependencies first (better caching)
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader

# 6. Copy the rest of the application
COPY . .

# 7. Finalize Composer
RUN composer dump-autoload --optimize

# 8. Set permissions for Laravel
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# 9. Expose and Run
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
