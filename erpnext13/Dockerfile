# erpnext
FROM ubuntu:20.04
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass1234
ENV ADMIN_PASSWORD=admin

# 拷贝基础软件安装脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本。
RUN chmod -R 777 /installdata/* && /installdata/install-erpnext-ubuntu20.04.sh -qd

# 切换用户
USER frappe
WORKDIR /home/frappe/frappe-bench

EXPOSE 3306 80

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["sudo supervisord -n -c /etc/supervisor/supervisord.conf"]
