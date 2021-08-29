#!/bin/bash
set -e
# 定义修改源函数
. /installdata/alterSources.sh
# 配置运行环境变量
echo "===================配置运行环境变量==================="
cd ~
alias python=python3
alias pip=pip3
echo "export PATH=/home/frappe/.local/bin:\$PATH" >> ~/.bashrc
export PATH=/home/frappe/.local/bin:$PATH
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
# 重启redis-server和mariadb
echo "===================重启redis-server和mariadb==================="
sudo service redis-server restart
sudo service mysql restart
# 安装bench
echo "===================安装bench==================="
sudo -H pip3 install frappe-bench
# 测试bench安装
echo "===================测试bench安装是否成功，如显示版本号为成功如“5.2.1”，否则安装失败。==================="
bench --version
# 初始化frappe
echo "===================初始化frappe==================="
# 如果有"fromGitee"参数则添加Gitee仓库地址。
if [ "$(echo $* |grep -o fromGitee)" == "fromGitee" ];then
    echo "===================从Gitee仓库拉取==================="
    bench init --frappe-branch version-13 --python /usr/bin/python3 --ignore-exist frappe-bench --frappe-path=https://gitee.com/qinyanwan/frappe
else
    echo "===================从官方仓库拉取==================="
    bench init --frappe-branch version-13 --python /usr/bin/python3 --ignore-exist frappe-bench
fi
# 获取erpnext应用
echo "===================获取erpnext应用==================="
cd ~/frappe-bench
# 如果有"fromGitee"参数则添加Gitee仓库地址。
if [ "$(echo $* |grep -o fromGitee)" == "fromGitee" ];then
    echo "===================从Gitee仓库拉取==================="
    bench get-app --branch version-13 erpnext https://gitee.com/qinyanwan/erpnext
else
    echo "===================从官方仓库拉取==================="
    bench get-app --branch version-13 erpnext
fi
# cd ~/frappe-bench && ./env/bin/pip3 install -e apps/erpnext/
# 建立新网站site1.local
echo "===================建立新网站site1.local==================="
bench new-site --mariadb-root-password ${MARIADB_ROOT_PASSWORD} --admin-password ${ADMIN_PASSWORD} site1.local
# 安装erpnext应用到新网站
echo "===================安装erpnext应用到新网站==================="
bench --site site1.local install-app erpnext
# 安装中文本地化
echo "===================安装中文本地化==================="
bench get-app https://gitee.com/yuzelin/erpnext_chinese.git
bench --site site1.local install-app erpnext_chinese
# 设置网站超时时间
echo "===================设置网站超时时间==================="
bench config http_timeout 6000
# 修正权限
echo "===================修正权限==================="
sudo chown -R frappe:frappe /home/frappe/frappe-bench/*
# 修改安装源为国内源
if [ "$(echo $* |grep -o cnMirror)" == "cnMirror" ];then
    echo "===================修改安装源为国内源==================="
    sudo /installdata/alterSources.sh all
    cp -af /root/.pip /home/frappe/
fi
# 清理垃圾,ERPNext安装完毕
echo "===================清理垃圾,ERPNext安装完毕==================="
sudo -H apt clean
sudo -H apt autoremove
sudo -H rm -rf /var/lib/apt/lists/*
sudo -H pip cache purge
sudo -H npm cache clean --force
sudo -H yarn cache clean
# 确认安装
echo "===================确认安装==================="
bench version
exit 0
