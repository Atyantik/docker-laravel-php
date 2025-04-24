#!/bin/bash

# Setup trap for proper process handling
trap 'kill $(jobs -p)' EXIT

/usr/bin/wait-for.sh db:5432 -- echo "DB Running..."
/usr/bin/wait-for.sh redis:6379 -- echo "Redist Running..."
/usr/bin/wait-for.sh memcached:11211 -- echo "Memcached Running..."
/usr/bin/wait-for.sh s3:9000 -- echo "S3 Running..."

composer install --no-dev --optimize-autoloader --no-interaction
npm install
npm i dotenv --no-save
npm run build

php artisan optimize:clear
php artisan optimize

php artisan migrate --force

php-fpm -R
