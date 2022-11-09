FROM registry.fedoraproject.org/fedora:37

# Install packages to fedora base image
RUN dnf update -y && \
    dnf install -y httpd php-gd php-sodium php php-xml php-common php-mysqlnd && \
    dnf install -y php-pecl-imagick unzip && \
    dnf clean all

# Create run dir for php-fpm
RUN mkdir /run/php-fpm 

# Copy in wordpress zip
# download from: https://wordpress.org/latest.zip
# https://wordpress.org/download/
COPY ./latest.zip /
# Copy in entrypoint script which does the magic once the container is run
COPY ./entrypoint.sh /
RUN chmod 755 /entrypoint.sh

# Clean up anything in /var/www/html
RUN rm -rf /var/www/html/*

# Set Apache to log to stdout instead of file
RUN sed -i 's/ErrorLog \"logs\/error_log\"/ErrorLog \"\/dev\/stdout\"/g' /etc/httpd/conf/httpd.conf
RUN sed -i 's/CustomLog \"logs\/access_log\" combined/CustomLog \"\/dev\/stdout\" combined/g' /etc/httpd/conf/httpd.conf

# Allow permalinks changing in wordpress to work
# replaces 2nd occurence in httpd.conf of AllowOverride None to AllowOverride All. 
# this could get sketchy if httpd conf changes but didn't want to provide my own httpd.conf at this point
RUN sed -i -z 's/AllowOverride None/AllowOverride All/2' /etc/httpd/conf/httpd.conf

# Probably not needed, but Apache is running on port 80 so expose it
EXPOSE 80

# Define volume for persistent website data
VOLUME ["/var/www/html"]

# Launch point when container is run
ENTRYPOINT ["/entrypoint.sh"]
