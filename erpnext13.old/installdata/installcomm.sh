#!/bin/bash
set -e
# 定义修改源函数
. /installdata/alterSources.sh
# 修改安装源加速国内安装。
if [ "$1" == "cnMirror" ];then
    echo "===================修改安装源加速国内安装==================="
    aptSources
else
    echo "===================不修改安装源==================="
fi
# 安装基础软件
echo "===================安装基础软件==================="
apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y \
    sudo \
    wget \
    curl \
    python3-dev \
    python3-setuptools \
    python3-pip \
    locales \
    tzdata \
    git \
    cron \
    software-properties-common \
    mariadb-server-10.3 \
    mariadb-client \
    libmysqlclient-dev \
    virtualenv \
    redis-server 
# 安装wkhtmltox
echo "===================安装wkhtmltox==================="
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb -P /tmp/
apt install -y /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
rm -f /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
wkhtmltopdf -V
# 修改pip默认源加速国内安装
if [ "$1" == "cnMirror" ];then
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
if [ "$1" == "cnMirror" ];then
    echo "===================修改用户pip默认源加速国内安装==================="
    cp -af /root/.pip /home/frappe/
else
    echo "===================不修改用户pip源==================="
fi
# 修正用户目录权限
chown -R frappe.frappe /home/frappe
# 修正用户shell
usermod -s /bin/bash frappe
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
# 获取最新版nodejs-v14，并安装
nodejs0=$(curl -sL https://nodejs.org/download/release/latest-v14.x/ | grep -o node-v14.*-linux-x64.tar.xz)
nodejs1=${nodejs0%%.tar*}
echo "==========即将安装nodejs到/usr/local/lib/nodejs/${nodejs1}=========="
wget https://nodejs.org/download/release/latest-v14.x/${nodejs1}.tar.xz -P /tmp/
mkdir -p /usr/local/lib/nodejs
tar -xJf /tmp/${nodejs1}.tar.xz -C /usr/local/lib/nodejs/
echo "export PATH=/usr/local/lib/nodejs/${nodejs1}/bin:\$PATH" >> /etc/profile.d/nodejs.sh
echo "export PATH=/usr/local/lib/nodejs/${nodejs1}/bin:\$PATH" >> ~/.bashrc
export PATH=/usr/local/lib/nodejs/${nodejs1}/bin:$PATH
source /etc/profile
# 修改npm源
if [ "$1" == "cnMirror" ];then
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
if [ "$1" == "cnMirror" ];then
    echo "===================修改yarn源加速国内安装==================="
    yarnSources
else
    echo "===================不修改yarn源==================="
fi
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
/etc/init.d/mysql restart
# 授权远程访问并修改密码
echo "===================修改数据库root本地访问密码==================="
mysqladmin -v -uroot password ${MARIADB_ROOT_PASSWORD}
echo "===================修改数据库root远程访问密码==================="
mysql -u root -p${MARIADB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}' WITH GRANT OPTION;"
echo "===================刷新权限表==================="
mysqladmin -v -uroot -p${MARIADB_ROOT_PASSWORD} reload
sed -i 's/^password.*$/password = '"${MARIADB_ROOT_PASSWORD}"'/' /etc/mysql/debian.cnf
echo "===================数据库配置完成==================="
# 清理垃圾
echo "===================清理垃圾==================="
apt clean
apt autoremove
rm -rf /var/lib/apt/lists/*
pip cache purge
npm cache clean --force
yarn cache clean
# 基础需求安装完毕。
echo "===================基础需求安装完毕。==================="
exit 0
