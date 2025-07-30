FROM atyantik/laravel-php:8.4-bullseye

# Set working directory
WORKDIR /var/www/app

# Copy composer.lock and composer.json
COPY ./composer.lock ./composer.json /var/www/app/

# Copy existing application directory contents
COPY . /var/www/app

COPY ./docker/staging/php/local.ini /usr/local/etc/php/conf.d/local.ini

COPY ./docker/staging/php/opcache.blacklist /usr/local/etc/php/opcache.blacklist

RUN mkdir /.config/ && chmod -R 777 /.config

RUN chmod -R 777 bootstrap

RUN sed -i -e 's/ = www-data/ = root/g' /usr/local/etc/php-fpm.d/www.conf

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction

RUN composer dump-autoload

RUN php artisan optimize:clear

RUN php artisan optimize

RUN apt-get update -y && apt-get install -y netcat wget

# Install Node.js 22
RUN set -uex; \
    apt-get update; \
    apt-get install -y ca-certificates curl gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
     | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    NODE_MAJOR=22; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
     > /etc/apt/sources.list.d/nodesource.list; \
    apt-get -qy update; \
    apt-get -qy install nodejs;

# Update npm to latest version
RUN npm install -g npm@latest

# Install wait-for script globally
COPY ./docker/staging/php/wait-for.sh /usr/bin/wait-for.sh
RUN chmod +x /usr/bin/wait-for.sh

ENTRYPOINT ["/bin/sh", "./docker/staging/php/entrypoint.sh"]
# CMD php-fpm
