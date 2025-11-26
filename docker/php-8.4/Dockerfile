# ============================
#       BUILDER STAGE
# ============================
FROM php:8.4-cli-bookworm AS php-builder

RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        pkg-config \
        build-essential \
        libxml2-dev \
        libssl-dev \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libicu-dev \
        libmagickwand-dev

# Install imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Configure gd
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install -j"$(nproc)" \
        bcmath \
        gd \
        intl \
        pcntl \
        pdo_mysql \
        zip \
        opcache \
        sockets

# Remove php source
RUN docker-php-source delete

# Strip binary sizes (REAL strip)
RUN set -eux; \
    find /usr/local -type f -name "*.so" -exec strip --strip-unneeded {} + || true; \
    find /usr/local/bin -type f -exec strip --strip-all {} + || true

# Final builder cleanup
RUN set -eux; \
    apt-get purge -y --auto-remove build-essential pkg-config libxml2-dev libssl-dev libzip-dev \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev libicu-dev libmagickwand-dev || true; \
    rm -rf /var/lib/apt/lists/* /tmp/pear


# ============================
#       RUNTIME STAGE
# ============================
FROM debian:bookworm-slim

RUN <<'BASH'
set -eux
apt-get update -y
apt-get install -y --no-install-recommends \
    ca-certificates \
    libxml2 \
    libssl3 \
    libpng16-16 \
    libzip4 \
    libjpeg62-turbo \
    libfreetype6 \
    libicu72 \
    libargon2-1 \
    libreadline8 \
    libsqlite3-0 \
    libcurl4 \
    libsodium23 \
    libonig5 \
    libmagickwand-6.q16-6 \
    libmagickcore-6.q16-6
rm -rf /var/lib/apt/lists/*
BASH

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

USER app
WORKDIR /app
EXPOSE 8000
