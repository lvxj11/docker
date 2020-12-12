# erpnext
FROM ubuntu:18.04
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass0129
ENV ADMIN_PASSWORD=admin

# 拷贝脚本
COPY ./installdata /installdata

# 运行脚本
RUN chmod -R 777 /installdata/* && /installdata/installapp.sh

EXPOSE 80 443 3306 8000 9000 6787

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

ENTRYPOINT /ENTRYPOINT.sh

