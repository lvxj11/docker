# erpnext
FROM ubuntu:20.04
LABEL author=lvxj11

# 设定参数
ENV MARIADB_ROOT_PASSWORD=Pass1234
ENV ADMIN_PASSWORD=admin

# 拷贝基础软件安装脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本。
# cnMirror：修改所有安装源为国内镜像。前置修改，所有安装将使用修改后的源
RUN chmod -R 777 /installdata/* && /installdata/installcomm.sh cnMirror

# 切换用户
USER frappe
WORKDIR /home/frappe

# 运行erpnext安装脚本。
# fromGitee：使用Gitee镜像安装。
# cnMirror：安装完成后修改所有安装源为国内源。
#           后置修改，使用官方源安装完成后修改为国内源。主要用于在国外服务器生成镜像然后在国内使用。
#           如已进行前置修改就不需要再次修改。
RUN /installdata/installerpnext.sh

WORKDIR /home/frappe/frappe-bench

EXPOSE 3306 8000

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

# ENTRYPOINT ["bash"]
CMD ["/installdata/start.sh"]
