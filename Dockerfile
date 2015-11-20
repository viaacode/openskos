# Docker version 1.8.2
FROM ubuntu:14.04
MAINTAINER Ruben Taelman "ruben.taelman@ugent.be"

# Install apache2
RUN apt-get -y update
RUN apt-get install -y apache2 php5 libapache2-mod-php5 mysql-client
EXPOSE 80

# Install requirements
RUN apt-get install -y git curl tar

# Install Zend 1.11
RUN curl https://packages.zendframework.com/releases/ZendFramework-1.11.15/ZendFramework-1.11.15.tar.gz -o /tmp/zend.tar.gz
RUN mkdir -p /var/www/zend && tar -xvzf /tmp/zend.tar.gz -C /var/www/zend --strip-components 1

# Install OpenSKOS
RUN git clone https://github.com/CatchPlus/OpenSKOS.git /var/www/OpenSKOS
COPY application.ini /var/www/OpenSKOS/application/configs/application.ini

# TODO: temp
RUN apt-get install -y vim

# Install correct configuration files
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY php.ini /etc/php5/apache2/php.ini
COPY setup.sh /tmp/setup.sh

# To enable fancy .htaccess rewriting rules
RUN a2enmod rewrite

# Set directory permissions
RUN chmod a+w /var/www/OpenSKOS/data/uploads \
    && chmod a+w /var/www/OpenSKOS/cache \
    && chmod a+w /var/www/OpenSKOS/public/data/icons/assigned \
    && chmod a+w /var/www/OpenSKOS/public/data/icons/uploads \
    && chmod -R a+r /var/www/OpenSKOS/

# Setup and start server
CMD /tmp/setup.sh && /usr/sbin/apache2ctl -D FOREGROUND
#CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]

