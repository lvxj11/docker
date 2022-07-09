#!/bin/bash
# v2.2 2022.07.04
set -e
# 脚本运行环境检查
# 检测是否ubuntu20.04
osVer=$(cat /etc/os-release | grep 'Ubuntu 20.04' || true)
if [[ ${osVer} == '' ]]; then
    echo '脚本只在ubuntu20.04版本测试通过。其它系统版本需要重新适配。退出安装。'
    exit 1
else
    echo '系统版本检测通过...'
fi
# 检测是否使用bash执行
if [[ 1 == 1 ]]; then
    echo 'bash检测通过...'
else
    echo '执行出错，脚本需要使用bash执行。'
    exit 1
fi
# 检测是否使用root用户执行
if [ "$(id -u)" != "0" ]; then
   echo "脚本需要使用root用户执行"
   exit 1
else
    echo '执行用户检测通过...'
fi
# 设定参数默认值，如果你不知道干嘛的就别改。
# 只适用于纯净版ubuntu20.04并使用root用户运行，其他系统请自行重新适配。
# 会安装python3.8，mariadb10.3，redis6.2以及erpnext的其他系统需求。
# 自定义选项使用方法例：./install.erpnext.sh benchVersion=5.6.0 frappePath=https://gitee.com/mirrors/frappe branch=version-13
# branch参数会同时修改frappe和erpnext的分支。
# 也可以直接修改下列变量
# 静默模式会默认删除已存在的安装目录和当前设置站点重名的数据库及用户。请谨慎使用。
mariadbPath=""
mariadbPort="3306"
mariadbRootPassword="Pass1234"
adminPassword="admin"
installDir="frappe-bench"
userName="frappe"
benchVersion=""
frappePath="https://gitee.com/mirrors/frappe"
frappeBranch="version-13"
erpnextPath="https://gitee.com/mirrors/erpnext"
erpnextBranch="version-13"
siteName="site1.local"
siteDbPassword="Pass1234"
webPort=""
productionMode="yes"
# 是否修改apt安装源，如果是云服务器建议不修改。
altAptSources="yes"
# 是否跳过确认参数直接安装
quiet="no"
# 是否为docker镜像
inDocker="no"
# 是否删除重复文件
removeDuplicate="yes"
# 遍历参数修改默认值
# 脚本后添加参数如有冲突，靠后的参数生效。
echo "===================获取参数==================="
argTag=""
for arg in $*
do
    if [[ $argTag != "" ]]; then
        case "${argTag}" in
        "webPort")
            t=$(echo ${arg}|sed 's/[0-9]//g')
            if [[ (${t} == "") && (${arg} -ge 80) && (${arg} -lt 65535) ]]; then
                webPort=${arg}
                echo "设定web端口为${webPort}。"
                # 只有收到正确的端口参数才跳转下一个参数，否则将继续识别当前参数。
                continue
            else
                # 只有-p没有正确的参数会将webPort参数置空
                webPort=""
            fi
            ;;
        esac
        argTag=""
    fi
    if [[ ${arg} == -* ]];then
        arg=${arg:1:${#arg}}
        for i in `seq ${#arg}`
        do
            arg0=${arg:$i-1:1}
            case "${arg0}" in
            "q")
                quiet='yes'
                removeDuplicate="yes"
                echo "不再确认参数，直接安装。"
                ;;
            "d")
                inDocker='yes'
                echo "针对docker镜像安装方式适配。"
                ;;
            "p")
                argTag='webPort'
                echo "针对docker镜像安装方式适配。"
                ;;
            esac
        done
    elif [[ ${arg} == *=* ]];then
        arg0=${arg%=*}
        arg1=${arg#*=}
        echo "${arg0} 为： ${arg1}"
        case "${arg0}" in
        "benchVersion")
            benchVersion=${arg1}
            echo "设置bench版本为： ${benchVersion}"
            ;;
        "mariadbRootPassword")
            mariadbRootPassword=${arg1}
            echo "设置数据库根密码为： ${mariadbRootPassword}"
            ;;
        "adminPassword")
            adminPassword=${arg1}
            echo "设置管理员密码为： ${adminPassword}"
            ;;
        "frappePath")
            frappePath=${arg1}
            echo "设置frappe拉取地址为： ${frappePath}"
            ;;
        "frappeBranch")
            frappeBranch=${arg1}
            echo "设置frappe分支为： ${frappeBranch}"
            ;;
        "erpnextPath")
            erpnextPath=${arg1}
            echo "设置erpnext拉取地址为： ${erpnextPath}"
            ;;
        "erpnextBranch")
            erpnextBranch=${arg1}
            echo "设置erpnext分支为： ${erpnextBranch}"
            ;;
        "branch")
            frappeBranch=${arg1}
            erpnextBranch=${arg1}
            echo "设置frappe分支为： ${frappeBranch}"
            echo "设置erpnext分支为： ${erpnextBranch}"
            ;;
        "siteName")
            siteName=${arg1}
            echo "设置站点名称为： ${siteName}"
            ;;
        "installDir")
            installDir=${arg1}
            echo "设置安装目录为： ${installDir}"
            ;;
        "userName")
            userName=${arg1}
            echo "设置安装用户为： ${userName}"
            ;;
        "siteDbPassword")
            siteDbPassword=${arg1}
            echo "设置站点数据库密码为： ${siteDbPassword}"
            ;;
        "webPort")
            webPort=${arg1}
            echo "设置web端口为： ${webPort}"
            ;;
        "altAptSources")
            altAptSources=${arg1}
            echo "是否修改apt安装源，云服务器有自己的安装，建议不修改。"
            ;;
        "quiet")
            quiet=${arg1}
            if [[ ${quiet} == "yes" ]];then
                removeDuplicate="yes"
            fi
            echo "不再确认参数，直接安装。"
            ;;
        "inDocker")
            inDocker=${arg1}
            echo "针对docker镜像安装方式适配。"
            ;;
        "productionMode")
            productionMode=${arg1}
            echo "是否开启生产模式： ${productionMode}"
            ;;
        esac
    fi
done
# 显示参数
if [[ ${quiet} != "yes" && ${inDocker} != "yes" ]]; then
    clear
fi
echo "数据库地址："${mariadbPath}
echo "数据库端口："${mariadbPort}
echo "数据库root用户密码："${mariadbRootPassword}
echo "管理员密码："${adminPassword}
echo "安装目录："${installDir}
echo "指定bench版本："${benchVersion}
echo "拉取frappe地址："${frappePath}
echo "指定frappe版本："${frappeBranch}
echo "拉取erpnext地址："${erpnextPath}
echo "指定erpnext版本："${erpnextBranch}
echo "网站名称："${siteName}
echo "网站数据库密码："${siteDbPassword}
echo "web端口："${webPort}
echo "是否修改apt安装源："${altAptSources}
echo "是否静默模式安装："${quiet}
echo "如有重名目录或数据库是否删除："${removeDuplicate}
echo "是否为docker镜像内安装适配："${inDocker}
echo "是否开启生产模式："${productionMode}
# 等待确认参数
if [[ ${quiet} != "yes" ]];then
    echo "===================请确认已设定参数并选择安装方式==================="
    echo "1. 安装为开发模式"
    echo "2. 安装为生产模式"
    echo "3. 不再询问，按照当前设定安装并开启静默模式"
    echo "4. 在Docker镜像里安装并开启静默模式"
    echo "*. 取消安装"
    echo -e "说明：开启静默模式后，如果有重名目录或数据库包括supervisor进程配置文件都将会删除后继续安装，请注意数据备份！ \n \
        开发模式需要手动启动“bench start”，启动后访问8000端口。\n \
        生产模式无需手动启动，使用nginx反代并监听80端口\n \
        此外生产模式会使用supervisor管理进程增强可靠性，并预编译代码开启redis缓存，提高应用性能。\n \
        在Docker镜像里安装会适配其进程启动方式将mariadb及nginx进程也交给supervisor管理。 \n \
        docker镜像主线程：“sudo supervisord -n -c /etc/supervisor/supervisord.conf”。请自行配置到镜像"
    read -r -p "请选择： " input
    case ${input} in
        1)
            productionMode="no"
    	    ;;
        2)
            productionMode="yes"
    	    ;;
        3)
            quiet="yes"
            removeDuplicate="yes"
    	    ;;
        4)
            quiet="yes"
            removeDuplicate="yes"
            inDocker="yes"
    	    ;;
        *)
            echo "取消安装..."
            exit 1
    	    ;;
    esac
fi
# 给参数添加关键字
echo "===================给需要的参数添加关键字==================="
if [[ ${benchVersion} != "" ]];then
    benchVersion="==${benchVersion}"
fi
if [[ ${frappePath} != "" ]];then
    frappePath="--frappe-path ${frappePath}"
fi
if [[ ${frappeBranch} != "" ]];then
    frappeBranch="--frappe-branch ${frappeBranch}"
fi
if [[ ${erpnextBranch} != "" ]];then
    erpnextBranch="--branch ${erpnextBranch}"
fi
if [[ ${siteDbPassword} != "" ]];then
    siteDbPassword="--db-password ${siteDbPassword}"
fi

# 开始安装基础软件，并求改配置使其符合要求
# 修改安装源加速国内安装。
if [[ ${altAptSources} == "yes" ]];then
    # 在执行前确定有操作权限
    rm -f /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse' > /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list
    echo "===================apt已修改为国内源==================="
fi
# 安装基础软件
echo "===================安装基础软件==================="
apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y \
    sudo \
    wget \
    curl \
    python3.8-minimal \
    python3.8-venv \
    python3-setuptools \
    python3-pip \
    python3-testresources \
    virtualenv \
    locales \
    tzdata \
    git \
    cron \
    software-properties-common \
    mariadb-server-10.3 \
    mariadb-client \
    libmysqlclient-dev \
    supervisor
# 环境需求检查
rteArr=()
warnArr=()
# 检测是否有之前安装的目录
while [[ -d "/home/${userName}/${installDir}" ]]; do
    if [[ ${quiet} != "yes" && ${inDocker} != "yes" ]]; then
        clear
    fi
    echo "检测到已存在安装目录：/home/${userName}/${installDir}"
    if [[ ${quiet} != "yes" ]];then
        echo '1. 删除后继续安装。（推荐）'
        echo '2. 输入一个新的安装目录。'
        read -r -p "*. 取消安装" input
        case ${input} in
            1)
                echo "删除目录重新初始化！"
                rm -rf /home/${userName}/${installDir}
                rm -f /etc/supervisor/conf.d/${installDir}.conf
                rm -f /etc/nginx/conf.d/${installDir}.conf
                ;;
            2)
                while true
                do
                    echo "当前目录名称："${installDir}
                    read -r -p "请输入新的安装目录名称：" input
                    if [[ ${input} != "" ]]; then
                        installDir=${input}
                        read -r -p "使用新的安装目录名称${siteName}，y确认，n重新输入：" input
                        if [[ ${input} == [y/Y] ]]; then
                            echo "将使用安装目录名称${installDir}重试。"
                            break
                        fi
                    fi
                done
                continue
                ;;
            *)
                echo "取消安装。"
                exit 1
                ;;
        esac
    else
        echo "静默模式，删除目录重新初始化！"
        rm -rf /home/${userName}/${installDir}
    fi
done
# 环境需求检查,python3
if type python3 >/dev/null 2>&1; then
    result=$(python3 -V | grep "3.8" || true)
    if [[ "${result}" == "" ]]
    then
        echo '==========已安装python3，但不是推荐的3.8版本。=========='
        warnArr[${#warnArr[@]}]="Python不是推荐的3.8版本。"
    else
        echo '==========已安装python3.8=========='
    fi
    rteArr[${#rteArr[@]}]=$(python3 -V)
else
    echo "==========python安装失败退出脚本！=========="
    exit 1
fi
# 环境需求检查,MariaDB
if type mysql >/dev/null 2>&1; then
    result=$(mysql -V | grep "10.3" || true)
    if [[ "${result}" == "" ]]
    then
        echo '==========已安装MariaDB，但不是推荐的10.3版本。=========='
        warnArr[${#warnArr[@]}]='MariaDB不是推荐的10.3版本。'
    else
        echo '==========已安装MariaDB10.3=========='
    fi
    rteArr[${#rteArr[@]}]=$(mysql -V)
else
    echo "==========MariaDB安装失败退出脚本！=========="
    exit 1
fi
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
sleep 2
# 授权远程访问并修改密码
if mysql -uroot -e quit >/dev/null 2>&1
then
    echo "===================修改数据库root本地访问密码==================="
    mysqladmin -v -uroot password ${mariadbRootPassword}
elif mysql -uroot -p${mariadbRootPassword} -e quit >/dev/null 2>&1
then
    echo "===================数据库root本地访问密码已配置==================="
else
    echo "===================数据库root本地访问密码错误==================="
    exit 1
fi
echo "===================修改数据库root远程访问密码==================="
mysql -u root -p${mariadbRootPassword} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${mariadbRootPassword}' WITH GRANT OPTION;"
echo "===================刷新权限表==================="
mysqladmin -v -uroot -p${mariadbRootPassword} reload
sed -i 's/^password.*$/password='"${mariadbRootPassword}"'/' /etc/mysql/debian.cnf
echo "===================数据库配置完成==================="
# 检查数据库是否有同名用户。如有，选择处理方式。
echo "==========检查数据库残留=========="
while true
do
    siteSha1=$(echo -n ${siteName} | sha1sum)
    siteSha1=_${siteSha1:0:16}
    dbUser=$(mysql -u root -p${mariadbRootPassword} -e "use mysql;SELECT User,Host FROM user;" | grep ${siteSha1} || true)
    if [[ ${dbUser} != "" ]]; then
        if [[ ${quiet} != "yes" && ${inDocker} != "yes" ]]; then
            clear
        fi
        echo '当前站点名称：'${siteName}
        echo '生成的数据库及用户名为：'${siteSha1}
        echo '已存在同名数据库用户，请选择处理方式。'
        echo '1. 重新输入新的站点名称。将自动生成新的数据库及用户名称重新校验。'
        echo '2. 删除重名的数据库及用户。'
        echo '3. 什么也不做使用设置的密码直接安装。（不推荐）'
        echo '*. 取消安装。'
        if [[ ${quiet} == "yes" ]]; then
            echo '当前为静默模式，将自动按第2项执行。'
            # 删除重名数据库
            mysql -u root -p${mariadbRootPassword} -e "drop database ${siteSha1};"
            arrUser=(${dbUser})
            # 如果重名用户有多个host，以步进2取用户名和用户host并删除。
            for ((i=0; i<${#arrUser[@]}; i=i+2))
            do
                mysql -u root -p${mariadbRootPassword} -e "drop user ${arrUser[$i]}@${arrUser[$i+1]};"
            done
            echo "已删除数据库及用户，继续安装！"
            continue
        fi
        read -r -p "请输入选择：" input
        case ${input} in
            '1')
                while true
                do
                    read -r -p "请输入新的站点名称：" inputSiteName
                    if [[ ${inputSiteName} != "" ]]; then
                        siteName=${inputSiteName}
                        read -r -p "使用新的站点名称${siteName}，y确认，n重新输入：" input
                        if [[ ${input} == [y/Y] ]]; then
                            echo "将使用站点名称${siteName}重试。"
                            break
                        fi
                    fi
                done
                continue
                ;;
            '2')
                mysql -u root -p${mariadbRootPassword} -e "drop database ${siteSha1};"
                arrUser=(${dbUser})
                for ((i=0; i<${#arrUser[@]}; i=i+2))
                do
                    mysql -u root -p${mariadbRootPassword} -e "drop user ${arrUser[$i]}@${arrUser[$i+1]};"
                done
                echo "已删除数据库及用户，继续安装！"
                continue
                ;;
            '3')
                echo "什么也不做使用设置的密码直接安装！"
                warnArr[${#warnArr[@]}]="检测到重名数据库及用户${siteSha1},选择了覆盖安装。可能造成无法访问，数据库无法连接等问题。"
                break
                ;;
            *)
            echo "取消安装..."
            exit 1
            ;;
        esac
    else
        echo "无重名数据库或用户。"
        break
    fi
done
# 确认可用的重启指令
echo "确认supervisor可用重启指令。"
supervisorCommand=""
if type supervisord >/dev/null 2>&1; then
    if [[ $(grep -E "[ *]reload)" /etc/init.d/supervisor) != '' ]]; then
        supervisorCommand="reload"
    elif [[ $(grep -E "[ *]restart)" /etc/init.d/supervisor) != '' ]]; then
        supervisorCommand="restart"
    else
        echo "/etc/init.d/supervisor中没有找到reload或restart指令"
        echo "将会继续执行，但可能因为使用不可用指令导致启动进程失败。"
        echo "如进程没有运行，请尝试手动重启supervisor"
        warnArr[${#warnArr[@]}]="没有找到可用的supervisor重启指令，如有进程启动失败，请尝试手动重启。"
    fi
else
    echo "supervisor没有安装"
    warnArr[${#warnArr[@]}]="supervisor没有安装或安装失败，不能使用supervisor管理进程。"
fi
echo "可用指令："${supervisorCommand}
# 安装最新版redis6.2
# 检查是否安装redis
if ! type redis-server >/dev/null 2>&1; then
    # 获取最新版redis6.2，并安装
    echo "==========获取最新版redis6.2，并安装=========="
    rm -rf /var/lib/redis
    rm -rf /etc/redis
    rm -rf /etc/default/redis-server
    rm -rf /etc/init.d/redis-server
    rm -f /usr/share/keyrings/redis-archive-keyring.gpg
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
    apt update
    redis0=$(apt-cache madison redis | grep -o 6:6.2.*~focal1 | head -1)
    echo "redis6.2最新版本为：${redis0}"
    echo "即将安装redis6.2"
    DEBIAN_FRONTEND=noninteractive apt install -y \
        redis-tools=${redis0} \
        redis-server=${redis0} \
        redis=${redis0}
    echo "锁定redis6.2版本防止自动升级"
    apt-mark hold redis-tools
    apt-mark hold redis-server
    apt-mark hold redis
    apt-mark showhold
fi
# 环境需求检查,redis
if type redis-server >/dev/null 2>&1; then
    result=$(redis-server -v | grep "6.2" || true)
    if [[ "${result}" == "" ]]
    then
        echo '==========已安装redis，但不是推荐的6.2版本。=========='
        warnArr[${#warnArr[@]}]='redis不是推荐的6.2版本。'
    else
        echo '==========已安装redi6.2=========='
    fi
    rteArr[${#rteArr[@]}]=$(redis-server -v)
else
    echo "==========redi安装失败退出脚本！=========="
    exit 1
fi
# 修改pip默认源加速国内安装
# 在执行前确定有操作权限
# pip3 config list
mkdir -p /root/.pip
echo '[global]' > /root/.pip/pip.conf
echo 'index-url=https://pypi.tuna.tsinghua.edu.cn/simple' >> /root/.pip/pip.conf
echo '[install]' >> /root/.pip/pip.conf
echo 'trusted-host=mirrors.tuna.tsinghua.edu.cn' >> /root/.pip/pip.conf
echo "===================pip已修改为国内源==================="
# 安装并升级pip及工具包
echo "===================安装并升级pip及工具包==================="
cd ~
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools cryptography psutil
alias python=python3
alias pip=pip3
# 安装wkhtmltox
echo "===================安装wkhtmltox==================="
# 检查是否安装redis
if ! type wkhtmltopdf >/dev/null 2>&1; then
    # 获取wkhtmltox_0.12.6-1，并安装
    echo "==========获取wkhtmltox_0.12.6-1，并安装=========="
    if [[ ${altAptSources} != "yes" ]];then
        wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb -P /tmp/
    else
        wget https://gitee.com/lvxj11/wkhtmltopdf/attach_files/941684/download/wkhtmltox_0.12.6-1.focal_amd64.deb -P /tmp/
    fi
    apt install -y /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
    rm -f /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb
    wkhtmltopdf -V
fi
# 环境需求检查,wkhtmltox
if type wkhtmltopdf >/dev/null 2>&1; then
    result=$(wkhtmltopdf -V | grep "0.12.6" || true)
    if [[ "${result}" == "" ]]
    then
        echo '==========已存在wkhtmltox，但不是推荐的0.12.6版本。=========='
        warnArr[${#warnArr[@]}]='wkhtmltox不是推荐的0.12.6版本。'
    else
        echo '==========已安装wkhtmltox_0.12.6=========='
    fi
    rteArr[${#rteArr[@]}]=$(wkhtmltopdf -V)
else
    echo "==========wkhtmltox安装失败退出脚本！=========="
    exit 1
fi
# 建立新用户组和用户
echo "===================建立新用户组和用户==================="
result=$(grep "${userName}:" /etc/group || true)
if [[ "${result}" == "" ]]
then
    gid=1000
    while true
    do
        result=$(grep ":${gid}:" /etc/group || true)
        if [[ "${result}" == "" ]]
        then
            echo "建立新用户组: ${gid}:${userName}"
            groupadd -g ${gid} ${userName}
            echo "已新建用户组${userName}，gid: ${gid}"
            break
        else
            gid=$(expr ${gid} + 1)
        fi
    done
else
    echo '用户组已存在'
fi
result=$(grep "${userName}:" /etc/passwd || true)
if [[ "${result}" == "" ]]
then
    uid=1000
    while true
    do
        result=$(grep ":x:${uid}:" /etc/passwd || true)
        if [[ "${result}" == "" ]]
        then
            echo "建立新用户: ${uid}:${userName}"
            useradd --no-log-init -r -m -u ${uid} -g ${gid} -G  sudo ${userName}
            echo "已新建用户${userName}，uid: ${uid}"
            break
        else
            uid=$(expr ${uid} + 1)
        fi
    done
else
    echo '用户已存在'
fi
echo "${userName} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir -p /home/${userName}
echo "export PATH=/home/${userName}/.local/bin:\$PATH" >> /home/${userName}/.bashrc
# 修改用户pip默认源加速国内安装
cp -af /root/.pip /home/${userName}/
# 修正用户目录权限
chown -R ${userName}.${userName} /home/${userName}
# 修正用户shell
usermod -s /bin/bash ${userName}
# 设置语言环境
echo "===================设置语言环境==================="
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo -e "export LC_ALL=en_US.UTF-8\nexport LC_CTYPE=en_US.UTF-8\nexport LANG=en_US.UTF-8" >> /root/.bashrc
echo -e "export LC_ALL=en_US.UTF-8\nexport LC_CTYPE=en_US.UTF-8\nexport LANG=en_US.UTF-8" >> /home/${userName}/.bashrc
# 设置时区为上海
echo "===================设置时区为上海==================="
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
# 设置监控文件数量上限
echo "===================设置监控文件数量上限==================="
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf
# 使其立即生效
/sbin/sysctl -p
# 检查是否安装nodejs14
source /etc/profile
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
fi
# 环境需求检查,node
if type node >/dev/null 2>&1; then
    result=$(node -v | grep "v14." || true)
    if [[ "${result}" == "" ]]
    then
        echo '==========已存在node，但不是v14版。这将有可能导致一些问题。建议卸载node后重试。=========='
        warnArr[${#warnArr[@]}]='node不是推荐的v14版本。'
    else
        echo '==========已安装node14=========='
    fi
    rteArr[${#rteArr[@]}]='node '$(node -v)
else
    echo "==========node安装失败退出脚本！=========="
    exit 1
fi
# 修改npm源
# 在执行前确定有操作权限
# npm get registry
npm config set registry https://registry.npmmirror.com -g
echo "===================npm已修改为国内源==================="
# 升级npm
echo "===================升级npm==================="
npm install -g npm
# 安装yarn
echo "===================安装yarn==================="
npm install -g yarn
# 修改yarn源
# 在执行前确定有操作权限
# yarn config list
yarn config set registry https://registry.npm.taobao.org --global
echo "===================yarn已修改为国内源==================="
# 基础需求安装完毕。
echo "===================基础需求安装完毕。==================="
# 切换用户
su - ${userName} <<EOF
# 配置运行环境变量
echo "===================配置运行环境变量==================="
cd ~
alias python=python3
alias pip=pip3
source /etc/profile
export PATH=/home/${userName}/.local/bin:$PATH
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
# 修改用户yarn源
# 在执行前确定有操作权限
# yarn config list
yarn config set registry https://registry.npm.taobao.org --global
echo "===================用户yarn已修改为国内源==================="
EOF
# 重启redis-server和mariadb
echo "===================重启redis-server和mariadb==================="
service redis-server restart
service mysql restart
# 安装bench
su - ${userName} <<EOF
echo "===================安装bench==================="
sudo -H pip3 install frappe-bench${benchVersion}
# 环境需求检查,bench
if type bench >/dev/null 2>&1; then
    benchV=\$(bench --version)
    echo '==========已安装bench=========='
    echo \${benchV}
else
    echo "==========bench安装失败退出脚本！=========="
    exit 1
fi
EOF
rteArr[${#rteArr[@]}]='bench '$(bench --version 2>/dev/null)
# bensh脚本适配docker
if [[ ${inDocker} == "yes" ]]; then
    # 修改bensh脚本不安装fail2ban
    echo "已配置在docker中运行，将注释安装fail2ban的代码。"
    # 确认bensh脚本使用supervisor指令代码行
    f="/usr/local/lib/python3.8/dist-packages/bench/config/production_setup.py"
    n=$(sed -n "/^[[:space:]]*if not which.*fail2ban-client/=" ${f})
    # 如找到代码注释判断行及执行行
    if [ ${n} ]; then
        echo "找到fail2ban安装代码行，添加注释符。"
        sed -i "${n} s/^/#&/" ${f}
        let n++
        sed -i "${n} s/^/#&/" ${f}
    fi
fi
# 初始化frappe
su - ${userName} <<EOF
echo "===================初始化frappe==================="
# 如果初始化失败，尝试5次。
for ((i=0; i<5; i++)); do
    rm -rf ~/${installDir}
    set +e
    bench init ${frappeBranch} --python /usr/bin/python3 --ignore-exist ${installDir} ${frappePath}
    err=\$?
    set -e
    if [[ \${err} == 0 ]]; then
        echo "执行返回正确\${i}"
        sleep 1
        break
    elif [[ \${i} -ge 4 ]]; then
        echo "==========frappe初始化失败太多\${i}，退出脚本！=========="
        exit 1
    else
        echo "==========frappe初始化失败第"\${i}"次！自动重试。=========="
    fi
done
echo "frappe初始化脚本执行结束..."
EOF
# 确认frappe初始化
su - ${userName} <<EOF
cd ~/${installDir}
# 环境需求检查,frappe
frappeV=\$(bench version | grep "frappe" || true)
if [[ \${frappeV} == "" ]]; then
    echo "==========frappe初始化失败退出脚本！=========="
    exit 1
else
    echo '==========frappe初始化成功=========='
    echo \${frappeV}
fi
EOF
# 适配docker
echo "判断是否适配docker"
if [[ ${inDocker} == "yes" ]]; then
    # 如果是在docker中运行，使用supervisor管理mariadb和nginx进程
    echo "================为docker镜像添加mariadb和nginx启动配置文件==================="
    mkdir /home/${userName}/${installDir}/config/supervisor
    configFile=/home/${userName}/${installDir}/config/supervisor/mysql.conf
    echo "[program:mariadb]" > ${configFile}
    echo "command=/usr/sbin/mysqld \
        --basedir=/usr \
        --datadir=/var/lib/mysql \
        --plugin-dir=/usr/lib/x86_64-linux-gnu/mariadb19/plugin \
        --user=mysql --skip-log-error \
        --pid-file=/run/mysqld/mysqld.pid \
        --socket=/var/run/mysqld/mysqld.sock" >> ${configFile}
    echo "priority=1" >> ${configFile}
    echo "autostart=true" >> ${configFile}
    echo "autorestart=true" >> ${configFile}
    echo "numprocs=1" >> ${configFile}
    echo "startretries=10" >> ${configFile}
    echo "exitcodes=0" >> ${configFile}
    echo "stopsignal=KILL" >> ${configFile}
    echo "stopwaitsecs=10" >> ${configFile}
    echo "redirect_stderr=true" >> ${configFile}
    echo "stdout_logfile_maxbytes=1024MB" >> ${configFile}
    echo "stdout_logfile_backups=10" >> ${configFile}
    echo "stdout_logfile=/var/run/log/supervisor_mysql.log" >> ${configFile}
    configFile=/home/${userName}/${installDir}/config/supervisor/nginx.conf
    echo "[program: nginx]" > ${configFile}
    echo "command=/usr/sbin/nginx -g 'daemon off;'" >> ${configFile}
    echo "autorestart=true" >> ${configFile}
    echo "autostart=true" >> ${configFile}
    echo "stderr_logfile=/var/run/log/supervisor_nginx_error.log" >> ${configFile}
    echo "stdout_logfile=/var/run/log/supervisor_nginx_stdout.log" >> ${configFile}
    echo "environment=ASPNETCORE_ENVIRONMENT=Production" >> ${configFile}
    echo "user=root" >> ${configFile}
    echo "stopsignal=INT" >> ${configFile}
    echo "startsecs=10" >> ${configFile}
    echo "startretries=5" >> ${configFile}
    echo "stopasgroup=true" >> ${configFile}
    # 关闭mariadb进程，启动supervisor进程并管理mariadb进程
    service mysql stop
    sleep 2
    if [[ ! -e /etc/supervisor/conf.d/mysql.conf ]]; then
        ln -s /home/${userName}/${installDir}/config/supervisor/mysql.conf /etc/supervisor/conf.d/mysql.conf
    fi
    i=$(ps aux |grep -c supervisor || true)
    if [[ ${i} -le 1 ]]; then
        /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
    else
        /usr/bin/supervisorctl reload
    fi
    sleep 2
fi
# 获取erpnext应用
su - ${userName} <<EOF
cd ~/${installDir}
echo "===================获取erpnext应用==================="
bench get-app ${erpnextBranch} ${erpnextPath}
# cd ~/${installDir} && ./env/bin/pip3 install -e apps/erpnext/
EOF
# 建立新网站
su - ${userName} <<EOF
cd ~/${installDir}
echo "===================建立新网站==================="
bench new-site --mariadb-root-password ${mariadbRootPassword} ${siteDbPassword} --admin-password ${adminPassword} ${siteName}
EOF
# 安装erpnext应用到新网站
su - ${userName} <<EOF
cd ~/${installDir}
echo "===================安装erpnext应用到新网站==================="
bench --site ${siteName} install-app erpnext
EOF
# 站点配置
su - ${userName} <<EOF
cd ~/${installDir}
# 设置网站超时时间
echo "===================设置网站超时时间==================="
bench config http_timeout 6000
# 开启默认站点并设置默认站点
bench config serve_default_site on
bench use ${siteName}
EOF
# 安装中文本地化
su - ${userName} <<EOF
cd ~/${installDir}
echo "===================安装中文本地化==================="
bench get-app https://gitee.com/yuzelin/erpnext_chinese.git
bench --site ${siteName} install-app erpnext_chinese
bench get-app https://gitee.com/yuzelin/erpnext_oob.git
bench --site ${siteName} install-app erpnext_oob
echo "===================安装权限优化==================="
bench get-app https://gitee.com/yuzelin/zelin_permission.git
bench --site ${siteName} install-app zelin_permission
EOF
# 清理工作台
su - ${userName} <<EOF
cd ~/${installDir}
echo "===================清理工作台==================="
bench clear-cache
EOF
# 生产模式开启
if [[ ${productionMode} == "yes" ]]; then
    echo "================开启生产模式==================="
    # 可能会自动安装一些软件，刷新软件库
    apt update
    # 预先安装nginx，防止自动部署出错
    apt install nginx -y
    rteArr[${#rteArr[@]}]=$(nginx -v 2>/dev/null)
    if [[ ${inDocker} == "yes" ]]; then
        # 使用supervisor管理nginx进程
        if [[ ! -e /etc/supervisor/conf.d/nginx.conf ]]; then
            ln -s /home/${userName}/${installDir}/config/supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf
        fi
        i=$(ps aux |grep -c supervisor || true)
        if [[ ${i} -le 1 ]]; then
            /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
        else
            /usr/bin/supervisorctl reload
        fi
    fi
    # 如果有检测到的supervisor可用重启指令，修改bensh脚本supervisor重启指令为可用指令。
    echo "修正脚本代码..."
    if [[ ${supervisorCommand} != "" ]]; then
        echo "可用的supervisor重启指令为："${supervisorCommand}
        # 确认bensh脚本使用supervisor指令代码行
        f="/usr/local/lib/python3.8/dist-packages/bench/config/supervisor.py"
        n=$(sed -n "/service.*supervisor.*reload\|service.*supervisor.*restart/=" ${f})
        # 如找到替换为可用指令
        if [ ${n} ]; then
            echo "替换bensh脚本supervisor重启指令为："${supervisorCommand}
            sed -i "${n} s/reload\|restart/${supervisorCommand}/g" ${f}
        fi
    fi
    # 准备执行开启生产模式脚本
    # 监控是否生成frappe配置文件，没有则重复执行。
    # 开启初始化时如果之前supervisor没有安装或安装失败会再次尝试安装。但可能因为没有修改为正确的重启指令不能重启。
    f="/etc/supervisor/conf.d/${installDir}.conf"
    i=0
    while [[ i -lt 9 ]]; do
        echo "尝试开启生产模式${i}..."
        set +e
        su - ${userName} <<EOF
        cd ~/${installDir}
        sudo bench setup production ${userName} --yes
EOF
        set -e
        i=$((${i} + 1))
        echo "判断执行结果"
        sleep 1
        if [[ -e ${f} ]]; then
            echo "配置文件已生成..."
            break
        elif [[ ${i} -ge 9 ]]; then
            echo "失败次数过多${i}，请尝试手动开启！"
            break
        else
            echo "配置文件生成失败${i}，自动重试。"
        fi
    done
    # 确认supervisor进程存在
    i=$(ps aux |grep -c supervisor || true)
    if [[ ${i} -le 1 ]]; then
        /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
    else
        /usr/bin/supervisorctl reload
    fi
fi
# 修正权限
echo "===================修正权限==================="
chown -R ${userName}:${userName} /home/${userName}/${installDir}/*
# 清理垃圾,ERPNext安装完毕
echo "===================清理垃圾,ERPNext安装完毕==================="
apt clean
apt autoremove -y
rm -rf /var/lib/apt/lists/*
pip cache purge
npm cache clean --force
yarn cache clean
su - ${userName} <<EOF
cd ~/${installDir}
npm cache clean --force
yarn cache clean
EOF
# 确认安装
if [[ ${quiet} != "yes" && ${inDocker} != "yes" ]]; then
    clear
fi
su - ${userName} <<EOF
cd ~/${installDir}
echo "===================确认安装==================="
bench version
EOF
# 如果有设定端口，修改为设定端口
if [[ ${webPort} != "" ]]; then
    echo "===================设置web端口为：${webPort}==================="
    # 再次验证端口号的有效性
    t=$(echo ${webPort}|sed 's/[0-9]//g')
    if [[ (${t} == "") && (${webPort} -ge 80) && (${webPort} -lt 65535) ]]; then
        if [[ ${productionMode} == "yes" ]]; then
            f="/home/${userName}/${installDir}/config/nginx.conf"
            if [[ -e ${f} ]]; then
                echo "找到配置文件："${f}
                n=($(sed -n "/^[[:space:]]*listen/=" ${f}))
                # 如找到替换为可用指令
                if [ ${n} ]; then
                    sed -i "${n} c listen ${webPort};" ${f}
                    sed -i "$((${n}+1)) c listen [::]:${webPort};" ${f}
                    /etc/init.d/nginx reload
                    echo "web端口号修改为："${webPort}
                else
                    echo "配置文件中没找到设置行。修改失败。"
                    warnArr[${#warnArr[@]}]="找到配置文件："${f}",没找到设置行。修改失败。"
                fi
            else
                echo "没有找到配置文件："${f}",端口修改失败。"
                warnArr[${#warnArr[@]}]="没有找到配置文件："${f}",端口修改失败。"
            fi
        else
            echo "开发模式修改端口号"
            f="/home/${userName}/${installDir}/Procfile"
            echo "找到配置文件："${f}
            if [[ -e ${f} ]]; then
                n=($(sed -n "/^web.*port.*/=" ${f}))
                # 如找到替换为可用指令
                if [ ${n} ]; then
                    sed -i "${n} c web: bench serve --port ${webPort}" ${f}
                    su - ${userName} bash -c "cd ~/${installDir}; bench restart"
                    echo "web端口号修改为："${webPort}
                else
                    echo "配置文件中没找到设置行。修改失败。"
                    warnArr[${#warnArr[@]}]="找到配置文件："${f}",没找到设置行。修改失败。"
                fi
            else
                echo "没有找到配置文件："${f}",端口修改失败。"
                warnArr[${#warnArr[@]}]="没有找到配置文件："${f}",端口修改失败。"
            fi
        fi
    else
        echo "设置的端口号无效或不符合要求，取消端口号修改。使用默认端口号。"
        warnArr[${#warnArr[@]}]="设置的端口号无效或不符合要求，取消端口号修改。使用默认端口号。"
    fi
fi
echo "===================主要运行环境==================="
for i in "${rteArr[@]}"
do
    echo ${i}
done
if [[ ${#warnArr[@]} != 0 ]]; then
    echo "===================警告==================="
    for i in "${warnArr[@]}"
    do
        echo ${i}
    done
fi
if [[ ${productionMode} == "yes" ]]; then
    if [[ -e /etc/supervisor/conf.d/${installDir}.conf ]]; then
        echo "已开启生产模式。请访问http://ip访问网站。默认监听80端口。"
    else
        echo "已配置开启生产模式。但supervisor配置文件生成失败，请排除错误后手动开启。"
    fi
else
    echo "使用su - ${userName}转到${userName}用户进入~/${installDir}目录"
    echo "运行bench start启动项目，默认端口号8000"
fi
exit 0
