# cloudreve
FROM ubuntu:18.04
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass0129
ENV ADMIN_PASSWORD=admin

# 拷贝基础软件安装脚本
COPY ./installdata/installcomm.sh /installdata/installcomm.sh

# 运行基础软件安装脚本
RUN chmod -R 777 /installdata/* && /installdata/installcomm.sh noMirror

# 切换用户
USER frappe
WORKDIR /home/frappe

# 拷贝erpnext12安装脚本
COPY ./installdata/installerpnext.sh /installdata/installerpnext.sh

# 运行erpnext12安装脚本
RUN sudo chmod -R 777 /installdata/* && /installdata/installerpnext.sh

# 拷贝erpnext12启动脚本
COPY ./installdata/start.sh /installdata/start.sh

# 修改启动脚本权限
RUN sudo chmod -R 777 /installdata/start.sh

EXPOSE 80 443 3306 8000 9000 6787

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

# ENTRYPOINT ["bash"]
CMD ["/installdata/start.sh"]
