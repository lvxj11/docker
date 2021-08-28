#!/bin/bash
set -e
# 定义修改源函数
aptSources() {
    # 在执行前确定有操作权限
    rm -f /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' > /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list
}
pipSources() {
    # 在执行前确定有操作权限
    mkdir -p ~/.pip
    echo '[global]' > ~/.pip/pip.conf
    echo 'index-url = https://mirrors.aliyun.com/pypi/simple' >> ~/.pip/pip.conf
    echo '[install]' >> ~/.pip/pip.conf
    echo 'trusted-host = mirrors.aliyun.com' >> ~/.pip/pip.conf
}
# 修改安装源加速国内安装。
echo "===================根据参数决定是否修改安装源==================="
if [ $1 != "noMirror" ];then
    echo "===================修改安装源加速国内安装==================="
    aptSources
else
    echo "===================不修改安装源==================="
fi
# 安装基础软件
echo "===================安装基础软件==================="
apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y \
    git \
    build-essential \
    python3-dev \
    python3-setuptools \
    python3-pip \
    libffi-dev \
    cron \
    locales \
    sudo \
    wget \
    curl \
    tzdata \
    dnsmasq \
    fontconfig \
    htop \
    libcrypto++-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libxext6 \
    libxrender1 \
    libxslt1-dev \
    libxslt1.1 \
    ntp \
    postfix \
    python-tk \
    screen \
    vim \
    xfonts-75dpi \
    xfonts-base \
    zlib1g-dev \
    libsasl2-dev \
    libldap2-dev \
    libcups2-dev \
    pv \
    libssl1.1 \
    virtualenv \
    software-properties-common \
    dirmngr \
    apt-transport-https \
    redis-server
# 安装wkhtmltox
echo "===================安装wkhtmltox==================="
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb -P /tmp/
apt install -y /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
rm -f /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
# 修改pip默认源加速国内安装
echo "===================根据参数决定是否修改pip源==================="
if [ $1 != "noMirror" ];then
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
echo "===================根据参数决定是否修改用户pip源==================="
if [ $1 != "noMirror" ];then
    echo "===================修改用户pip默认源加速国内安装==================="
    cp -af /root/.pip /home/frappe/
else
    echo "===================不修改用户pip源==================="
fi
echo -e "export LC_ALL=en_US.UTF-8\nexport LC_CTYPE=en_US.UTF-8\nexport LANG=en_US.UTF-8" >> /home/frappe/.bashrc
chown -R frappe.frappe /home/frappe
# 设置语言环境
echo "===================设置语言环境==================="
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo -e "export LC_ALL=en_US.UTF-8\nexport LC_CTYPE=en_US.UTF-8\nexport LANG=en_US.UTF-8" >> /root/.bashrc
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
# 安装mariadb10.3版
echo "===================安装mariadb10.3版==================="
# apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirrors.tuna.tsinghua.edu.cn/mariadb/repo/10.3/ubuntu bionic main'
# echo "deb https://mirrors.aliyun.com/mariadb/repo/10.3/ubuntu bionic main" > /etc/apt/sources.list.d/mariadb.list
apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y \
    mariadb-server \
    mariadb-client \
    libmariadbclient18 \
    python3-mysqldb
# 修改数据库配置文件
echo "===================修改数据库配置文件==================="
echo "[mysqld]" > /etc/mysql/conf.d/frappe.cnf
echo "character-set-client-handshake = FALSE" >> /etc/mysql/conf.d/frappe.cnf
echo "character-set-server = utf8mb4" >> /etc/mysql/conf.d/frappe.cnf
echo "collation-server = utf8mb4_unicode_ci" >> /etc/mysql/conf.d/frappe.cnf
echo "bind-address = 0.0.0.0" >> /etc/mysql/conf.d/frappe.cnf
# echo "skip-name-resolve = 1" >> /etc/mysql/conf.d/frappe.cnf
echo "" >> /etc/mysql/conf.d/frappe.cnf
echo "[mysql]" >> /etc/mysql/conf.d/frappe.cnf
echo "default-character-set = utf8mb4" >> /etc/mysql/conf.d/frappe.cnf
echo "" >> /etc/mysql/conf.d/frappe.cnf
service mysql restart
# 授权远程访问并修改密码
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}' WITH GRANT OPTION;"
mysqladmin -u root -h 127.0.0.1 password ${MARIADB_ROOT_PASSWORD}
# 安装nodejs
echo "===================安装nodejs==================="
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt install -y nodejs
# 修改npm源
echo "===================根据参数决定是否修改npm源==================="
if [ $1 != "noMirror" ];then
    echo "===================修改npm源加速国内安装==================="
    npm config set registry https://registry.npm.taobao.org
else
    echo "===================不修改npm源==================="
fi
# 安装yarn
echo "===================安装yarn==================="
npm install -g yarn
# 修改yarn源
echo "===================根据参数决定是否修改yarn源==================="
if [ $1 != "noMirror" ];then
    echo "===================修改yarn源加速国内安装==================="
    yarn config set registry https://registry.npm.taobao.org
else
    echo "===================不修改yarn源==================="
fi
# 清理垃圾，基础需求安装完毕。
echo "===================清理垃圾，基础需求安装完毕。==================="
apt clean
apt autoremove
rm -rf /var/lib/apt/lists/*
pip cache purge
npm cache clean --force
yarn cache clean
exit 0
