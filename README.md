# Atyantik's Laravel PHP Docker Image 🌟

[![Docker Hub](https://img.shields.io/badge/Docker-Hub-blue)](https://hub.docker.com/repository/docker/atyantik/laravel-php)

This repository provides a **custom PHP 8.4 Docker image** based on the Bullseye distribution, optimized for running Laravel applications. It includes pre-installed PHP extensions, tools, and multi-architecture support for **AMD64** and **ARM64**. 🚀

---

## ✨ Features: What This Dockerfile Provides

This Dockerfile is tailored for **Laravel** applications and includes the following features:

1. **PHP 8.4** with FPM (FastCGI Process Manager).
2. ✅ **Pre-installed PHP Extensions**:
   - Essential extensions required by most Laravel applications.
   - See the [Extension Table](#php-extensions) below for a full list. 🧩
3. ✅ **Pre-installed Tools**:
   - **Composer** (globally available for dependency management).
   - **MongoDB Tools** (e.g., `mongodump`) for database backups and operations.
4. ✅ **Xdebug**:
   - Included but disabled by default for production readiness.
   - XDebug 3.4.0beta1 is used for compatibility with php 8.4
5. ✅ **Multi-Architecture Builds**:
   - Supports both AMD64 (x86_64) and ARM64 (aarch64) architectures.

---

## 🧩 PHP Extensions

Here's a detailed list of pre-installed PHP extensions:

| Extension            | Description                                           | Status |
|----------------------|-------------------------------------------------------|--------|
| **pdo_mysql**        | MySQL database support                                | ✅      |
| **pdo_pgsql**        | PostgreSQL database support                           | ✅      |
| **pdo_sqlite**       | SQLite lightweight database support                   | ✅      |
| **mbstring**         | Multibyte string handling for UTF-8 support           | ✅      |
| **intl**             | Internationalization and localization features        | ✅      |
| **gd**               | Image processing (JPEG, PNG)                          | ✅      |
| **zip**              | Support for ZIP compression                           | ✅      |
| **opcache**          | Performance optimization through script caching       | ✅      |
| **soap**             | SOAP-based web services                               | ✅      |
| **redis**            | Redis for caching and sessions                        | ✅      |
| **memcached**        | Memcached for caching and sessions                    | ✅      |
| **mongodb**          | MongoDB database support                              | ✅      |
| **gmp**              | Arbitrary precision arithmetic                        | ✅      |
| **exif**             | Metadata handling for images                          | ✅      |
| **imagick**          | ImageMagick image processing and manipulation        | ✅      |

---

## 🛠 Pre-installed Tools

1. **Composer**:
   - Installed globally for dependency management.
   - Optimized to use only HTTPS for Packagist repositories.

2. **MongoDB Tools**:
   - Includes **mongodump** for backup operations and other utilities.

---

## 🚀 How to Use

This Docker image is available on [Docker Hub](https://hub.docker.com/repository/docker/atyantik/laravel-php). You can pull it directly or use it as a base image in your own Dockerfile:

```dockerfile
FROM atyantik/laravel-php:8.4-bullseye
```

### Example: Running a Laravel Application

1. Build your Laravel application image using this base image:
   ```dockerfile
   FROM atyantik/laravel-php:8.4-bullseye

   COPY . /var/www/html
   WORKDIR /var/www/html

   RUN composer install --no-dev --optimize-autoloader
   ```
2. Start the container:
   ```bash
   docker run -p 8000:9000 my-laravel-app
   ```

---

## 🛠 Compilation Steps

Follow these steps to build the image yourself:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/atyantik/laravel-php-docker.git
   cd laravel-php-docker
   ```

2. **Enable Buildx for Multi-Architecture Builds**:
   - If Buildx is not set up, enable it by following [Docker's Buildx Guide](https://docs.docker.com/buildx/working-with-buildx/).

3. **Build AMD64 Image**:
   ```bash
   docker buildx build --platform="linux/amd64" -t atyantik/laravel-php:8.4-bullseye-amd64 .
   ```

4. **Build ARM64 Image**:
   ```bash
   docker buildx build --platform="linux/arm64" -t atyantik/laravel-php:8.4-bullseye-arm64 .
   ```

5. **Push Images to Docker Hub**:
   ```bash
   docker push atyantik/laravel-php:8.4-bullseye-amd64
   docker push atyantik/laravel-php:8.4-bullseye-arm64
   ```

6. **Create and Push a Manifest for Multi-Architecture**:
   ```bash
   docker manifest create atyantik/laravel-php:8.4-bullseye \
     atyantik/laravel-php:8.4-bullseye-amd64 \
     atyantik/laravel-php:8.4-bullseye-arm64
   docker manifest push atyantik/laravel-php:8.4-bullseye
   ```

💻 Visit us at: [atyantik.com](https://atyantik.com)

## 📚 Examples and Docker Configurations

This repository includes two types of example configurations to help you get started:

### 1. General PHP Application Setup

Located in `example/general/`, this is a simple setup for any PHP application:

```yaml
services:
  app:
    image: atyantik/laravel-php:8.4-bullseye
    volumes:
      - ./public:/var/www/html
      - ./php/php.ini:/usr/local/etc/php/php.ini

  webserver:
    image: nginx:latest
    volumes:
      - ./public:/var/www/html
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "8080:80"
    depends_on:
      - app
```

This configuration provides:
- PHP-FPM service using our custom image
- Nginx web server
- Basic volume mounting for code and configuration
- Simple networking between services

### 2. Laravel-Specific Setup

Located in `example/laravel/`, this is a comprehensive setup for Laravel applications with two environments:

#### Local Development (`compose.yml`)

A complete development environment with:
- PostgreSQL database
- Redis for caching and queues
- Mailpit for email testing
- pgAdmin for database management
- Memcached for caching
- MinIO for S3-compatible storage
- Supervisor for queue workers
- Nginx web server
- Vite support for frontend development

Key features:
- Hot-reloading for development
- Persistent data storage
- Development tools (Mailpit, pgAdmin)
- Local storage for files and databases

#### Staging Environment (`compose.staging.yml`)

A production-like environment with:
- Optimized PHP configuration
- Secure Redis setup
- Persistent volumes
- SSL support
- Production-ready Nginx configuration
- Bootstrapper for initial setup

Key differences from development:
- No development tools
- Secure configurations
- Production-ready settings
- Volume-based storage
- SSL support

### How to Use These Examples

1. **For General PHP Applications**:
   ```bash
   cd example/general
   docker-compose up -d
   ```
   Access your application at `http://localhost:8080`

2. **For Laravel Applications**:
   To integrate these Docker configurations into your existing Laravel project:

   1. Copy the following files from `example/laravel/` to your project root:
      - `compose.yml` (for development)
      - `compose.staging.yml` (for staging)
      - `docker/` directory with all its contents

   2. Update your Laravel configuration files:
      - In `bootstrap/app.php`, ensure allowing trustedProxies
      - In `vite.config.js`, update the server.hmr
      - In your project's `.env` file, add these variables:
```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=local_laravel
DB_PASSWORD=local@laravel

REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_SCHEME=null
MAIL_HOST=mail
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=laravel-bucket
AWS_USE_PATH_STYLE_ENDPOINT=true
AWS_ENDPOINT=http://s3:9000

MEMCACHED_HOST=memcached
CACHE_STORE=memcached
QUEUE_CONNECTION=redis
FILESYSTEM_DISK=s3
APP_URL=https://laravel.localhost
COMPOSE_BAKE=true
```

   3. Start the services:
      ```bash
      # Development
      docker compose up -d
      
      # Staging
      docker compose -f compose.staging.yml up -d
      ```

### Best Practices

1. **Development**:
   - Use the development configuration for local development
   - Enable Xdebug when needed
   - Use Mailpit for email testing
   - Utilize pgAdmin for database management

2. **Staging**:
   - Use the staging configuration as a base
   - Implement proper SSL certificates
   - Set secure passwords for all services
   - Use persistent volumes for data
   - Configure proper backup strategies
   - Whenever possible use proper staging configuration not the provided docker-compose.yml
   - The provided configurations is to get staging server quick up and running on single server instance.

3. **Security**:
   - Never commit sensitive environment variables
   - Use strong passwords in production
   - Implement proper SSL/TLS
   - Regularly update container images  

---

## 🌐 Links

- **Docker Hub Repository**: [https://hub.docker.com/repository/docker/atyantik/laravel-php](https://hub.docker.com/repository/docker/atyantik/laravel-php)
- **Atyantik Technologies**: [atyantik.com](https://atyantik.com)

---

## 🤝 About Atyantik Technologies

![Atyantik Logo](https://cdn.atyantik.com/atyantik-logo.png)

At **Atyantik Technologies**, we specialize in building world-class software solutions with a focus on innovation, scalability, and efficiency. We believe in delivering value through cutting-edge technologies and industry best practices.