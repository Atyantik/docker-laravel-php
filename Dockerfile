FROM php:8.3-fpm-bullseye

# Install necessary libraries and PHP extensions
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        cmake \
        wget \
        git \
        libfreetype6-dev \
        libfontconfig1-dev \
        libpng-dev \
        libjpeg-dev \
        libc-dev \
        jpegoptim optipng pngquant gifsicle \
        unzip \
        curl \
        libzip-dev \
        libpq-dev \
        pkg-config \
        libssl-dev \
        zlib1g zlib1g-dev \
        libxml2-dev \
        libonig-dev \
        libmemcached-dev \
        libgmp-dev \
        libsqlite3-dev \
        postgresql-client \
        graphviz && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install \
        gd \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        mbstring \
        mysqli \
        exif \
        zip \
        intl \
        soap \
        gmp \
        opcache && \
    pecl install mongodb && docker-php-ext-enable mongodb && \
    pecl install memcached && docker-php-ext-enable memcached && \
    pecl install redis && docker-php-ext-enable redis && \
    pecl install apcu && docker-php-ext-enable apcu && \
    pecl install xdebug-3.4.0beta1 && docker-php-ext-enable xdebug && \
    echo "xdebug.mode=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    /usr/local/bin/composer config --global repo.packagist composer https://packagist.org && \
    cd /tmp && \
    curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.1.6.tgz > mongodb.tar.gz && \
    mkdir -p /etc/mongodb && tar xvzf mongodb.tar.gz -C /etc/mongodb --strip-components 1 && \
    rm -rf /tmp/mongodb.tar.gz /tmp/* && \
    apt-get remove --purge -y $PHPIZE_DEPS && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set permissions for Composer
RUN mkdir -p /.composer/ && chmod -R 777 /.composer/

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
