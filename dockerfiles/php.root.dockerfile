FROM php:7.3-fpm-bullseye

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
        libzip-dev \
        firebird-dev \
		git \
		build-essential \
		automake \
		bison \
		flex \
		libtool \
		unzip \
		re2c --no-install-recommends --no-install-suggests \
	&& mkdir -p /tmp/sdk \
	&& mkdir -p /opt/sqlanywhere16 \
	&& cd /tmp \
	&& curl -fSL https://s3.amazonaws.com/sqlanywhere/drivers/php/sasql_php.zip -o ./sdk/sasql_php.zip \
	&& git clone --depth 1 https://github.com/cbsan/sdk-sqlanywhere-php.git dep_sdk \
	&& cp -r ./dep_sdk/dep_lib/* /opt/sqlanywhere16 \
	&& cd ./sdk \
	&& unzip sasql_php.zip \
	&& phpize \
	&& phpize \
	&& ./configure --with-sqlanywhere \
	&& make \
	&& make install \
	&& docker-php-ext-enable sqlanywhere \
	&& rm -rf /tmp/* \
	&& echo "/opt/sqlanywhere16/lib64" >> /etc/ld.so.conf.d/sqlanywhere16.conf \
	&& ldconfig \
	&& cd / && ln -sF /opt/sqlanywhere16/dblgen16.res dblgen16.res \
	&& apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $DEP_BUILD

RUN docker-php-ext-configure gd
RUN docker-php-ext-install -j$(nproc) gd
RUN sed -i "s/user = www-data/user = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN docker-php-ext-install pdo pdo_mysql gd pdo_firebird zip
    
USER root

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
