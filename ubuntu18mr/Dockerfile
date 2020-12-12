# erpnext
FROM ubuntu:18.04
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass0129
ENV ADMIN_PASSWORD=admin

# 拷贝脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本
RUN chmod -R 777 /installdata/* && /installdata/installcomm.sh
