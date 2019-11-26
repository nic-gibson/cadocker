#!/bin/bash

set -e

## Collective Access
# Admin karpeta sortu
if [ ! -d /var/www/html/admin ]
then
	mkdir /var/www/html/admin
fi
# Fitxategiak ekarri
cp -r /usr/src/collective-access/* /var/www/html/admin/

# Konfigurazio fitxategia sortu
cp /var/www/html/admin/setup.php-dist /var/www/html/admin/setup.php 

# DB konexioa
sed -i 's/localhost/'"$PROVIDENCE_DB_HOST"'/g' /var/www/html/admin/setup.php
sed -i 's/my_database_user/'"$PROVIDENCE_DB_USER"'/g' /var/www/html/admin/setup.php
sed -i 's/my_database_password/'"$PROVIDENCE_DB_PASSWORD"'/g' /var/www/html/admin/setup.php
sed -i 's/name_of_my_database/'"$PROVIDENCE_DB_NAME"'/g' /var/www/html/admin/setup.php

# APP config
sed -i 's/My First CollectiveAccess System/'"$PROVIDENCE_APP_DISPLAY_NAME"'/g' /var/www/html/admin/setup.php
sed -i 's/info@put-your-domain-here.com/'"$PROVIDENCE_ADMIN_EMAIL"'/g' /var/www/html/admin/setup.php


## Pawtucket2
cp -r /usr/src/pawtucket/* /var/www/html/

# Konfigurazio fitxategia sortu
cp /var/www/html/setup.php-dist /var/www/html/setup.php 


# Media karpeta sortu
if [ ! -d /var/www/html/media ]
then
	mkdir /var/www/html/media
fi
# Sortu lotura sinbolikoa
ln -s  /var/www/html/media /var/www/html/admin/media
chown -h www-data:www-data /var/www/html/admin/media/

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
