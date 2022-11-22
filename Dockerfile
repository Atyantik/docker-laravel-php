FROM php:8.1-fpm-alpine

RUN apk add --no-cache \
  $PHPIZE_DEPS \
  freetype \
  libpng \
  libjpeg-turbo \
  freetype-dev \
  libpng-dev \
  libjpeg-turbo-dev \
  libc-dev \
  jpegoptim optipng pngquant gifsicle \
  postgresql-dev \
  unzip \
  curl \
  libzip-dev \
  curl-dev \
  pkgconfig \
  libressl-dev \
  libmcrypt-dev \
  zlib-dev \
  libxml2-dev \
  oniguruma-dev \
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
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

# Install Mongo DB
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

RUN echo '' | pecl install redis
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
