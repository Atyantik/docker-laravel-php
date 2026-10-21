# Pinned to a patched release (CVE-2026-109618, CVE-2026-109619). The build fails if this tag does not exist.
ARG PHP_VERSION=8.2.35
FROM php:${PHP_VERSION}-fpm-bookworm

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
  $PHPIZE_DEPS \
  cmake libfreetype6-dev libfontconfig1-dev xclip \
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
  libmcrypt-dev \
  zlib1g zlib1g-dev \
  libxml2-dev \
  libonig-dev \
  graphviz \
  && docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ && \
  docker-php-ext-install gd \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    mysqli \
    exif \
    zip \
    intl \
    ftp

# Install Mongo DB
# PECL's download server returned HTTP 500 for mongodb on 2026-10-21, so take the
# same release from the MongoDB GitHub project, pinned by SHA256.
RUN curl -fsSL --retry 5 -o /tmp/mongodb-2.5.5.tgz https://github.com/mongodb/mongo-php-driver/releases/download/2.5.5/mongodb-2.5.5.tgz \
    && echo "0eaf84ff709f73183d80597f31ff02937f6aefde01eb895a0aa19334a290cec0  /tmp/mongodb-2.5.5.tgz" | sha256sum -c - \
    && pecl install /tmp/mongodb-2.5.5.tgz \
    && rm /tmp/mongodb-2.5.5.tgz \
    && docker-php-ext-enable mongodb

# Retry because PECL downloads fail intermittently
RUN for i in 1 2 3 4 5 6; do pecl install redis && break; [ "$i" = 6 ] && exit 1; sleep 15; done
RUN docker-php-ext-enable redis

RUN docker-php-ext-install opcache

RUN rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Optimize composer ot use only https protocol from packagist
RUN /usr/local/bin/composer config --global repo.packagist composer https://packagist.org

# Install mongodb tools for mongodump
RUN cd /tmp && \
    curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.1.6.tgz > mongodb.tar.gz && \
    mkdir -p /etc/mongodb && tar xvzf mongodb.tar.gz -C /etc/mongodb --strip-components 1 && \
    rm -rf /tmp/mongodb.tar.gz

RUN mkdir -p /.composer/ && chmod -R 777 /.composer/

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
