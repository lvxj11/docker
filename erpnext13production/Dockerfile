# erpnext
FROM lvxj11/erpnext:latest
LABEL author=lvxj11


# 设定工作用户及工作目录
USER frappe
WORKDIR /home/frappe/frappe-bench

# 开始安装
RUN /bin/bash -c "sudo set -e && \
    sudo apt update && \
    cd ~/frappe-bench && \
    bench version"

# 开放端口
EXPOSE 80

# 设定存储卷
VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

# 设定信号
STOPSIGNAL SIGTERM

#设定入口指令
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["sudo supervisord -c /etc/supervisor/supervisord.conf"]
