#！/bin/bash
service redis-server restart
nohup mysqld_safe &
cd /home/frappe/frappe-bench
bench start
