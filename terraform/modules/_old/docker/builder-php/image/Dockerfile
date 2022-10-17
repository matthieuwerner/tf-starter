FROM debian:10.9-slim

RUN apt-get update \
    && apt install -y --no-install-recommends \
        ca-certificates \
        gnupg \
    && echo "deb https://packages.sury.org/php buster main" > /etc/apt/sources.list.d/sury.list \
    && apt-key adv --fetch-keys https://packages.sury.org/php/apt.gpg

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ARG PHP_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-iconv \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-uuid \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Fake user to maps with the one on the host
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN addgroup --gid $GROUP_ID app && \
    adduser --system --uid $USER_ID --home /home/app --shell /bin/bash app

# Configuration
COPY php-configuration /etc/php/${PHP_VERSION}

ARG NODEJS_VERSION=14.x
RUN echo "deb https://deb.nodesource.com/node_${NODEJS_VERSION} buster main" > /etc/apt/sources.list.d/nodejs.list \
    && apt-key adv --fetch-keys https://deb.nodesource.com/gpgkey/nodesource.gpg.key

# Default toys
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        git \
        make \
        nodejs \
        sudo \
        unzip \
    && apt-get clean \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Config
COPY etc /etc/
ARG PHP_VERSION
COPY php-configuration /etc/php/${PHP_VERSION}
RUN adduser app sudo \
    && mkdir /var/log/php \
    && chmod 777 /var/log/php \
    && phpenmod app-default \
    && phpenmod app-builder

# Composer
COPY --from=composer/composer:2.1.6 /usr/bin/composer /usr/bin/composer
RUN mkdir -p "/home/app/.composer/cache" \
    && chown app: /home/app/.composer -R

# PHPStan
RUN curl -sSL https://github.com/phpstan/phpstan/releases/download/1.3.3/phpstan.phar -o phpstan \
    && chmod a+x phpstan \
    && mv phpstan /usr/local/bin/phpstan

# CSFixer
RUN curl -L https://cs.symfony.com/download/php-cs-fixer-v3.phar -o php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer


WORKDIR /home/app/application

