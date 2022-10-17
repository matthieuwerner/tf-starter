ARG PROJECT_NAME

FROM php-base

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
