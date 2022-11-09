#!/bin/bash
#

echo "[ENTRYPOINT] Checking for existing wordpress install at /var/www/html"

if [ -d "/var/www/html" ]
then
        if [ -z "$(ls -A /var/www/html)" ]; then
                # install wordpress
                echo "[ENTRYPOINT] Unzipping latest.zip into /tmp..."
                unzip /latest.zip -d /tmp
                echo "[ENTRYPOINT] Moving temp files into http root..."
                mv /tmp/wordpress/* /var/www/html
                echo "[ENTRYPOINT] Cleaning up tmp file"
                rm -rf /tmp/wordpress
		echo "[ENTRYPOINT] Setting permissions to apache user..."
		chown apache:apache -R /var/www/html
	else
                echo "[ENTRYPOINT] Existing files found at http root, not installing wordpress"
        fi
else
        echo "[ENTRYPOINT] http root not found! something went horribly wrong"
fi

echo "[ENTRYPOINT] Starting php-fpm process..."
/usr/sbin/php-fpm
sleep 1
echo "[ENTRYPOINT] Starting Apache process..."
exec /usr/sbin/httpd -D FOREGROUND
