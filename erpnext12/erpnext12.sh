#!/bin/sh
docker run -itd -p 46114:80 -p 46115:46115 -p 46116:3306 -p 46117:8000 \
  -v erpnext12_db:/var/lib/mysql \
  -v erpnext12_nginx:/etc/nginx \
  -v erpnext12_tmp:/tmp \
  -v erpnext12_home:/home \
  --name erpnext12 ubuntu:18.04
docker cp ./sources.list.ubuntu18 erpnext12:/etc/apt/sources.list
docker cp ./installdata erpnext12:/tmp/
docker exec -it erpnext12 bash -c 'cd /tmp/installdata && ./installapp.sh'