FROM php:7.3-apache-buster

#
# Konfigurazioa
#

# Erabiltzaile nagusia
USER fototeka

# Apache erabiltzailea
ENV APACHE_RUN_USER fototeka
ENV APACHE_RUN_GROUP fototeka

# Pakete bertsioak zehaztu
ENV PROVINCE_VERSION 1.7.8
ENV PAWTUCKET_VERSION 1.7.8
ENV IMAGEMAGIC_VERSION 7.0.9-7

# PHP lan ingurunea
ARG PHP_ENV
ENV PHP_ENV ${PHP_ENV:-production}

#
# Dependentziak
#

# Beharrezko paketeak instalatu
RUN apt-get update && apt-get install -y \
    unzip \
    rsync \
    ffmpeg \
    zlib1g-dev \
    libzip-dev \
    libpng-dev \
    dcraw
#    build-essential \
#    libmagickwand-dev \
#    libgraphicsmagick1-dev

# Imagemagick
#RUN curl -fsSL -o imagemagick.zip \
#        "https://github.com/ImageMagick/ImageMagick/archive/${IMAGEMAGIC_VERSION}.zip";
#RUN unzip imagemagick.zip > /dev/null; \
#    rm imagemagick.zip;

#RUN cd ImageMagick-${IMAGEMAGIC_VERSION}; \
#    ./configure; \
#    make; \
#    make install; \
#    ldconfig /usr/local/lib;

RUN apt install -y imagemagick;

# Zip extensioa
RUN docker-php-ext-install zip

# Mysql extensioa instalatu
RUN docker-php-ext-install mysqli

# GD extensioa instalatu
RUN docker-php-ext-install gd

#
# Collectiveaccess
#

# Providence instalatu
RUN curl -fsSL -o providence.zip \
        "https://github.com/collectiveaccess/providence/archive/${PROVINCE_VERSION}.zip";

RUN unzip providence.zip > /dev/null; \
        rm providence.zip; \
    mkdir /usr/src/collective-access; \
        mv providence-${PROVINCE_VERSION}/* /usr/src/collective-access/;

# Pawtucket2
RUN curl -fsSL -o pawtucket.zip \
        "https://github.com/collectiveaccess/pawtucket2/archive/${PAWTUCKET_VERSION}.zip";

RUN unzip pawtucket.zip > /dev/null; \
        rm pawtucket.zip; \
    mkdir /usr/src/pawtucket; \
        mv pawtucket2-${PAWTUCKET_VERSION}/* /usr/src/pawtucket/;

# PHP konfigurazio fitxategia kopiatu
RUN cp /usr/local/etc/php/php.ini-$PHP_ENV /usr/local/etc/php/php.ini;

#
# Garbiketak
#
RUN rm -rf providence-${PROVINCE_VERSION}; \
    rm -rf pawtucket2-${PAWTUCKET_VERSION}; \
    rm -rf ImageMagick-${IMAGEMAGIC_VERSION};

#
# Martxan jartzeko
#

COPY docker-entrypoint.sh /usr/local/bin/       

VOLUME /var/www/html

RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["apache2-foreground"]
