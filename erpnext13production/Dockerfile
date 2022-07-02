# erpnext
FROM lvxj11/erpnext:latest
LABEL author=lvxj11

# 开始安装
RUN /bin/bash -c "sudo set -e && \
    sudo apt update && \
    DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y && \
    cd ~/frappe-bench && \
    sudo bench setup production frappe --yes && \
    bench doctor && \
    bench version"

# 切换用户
USER frappe
WORKDIR /home/frappe/frappe-bench

EXPOSE 80

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["supervisor", "-c", "/etc/supervisor/supervisord.conf"]
