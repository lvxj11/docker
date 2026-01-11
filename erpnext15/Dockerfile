# erpnext
FROM ubuntu:22.04
LABEL author=lvxj11

# 设定参数 - 注释掉内部数据库密码，使用外部数据库
# ENV MARIADB_ROOT_PASSWORD=Pass1234  # 使用外部数据库，注释掉内部数据库密码
ENV ADMIN_PASSWORD=admin

# 外部数据库连接参数
ENV EXTERNAL_DB_HOST=mysql
ENV EXTERNAL_DB_PORT=3306
ENV EXTERNAL_DB_USER=root
ENV EXTERNAL_DB_PASSWORD=jiangbn6

# 拷贝基础软件安装脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本。
# 修改：不再需要-d参数，因为不使用内部MariaDB的supervisor管理
RUN /bin/bash -c "chmod -R 777 /installdata/* && /installdata/install-erpnext15.sh -q"

# 切换用户
USER frappe
WORKDIR /home/frappe/frappe-bench

# 修改：只暴露Web端口，不暴露数据库端口（使用外部数据库）
EXPOSE 80

# 修改：只保留站点数据卷，移除数据库数据卷（使用外部数据库）
VOLUME /home/frappe/frappe-bench/sites
# VOLUME /var/lib/mysql  # 使用外部数据库，注释掉内部数据库数据卷

STOPSIGNAL SIGTERM

# 修改：移除内部数据库相关配置
# 注意：使用外部数据库时，只需启动ERPNext相关进程
ENTRYPOINT ["/bin/bash", "-c"]
# 修改：如果脚本已配置supervisor管理ERPNext进程，则使用supervisor
# 如果未配置，可能需要直接启动bench进程
CMD ["sudo /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf"]
