# erpnext
FROM ubuntu:18.04
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass1234
ENV ADMIN_PASSWORD=admin

# 拷贝基础软件安装脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本
RUN chmod -R 777 /installdata/* && /installdata/installcomm.sh noMirror

# 切换用户
USER frappe
WORKDIR /home/frappe

# 运行erpnext安装脚本
RUN /installdata/installerpnext.sh && sudo /installdata/alterSources.sh

EXPOSE 80 443 3306 8000 9000 6787

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

# ENTRYPOINT ["bash"]
CMD ["/installdata/start.sh"]
