#!/bin/bash

set -e

# Fitxategiak ekarri
cp -r /usr/src/collective-access/* /var/www/html/

# Konfigurazio fitxategia sortu
cp /var/www/html/setup.php-dist /var/www/html/setup.php 

# Baimenak
chown -R www-data:www-data /var/www/html/

# DB konexioa
sed -i 's/localhost/'"$PROVIDENCE_DB_HOST"'/g' /var/www/html/setup.php
sed -i 's/my_database_user/'"$PROVIDENCE_DB_USER"'/g' /var/www/html/setup.php
sed -i 's/my_database_password/'"$PROVIDENCE_DB_PASSWORD"'/g' /var/www/html/setup.php
sed -i 's/name_of_my_database/'"$PROVIDENCE_DB_NAME"'/g' /var/www/html/setup.php

# APP config
sed -i 's/My First CollectiveAccess System/'"$PROVIDENCE_APP_DISPLAY_NAME"'/g' /var/www/html/setup.php
sed -i 's/info@put-your-domain-here.com/'"$PROVIDENCE_ADMIN_EMAIL"'/g' /var/www/html/setup.php


# PHP entrypoint
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
