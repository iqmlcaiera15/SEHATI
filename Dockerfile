# Gunakan image PHP dengan ekstensi yang dibutuhkan
FROM php:8.1-fpm

# Install ekstensi yang diperlukan Laravel
RUN apt-get update && apt-get install -y \
    libpq-dev \
    zip \
    unzip \
    git \
    curl \
    libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy source code Laravel ke dalam container
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Beri permission untuk Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Jalankan PHP built-in server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
