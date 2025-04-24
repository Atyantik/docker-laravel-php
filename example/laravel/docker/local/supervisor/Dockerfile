FROM atyantik/laravel-php:8.4-bullseye

VOLUME [ "/var/www/app" ]

# Set working directory
WORKDIR /var/www/app

RUN mkdir -p /etc/supervisor/conf.d

RUN apt-get update -y && apt-get install netcat wget supervisor -y && rm -rf /tmp/* /var/cache/apk/*

COPY ./docker/local/supervisor/supervisord.conf /etc/supervisord.conf

COPY ./docker/local/php/local.ini /usr/local/etc/php/conf.d/local.ini

COPY ./docker/local/supervisor/conf.d /etc/supervisor/conf.d

COPY ./docker/local/php/wait-for.sh /usr/bin/wait-for.sh

RUN chmod +x /usr/bin/wait-for.sh


ENTRYPOINT ["/bin/sh", "./docker/local/supervisor/entrypoint.sh"]
