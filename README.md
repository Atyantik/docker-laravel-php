### Create AMD and ARM builds with buildx
```
docker buildx build --platform="linux/amd64" -t atyantik/laravel-php:8.3-bullseye-amd64 .
```  

```
docker buildx build --platform="linux/arm64" -t atyantik/laravel-php:8.3-bullseye-arm64 .
```  

### Push both to docker hub
docker push atyantik/laravel-php:8.3-bullseye-arm64
docker push atyantik/laravel-php:8.3-bullseye-amd64


`// docker manifest rm atyantik/laravel-php:8.3 atyantik/laravel-php:8.3-bullseye-amd64 atyantik/laravel-php:8.3-bullseye-arm64`

docker manifest create atyantik/laravel-php:8.3-bullseye atyantik/laravel-php:8.3-bullseye-amd64 atyantik/laravel-php:8.3-bullseye-arm64

docker manifest push atyantik/laravel-php:8.3-bullseye

