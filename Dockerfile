# Use the PHP 8.4 CLI image as the builder stage base
FROM php:8.4-cli-bookworm AS php-builder

# Prepare the builder stage with all required tools and headers
RUN set -eux; \
    apt-get update -y

RUN set -eux; \
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

# Compile the imagick extension through PECL (pin version) + clean
RUN set -eux; \
    pecl install imagick

RUN set -eux; \
    docker-php-ext-enable imagick

# Configure the gd extension to rely on system JPEG and freetype
RUN set -eux; \
    docker-php-ext-configure gd --with-freetype --with-jpeg

# Build the required PHP extensions in parallel to speed up the process
RUN set -eux; \
    docker-php-ext-install -j"$(nproc)" \
        bcmath \
        gd \
        intl \
        pcntl \
        pdo_mysql \
        zip \
        opcache

# Remove the PHP source tree because it is no longer needed
RUN set -eux; \
    docker-php-source delete

# Optional: shrink builder layer and binaries (affects final size after copy)
RUN set -eux; \
    apt-get purge -y --auto-remove build-essential pkg-config \
        libxml2-dev libssl-dev libzip-dev libpng-dev libjpeg62-turbo-dev \
        libfreetype6-dev libicu-dev libmagickwand-dev || true

RUN set -eux; \
    rm -rf /var/lib/apt/lists/* /tmp/pear

# Strip binaries and shared objects to reduce size
RUN set -eux; \
    command -v strip >/dev/null 2>&1 || true


# Start the runtime stage from a slim Debian base
FROM debian:bookworm-slim

# Install the runtime libraries required by PHP and compiled extensions
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
    libonig5 \
    libmagickwand-6.q16-6 \
    libmagickcore-6.q16-6
rm -rf /var/lib/apt/lists/*
BASH

# Copy the compiled PHP binaries and modules from the builder stage
COPY --from=php-builder /usr/local/ /usr/local/

# Provide the project-specific PHP runtime configuration
COPY php.ini /usr/local/etc/php/conf.d/zz-php.ini

# Provide the opcache tuning that accompanies this image
COPY opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

# Create the non-root app user and clean up documentation to reduce size
RUN <<'BASH'
set -eux
groupadd -f -g 1000 app
useradd -u 1000 -g app -s /usr/sbin/nologin -M app
install -d -o app -g app -m 0750 /app
rm -rf /usr/share/doc /usr/share/man /usr/share/locale/* || true
rm -f /usr/local/etc/php/conf.d/*sodium*.ini
BASH

RUN set -eux; f=/etc/ImageMagick-6/policy.xml; \
  for p in PDF PS XPS EPS MVG MSL TEXT URL EPHEMERAL HTTPS HTTP; do \
    sed -i "s#<policy domain=\"coder\" rights=\"\(read\|write\)\" pattern=\"$p\"/>#<policy domain=\"coder\" rights=\"none\" pattern=\"$p\"/>#g" "$f" || true; \
  done

# Run the container with the unprivileged app user by default
USER app
EXPOSE 8000
WORKDIR /app
