#！/bin/bash
sudo echo -n > /home/frappe/frappe-bench/sites/currentsite.txt
ps -ef|grep '/bin/sh /init-start.sh' |grep -v grep|awk '{print $2}' | xargs kill -9
