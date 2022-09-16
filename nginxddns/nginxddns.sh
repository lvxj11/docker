#!/bin/bash
# docker run -itd --name nginxddns -p 80:80 -p 443:443 -p 8080:8080 -p 9876:9876 ubuntu:22.04 bash -c "while true; do sleep 60; done"

# 安装ddns-go
# 安装所需软件
apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y \
        supervisor \
        openjdk-11-jdk \
        nginx \
        net-tools \
        curl \
        wget \
        tzdata
# 安装nginxwebui
mkdir /opt/nginxWebUI
wget -O /opt/nginxWebUI/nginxWebUI.jar http://file.nginxwebui.cn/nginxWebUI-3.3.7.jar
# 配置supervisor进程管理
cat << EOF > /etc/supervisor/conf.d/nginxWebUI.conf
#项目名
[program:nginxWebUI]
#脚本目录
directory=/opt/nginxWebUI
#脚本执行命令
command=java -jar -Dfile.encoding=UTF-8 /opt/nginxWebUI/nginxWebUI.jar --server.port=8080 --project.home=/opt/nginxWebUI/
#supervisor启动的时候是否随着同时启动，默认True
autostart=true
#当程序exit的时候，这个program不会自动重启,默认unexpected，设置子进程挂掉后自动重启的情况，有三个选项，false,unexpected和true。如果为false的时候，无论什么情况下，都不会被重新启动，如果为unexpected，只有当进程的退出码不在下面的exitcodes里面定义的
autorestart=true
#这个选项是子进程启动多少秒之后，此时状态如果是running，则我们认为启动成功了。默认值为1
startsecs=1
#脚本运行的用户身份 
user=root
#日志输出 
stderr_logfile=/opt/nginxWebUI/stderr.log 
stdout_logfile=/opt/nginxWebUI/stdout.log 
#把stderr重定向到stdout，默认 false
redirect_stderr=true
#stdout日志文件大小，默认 50MB
stdout_logfile_maxbytes=50MB
#stdout日志文件备份数
stdout_logfile_backups=10
EOF
# 安装ddns-go
mkdir /opt/ddns-go
wget -O /opt/ddns-go/ddns-go.tar.gz https://github.com/jeessy2/ddns-go/releases/download/v3.7.2/ddns-go_3.7.2_Linux_x86_64.tar.gz
cd /opt/ddns-go
tar -zxvf /opt/ddns-go/ddns-go.tar.gz
rm -f /opt/ddns-go/ddns-go.tar.gz
cat << EOF > /etc/supervisor/conf.d/ddns-go.conf
#项目名
[program:ddns-go]
#脚本目录
directory=/opt/ddns-go
#脚本执行命令
command=/opt/ddns-go/ddns-go -l :9876 -f 300
#supervisor启动的时候是否随着同时启动，默认True
autostart=true
#当程序exit的时候，这个program不会自动重启,默认unexpected，设置子进程挂掉后自动重启的情况，有三个选项，false,unexpected和true。如果为false的时候，无论什么情况下，都不会被重新启动，如果为unexpected，只有当进程的退出码不在下面的exitcodes里面定义的
autorestart=true
#这个选项是子进程启动多少秒之后，此时状态如果是running，则我们认为启动成功了。默认值为1
startsecs=1
#脚本运行的用户身份 
user=root
#日志输出 
stderr_logfile=/opt/ddns-go/stderr.log 
stdout_logfile=/opt/ddns-go/stdout.log 
#把stderr重定向到stdout，默认 false
redirect_stderr=true
#stdout日志文件大小，默认 50MB
stdout_logfile_maxbytes=50MB
#stdout日志文件备份数
stdout_logfile_backups=10
EOF
cd ~
# supervisor重载配置文件
i=$(ps aux |grep -c supervisor || true)
if [[ ${i} -le 1 ]]; then
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
else
    /usr/bin/supervisorctl reload
fi
