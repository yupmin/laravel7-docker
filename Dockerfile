FROM php:7.4-fpm-alpine
MAINTAINER yun young jin <yupmin@gmail.com>

RUN apk update && \
# for composer
    apk add zip git && \
    apk add --no-cache \
# for intl
    icu-dev \
# for zip
    zlib-dev libzip-dev && \
    docker-php-ext-install opcache intl bcmath zip pdo_mysql pcntl
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i "s/display_errors = Off/display_errors = On/" /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 16M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 16M/" /usr/local/etc/php/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /usr/local/etc/php/php.ini && \
    sed -i "s/variables_order = .*/variables_order = 'EGPCS'/" /usr/local/etc/php/php.ini&& \
    sed -i "s/pm.max_children = .*/pm.max_children = 60/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.start_servers = .*/pm.start_servers = 20/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = 15/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = 25/" /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html
COPY . /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER 1
RUN cp .env.example .env && \
    curl -sS https://getcomposer.org/installer | php -- && \
# for more speed
    php composer.phar config -g repos.packagist composer https://packagist.kr && \
    php composer.phar global require hirak/prestissimo && \
# composer install
    php composer.phar install --no-dev --no-scripts && \
# change directory permission
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache/ && \
# run start.sh
    cp docker/start.sh /usr/local/bin/start && chmod u+x /usr/local/bin/start

CMD ["start"]
