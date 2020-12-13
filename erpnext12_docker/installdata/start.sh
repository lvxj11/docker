#!/bin/bash
source /etc/profile
sudo service redis-server restart
sudo service mysql restart
export PATH=/home/frappe/.local/bin:\$PATH
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
cd ~/frappe-bench
bench start
