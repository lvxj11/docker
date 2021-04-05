#!/bin/bash
C_NAME="ERPnext13"
docker run -itd -p 46114:8000 -p 46115:9000 \
  -v ${C_NAME}_db:/var/lib/mysql \
  -v ${C_NAME}_sites:/home/frappe/frappe-bench/sites \
  --name ${C_NAME} registry.cn-beijing.aliyuncs.com/lvxj11/erpnext13:2021.04.05
