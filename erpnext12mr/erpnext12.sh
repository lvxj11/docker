#!/bin/sh
docker run -itd -p 46110:80 -p 46111:9000 -p 46112:3306 -p 46113:8000 \
  -v erp12_db:/var/lib/mysql \
  -v erp12_nginx:/etc/nginx \
  -v erp12_tmp:/tmp \
  -v erp12_home:/home \
  --name erp12 erpnext12
