FROM debian:trixie-slim AS build

ENV DEBIAN_FRONTEND=noninteractive 

RUN set -eux; \
    apt update -y; \
    apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg; \
    update-ca-certificates

RUN curl -fsSL https://key.henderkes.com/static-php.gpg -o /usr/share/keyrings/static-php.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/static-php.gpg] https://deb.henderkes.com/ stable main" \
      > /etc/apt/sources.list.d/static-php.list && \
    apt update -y

RUN apt install -y --no-install-recommends \
      frankenphp \
      php-zts-bcmath \
      php-zts-intl \
      php-zts-gd \
      php-zts-imagick \
      php-zts-pdo \
      php-zts-pdo-mysql \
      php-zts-zip \
      php-zts-fileinfo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PHP_INI_DIR=/etc/php-zts

RUN set -eux; \
    apt update -y; \
    apt install -y --no-install-recommends \
      ca-certificates \
      curl; \
    update-ca-certificates; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/bin/frankenphp /usr/bin/frankenphp
COPY --from=build /usr/lib/php-zts /usr/lib/php-zts
COPY --from=build /usr/lib/libphp-zts-84.so /usr/lib/libphp-zts-84.so
COPY --from=build /etc/php-zts /etc/php-zts

RUN rm -rf /usr/share/doc /usr/share/man /usr/share/locale/* || true

COPY php.ini /etc/php-zts/php.ini

RUN set -eux; \
    groupadd -f -g 1000 app; \
    useradd -u 1000 -g app -s /usr/sbin/nologin -M app; \
    install -d -o app -g app -m 0750 /app

WORKDIR /app

USER app

EXPOSE 8000