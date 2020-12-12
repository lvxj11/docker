#！/bin/bash
sudo service redis-server restart
sudo service mysql restart
cd ~/frappe-bench && bench start
