#!/bin/bash
docker run --rm -p 3000:80 -i -t openskos /usr/sbin/apache2ctl -D FOREGROUND
