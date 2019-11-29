#!/bin/bash

set -e

## Providence
# Admin karpeta sortu
if [ ! -d /var/www/html/admin ]
then
	mkdir /var/www/html/admin
fi

# Fitxategiak ekarri
if [ -d /var/www/html/admin/media ]
then
    rsync -a /usr/src/collective-access/ /var/www/html/admin/ --exclude media/
else
    cp -r /usr/src/collective-access/* /var/www/html/admin/
fi

# Konfigurazio fitxategia sortu, ez bada existitzen
if [ ! -f /var/www/html/admin/setup.php ]
then
    cp /var/www/html/admin/setup.php-dist /var/www/html/admin/setup.php 

    # DB konexioa
    sed -i 's/localhost/'"$PROVIDENCE_DB_HOST"'/g' /var/www/html/admin/setup.php
    sed -i 's/my_database_user/'"$PROVIDENCE_DB_USER"'/g' /var/www/html/admin/setup.php
    sed -i 's/my_database_password/'"$PROVIDENCE_DB_PASSWORD"'/g' /var/www/html/admin/setup.php
    sed -i 's/name_of_my_database/'"$PROVIDENCE_DB_NAME"'/g' /var/www/html/admin/setup.php

    # APP config
    sed -i 's/My First CollectiveAccess System/'"$PROVIDENCE_APP_DISPLAY_NAME"'/g' /var/www/html/admin/setup.php
    sed -i 's/info@put-your-domain-here.com/'"$PROVIDENCE_ADMIN_EMAIL"'/g' /var/www/html/admin/setup.php
fi

## Pawtucket2
cp -r /usr/src/pawtucket/* /var/www/html/

# Konfigurazio fitxategia sortu
if [ ! -f /var/www/html/setup.php ]
then
    cp /var/www/html/setup.php-dist /var/www/html/setup.php 

    # DB konexioa
    sed -i 's/localhost/'"$PROVIDENCE_DB_HOST"'/g' /var/www/html/setup.php
    sed -i 's/my_database_user/'"$PROVIDENCE_DB_USER"'/g' /var/www/html/setup.php
    sed -i 's/my_database_password/'"$PROVIDENCE_DB_PASSWORD"'/g' /var/www/html/setup.php
    sed -i 's/name_of_my_database/'"$PROVIDENCE_DB_NAME"'/g' /var/www/html/setup.php

    # APP config
    sed -i 's/My First CollectiveAccess System/'"$PROVIDENCE_APP_DISPLAY_NAME"'/g' /var/www/html/setup.php
    sed -i 's/info@put-your-domain-here.com/'"$PROVIDENCE_ADMIN_EMAIL"'/g' /var/www/html/setup.php
fi

# Sortu lotura sinbolikoa
if [ ! -d /var/www/html/media ]
then
    mv /var/www/html/admin/media /var/www/html/
    ln -s  /var/www/html/media /var/www/html/admin/media
    chown -h www-data:www-data /var/www/html/admin/media/
fi

# Baimenak egokitu
chown -R www-data:www-data /var/www/html/

# PHP entrypoint
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
