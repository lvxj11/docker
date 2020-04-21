#!/bin/bash
cd /home/frappe/frappe-bench
bench new-site --mariadb-root-password ${MARIADB_ROOT_PASSWORD} --admin-password ${ADMIN_PASSWORD} $1
bench --site $1 install-app erpnext
