FROM php:7.3-apache-buster

RUN apt-get update && apt-get install -y \
    unzip \
    zlib1g-dev \
    libzip-dev

# Zip extensioa
RUN docker-php-ext-install zip

# Mysql extensioa instalatu
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

ENV PROVINCE_VERSION 1.7.8

# Providence instalatu
RUN curl -fsSL -o providence.zip \
        "https://github.com/collectiveaccess/providence/archive/${PROVINCE_VERSION}.zip";

RUN unzip providence.zip; \
        rm providence.zip; \
        mv providence-${PROVINCE_VERSION}/* /var/www/html/;

COPY docker-entrypoint.sh /usr/local/bin/

RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["apache2-foreground"]
