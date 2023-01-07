### Create AMD and ARM builds with buildx
docker buildx build --platform="linux/amd64" -t atyantik/laravel-php:8.1-amd64 .
docker buildx build --platform="linux/arm64" -t atyantik/laravel-php:8.1-arm64 .

### Push both to docker hub
docker push atyantik/laravel-php:8.1-arm64
docker push atyantik/laravel-php:8.1-amd64

docker manifest create atyantik/laravel-php:8.1 atyantik/laravel-php:8.1-amd64 

docker manifest rm atyantik/laravel-php:8.1 atyantik/laravel-php:8.1-amd64 atyantik/laravel-php:8.1-arm64

docker manifest create atyantik/laravel-php:8.1 atyantik/laravel-php:8.1-amd64 atyantik/laravel-php:8.1-arm64

docker manifest push atyantik/laravel-php:8.1

