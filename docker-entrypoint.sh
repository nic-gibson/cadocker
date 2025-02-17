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

# Sortu 'fototeka' taldea
getent group fototeka &>/dev/null || groupadd --gid $FOTOTEKA_GROUP_ID fototeka
# Sortu 'fototeka' erabiltzailea
id -u fototeka &>/dev/null || useradd -d /var/www/html -s /bin/bash -u $FOTOTEKA_USER_ID -g fototeka fototeka

# Sortu lotura sinbolikoa
if [ ! -d /var/www/html/media ]
then
    ln -s  /var/www/html/admin/media /var/www/html/media
    chown -h fototeka:fototeka /var/www/html/media/
fi

# Baimenak egokitu
chown -R fototeka:fototeka /var/www/html/

# PHP.ini egokitu
# Errepresentazio bat kargatzean "CSRF token is not valid" errorea ematen badu tamaina muga gainditu delako izan daiteke (Lehen 8M zen).
sed -i -E 's/upload_max_filesize = [0-9]+M/upload_max_filesize = 150M/g' /usr/local/etc/php/php.ini
sed -i -E 's/post_max_size = [0-9]+M/post_max_size = 150M/g' /usr/local/etc/php/php.ini

# Exekuzio denbora 30 segundotik 60ra handitu. Bilaketak egiten denbora asko pasatzen du batzuetan.
sed -i -E 's/max_execution_time = [0-9]+/max_execution_time = 60/g' /usr/local/etc/php/php.ini

# Redis kontainer batekin erabili ahal izateko.
# https://stackoverflow.com/questions/8141407/install-pecl-modules-without-the-prompts
printf "\n" | pecl install redis
echo "extension=redis.so" >> /usr/local/etc/php/php.ini

# 1.16.0 bertsio berriak menpekotasun arazoak ematen zituen.
composer --working-dir=/var/www/html/admin require phpoffice/phpspreadsheet:1.15.0

# convert-ek erroreak ematen ditu fitxategi handiekin. Memoria eta disko gehiago erabiltzen utzi.
sed -i -E 's/name="memory" value="[0-9]+MiB"/name="memory" value="3GiB"/g' /etc/ImageMagick-6/policy.xml
sed -i -E 's/name="disk" value="[0-9]+GiB"/name="disk" value="3GiB"/g' /etc/ImageMagick-6/policy.xml

# PHP entrypoint
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
