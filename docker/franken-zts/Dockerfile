FROM debian:trixie-slim AS build

ENV PHP_VERSION=8.4.14 \
    MAKEFLAGS="-j$(nproc)"

RUN apt update -y && apt install -y --no-install-recommends \
    ca-certificates build-essential autoconf bison re2c pkg-config \
    libssl-dev libcurl4-openssl-dev libxml2-dev libzip-dev zlib1g-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    sqlite3 libsqlite3-dev libicu-dev libonig-dev \
    git wget unzip curl

WORKDIR /usr/src

RUN wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz \
 && tar -xf php-${PHP_VERSION}.tar.gz && cd php-${PHP_VERSION} \
 && ./configure \
        --enable-zts \
        --enable-embed \
        --enable-opcache \
        --with-zlib \
        --enable-pdo \
        --with-pdo-mysql \
        --with-openssl \
        --enable-mbstring \
        --enable-gd \
        --with-jpeg \
        --with-freetype \
        --enable-intl \
        --with-sqlite3 \
        --with-pdo-sqlite \
 && make && make install
