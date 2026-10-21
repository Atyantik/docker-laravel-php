# Pinned to a patched release (CVE-2026-109618, CVE-2026-109619). The build fails if this tag does not exist.
ARG PHP_VERSION=8.3.36
FROM php:${PHP_VERSION}-fpm-bookworm

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
        graphviz \
        imagemagick \
        libmagickwand-dev && \
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
    # PECL's download server returned HTTP 500 for mongodb on 2026-10-21, so take the
    # same release from the MongoDB GitHub project, pinned by SHA256. Retry the other
    # PECL downloads because they fail intermittently.
    pecl_retry() { for i in 1 2 3 4 5 6; do pecl install "$1" && return 0; sleep 15; done; return 1; } && \
    curl -fsSL --retry 5 -o /tmp/mongodb-2.5.5.tgz https://github.com/mongodb/mongo-php-driver/releases/download/2.5.5/mongodb-2.5.5.tgz && \
    echo "0eaf84ff709f73183d80597f31ff02937f6aefde01eb895a0aa19334a290cec0  /tmp/mongodb-2.5.5.tgz" | sha256sum -c - && \
    pecl install /tmp/mongodb-2.5.5.tgz && docker-php-ext-enable mongodb && \
    pecl_retry memcached && docker-php-ext-enable memcached && \
    pecl_retry redis && docker-php-ext-enable redis && \
    pecl_retry apcu && docker-php-ext-enable apcu && \
    pecl_retry imagick && docker-php-ext-enable imagick && \
    pecl_retry xdebug-3.4.0beta1 && docker-php-ext-enable xdebug && \
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
