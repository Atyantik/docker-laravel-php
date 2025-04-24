#!/bin/bash

/usr/bin/wait-for.sh app:9000 -- echo "App Running..."
/usr/bin/wait-for.sh db:5432 -- echo "DB Running..."
/usr/bin/wait-for.sh redis:6379 -- echo "Redist Running..."
/usr/bin/wait-for.sh memcached:11211 -- echo "Memcached Running..."
/usr/bin/wait-for.sh mail:1025 -- echo "Mail Running..."
/usr/bin/wait-for.sh s3:9000 -- echo "S3 Running..."

php artisan optimize:clear
supervisord --nodaemon --configuration /etc/supervisord.conf
