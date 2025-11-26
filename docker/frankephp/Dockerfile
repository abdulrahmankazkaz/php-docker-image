# ============================
#       BUILDER STAGE
# ============================
FROM php:8.4-cli-bookworm AS php-builder

RUN set -eux \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates pkg-config build-essential \
      libxml2-dev libssl-dev libzip-dev libpng-dev \
      libjpeg62-turbo-dev libfreetype6-dev libicu-dev \
      libmagickwand-dev \
 && pecl install imagick \
 && docker-php-ext-enable imagick \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" bcmath gd intl pcntl pdo_mysql pdo zip opcache \
 && docker-php-source delete \
 && find /usr/local/lib/php/extensions/ -type f -name "*.so" -exec strip --strip-unneeded {} + || true \
 && strip --strip-all /usr/local/bin/php || true \
 && apt-get purge -y --auto-remove \
      build-essential pkg-config libxml2-dev libssl-dev libzip-dev \
      libpng-dev libjpeg62-turbo-dev libfreetype6-dev libicu-dev libmagickwand-dev \
 && rm -rf /var/lib/apt/lists/* /tmp/pear


# ============================
#       RUNTIME STAGE
# ============================
FROM debian:bookworm-slim

RUN set -eux \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates libxml2 libssl3 libpng16-16 libzip4 libjpeg62-turbo \
      libfreetype6 libicu72 libargon2-1 libreadline8 libsqlite3-0 libcurl4 \
      libsodium23 libonig5 libmagickwand-6.q16-6 libmagickcore-6.q16-6 curl \
 && curl -fsSL https://key.henderkes.com/static-php.gpg -o /usr/share/keyrings/static-php.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/static-php.gpg] https://deb.henderkes.com/ stable main" \
    > /etc/apt/sources.list.d/static-php.list \
 && apt-get update && apt-get install -y --no-install-recommends frankenphp \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Copy PHP from builder
COPY --from=php-builder /usr/local/ /usr/local/

# Provide runtime configs
COPY php.ini /usr/local/etc/php/conf.d/zz-php.ini

# Create non-root user
RUN <<'BASH'
set -eux
groupadd -f -g 1000 app
useradd -u 1000 -g app -s /usr/sbin/nologin -M app
install -d -o app -g app -m 0750 /app

# Clean unneeded locales/docs
rm -rf /usr/share/doc /usr/share/man /usr/share/locale/* || true

# Disable unwanted ImageMagick coders for security
f=/etc/ImageMagick-6/policy.xml
for p in PDF PS XPS EPS MVG MSL TEXT URL EPHEMERAL HTTPS HTTP; do
  sed -i "s#<policy domain=\"coder\" rights=\"\(read\|write\)\" pattern=\"$p\"/>#<policy domain=\"coder\" rights=\"none\" pattern=\"$p\"/>#g" "$f" || true
done
BASH

# Ensure PHP binary path works
ENV PATH="/usr/local/bin:/usr/local/sbin:${PATH}"

COPY --chown=app:app docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0550 /usr/local/bin/docker-entrypoint.sh


USER app

WORKDIR /app

EXPOSE 8000

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]