FROM atyantik/laravel-php:8.4-bullseye

# Set working directory
WORKDIR /var/www/app

COPY ./docker/local/php/local.ini /usr/local/etc/php/conf.d/local.ini

RUN mkdir /.config/ && chmod -R 777 /.config

RUN sed -i -e 's/ = www-data/ = root/g' /usr/local/etc/php-fpm.d/www.conf

RUN apt-get update -y && apt-get install -y netcat wget

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

RUN npm install -g npm@latest

COPY ./docker/local/php/wait-for.sh /usr/bin/wait-for.sh

RUN chmod +x /usr/bin/wait-for.sh

ENTRYPOINT ["/bin/sh", "./docker/local/php/entrypoint.sh"]