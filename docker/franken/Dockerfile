FROM debian:trixie-slim AS build

ENV DEBIAN_FRONTEND=noninteractive 

RUN set -eux; \
    apt update -y; \
    apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg; \
    update-ca-certificates

RUN curl https://frankenphp.dev/install.sh | sh

RUN apt install -y --no-install-recommends \
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

RUN rm -rf /usr/share/doc /usr/share/man /usr/share/locale/* || true

COPY php.ini /etc/php-zts/php.ini

RUN set -eux; \
    groupadd -f -g 1000 app; \
    useradd -u 1000 -g app -s /usr/sbin/nologin -M app; \
    install -d -o app -g app -m 0750 /app

COPY --chown=app:app docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0550 /usr/local/bin/docker-entrypoint.sh

WORKDIR /app
USER app
EXPOSE 8000

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

