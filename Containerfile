FROM registry.fedoraproject.org/fedora:37

# some labels because this is a thing
LABEL io.k8s.description="Wordpress image based on Fedora 37 with Apache and FPM"
LABEL com.drachenz.author="James"
LABEL com.drachenz.name="f37_wp"
LABEL io.openshift.wants="mariadb"

# Install packages to fedora base image
RUN dnf update -y && \
    dnf install -y httpd php-gd php-sodium php php-xml php-common php-mysqlnd && \
    dnf install -y php-pecl-imagick unzip && \
    dnf clean all && \
    rm -rf /var/www/html/*

# Create run dir for php-fpm, set permissions to non-root and to work with
# any uid OpenShift gives us
RUN mkdir /run/php-fpm && \
    chown apache:0 -R /run/php-fpm && \
    chmod -R g=u /run/php-fpm && \
    chown apache:0 -R /run/httpd && \
    chown apache:0 -R /var/www/html && \
    chmod -R g=u /run/httpd && \
    chmod -R g=u /var/www/html

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

# use 8080 so process can start non-root
EXPOSE 8080

# Define volume for persistent website data
VOLUME ["/var/www/html"]

# set user to apache uid. if this is OpenShift it'll just
# give whatever uid it picks 
USER apache

# Launch point when container is run
ENTRYPOINT ["/entrypoint.sh"]
