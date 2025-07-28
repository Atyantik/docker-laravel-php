FROM atyantik/laravel-php:8.4-bullseye

# Copy composer.lock and composer.json
COPY ./composer.lock ./composer.json /var/www/app/

# Set working directory
WORKDIR /var/www/app

RUN mkdir -p /etc/supervisor/conf.d

RUN apt-get update -y && apt-get install netcat wget supervisor -y && rm -rf /tmp/* /var/cache/apk/*

# Copy existing application directory contents
COPY . /var/www/app

COPY ./docker/staging/supervisor/supervisord.conf /etc/supervisord.conf

COPY ./docker/staging/php/local.ini /usr/local/etc/php/conf.d/local.ini

COPY ./docker/staging/php/opcache.blacklist /usr/local/etc/php/opcache.blacklist

COPY ./docker/staging/supervisor/conf.d /etc/supervisor/conf.d

COPY ./docker/staging/supervisor/entrypoint.sh ./entrypoint.sh

COPY ./docker/staging/php/wait-for.sh /usr/bin/wait-for.sh

RUN chmod +x /usr/bin/wait-for.sh

RUN chmod -R 777 bootstrap

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction

RUN composer dump-autoload

ENTRYPOINT ["/bin/sh", "./entrypoint.sh"]
