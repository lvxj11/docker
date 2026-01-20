# erpnext
FROM frappe/bench:latest
LABEL author=lvxj11

# 拷贝基础软件安装脚本
COPY ./installdata /installdata

# 运行基础软件安装脚本。
RUN /bin/bash -c "sudo chmod -R 777 /installdata/* && /installdata/install-erpnext16.sh"

# 切换用户
USER frappe
WORKDIR /home/frappe/frappe-bench

EXPOSE 3306 80

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["sudo /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf"]
