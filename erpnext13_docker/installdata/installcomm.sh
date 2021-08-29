#!/bin/bash
set -e
# 定义修改源函数
. /installdata/alterSources.sh
# 修改安装源加速国内安装。
if [ $1 == "cnMirror" ];then
    echo "===================修改安装源加速国内安装==================="
    aptSources
else
    echo "===================不修改安装源==================="
fi
# 安装基础软件
echo "===================安装基础软件==================="
apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y \
    sudo \
    wget \
    curl \
    python3 \
    python3-pip \
    locales \
    tzdata \
    git \
    cron \
    software-properties-common \
    mariadb-server-10.3 \
    mariadb-client \
    python3-mysqldb \
    redis-server 
# 安装wkhtmltox
echo "===================安装wkhtmltox==================="
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb -P /tmp/
apt install -y /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
rm -f /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
wkhtmltopdf -V
# 修改pip默认源加速国内安装
if [ $1 == "cnMirror" ];then
    echo "===================修改pip默认源加速国内安装==================="
    pipSources
else
    echo "===================不修改pip源==================="
fi
# 建立新用户组和用户
echo "===================建立新用户组和用户==================="
groupadd -g 1000 frappe
useradd --no-log-init -r -m -u 1000 -g 1000 -G  sudo frappe
echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir -p /home/frappe
# 修改用户pip默认源加速国内安装
if [ $1 == "cnMirror" ];then
    echo "===================修改用户pip默认源加速国内安装==================="
    cp -af /root/.pip /home/frappe/
else
    echo "===================不修改用户pip源==================="
fi
# 修正用户目录权限
chown -R frappe.frappe /home/frappe
# 设置语言环境
echo "===================设置语言环境==================="
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo -e "export LC_ALL=en_US.UTF-8\nexport LC_CTYPE=en_US.UTF-8\nexport LANG=en_US.UTF-8" >> /root/.bashrc
echo -e "export LC_ALL=en_US.UTF-8\nexport LC_CTYPE=en_US.UTF-8\nexport LANG=en_US.UTF-8" >> /home/frappe/.bashrc
# 设置时区为上海
echo "===================设置时区为上海==================="
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
# 设置监控文件数量上限
echo "===================设置监控文件数量上限==================="
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf
# 安装并升级pip及工具包
echo "===================安装并升级pip及工具包==================="
cd ~
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools cryptography psutil
alias python=python3
alias pip=pip3
# 修改数据库配置文件
echo "===================修改数据库配置文件==================="
echo "[mysqld]" >> /etc/mysql/my.cnf
echo "character-set-client-handshake = FALSE" >> /etc/mysql/my.cnf
echo "character-set-server = utf8mb4" >> /etc/mysql/my.cnf
echo "collation-server = utf8mb4_unicode_ci" >> /etc/mysql/my.cnf
echo "bind-address = 0.0.0.0" >> /etc/mysql/my.cnf
echo "" >> /etc/mysql/my.cnf
echo "[mysql]" >> /etc/mysql/my.cnf
echo "default-character-set = utf8mb4" >> /etc/mysql/my.cnf
service mysql restart
# 授权远程访问并修改密码
echo "===================修改数据库root本地访问密码==================="
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}' WITH GRANT OPTION;"
# echo "===================修改数据库root远程访问密码==================="
# mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}' WITH GRANT OPTION;"
echo "===================数据库配置完成==================="
# 安装nodejs
echo "===================安装nodejs==================="
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt install -y nodejs
# 修改npm源
if [ $1 == "cnMirror" ];then
    echo "===================修改npm源加速国内安装==================="
    npmSources
else
    echo "===================不修改npm源==================="
fi
# 升级npm
echo "===================升级npm==================="
npm install -g npm
# 安装yarn
echo "===================安装yarn==================="
npm install -g yarn
# 修改yarn源
if [ $1 == "cnMirror" ];then
    echo "===================修改yarn源加速国内安装==================="
    yarnSources
else
    echo "===================不修改yarn源==================="
fi
# 基础需求安装完毕。
echo "===================基础需求安装完毕。==================="
exit 0
