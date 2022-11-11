FROM registry.fedoraproject.org/fedora:37

# Install packages to fedora base image
RUN dnf update -y && \
    dnf install -y httpd php-gd php-sodium php php-xml php-common php-mysqlnd && \
    dnf install -y php-pecl-imagick unzip && \
    dnf clean all

# Create run dir for php-fpm, set permissions to non-root
RUN mkdir /run/php-fpm && chown apache:apache -R /run/php-fpm

# set apache dir permissions for non-root
RUN chown apache:apache -R /run/httpd
RUN chown apache:apache -R /var/www/html

# Copy in wordpress zip
# download from: https://wordpress.org/latest.zip
# https://wordpress.org/download/
COPY ./latest.zip /
# Copy in entrypoint script which does the magic once the container is run
COPY ./entrypoint.sh /
RUN chmod 755 /entrypoint.sh

# customized config files for apache and php-fpm to start as non-root
COPY etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf
COPY etc/php-fpm.conf /etc/php-fpm.conf
COPY etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf
COPY etc/php.ini /etc/php.ini

# Clean up anything in /var/www/html
RUN rm -rf /var/www/html/*

# use 8080 so process can start non-root
EXPOSE 8080

# Define volume for persistent website data
VOLUME ["/var/www/html"]

# set user to apache uid
USER apache:apache

# Launch point when container is run
ENTRYPOINT ["/entrypoint.sh"]
