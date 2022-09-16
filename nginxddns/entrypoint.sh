#!/bin/bash
cd ~
# 判断应用目录是否存在
if [[ ! -d "/app/nginxWebUI" ]]; then
    mkdir -p /app/nginxWebUI
    ln -s /entrypoint/nginxWebUI.jar /app/nginxWebUI/nginxWebUI.jar
    mkdir /app/ddns-go
    ln -s /entrypoint/ddns-go /app/ddns-go/ddns-go
fi
# 启动supervisor
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
