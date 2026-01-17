FROM dunglas/frankenphp

ENV DEBIAN_FRONTEND=noninteractive 

RUN set -eux; \
    apt update -y;

RUN install-php-extensions bcmath gd intl pcntl imagick pdo_mysql zip 

RUN rm -rf /usr/share/doc /usr/share/man /usr/share/locale/* || true

COPY php.ini /usr/local/etc/php

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

