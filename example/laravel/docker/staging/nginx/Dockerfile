FROM nginx:1.27

RUN sed -i -e 's/user www-data;/user www;/g' /etc/nginx/nginx.conf

RUN sed -i -e 's/user nginx;/user root;/g' /etc/nginx/nginx.conf

COPY . /var/www/app

COPY ./docker/staging/nginx/conf.d/www.conf /etc/nginx/conf.d/default.conf
