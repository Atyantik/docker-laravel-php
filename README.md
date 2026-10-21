# Atyantik's Laravel PHP Docker Image 🌟

[![Docker Hub](https://img.shields.io/badge/Docker-Hub-blue)](https://hub.docker.com/repository/docker/atyantik/laravel-php)

This repository provides a **custom PHP 8.3 Docker image** based on the Bookworm distribution, optimized for running Laravel applications. It includes pre-installed PHP extensions, tools, and multi-architecture support for **AMD64** and **ARM64**. 🚀

---

## ✨ Features: What This Dockerfile Provides

This Dockerfile is tailored for **Laravel** applications and includes the following features:

1. **PHP 8.3** with FPM (FastCGI Process Manager).
2. ✅ **Pre-installed PHP Extensions**:
   - Essential extensions required by most Laravel applications.
   - See the [Extension Table](#php-extensions) below for a full list. 🧩
3. ✅ **Pre-installed Tools**:
   - **Composer** (globally available for dependency management).
   - **MongoDB Tools** (e.g., `mongodump`) for database backups and operations.
4. ✅ **Xdebug**:
   - Included but disabled by default for production readiness.
   - XDebug 3.4.0beta1 is used for compatibility with php 8.3
5. ✅ **Multi-Architecture Builds**:
   - Supports both AMD64 (x86_64) and ARM64 (aarch64) architectures.

---

## 🧩 PHP Extensions

Here’s a detailed list of pre-installed PHP extensions:

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
| **imagick**          | ImageMagick support for advanced image processing     | ✅      |

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
FROM atyantik/laravel-php:8.3-bookworm
```

### Example: Running a Laravel Application

1. Build your Laravel application image using this base image:
   ```dockerfile
   FROM atyantik/laravel-php:8.3-bookworm

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
   docker buildx build --platform="linux/amd64" -t atyantik/laravel-php:8.3-bookworm-amd64 .
   ```

4. **Build ARM64 Image**:
   ```bash
   docker buildx build --platform="linux/arm64" -t atyantik/laravel-php:8.3-bookworm-arm64 .
   ```

5. **Push Images to Docker Hub**:
   ```bash
   docker push atyantik/laravel-php:8.3-bookworm-amd64
   docker push atyantik/laravel-php:8.3-bookworm-arm64
   ```

6. **Create and Push a Manifest for Multi-Architecture**:
   ```bash
   docker manifest create atyantik/laravel-php:8.3-bookworm \
     atyantik/laravel-php:8.3-bookworm-amd64 \
     atyantik/laravel-php:8.3-bookworm-arm64
   docker manifest push atyantik/laravel-php:8.3-bookworm
   ```

---

## 🌐 Links

- **Docker Hub Repository**: [https://hub.docker.com/repository/docker/atyantik/laravel-php](https://hub.docker.com/repository/docker/atyantik/laravel-php)
- **Atyantik Technologies**: [atyantik.com](https://atyantik.com)

---

## 🤝 About Atyantik Technologies

![Atyantik Logo](https://cdn.atyantik.com/atyantik-logo.png)

At **Atyantik Technologies**, we specialize in building world-class software solutions with a focus on innovation, scalability, and efficiency. We believe in delivering value through cutting-edge technologies and industry best practices.

💻 Visit us at: [atyantik.com](https://atyantik.com)