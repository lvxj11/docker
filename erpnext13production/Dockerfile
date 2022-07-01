# erpnext
FROM lvxj11/erpnext:latest
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass1234
ENV ADMIN_PASSWORD=admin

# 拷贝基础软件安装脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本。
RUN chmod -R 777 /installdata/* && /installdata/toproduction.sh

# 切换用户
USER frappe
WORKDIR /home/frappe/frappe-bench

EXPOSE 80

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/installdata/start.sh"]
