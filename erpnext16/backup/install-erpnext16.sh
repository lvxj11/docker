#!/bin/bash
# install-erpnext-docker v0.1 20260115
# 设定参数默认值，如果你不知道干嘛的就别改。
# 只适用于官方bench镜像，其他系统请自行重新适配。
# 会安装mariadb，redis以及erpnext的其他系统需求。
# 自定义选项使用方法例：./install-erpnext15.sh benchVersion=X.XX.X frappePath=https://gitee.com/mirrors/frappe
# 会默认删除已存在的安装目录和当前设置站点重名的数据库及用户。请谨慎使用。
# branch参数会同时修改frappe和erpnext的分支。
set -e
if [ -e "~/.profile" ];then
    source ~/.profile
fi
if [ -e "~/.bashrc" ];then
    source ~/.bashrc
fi
mariadbPath=""
mariadbPort="3306"
mariadbRootPassword="Pass1234"
adminPassword="admin"
installDir="frappe-bench"
userName="frappe"
benchVersion=""
# frappePath="https://gitee.com/mirrors/frappe"
frappePath=""
frappeBranch="version-16"
# erpnextPath="https://gitee.com/mirrors/erpnext"
erpnextPath="https://github.com/frappe/erpnext"
erpnextBranch="version-16"
siteName="site1.local"
siteDbPassword="Pass1234"
webPort=""
# 是否开启生产模式
productionMode="true"
# 是否修改apt安装源，如果是云服务器建议不修改。
altAptSources="true"
benchPath="/home/frappe/.bench/bench/"
# 存储返回警告信息
warnArr=()

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}
# 倒计时等待函数
wait_for() {
    local seconds=$1
    local message=${2:-""}
    local i
    for ((i = 0; i < seconds; i++)); do
        if [ -z "$message" ]; then
            echo -n "."
        else
            echo -ne "\r$message"
        fi
        sleep 1
    done
    echo -ne "\r"
}
# 给参数添加关键字
args_add_keyword() {
    # 没有设定端口号，显示默认端口号。
    if [[ ${productionMode} == "true" ]]; then
        webPort="80"
    else
        webPort="8000"
    fi
    print_info "给需要的参数添加关键字..."
    if [ "${benchVersion}" != "" ];then
        benchVersion="==${benchVersion}"
    fi
    if [ "${frappePath}" != "" ];then
        frappePath="--frappe-path ${frappePath}"
    fi
    if [ "${frappeBranch}" != "" ];then
        frappeBranch="--frappe-branch ${frappeBranch}"
    fi
    if [ "${erpnextBranch}" != "" ];then
        erpnextBranch="--branch ${erpnextBranch}"
    fi
}

# 修改apt安装源加速国内安装。
modify_apt_sources() {
    print_info "修改apt源..."
    if [ -f "/etc/apt/sources.list" ]; then
        sudo sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
    fi
    if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
        sudo sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources
    fi
    print_info "apt已修改为国内源..."
}

# 安装支持软件
install_support_software() {
    if [ ! -e "/etc/apt/sources.list.d/mariadb.list" ]; then
        curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.8
    fi
    print_info "安装支持软件..."
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
    sudo DEBIAN_FRONTEND=noninteractive apt install -y \
        redis-server \
        mariadb-server \
        mariadb-client \
        supervisor
}
# 检查supervisor
check_supervisor() {
    print_info "检查supervisor..."
    local pidFile="/var/run/supervisord.pid"
    if ! [ -f "${pidFile}" ] || ! sudo kill -0 "$(cat "${pidFile}")" 2>/dev/null; then
        print_info "启动supervisor进程"
        sudo /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
        wait_for 2
    elif [ $1 == "reload" ]; then
        print_info "重载supervisor配置"
        sudo /usr/bin/supervisorctl reload
        wait_for 2
    fi
}
# 检查并配置MariaDB
check_and_config_mariadb() {
    # 修改数据库配置文件
    if [ ! -e "/etc/mysql/mariadb.conf.d/99-erpnext.cnf" ]; then
        print_info "修改数据库配置文件..."
        # 确保配置目录存在
        sudo mkdir -p /etc/mysql/mariadb.conf.d/
        # 创建或修改ERPNext配置文件
        sudo tee /etc/mysql/mariadb.conf.d/99-erpnext.cnf > /dev/null << 'EOF'
# ERPNext install script added
[mysqld]
character-set-client-handshake=FALSE
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
bind-address=0.0.0.0
innodb_file_per_table=1
innodb_file_format=Barracuda
innodb_large_prefix=ON

[mysql]
default-character-set=utf8mb4
EOF
        print_info "MariaDB配置文件已创建: /etc/mysql/mariadb.conf.d/99-erpnext.cnf"
    else
        print_warn "MariaDB配置文件已存在: /etc/mysql/mariadb.conf.d/99-erpnext.cnf"
    fi
    local pidId="$(pidof mariadbd)"
    # 如果存在，则停止
    if [ -n "${pidId}" ]; then
        print_info "停止MariaDB服务..."
        sudo kill -TERM ${pidId}
        wait_for 2
    fi
    sudo /usr/bin/mariadbd-safe &
    print_info "启动MariaDB服务..."
    wait_for 3
    # 本地 root 无密码可登录
    if sudo mariadb -uroot -e "SELECT 1" >/dev/null 2>&1; then
        print_info "===== 设置 MariaDB root 密码 ====="
        sudo mariadb -uroot << SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${mariadbRootPassword}';
FLUSH PRIVILEGES;
SQL
    # 已有密码
    elif sudo mariadb -uroot -p"${mariadbRootPassword}" -e "SELECT 1" >/dev/null 2>&1; then
        print_info "root 密码已存在..."
    else
        print_error "root 密码验证失败..."
        exit 1
    fi
    print_info "配置 root 远程访问..."
    sudo mariadb -uroot -p"${mariadbRootPassword}" << SQL
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${mariadbRootPassword}';
ALTER USER 'root'@'%' IDENTIFIED BY '${mariadbRootPassword}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
SQL
    print_info "数据库配置完成"
}

# 检查数据库是否有同名用户。如有，选择处理方式。
check_database() {
    print_info "检查数据库残留..."
    while true; do
        siteSha1=$(echo -n ${siteName} | sha1sum)
        siteSha1=_${siteSha1:0:16}
        dbUser=$(mysql -u root -p${mariadbRootPassword} -e "use mysql;SELECT User,Host FROM user;" | grep ${siteSha1} || true)
        if [ "${dbUser}" != "" ]; then
            # 删除重名数据库
            mysql -u root -p${mariadbRootPassword} -e "drop database ${siteSha1};"
            arrUser=(${dbUser})
            # 如果重名用户有多个host，以步进2取用户名和用户host并删除。
            for ((i=0; i<${#arrUser[@]}; i=i+2))
            do
                mysql -u root -p${mariadbRootPassword} -e "drop user ${arrUser[$i]}@${arrUser[$i+1]};"
            done
            print_warn "已删除数据库及用户，继续安装！"
            continue
        else
            print_info "无重名数据库或用户。"
            break
        fi
    done
    if [ -d "/home/${userName}/${installDir}" ]; then
        print_warn "存在同名目录，删除..."
        rm -rf /home/${userName}/${installDir}
    fi
}
# 环境需求检查,redis
check_redis() {
    if type redis-server >/dev/null 2>&1; then
        result=$(redis-server -v | grep "7" || true)
        if [ "${result}" == "" ]
        then
            print_warn '已安装redis，但不是推荐的7版本...'
            warnArr[${#warnArr[@]}]='redis不是推荐的7版本。'
        else
            print_info '已安装redis7...'
            sudo /etc/init.d/redis-server stop
        fi
    else
        print_error "redis安装失败退出脚本！"
        exit 1
    fi
}
# 检查wkhtmltox
check_wkhtmltox() {
    if type wkhtmltopdf >/dev/null 2>&1; then
        result=$(wkhtmltopdf -V | grep "0.12.6" || true)
        if [ "${result}" == "" ]
        then
            print_warn '已存在wkhtmltox，但不是推荐的0.12.6版本'
            warnArr[${#warnArr[@]}]='wkhtmltox不是推荐的0.12.6版本。'
        else
            print_info '已安装wkhtmltox_0.12.6'
        fi
    else
        # 搜索软件源是否有wkhtmltopdf 0.12.6版本
        if [ $(apt list "wkhtmltopdf*" | grep "0.12.6" | grep "amd64" | wc -l 2>/dev/null) -gt 0 ]; then
            print_info "从软件源安装wkhtmltox_0.12.6..."
            sudo DEBIAN_FRONTEND=noninteractive apt install -y wkhtmltopdf
        else
            print_info "下载并安装wkhtmltopdf_0.12.6..."
            wget "https://gh-proxy.org/https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb" -O wkhtmltopdf.deb
            dpkg -i wkhtmltopdf.deb
        fi
    fi
}
# 检查nodejs
check_nodejs() {
    # 环境需求检查,node
    if type node >/dev/null 2>&1; then
        result=$(node -v | grep "v24." || true)
        if [ "${result}" == "" ]; then
            print_warn '已存在node，但不是v24版。这将有可能导致一些问题。建议卸载node后重试...'
            warnArr[${#warnArr[@]}]='node不是推荐的v24版本。'
        else
            print_info '已安装node24'
        fi
    else
        print_error "node安装失败退出脚本！"
        exit 1
    fi
    # 修改npm源
    # 在执行前确定有操作权限
    # npm get registry
    npm config set registry https://registry.npmmirror.com -g
    print_info "npm已修改为国内源..."
    # 升级npm
    print_info "升级npm..."
    npm install -g npm
    # 安装yarn
    print_info "安装yarn..."
    npm install -g yarn
    # 修改yarn源
    # 在执行前确定有操作权限
    # yarn config list
    yarn config set registry https://registry.npmmirror.com --global
    print_info "yarn已修改为国内源..."
}
# 配置supervisor
configure_supervisor() {
    # 使用supervisor管理mariadb和nginx进程
    print_info "为docker镜像添加mariadb和nginx启动配置文件..."
    supervisorConfigDir=/root/.config/supervisor
    sudo mkdir -p ${supervisorConfigDir}
    local f=${supervisorConfigDir}/mariadb.conf
    sudo rm -f ${f}
    sudo tee ${f} > /dev/null << 'EOF'
[program:mariadb]
command=/usr/sbin/mariadbd --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin --user=mysql --skip-log-error
priority=1
autostart=true
autorestart=true
numprocs=1
startretries=10
stopwaitsecs=10
redirect_stderr=true
stdout_logfile_maxbytes=1024MB
stdout_logfile_backups=10
stdout_logfile=/var/run/log/supervisor_mysql.log
EOF
    # 关闭mariadb进程，启动supervisor进程并管理mariadb进程
    print_info "关闭mariadb进程，启动supervisor进程并管理mariadb进程"
    sudo kill -TERM $(pidof mariadbd)
    if [ ! -e /etc/supervisor/conf.d/mariadb.conf ]; then
        sudo ln -fs ${supervisorConfigDir}/mariadb.conf /etc/supervisor/conf.d/mariadb.conf
    fi
    f=${supervisorConfigDir}/nginx.conf
    sudo rm -f ${f}
    sudo tee ${f} > /dev/null << 'EOF'
[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
autorestart=true
autostart=true
stderr_logfile=/var/run/log/supervisor_nginx_error.log
stdout_logfile=/var/run/log/supervisor_nginx_stdout.log
environment=ASPNETCORE_ENVIRONMENT=Production
user=root
stopsignal=INT
startsecs=10
startretries=5
stopasgroup=true
EOF
}
# 修改pip软件源
modify_pip_source() {
    # 修改pip默认源加速国内安装
    sudo mkdir -p /root/.pip
    local f="/root/.pip/pip.conf"
    sudo tee ${f} > /dev/null << 'EOF'
[global]
index-url=https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host=mirrors.tuna.tsinghua.edu.cn
EOF
    sudo cp -af /root/.pip /home/${userName}/
    # 修正用户目录权限
    sudo chown -R ${userName}.${userName} /home/${userName}
}
# 安装erpnext
install_erpnext() {
    cd /home/${userName}
    print_info "初始化工作目录..."
    bench init ${frappeBranch} --ignore-exist ${installDir} ${frappePath}
    cd /home/${userName}/${installDir}
    print_info "拉取erpnext应用..."
    bench get-app ${erpnextBranch} ${erpnextPath}
    print_info "建立新站点..."
    bench new-site --mariadb-root-username "root" --mariadb-root-password ${mariadbRootPassword} --db-password ${siteDbPassword} --admin-password ${adminPassword} ${siteName}
    print_info "启动bench并等待拉起redis进程..."
    bench start > bench-start.log 2>&1 &
    local benchPid=$!
    for i in $(seq 1 30); do
        if ps aux 2>/dev/null | grep -q ':11000' && \
        ps aux 2>/dev/null | grep -q ':13000'; then
            echo -ne "\r"
            echo "✓ Redis 进程启动"
            break
        fi
        echo -n "."
        sleep 1
    done
    print_info "安装erpnext应用..."
    bench --site ${siteName} install-app erpnext
    print_info "停止bench进程并等待结束..."
    kill "${benchPid}"
    wait "${benchPid}" 2>/dev/null || true
    print_info "配置frappe应用..."
    bench config http_timeout 6000
    bench config serve_default_site on
    bench use ${siteName}
}
# 使用supervisor管理nginx进程
configure_nginx_with_supervisor() {
    print_info "使用supervisor管理nginx进程"
    print_info "安装应用..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y \
        nginx \
        ansible
    sudo /etc/init.d/nginx stop
    if [[ ! -e /etc/supervisor/conf.d/nginx.conf ]]; then
        sudo ln -fs ${supervisorConfigDir}/nginx.conf /etc/supervisor/conf.d/nginx.conf
    fi
}
# 修改bench脚本适配docker中使用
modify_bench_script() {
    # 如果有检测到的supervisor可用重启指令，修改bensh脚本supervisor重启指令为可用指令。
    print_info "修正脚本代码..."
    # 修改bensh脚本不安装fail2ban
    print_info "已配置在docker中运行，将注释安装fail2ban的代码。"
    # 确认bensh脚本使用supervisor指令代码行
    local f="${benchPath}config/production_setup.py"
    if [ -e ${f} ]; then
        n=$(sed -n "/^[[:space:]]*if not which.*fail2ban-client/=" ${f})
        # 如找到代码注释判断行及执行行
        if [ ${n} ]; then
            print_info "找到fail2ban安装代码行，添加注释符。"
            sudo sed -i "${n} s/^/#&/" ${f}
            let n++
            sudo sed -i "${n} s/^/#&/" ${f}
        fi
    else
        print_warn "未找到${f}文件,fail2ban安装代码未注释"
    fi
    if [[ ${supervisorCommand} != "" ]]; then
        print_info "可用的supervisor重启指令为："${supervisorCommand}
        # 确认bensh脚本使用supervisor指令代码行
        f="${benchPath}config/supervisor.py"
        n=$(sed -n "/service.*supervisor.*reload\|service.*supervisor.*restart/=" ${f})
        # 如找到替换为可用指令
        if [ ${n} ]; then
            print_info "替换bensh脚本supervisor重启指令为："${supervisorCommand}
            sudo sed -i "${n} s/reload\|restart/${supervisorCommand}/g" ${f}
        fi
    fi
}

# 开启生产模式
enable_production_mode() {
    local f="/etc/supervisor/conf.d/${installDir}.conf"
    for i in {1..9}; do
        print_info "开启生产模式（第${i}次）..."
        sudo -E env PATH="$PATH" bench setup production ${userName} --yes
        wait_for 2
        if [[ -e ${f} ]]; then
            print_info "配置文件已生成..."
            break
        elif [[ ${i} -ge 9 ]]; then
            print_error "失败次数过多${i}，开启生产模式失败！"
            exit 1
        fi
    done
}
# 修正supervisor配置
modify_supervisor_config() { 
    print_info "修正supervisor配置"
    sudo tee /etc/supervisor/conf.d/bench_fix.conf > /dev/null << 'EOF'
[program:frappe-bench-frappe-schedule]
environment=
    PYTHONPATH="/home/frappe/.bench:/home/frappe/.pyenv/versions/3.14.2/lib/python3.14/site-packages:/home/frappe/frappe-bench/env/lib/python3.14/site-packages:$PYTHONPATH",
    PATH="/home/frappe/.local/bin:/home/frappe/.pyenv/shims:/home/frappe/.pyenv/bin:%(ENV_PATH)s"

[program:frappe-bench-frappe-short-worker]
environment=
    PYTHONPATH="/home/frappe/.bench:/home/frappe/.pyenv/versions/3.14.2/lib/python3.14/site-packages:/home/frappe/frappe-bench/env/lib/python3.14/site-packages:$PYTHONPATH",
    PATH="/home/frappe/.local/bin:/home/frappe/.pyenv/shims:/home/frappe/.pyenv/bin:%(ENV_PATH)s"

[program:frappe-bench-frappe-long-worker]
environment=
    PYTHONPATH="/home/frappe/.bench:/home/frappe/.pyenv/versions/3.14.2/lib/python3.14/site-packages:/home/frappe/frappe-bench/env/lib/python3.14/site-packages:$PYTHONPATH",
    PATH="/home/frappe/.local/bin:/home/frappe/.pyenv/shims:/home/frappe/.pyenv/bin:%(ENV_PATH)s"
EOF
}
# 清理安装缓存
clean_cache() {
    # 清理垃圾,ERPNext安装完毕
    print_info "清理apt缓存..."
    sudo apt clean
    sudo apt autoremove -y
    sudo rm -rf /var/lib/apt/lists/*
    print_info "清理node缓存..."
    pip cache purge
    npm cache clean --force
    yarn cache clean
    print_info "清理bench缓存..."
    cd /home/${userName}/${installDir}
    bench clear-cache
    bench clear-website-cache
}
# 显示安装状态
show_status() {
    echo "===================主要运行环境==================="
    echo "系统：$(lsb_release -d | awk 'NR==1{print $2}')"
    echo "python版本：$(python3 --version | awk 'NR==1{print $2}')"
    echo "node版本：$(node --version)"
    echo "mariadb版本：$(mariadb --version | awk 'NR==1{print $3}')"
    echo "redis版本：$(redis-server --version | awk -F'v=| ' 'NR==1{print $4}')"
    echo "nginx版本：$(nginx -v 2>&1 | awk -F/ 'NR==1{print $2}')"
    echo "supervisor版本：$(sudo /usr/bin/supervisorctl version)"
    echo "wkhtmltox版本：$(wkhtmltopdf --version | awk 'NR==1{print $2}')"
    echo "bench版本：$(bench --version)"
    bench version
    if [ ${#warnArr[@]} != 0 ]; then
        print_warn "===================警告==================="
        for i in "${warnArr[@]}"
        do
            print_warn ${i}
        done
    fi
    echo "管理员账号：administrator，密码：${adminPassword}。"
    if [ "${productionMode}" == "true" ]; then
        if [ -e /etc/supervisor/conf.d/${installDir}.conf ]; then
            print_info "已开启生产模式。使用ip或域名访问网站。监听${webPort}端口。"
        fi
    else
        print_info "进入~/${installDir}目录"
        print_info "运行bench start启动项目，使用ip或域名访问网站。监听${webPort}端口。"
    fi
    print_info "当前supervisor状态："
    sudo /usr/bin/supervisorctl status
}

# 给参数添加关键字
args_add_keyword
if [ "${altAptSources}" == "true" ];then
    modify_apt_sources
fi
install_support_software
check_and_config_mariadb
check_database
check_redis
check_wkhtmltox
check_nodejs
configure_supervisor
check_supervisor reload
modify_pip_source
install_erpnext
if [ "${productionMode}" == "true" ]; then
    configure_nginx_with_supervisor
    modify_bench_script
    check_supervisor reload
    enable_production_mode
    modify_supervisor_config
fi
check_supervisor reload
clean_cache
show_status
exit 0
