FROM php:7.4-fpm

ENV UID=1000
ENV GID=1000

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    default-mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libzip-dev \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    libmcrypt-dev \
    zlib1g-dev \
    libxml2-dev \
    libonig-dev \
    graphviz \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install exif \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install zip \
    && docker-php-source delete

# Install Mongo DB
RUN pecl install mongodb \
    &&  echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongo.ini

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Optimize composer ot use only https protocol from packagist
RUN /usr/local/bin/composer config --global repo.packagist composer https://packagist.org

# Install hirak/prestissimo for parallel download
RUN /usr/local/bin/composer global require hirak/prestissimo --no-plugins --no-scripts

# Install mongodb tools for mongodump
RUN cd /tmp && \
    curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.1.6.tgz > mongodb.tar.gz && \
    mkdir -p /etc/mongodb && tar xvzf mongodb.tar.gz -C /etc/mongodb --strip-components 1 && \
    rm -rf /tmp/mongodb.tar.gz

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
