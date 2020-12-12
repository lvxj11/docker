#!/bin/sh
docker run -itd -p 46110:80 -p 46111:46111 -p 46112:3306 -p 46113:8000 \
  -v erp12u18_db:/var/lib/mysql \
  -v erp12u18_nginx:/etc/nginx \
  -v erp12u18_tmp:/tmp \
  -v erp12u18_home:/home \
  --name erp12u18 ubuntu:18.04
docker cp ./sources.list.ubuntu18 erp12u18:/etc/apt/sources.list
docker cp ./installdata erp12u18:/tmp/
docker exec -it erp12u18 bash -c 'cd /tmp/installdata && ./installapp.sh'