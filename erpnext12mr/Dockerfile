# erpnext
FROM ubuntu18mr
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass0129
ENV ADMIN_PASSWORD=admin
# ENV PATH=/home/frappe/.local/bin:$PATH

# 拷贝脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本
RUN chmod -R 777 /installdata/*

# 切换用户
USER frappe
WORKDIR /home/frappe

# 运行erpnext安装脚本
RUN /bin/bash -c "/installdata/installerpnext.sh"


EXPOSE 80 443 3306 8000 9000 6787

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

ENTRYPOINT /installdata/ENTRYPOINT.sh
