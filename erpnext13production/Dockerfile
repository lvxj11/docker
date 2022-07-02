# erpnext
FROM lvxj11/erpnext:latest
LABEL author=lvxj11


# 设定工作用户及工作目录
USER frappe
WORKDIR /home/frappe/frappe-bench

# 开始安装
RUN /bin/bash -c 'apt update; \
    f="/usr/local/lib/python3.8/dist-packages/bench/config/supervisor.py"
    n=$(sed -n "/service.*supervisor.*reload/=" ${f}); \
    if ${n}; \
    then sudo sed -i "${n} s/reload/restart/g" ${f}; \
    fi; \
    cd ~/frappe-bench; \
    f="/usr/local/lib/python3.8/dist-packages/bench/config/supervisor.py"; \
    echo "OK"'

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
