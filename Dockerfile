FROM php:7.0-fpm

MAINTAINER Farouk HAMA ISSA <issa.farouk@gmail.com>

# Install "curl", "libmemcached-dev", "libpq-dev", "libjpeg-dev",
#         "libpng12-dev", "libfreetype6-dev", "libssl-dev", "libmcrypt-dev",
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng12-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev

# Install the PHP mcrypt extention
RUN docker-php-ext-install mcrypt

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql

# Install the PHP gd library
RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

# PHP Memcached:
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p memcached \
    && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && ( \
        cd memcached \
        && phpize \
        && ./configure \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r memcached \
    && rm /tmp/memcached.tar.gz \
    && docker-php-ext-enable memcached

# xDebug:

RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

## Copy xdebug configration for remote debugging

COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# PHP REDIS EXTENSION FOR PHP 7.0

RUN  pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis
#
## ZipArchive:
#
RUN pecl install zip && \
    docker-php-ext-enable zip
#
## bcmath:
#
RUN docker-php-ext-install bcmath
#
#
ADD ./maniart.ini /usr/local/etc/php/conf.d
ADD ./maniart.pool.conf /usr/local/etc/php-fpm.d/
#
RUN rm -r /var/lib/apt/lists/*
#
RUN usermod -u 1000 www-data
#
WORKDIR /var/www
#
CMD ["php-fpm"]
#
EXPOSE 9000
