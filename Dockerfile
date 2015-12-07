# Docker version 1.8.2
FROM ubuntu:14.04
MAINTAINER Ruben Taelman "ruben.taelman@ugent.be"

# VIAA proxy
ENV http_proxy="http://proxy.do.viaa.be:80/"
ENV https_proxy="http://proxy.do.viaa.be:80/"

# Install apache2
RUN apt-get -y update
RUN apt-get install -y apache2 php5 libapache2-mod-php5 mysql-client php5-mysql
EXPOSE 80

# Install requirements
RUN apt-get install -y git curl tar

# Install Zend 1.11
RUN curl https://packages.zendframework.com/releases/ZendFramework-1.11.15/ZendFramework-1.11.15.tar.gz -o /tmp/zend.tar.gz
RUN mkdir -p /var/www/zend && tar -xvzf /tmp/zend.tar.gz -C /var/www/zend --strip-components 1

# Install OpenSKOS
RUN git clone https://github.com/rubensworks/OpenSKOS.git /var/www/OpenSKOS
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

# Install Java
RUN DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update -y
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Install Apache Solr 3.4
RUN curl http://archive.apache.org/dist/lucene/solr/3.4.0/apache-solr-3.4.0.tgz -o /tmp/solr.tar.gz
RUN mkdir -p /var/www/solr && tar -xvzf /tmp/solr.tar.gz -C /var/www/solr --strip-components 1

# Configure Solr
RUN mkdir /var/www/solr/example/openskos
RUN cp -r /var/www/OpenSKOS/data/solr/conf /var/www/solr/example/openskos

# Setup and start server
CMD /tmp/setup.sh \
    && cd /var/www/solr/example && (java -Dsolr.solr.home="./openskos" -Xms1024m -Xmx1024m -jar start.jar &) \
    && /usr/sbin/apache2ctl -D FOREGROUND

