#!/bin/bash
set -e
# 只适用于纯净版ubuntu20.04并使用root用户运行，其他系统请自行重新适配。
# 会安装mariadb10.3，redis以及erpnext的其他系统需求。
# 设定参数，已设定常用的默认值。如果你不知道干嘛的就别改了。
# 自定义选项使用方法例：./install.erpnext.sh benchVersion=5.6.0 frappePath=https://gitee.com/mirrors/frappe branch=version-13
# branch参数会同时修改frappe和erpnext的分支。
# 也可以直接修改下列变量
mariadbRootPassword="Pass1234"
adminPassword="admin"
benchVersion=""
frappePath="https://gitee.com/mirrors/frappe"
frappeBranch="version-13"
erpnextPath="https://gitee.com/mirrors/erpnext"
erpnextBranch="version-13"
# 是否修改apt安装源，如果是云服务器建议不修改。
altAptSources="yes"
# 是否跳过确认参数直接安装
quiet="no"
# 遍历参数修改默认值
echo "===================获取参数==================="
for arg in $*
do
    arg0=${arg%=*}
    arg1=${arg#*=}
    echo "$arg0 为 $arg1"
    case "$arg0" in
    "benchVersion")
        benchVersion=${arg1}
        echo "设置bench版本为 ${benchVersion}"
        ;;
    "mariadbRootPassword")
        mariadbRootPassword=${arg1}
        echo "设置数据库根密码为 ${mariadbRootPassword}"
        ;;
    "adminPassword")
        adminPassword=${arg1}
        echo "设置管理员密码为 ${adminPassword}"
        ;;
    "frappePath")
        frappePath=${arg1}
        echo "设置frappe拉取地址为 ${frappePath}"
        ;;
    "frappeBranch")
        frappeBranch=${arg1}
        echo "设置frappe分支为 ${frappeBranch}"
        ;;
    "erpnextPath")
        erpnextPath=${arg1}
        echo "设置erpnext拉取地址为 ${erpnextPath}"
        ;;
    "erpnextBranch")
        erpnextBranch=${arg1}
        echo "设置erpnext分支为 ${erpnextBranch}"
        ;;
    "branch")
        frappeBranch=${arg1}
        erpnextBranch=${arg1}
        echo "设置frappe分支为 ${frappeBranch}"
        echo "设置erpnext分支为 ${erpnextBranch}"
        ;;
    "altAptSources")
        altAptSources=$arg1
        echo "是否修改apt安装源，国内云服务器建议不修改。"
        ;;
    "quiet")
        quiet=$arg1
        echo "不再确认参数，直接安装。"
        ;;
    esac
done
# 显示参数并给参数添加关键字
echo "===================显示参数并给参数添加关键字==================="
echo "数据库密码： ${mariadbRootPassword}"
echo "管理员密码： ${adminPassword}"
if [[ $benchVersion != "" ]];then
    benchVersion="==${benchVersion}"
    echo "bench版本： ${benchVersion}"
fi
if [[ $frappePath != "" ]];then
    frappePath="--frappe-path ${frappePath}"
    echo "frappe拉取地址： ${frappePath}"
fi
if [[ $frappeBranch != "" ]];then
    frappeBranch="--frappe-branch ${frappeBranch}"
    echo "frappe分支： ${frappeBranch}"
fi
if [[ $erpnextPath != "" ]];then
    echo "erpnext拉取地址： ${erpnextPath}"
fi
if [[ $erpnextBranch != "" ]];then
    erpnextBranch="--branch ${erpnextBranch}"
    echo "erpnext分支： ${erpnextBranch}"
fi
if [[ $altAptSources == "yes" ]];then
    echo "修改apt安装源为清华源"
else
    echo "不修改apt安装源"
fi
# 等待确认参数
if [[ $quiet != "yes" ]];then
    read -r -p "是否继续? [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
    		echo "继续安装！"
    		;;
        *)
    	echo "取消安装..."
    	exit 1
    	;;
    esac
fi
# 定义修改源函数
# 修改apt源
aptSources() {
    # 在执行前确定有操作权限
    rm -f /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse' > /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list
    echo "===================apt已修改为国内源==================="
}
# 修改pip源
pipSources() {
    # 在执行前确定有操作权限
    # pip3 config list
    mkdir -p /root/.pip
    echo '[global]' > /root/.pip/pip.conf
    echo 'index-url=https://pypi.tuna.tsinghua.edu.cn/simple' >> /root/.pip/pip.conf
    echo '[install]' >> /root/.pip/pip.conf
    echo 'trusted-host=mirrors.tuna.tsinghua.edu.cn' >> /root/.pip/pip.conf
    echo "===================pip已修改为国内源==================="
}
# 修改npm源
npmSources() {
    # 在执行前确定有操作权限
    # npm get registry
    npm config set registry https://registry.npmmirror.com -g
    echo "===================npm已修改为国内源==================="
}
# 修改yarn源
yarnSources() {
    # 在执行前确定有操作权限
    # yarn config list
    yarn config set registry https://registry.npm.taobao.org --global
    yarn config set sass_binary_site "https://cdn.npm.taobao.org/dist/node-sass/" --global
    echo "===================yarn已修改为国内源==================="
}
# 修改安装源加速国内安装。
if [[ $altAptSources == "yes" ]];then
    aptSources
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
    python3-testresources \
    virtualenv \
    redis-server
# 修改pip默认源加速国内安装
pipSources
# 安装并升级pip及工具包
echo "===================安装并升级pip及工具包==================="
cd ~
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools cryptography psutil
alias python=python3
alias pip=pip3
# 安装wkhtmltox
echo "===================安装wkhtmltox==================="
if [[ $altAptSources != "yes" ]];then
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb -P /tmp/
else
    wget https://gitee.com/lvxj11/wkhtmltopdf/attach_files/941684/download/wkhtmltox_0.12.6-1.focal_amd64.deb -P /tmp/
fi
apt install -y /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
rm -f /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
wkhtmltopdf -V
# 建立新用户组和用户
echo "===================建立新用户组和用户==================="
result=$(grep "frappe:" /etc/group || true)
if [[ "$result" == "" ]]
then
    gid=1000
    while true
    do
        result=$(grep ":${gid}:" /etc/group || true)
        if [[ "$result" == "" ]]
        then
            echo "建立新用户组: ${gid}:frappe"
            groupadd -g ${gid} frappe
            echo "已新建用户组frappe，gid: ${gid}"
            break
        else
            gid=$(expr ${gid} + 1)
        fi
    done
else
    echo '用户组已存在'
fi
result=$(grep "frappe:" /etc/passwd || true)
if [[ "$result" == "" ]]
then
    uid=1000
    while true
    do
        result=$(grep ":x:${uid}:" /etc/passwd || true)
        if [[ "$result" == "" ]]
        then
            echo "建立新用户: ${uid}:frappe"
            useradd --no-log-init -r -m -u ${uid} -g ${gid} -G  sudo frappe
            echo "已新建用户frappe，uid: ${uid}"
            break
        else
            uid=$(expr ${uid} + 1)
        fi
    done
else
    echo '用户已存在'
fi
echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir -p /home/frappe
echo "export PATH=/home/frappe/.local/bin:\$PATH" >> /home/frappe/.bashrc
# 修改用户pip默认源加速国内安装
cp -af /root/.pip /home/frappe/
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
# 检查是否安装nodejs14
if ! type node >/dev/null 2>&1; then
    # 获取最新版nodejs-v14，并安装
    echo "==========获取最新版nodejs-v14，并安装=========="
    nodejs0=$(curl -sL https://nodejs.org/download/release/latest-v14.x/ | grep -o node-v14.*-linux-x64.tar.xz)
    nodejs1=${nodejs0%%.tar*}
    echo "nodejs14最新版本为：${nodejs1}"
    echo "即将安装nodejs14到/usr/local/lib/nodejs/${nodejs1}"
    wget https://nodejs.org/download/release/latest-v14.x/${nodejs1}.tar.xz -P /tmp/
    mkdir -p /usr/local/lib/nodejs
    tar -xJf /tmp/${nodejs1}.tar.xz -C /usr/local/lib/nodejs/
    echo "export PATH=/usr/local/lib/nodejs/${nodejs1}/bin:\$PATH" >> /etc/profile.d/nodejs.sh
    echo "export PATH=/usr/local/lib/nodejs/${nodejs1}/bin:\$PATH" >> ~/.bashrc
    export PATH=/usr/local/lib/nodejs/${nodejs1}/bin:$PATH
    source /etc/profile
else
    result=$(node -v | grep "v14." || true)
    if [[ "$result" == "" ]]
    then
        echo '==========已存在node，但不是v14版。这将有可能导致一些问题。建议卸载node后重试。=========='
    else
        echo '==========已存在nodejs14，跳过安装=========='
    fi
fi
# 修改npm源
npmSources
# 升级npm
echo "===================升级npm==================="
npm install -g npm
# 安装yarn
echo "===================安装yarn==================="
npm install -g yarn
# 修改yarn源
yarnSources
# 修改数据库配置文件
echo "===================修改数据库配置文件==================="
echo "[mysqld]" >> /etc/mysql/my.cnf
echo "character-set-client-handshake=FALSE" >> /etc/mysql/my.cnf
echo "character-set-server=utf8mb4" >> /etc/mysql/my.cnf
echo "collation-server=utf8mb4_unicode_ci" >> /etc/mysql/my.cnf
echo "bind-address=0.0.0.0" >> /etc/mysql/my.cnf
echo "" >> /etc/mysql/my.cnf
echo "[mysql]" >> /etc/mysql/my.cnf
echo "default-character-set=utf8mb4" >> /etc/mysql/my.cnf
/etc/init.d/mysql restart
# 授权远程访问并修改密码
echo "===================修改数据库root本地访问密码==================="
mysqladmin -v -uroot password ${mariadbRootPassword}
echo "===================修改数据库root远程访问密码==================="
mysql -u root -p${mariadbRootPassword} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${mariadbRootPassword}' WITH GRANT OPTION;"
echo "===================刷新权限表==================="
mysqladmin -v -uroot -p${mariadbRootPassword} reload
sed -i 's/^password.*$/password='"${mariadbRootPassword}"'/' /etc/mysql/debian.cnf
echo "===================数据库配置完成==================="
# 基础需求安装完毕。
echo "===================基础需求安装完毕。==================="
# 切换用户
su - frappe <<EOF
# 配置运行环境变量
echo "===================配置运行环境变量==================="
cd ~
alias python=python3
alias pip=pip3
source /etc/profile
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
sudo -H pip3 install frappe-bench${benchVersion}
# 测试bench安装
echo "===================测试bench安装是否成功，如显示版本号为成功如“5.2.1”，否则安装失败。==================="
bench --version
# 初始化frappe
echo "===================初始化frappe==================="
bench init ${frappeBranch} --python /usr/bin/python3 --ignore-exist frappe-bench ${frappePath}
# 获取erpnext应用
echo "===================获取erpnext应用==================="
cd ~/frappe-bench
bench get-app $erpnextBranch $erpnextPath
# cd ~/frappe-bench && ./env/bin/pip3 install -e apps/erpnext/
# 建立新网站site1.local
echo "===================建立新网站site1.local==================="
bench new-site --mariadb-root-password ${mariadbRootPassword} --admin-password ${adminPassword} site1.local
# 安装erpnext应用到新网站
echo "===================安装erpnext应用到新网站==================="
bench --site site1.local install-app erpnext
# 设置网站超时时间
echo "===================设置网站超时时间==================="
bench config http_timeout 6000
# 开启默认站点并设置site1.local为默认站点
bench config serve_default_site on
bench use site1.local
# 安装中文本地化
echo "===================安装中文本地化==================="
bench get-app https://gitee.com/yuzelin/erpnext_chinese.git
bench --site site1.local install-app erpnext_chinese
bench get-app https://gitee.com/yuzelin/erpnext_oob.git
bench --site site1.local install-app erpnext_oob
echo "===================安装权限优化==================="
bench get-app https://gitee.com/yuzelin/zelin_permission.git
bench --site site1.local install-app zelin_permission
# 群主推荐的自定义模块
# echo "===================安装群主推荐的自定义模块==================="
# bench get-app https://github.com/bhavesh95863/whitelabel
# bench --site site1.local install-app whitelabel
# 清理工作台
bench migrate
bench restart
bench clear-cache
# 修正权限
echo "===================修正权限==================="
sudo chown -R frappe:frappe /home/frappe/frappe-bench/*
# 清理垃圾,ERPNext安装完毕
echo "===================清理垃圾,ERPNext安装完毕==================="
sudo -H apt clean
sudo -H apt autoremove -y
sudo -H rm -rf /var/lib/apt/lists/*
sudo -H pip cache purge
npm cache clean --force
yarn cache clean
# 确认安装
echo "===================确认安装==================="
bench version
EOF
exit 0
