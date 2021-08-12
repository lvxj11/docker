#!/bin/bash
set -e
cd ~
alias python=python3
alias pip=pip3
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
# pip3 install --user frappe-bench
sudo -H pip3 install frappe-bench
# 测试bench安装
echo "测试bench安装是否成功，如显示版本号为成功如“5.2.1”，否则安装失败。"
bench --version
# 初始化frappe
bench init --frappe-branch version-13 --python /usr/bin/python3 --ignore-exist frappe-bench
# cd ~/frappe-bench && ./env/bin/pip3 install -e apps/frappe/
# 获取erpnext应用
cd ~/frappe-bench
bench get-app --branch version-13 erpnext
# cd ~/frappe-bench && ./env/bin/pip3 install -e apps/erpnext/
# 建立新网站
bench new-site --mariadb-root-password ${MARIADB_ROOT_PASSWORD} --admin-password ${ADMIN_PASSWORD} site1.local
# 安装erpnext应用到新网站
bench --site site1.local install-app erpnext
# 安装中文本地化
bench get-app https://gitee.com/yuzelin/erpnext_chinese.git
bench install-app erpnext_chinese --site site1.local
# 设置网站超时时间
bench config http_timeout 6000
# 修正权限
sudo chown -R frappe:frappe /home/frappe/frappe-bench/*
# 清理垃圾
sudo -H apt clean
sudo -H apt autoremove
sudo -H rm -rf /var/lib/apt/lists/*
sudo -H pip cache purge
sudo -H npm cache clean --force
sudo -H yarn cache clean
exit 0
