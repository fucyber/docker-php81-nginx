FROM alpine:latest

WORKDIR /var/www/

# Essentials
RUN echo "UTC" > /etc/timezone
RUN apk add --no-cache zip unzip curl sqlite nginx supervisor

RUN apk update && apk upgrade
# RUN apk add nginx

# Installing bash
RUN apk add bash
RUN sed -i 's/bin\/ash/bin\/bash/g' /etc/passwd

RUN apk --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main add \
    icu-libs \
    &&apk --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community add \
    # Current packages don't exist in other repositories
    libavif \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted gnu-libiconv \
    # Packages
    tini \
    php81 \
    php81-dev \
    php81-common \
    php81-gd \
    php81-xmlreader \
    php81-bcmath \
    php81-ctype \
    php81-curl \
    php81-exif \
    php81-iconv \
    php81-intl \
    php81-mbstring \
    php81-opcache \
    php81-openssl \
    php81-pcntl \
    php81-phar \
    php81-session \
    php81-xml \
    php81-xsl \
    php81-zip \
    php81-zlib \
    php81-dom \
    php81-fpm \
    php81-sodium \
    php81-fpm \ 
    php81-pdo_mysql \
    php81-pdo \
    php81-tokenizer \
    php81-odbc \
    php81-iconv \
    php81-fileinfo \
    php81-xmlwriter \
    # Iconv Fix
    php81-pecl-apcu \
    && ln -s /usr/bin/php81 /usr/bin/php

ARG COMPOSER_VERSION=2.2.1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION}

RUN apk --no-cache add curl nano

RUN mkdir -p /etc/supervisor.d/
COPY dockers/supervisord.ini /etc/supervisor.d/supervisord.ini

# sock-file
RUN mkdir -p /var/run/
RUN mkdir /var/run/php

# Configure PHP
RUN mkdir -p /run/php/
RUN touch /run/php/php81.0-fpm.pid

COPY dockers/php.ini-production /etc/php81/php.ini
# COPY dockers/php-fpm.conf /etc/php81/php-fpm.conf


# Configure NGINX
COPY dockers/nginx.conf /etc/nginx/nginx.conf
# COPY dockers/nginx-laravel.conf /etc/nginx/http.d/default.conf

RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log





EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]

