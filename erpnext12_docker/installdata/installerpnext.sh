#!/bin/bash
set -e
cd ~
# 配置运行环境变量
echo "export PATH=/home/frappe/.local/bin:\$PATH" >> ~/.bashrc
export PATH=/home/frappe/.local/bin:$PATH
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
# 重启redis-server和mariadb
sudo service redis-server restart
sudo service mysql restart
# 安装bench
pip3 install --user frappe-bench --no-cache
# sudo -H pip3 install frappe-bench --no-cache
# 测试bench安装
echo "测试bench安装"
bench --version
# 初始化frappe
bench init --frappe-branch version-12 --python /usr/bin/python3 --ignore-exist frappe-bench
# cd ~/frappe-bench && ./env/bin/pip3 install -e apps/frappe/
# 获取erpnext应用
cd ~/frappe-bench
bench get-app --branch version-12 erpnext
# cd ~/frappe-bench && ./env/bin/pip3 install -e apps/erpnext/
# 设置网站超时时间
bench config http_timeout 6000
# 建立新网站
bench new-site --mariadb-root-password ${MARIADB_ROOT_PASSWORD} --admin-password ${ADMIN_PASSWORD} site1.local
# 安装erpnext应用到新网站
bench --site site1.local install-app erpnext
# 清理垃圾
apt clean
apt autoremove
rm -rf /var/lib/apt/lists/*
pip cache purge
npm cache clean --force
yarn cache clean
exit 0
