#!/bin/bash
docker run -itd -p 46110:80 -p 46111:9000 -p 46112:3306 -p 46113:8000 \
  -v erp12_db:/var/lib/mysql \
  -v erp12_nginx:/etc/nginx \
  -v erp12_tmp:/tmp \
  -v erp12_home:/home \
  --name erp12 erpnext:t5 \
  bash -c "sudo service redis-server restart \
      && sudo service mysql restart \
      && export LC_ALL=en_US.UTF-8 \
      && export LC_CTYPE=en_US.UTF-8 \
      && export LANG=en_US.UTF-8 \
      && export PATH=/home/frappe/.local/bin:$PATH \
      && cd ~/frappe-bench \
      && bench start"
  