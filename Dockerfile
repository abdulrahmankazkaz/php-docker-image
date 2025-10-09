FROM php:8.4-cli-bookworm AS php-builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      pkg-config build-essential \
      libxml2-dev libssl-dev libzip-dev \
      libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
      libicu-dev libonig-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" \
      bcmath gd intl mbstring pcntl pdo_mysql zip opcache \
 && docker-php-source delete \
 && apt-get purge -y --auto-remove \
      build-essential pkg-config \
      libxml2-dev libssl-dev libzip-dev \
      libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
      libicu-dev libonig-dev \
 && rm -rf /var/lib/apt/lists/*

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Baghdad 

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      libxml2 libssl3 libreadline8 \
      libzip4 \
      libpng16-16 libjpeg62-turbo libfreetype6 \
      libicu72 libonig5 \
      libsqlite3-0 libcurl4 libargon2-1 libsodium23 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=php-builder /usr/local/ /usr/local/

COPY php.ini /usr/local/etc/php/conf.d/zz-php.ini

COPY opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

RUN groupadd -f -g 1000 app \
 && useradd -u 1000 -g app -s /usr/sbin/nologin -M app \
 && install -d -o app -g app -m 0750 /app \
 && rm -rf /usr/share/doc /usr/share/man /usr/share/locale/* || true

USER app

EXPOSE 8000

WORKDIR /app
