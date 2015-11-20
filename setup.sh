#!/bin/bash
sleep 1
if [ ! -f /.openskos-installed ]; then
    echo "Provisioning..."
    while ! nc -z db 3306; do sleep 3; done
    mysql --host=db -u openskos --password=openskos openskos < /var/www/OpenSKOS/data/openskos-create.sql
    php -d include_path=/var/www/zend/library/ /var/www/OpenSKOS/tools/tenant.php --code 1111 --name ABCD --email admin@example.org --password admin create
    touch /.openskos-installed
fi
